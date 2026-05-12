import type { Asset, ClothingSlot } from "../interface/Asset";
import type { ClothingModelAssetsData, ClothingModelAssetsResponse } from "../interface/ClothingModelAssets";
import { clothingAssets } from "./clothingAssets";
import { getWebviewToken } from "../utils/authToken";

const DEFAULT_API_URL = "/api/clothingModel";
const DEFAULT_REQUEST_TIMEOUT_MS = 10_000;
const MODEL_FILE_SUFFIX = "file";
const MODEL_ASSETS_SUFFIX = "assets";
const LEGACY_REMOTE_MODEL_PATTERN = /^https?:\/\//i;
const PUBLIC_CHARACTER_ASSET_PATTERN = /^(character-assets|templates)\//i;
const PUBLIC_STORAGE_ASSET_PATTERN = /^models\//i;

export const API_URL =
  (import.meta.env.VITE_CLOTHING_API_URL as string) || DEFAULT_API_URL;

function defaultFetchOptions(): RequestInit {
  return {
    // webview may be treated like a remote origin; prefer explicit CORS mode
    mode: "cors",
    cache: "no-store",
    credentials: "include",
    headers: buildRequestHeaders(),
  };
}

function buildRequestHeaders(overrideHeaders?: HeadersInit): Headers {
  const headers = new Headers({
    Accept: "application/json",
  });

  if (overrideHeaders) {
    const customHeaders = new Headers(overrideHeaders);
    customHeaders.forEach((value, key) => {
      headers.set(key, value);
    });
  }

  if (!headers.has("Authorization")) {
    const token = getWebviewToken();
    if (token) {
      headers.set("Authorization", `Bearer ${token}`);
    }
  }

  return headers;
}

async function fetchWithTimeout(
  url: string,
  options: RequestInit = {},
  timeoutMs = DEFAULT_REQUEST_TIMEOUT_MS,
) {
  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, { ...options, signal: controller.signal });
    return res;
  } finally {
    clearTimeout(id);
  }
}

const VALID_SLOTS = new Set<ClothingSlot>(["top", "bottom", "shoes"]);

function isClothingSlot(value: string): value is ClothingSlot {
  return VALID_SLOTS.has(value as ClothingSlot);
}

function parseSlots(raw: unknown): ClothingSlot[] {
  if (typeof raw === "string") {
    const trimmedRaw = raw.trim();

    if (trimmedRaw.startsWith("[") && trimmedRaw.endsWith("]")) {
      try {
        const parsedRaw = JSON.parse(trimmedRaw) as unknown;
        return parseSlots(parsedRaw);
      } catch {
        return [];
      }
    }

    return raw
      .split(",")
      .map((slot) => slot.trim())
      .filter(isClothingSlot);
  }

  if (!Array.isArray(raw)) return [];

  return raw
    .map((slot) => String(slot).trim())
    .filter(isClothingSlot);
}

function buildModelFileUrl(id: string): string {
  return `${API_URL}/${id}/${MODEL_FILE_SUFFIX}`;
}

function buildModelAssetsUrl(id: string): string {
  return `${API_URL}/${id}/${MODEL_ASSETS_SUFFIX}`;
}

function normalizeAssetPath(id: string, pathRaw: string): string {
  if (!pathRaw) {
    return buildModelFileUrl(id);
  }

  if (PUBLIC_CHARACTER_ASSET_PATTERN.test(pathRaw)) {
    return `/${pathRaw.replace(/^\/+/, "")}`;
  }

  if (PUBLIC_STORAGE_ASSET_PATTERN.test(pathRaw)) {
    return `/storage/${pathRaw.replace(/^\/+/, "")}`;
  }

  return buildModelFileUrl(id);
}

function normalizeApiAsset(item: unknown): Asset | null {
  if (!item || typeof item !== "object") return null;
  const it = item as Record<string, unknown>;

  const id = it.id !== undefined && it.id !== null ? String(it.id) : undefined;
  const name = (it.name as string) ?? (it.title as string) ?? "";

  const pathRaw =
    (it.model as string) ?? (it.path as string) ?? (it.url as string) ?? "";

  const slots = parseSlots(it.slots ?? []);

  const category = (it.category as string) ?? "";

  if (!id || !pathRaw || LEGACY_REMOTE_MODEL_PATTERN.test(pathRaw)) {
    return null;
  }

  return {
    id: String(id),
    name: name || String(id),
    category: category || "",
    path: normalizeAssetPath(String(id), pathRaw),
    slots,
  } as Asset;
}

/**
 * Fetch clothing assets from remote API.
 * Throws on network or unexpected response format.
 */
