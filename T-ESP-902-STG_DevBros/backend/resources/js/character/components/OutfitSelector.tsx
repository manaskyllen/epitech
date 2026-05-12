import {
  CLOTHING_SLOT_LABELS,
  CLOTHING_SLOT_ORDER,
} from "../constants/mannequinView";
import LoadingIndicator from "./LoadingIndicator";
import type { Asset, ClothingSlot } from "../interface/Asset";
import type {
  AssetFileApi,
  ClothingModelAssetsData,
} from "../interface/ClothingModelAssets";

type OutfitSelectorProps = {
  activeSlot: ClothingSlot;
  assetsBySlot: Record<ClothingSlot, Asset[]>;
  selectedAssets: Record<ClothingSlot, Asset | null>;
  slotAssets: Record<ClothingSlot, ClothingModelAssetsData | null>;
  slotLoading: Record<ClothingSlot, boolean>;
  slotErrors: Record<ClothingSlot, string | null>;
  selectedTextureUrls: Record<ClothingSlot, string | null>;
  onChangeSlot: (slot: ClothingSlot) => void;
  onClearSlot: (slot: ClothingSlot) => void;
  onSelectAsset: (slot: ClothingSlot, asset: Asset) => void;
  onSelectTexture: (slot: ClothingSlot, textureUrl: string | null) => void;
};

const TEXTURE_FILENAME_EXTENSION_PATTERN = /\.[^.]+$/;
const TEXTURE_FILENAME_SEPARATOR_PATTERN = /[_-]+/g;
const DEFAULT_TEXTURE_FILENAME_PATTERN = /^(default|texture|diffuse|base)$/i;

const getPathSegments = (value: string | null | undefined) =>
  (value ?? "")
    .split("/")
    .map((s) => s.trim())
    .filter(Boolean);

const formatTextureText = (value: string) =>
  value
    .replace(TEXTURE_FILENAME_EXTENSION_PATTERN, "")
    .replace(TEXTURE_FILENAME_SEPARATOR_PATTERN, " ")
    .trim();

const formatTextureLabel = (texture: AssetFileApi) => {
  const filenameLabel = formatTextureText(texture.filename);

  if (filenameLabel && !DEFAULT_TEXTURE_FILENAME_PATTERN.test(filenameLabel)) {
    return filenameLabel;
  }

  const pathSegments = [
    ...getPathSegments(texture.shared_path),
    ...getPathSegments(texture.key),
  ];
  const textureDirectoryName = pathSegments.at(-2);
  const fallbackLabel =
    textureDirectoryName && textureDirectoryName !== texture.filename
      ? textureDirectoryName
      : texture.key;

  return formatTextureText(fallbackLabel) || filenameLabel || "Texture";
};

