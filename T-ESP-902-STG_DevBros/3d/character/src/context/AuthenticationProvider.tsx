import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { getWebviewToken } from "../utils/authToken";

type AuthenticationContextValue = {
  token: string | null;
  isAuthenticated: boolean;
  refreshToken: () => void;
};

const AuthenticationContext = createContext<
  AuthenticationContextValue | undefined
>(undefined);

export default function AuthenticationProvider({
  children,
}: {
  children: ReactNode;
}) {
  const [token, setToken] = useState<string | null>(() => getWebviewToken());

  const refreshToken = useCallback(() => {
    setToken(getWebviewToken());
  }, []);

  useEffect(() => {
    if (typeof window === "undefined" || typeof document === "undefined") {
      return;
    }

    const handleVisibilityChange = () => {
      if (document.visibilityState === "visible") {
        refreshToken();
      }
    };

    refreshToken();
    window.addEventListener("focus", refreshToken);
    document.addEventListener("visibilitychange", handleVisibilityChange);

    return () => {
      window.removeEventListener("focus", refreshToken);
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [refreshToken]);

  const value = useMemo(
    () => ({
      token,
      isAuthenticated: Boolean(token),
      refreshToken,
    }),
    [token, refreshToken],
  );

  return (
    <AuthenticationContext.Provider value={value}>
      {children}
    </AuthenticationContext.Provider>
  );
}

export function useAuthentication() {
  const context = useContext(AuthenticationContext);
  if (!context) {
    throw new Error(
      "useAuthentication must be used within an AuthenticationProvider",
    );
  }
  return context;
}