export async function fetchClothingAssets(
  options?: RequestInit,
  timeoutMs?: number,
): Promise<Asset[]> {
  const init = {
    ...defaultFetchOptions(),
    ...(options ?? {}),
    headers: buildRequestHeaders(options?.headers),
  } as RequestInit;
  const res = await fetchWithTimeout(
    API_URL,
    init,
    timeoutMs ?? DEFAULT_REQUEST_TIMEOUT_MS,
  );
  if (!res.ok) {
    throw new Error(`Failed to fetch clothing assets: ${res.status} ${res.statusText}`);
  }
  const data = await res.json();
  if (!Array.isArray(data)) {
    throw new Error("Invalid clothing assets format from API: expected array");
  }
  // normalize arbitrary API response into our Asset shape
  const normalized = (data as unknown[])
    .map((it) => normalizeApiAsset(it))
    .filter((a): a is Asset => a !== null);
  return normalized;
}

export async function fetchClothingModelAssets(
  modelId: string,
  options?: RequestInit,
  timeoutMs?: number,
): Promise<ClothingModelAssetsData> {
  const init = {
    ...defaultFetchOptions(),
    ...(options ?? {}),
    headers: buildRequestHeaders(options?.headers),
  } as RequestInit;

  const response = await fetchWithTimeout(
    buildModelAssetsUrl(modelId),
    init,
    timeoutMs ?? DEFAULT_REQUEST_TIMEOUT_MS,
  );

  if (!response.ok) {
    throw new Error(
      `Failed to fetch clothing model assets: ${response.status} ${response.statusText}`,
    );
  }

  const payload = (await response.json()) as ClothingModelAssetsResponse;

  if (!payload?.data?.model) {
    throw new Error("Invalid clothing model assets format from API");
  }

  return payload.data;
}

/**
 * Try to refresh the in-memory `clothingAssets` array exported by
 * `clothingAssets.ts`. This mutates the array in-place so existing
 * importers that read the array will see updated contents without
 * changing their import code.
 */
export async function refreshClothingAssets(): Promise<void> {
  try {
    const newAssets = await fetchClothingAssets();
    // Replace contents in-place so references held elsewhere remain valid
    clothingAssets.splice(0, clothingAssets.length, ...newAssets);
    // eslint-disable-next-line no-console
    console.info("Clothing assets refreshed from API (", newAssets.length, ")");
  } catch (err) {
    // eslint-disable-next-line no-console
    console.warn("Could not refresh clothing assets from API:", err);
    // Keep local assets as fallback
  }
}

/**
 * Convenience: fetch with fallback to local assets.
 */
export async function fetchClothingAssetsWithFallback(): Promise<Asset[]> {
  try {
    return await fetchClothingAssets();
  } catch (_) {
    return clothingAssets;
  }
}

/**
 * Return prepared request info so the host/webview can perform the request
 * itself (useful when the native side wants to forward the request or when
 * fetch must be performed with different credentials from the webview).
 */
export function getClothingRequestInfo(timeoutMs = DEFAULT_REQUEST_TIMEOUT_MS) {
  return {
    url: API_URL,
    init: defaultFetchOptions(),
    timeoutMs,
  };
}

/**
 * Attach a global receiver for hosts embedding this page in a webview.
 * The native side can call `window.receiveClothingAssets(payload)` where
 * `payload` is an Array of assets or a JSON string. This will replace the
 * in-memory `clothingAssets` array so existing imports pick up the data.
 */
export function attachWebviewReceiver() {
  try {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (window as any).receiveClothingAssets = (payload: unknown) => {
      try {
        const data = Array.isArray(payload) ? payload : JSON.parse(String(payload));
            if (Array.isArray(data)) {
              const normalized = (data as unknown[])
                .map((it) => normalizeApiAsset(it))
                .filter((a): a is Asset => a !== null);
              clothingAssets.splice(0, clothingAssets.length, ...normalized);
              // eslint-disable-next-line no-console
              console.info("Clothing assets injected via webview (", normalized.length, ")");
              return true;
            }
      } catch (e) {
        // eslint-disable-next-line no-console
        console.warn("Invalid payload for receiveClothingAssets:", e);
      }
      return false;
    };
  } catch (e) {
    // attaching failed - likely non-browser environment
  }
}

export function setClothingAssetsFromHost(assets: unknown[]) {
  const normalized = assets
    .map((it) => normalizeApiAsset(it))
    .filter((a): a is Asset => a !== null);
  clothingAssets.splice(0, clothingAssets.length, ...normalized);
}

export { defaultFetchOptions, fetchWithTimeout };