export default function OutfitSelector({
  activeSlot,
  assetsBySlot,
  selectedAssets,
  slotAssets,
  slotLoading,
  slotErrors,
  selectedTextureUrls,
  onChangeSlot,
  onClearSlot,
  onSelectAsset,
  onSelectTexture,
}: OutfitSelectorProps) {
  const textures = slotAssets[activeSlot]?.textures ?? [];
  const selectedTextureUrl = selectedTextureUrls[activeSlot];
  const selectedTexture = textures.find((t) => t.url === selectedTextureUrl);
  const selectedAsset = selectedAssets[activeSlot];

  return (
    <section className="rounded-4xl bg-white/4 p-4 text-white ring-1 ring-white/8">

      {/* Slot tabs */}
      <div className="flex gap-2 overflow-x-auto pb-1 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
        {CLOTHING_SLOT_ORDER.map((slot) => {
          const isActive = slot === activeSlot;
          const hasSelection = !!selectedAssets[slot];

          return (
            <button
              key={slot}
              type="button"
              onClick={() => onChangeSlot(slot)}
              className={`relative rounded-full px-4 py-2 text-[10px] uppercase tracking-[0.22em] transition duration-300 ease-out ${
                isActive
                  ? "bg-white text-black"
                  : "bg-white/6 text-white/60 hover:bg-white/10 hover:text-white/80"
              }`}
            >
              {CLOTHING_SLOT_LABELS[slot]}
              {hasSelection && !isActive && (
                <span
                  aria-hidden="true"
                  className="absolute right-1.5 top-1.5 h-1.5 w-1.5 rounded-full bg-white/60"
                />
              )}
            </button>
          );
        })}
      </div>

      {/* Selected item header */}
      <div className="mt-4 flex items-center justify-between gap-3">
        <div className="min-w-0 flex-1">
          {selectedAsset ? (
            <>
              <p className="truncate text-sm font-medium text-white">
                {selectedAsset.name}
              </p>
              {selectedTexture && (
                <p className="mt-0.5 truncate text-[10px] uppercase tracking-[0.18em] text-white/40">
                  {formatTextureLabel(selectedTexture)}
                </p>
              )}
            </>
          ) : (
            <p className="text-sm text-white/35">Aucune pièce sélectionnée</p>
          )}
        </div>

        {selectedAsset && (
          <button
            type="button"
            onClick={() => onClearSlot(activeSlot)}
            aria-label={`Retirer ${selectedAsset.name}`}
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-white/6 text-white/50 transition duration-300 ease-out hover:bg-white/12 hover:text-white"
          >
            <svg width="10" height="10" viewBox="0 0 10 10" fill="none" aria-hidden="true">
              <path
                d="M1.5 1.5L8.5 8.5M8.5 1.5L1.5 8.5"
                stroke="currentColor"
                strokeWidth="1.6"
                strokeLinecap="round"
              />
            </svg>
          </button>
        )}
      </div>

      {/* Asset cards */}
      <div className="mt-4 flex gap-2.5 overflow-x-auto pb-1 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
        {/* None card */}
        <button
          type="button"
          onClick={() => onClearSlot(activeSlot)}
          className={`flex h-22 w-24 shrink-0 flex-col justify-between rounded-3xl px-4 py-4 text-left transition duration-300 ease-out ${
            !selectedAsset
              ? "bg-white text-black"
              : "bg-white/3 text-white/40 hover:bg-white/[0.07]"
          }`}
        >
          <span className="text-[10px] uppercase tracking-[0.22em]">None</span>
          <span className="text-sm">—</span>
        </button>

        {assetsBySlot[activeSlot].map((asset) => {
          const isActive = selectedAsset?.id === asset.id;

          return (
            <button
              key={asset.id}
              type="button"
              onClick={() => onSelectAsset(activeSlot, asset)}
              className={`relative flex h-22 w-36 shrink-0 flex-col justify-between rounded-3xl px-4 py-4 text-left transition duration-300 ease-out ${
                isActive
                  ? "bg-white text-black"
                  : "bg-white/3 text-white hover:bg-white/[0.07]"
              }`}
            >
              {isActive && (
                <span className="absolute right-3 top-3" aria-hidden="true">
                  <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                    <path
                      d="M2 6.5L4.5 9L10 3"
                      stroke="currentColor"
                      strokeWidth="1.6"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    />
                  </svg>
                </span>
              )}
              <span className="text-[10px] uppercase tracking-[0.22em] opacity-45">
                {CLOTHING_SLOT_LABELS[activeSlot]}
              </span>
              <span className="line-clamp-2 text-sm">{asset.name}</span>
            </button>
          );
        })}
      </div>

      {slotErrors[activeSlot] && (
        <p className="mt-4 text-xs text-white/45">{slotErrors[activeSlot]}</p>
      )}

      {/* Textures / Colors */}
      {(slotLoading[activeSlot] || textures.length > 0) && (
        <div className="mt-5">
          <div className="mb-3 flex items-center gap-2.5">
            <p className="text-[10px] uppercase tracking-[0.22em] text-white/40">
              Couleurs
            </p>
            {slotLoading[activeSlot] && <LoadingIndicator variant="dots" />}
          </div>

          {textures.length > 0 && (
            <div className="flex gap-2 overflow-x-auto pb-1 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
              {textures.map((texture) => {
                const textureUrl = texture.url ?? null;
                const isActive = textureUrl === selectedTextureUrl;

                return (
                  <button
                    key={texture.key}
                    type="button"
                    disabled={textureUrl === null}
                    onClick={() => onSelectTexture(activeSlot, textureUrl)}
                    className={`relative flex h-19 w-28 shrink-0 flex-col justify-between rounded-[1.25rem] px-3 py-3 text-left transition duration-300 ease-out disabled:opacity-35 ${
                      isActive
                        ? "bg-white text-black"
                        : "bg-white/3 text-white hover:bg-white/[0.07]"
                    }`}
                  >
                    {isActive && (
                      <span className="absolute right-2.5 top-2.5" aria-hidden="true">
                        <svg width="10" height="10" viewBox="0 0 10 10" fill="none">
                          <path
                            d="M1.5 5.5L3.5 7.5L8.5 2.5"
                            stroke="currentColor"
                            strokeWidth="1.5"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                          />
                        </svg>
                      </span>
                    )}
                    <span className="text-[10px] uppercase tracking-[0.18em] opacity-45">
                      Couleur
                    </span>
                    <span className="line-clamp-2 text-xs">
                      {formatTextureLabel(texture)}
                    </span>
                  </button>
                );
              })}
            </div>
          )}
        </div>
      )}
    </section>
  );
}
