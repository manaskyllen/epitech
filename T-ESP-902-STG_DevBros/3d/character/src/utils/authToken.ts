const TOKEN_KEYS = ["access_token", "token"] as const;

function decodeCookieValue(value: string): string {
  try {
    return decodeURIComponent(value);
  } catch {
    return value;
  }
}

function readStorageValue(key: string): string | null {
  if (typeof window === "undefined") {
    return null;
  }

  try {
    const value = window.localStorage.getItem(key);
    return value && value.trim().length > 0 ? value : null;
  } catch {
    return null;
  }
}

export function readCookieValue(cookieName: string, cookieSource?: string): string | null {
  const source =
    cookieSource ?? (typeof document !== "undefined" ? document.cookie : "");
  if (!source) {
    return null;
  }

  const target = `${cookieName}=`;
  const chunks = source.split(";").map((part) => part.trim());

  for (const chunk of chunks) {
    if (!chunk.startsWith(target)) {
      continue;
    }
    const raw = chunk.slice(target.length).trim();
    if (!raw) {
      return null;
    }
    return decodeCookieValue(raw);
  }

  return null;
}

export function getWebviewToken(cookieSource?: string): string | null {
  for (const key of TOKEN_KEYS) {
    const token = readCookieValue(key, cookieSource);
    if (token) {
      return token;
    }
  }

  for (const key of TOKEN_KEYS) {
    const token = readStorageValue(key);
    if (token) {
      return token;
    }
  }

  return null;
}
