import { useCallback, useEffect, useState } from "react";
import type { Asset } from "../interface/Asset";
import { clothingAssets } from "../clothing/clothingAssets";
import {
  fetchClothingAssetsWithFallback,
  refreshClothingAssets,
} from "../clothing/clothingService";

export function useClothingAssets(autoFetch = false) {
  const [assets, setAssets] = useState<Asset[]>(() => clothingAssets.slice());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    if (!autoFetch) return;
    let mounted = true;
    setLoading(true);
    void fetchClothingAssetsWithFallback()
      .then((data) => {
        if (!mounted) return;
        // ensure we got valid data; otherwise fallback to local JSON
        if (Array.isArray(data) && data.length > 0) {
          setAssets(data);
        } else {
          setAssets(clothingAssets.slice());
        }
      })
      .catch((err) => {
        if (!mounted) return;
        // fallback to local JSON on any error
        setAssets(clothingAssets.slice());
        setError(err as Error);
      })
      .finally(() => {
        if (!mounted) return;
        setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, [autoFetch]);

  const refresh = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchClothingAssetsWithFallback();
      if (Array.isArray(data) && data.length > 0) {
        setAssets(data);
      } else {
        setAssets(clothingAssets.slice());
      }
      // keep global in-sync for consumers that still import the array
      try {
        await refreshClothingAssets();
      } catch {
        // ignore
      }
    } catch (err) {
      // fallback to local JSON on error
      setAssets(clothingAssets.slice());
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, []);

  return { assets, loading, error, refresh } as const;
}
