import { useCallback, useEffect, useState } from "react";
import { fetchClothingModelAssets } from "../clothing/clothingService";
import { CLOTHING_SLOT_ORDER } from "../constants/mannequinView";
import type { ClothingSlot } from "../interface/Asset";
import type { ClothingModelAssetsData } from "../interface/ClothingModelAssets";

type SlotAssetMap = Record<ClothingSlot, ClothingModelAssetsData | null>;
type SlotLoadingMap = Record<ClothingSlot, boolean>;
type SlotErrorMap = Record<ClothingSlot, string | null>;
type SlotTextureSelectionMap = Record<ClothingSlot, string | null>;

const NUMERIC_IDENTIFIER_PATTERN = /^\d+$/;
const TEXTURE_LOAD_ERROR_MESSAGE = "Impossible de charger les textures.";

const createEmptySlotAssetMap = (): SlotAssetMap => ({
  top: null,
  bottom: null,
  shoes: null,
});

const createEmptySlotLoadingMap = (): SlotLoadingMap => ({
  top: false,
  bottom: false,
  shoes: false,
});

const createEmptySlotErrorMap = (): SlotErrorMap => ({
  top: null,
  bottom: null,
  shoes: null,
});

const createEmptyTextureSelectionMap = (): SlotTextureSelectionMap => ({
  top: null,
  bottom: null,
  shoes: null,
});

const isApiModelIdentifier = (value: string | undefined): boolean => {
  return typeof value === "string" && NUMERIC_IDENTIFIER_PATTERN.test(value);
};

const getDefaultTextureUrl = (
  assets: ClothingModelAssetsData | null,
): string | null => {
  if (!assets) {
    return null;
  }

  return (
    assets.textures.find((texture) => texture.selected)?.url ??
    assets.textures[0]?.url ??
    null
  );
};

const resolveSelectedTextureUrl = (
  assets: ClothingModelAssetsData | null,
  currentTextureUrl: string | null,
): string | null => {
  if (!assets) {
    return null;
  }

  if (!currentTextureUrl) {
    return getDefaultTextureUrl(assets);
  }

  const matchingTexture = assets.textures.find(
    (texture) => texture.url === currentTextureUrl,
  );

  return matchingTexture?.url ?? getDefaultTextureUrl(assets);
};

export function useClothingModelAssets(
  selectedModelIds: Record<ClothingSlot, string | undefined>,
) {
  const [slotAssets, setSlotAssets] = useState<SlotAssetMap>(
    createEmptySlotAssetMap,
  );
  const [slotLoading, setSlotLoading] = useState<SlotLoadingMap>(
    createEmptySlotLoadingMap,
  );
  const [slotErrors, setSlotErrors] = useState<SlotErrorMap>(
    createEmptySlotErrorMap,
  );
  const [selectedTextureUrls, setSelectedTextureUrls] =
    useState<SlotTextureSelectionMap>(createEmptyTextureSelectionMap);

  useEffect(() => {
    let cancelled = false;

    setSlotLoading((previousState) => {
      const nextState = { ...previousState };

      CLOTHING_SLOT_ORDER.forEach((slot) => {
        nextState[slot] = isApiModelIdentifier(selectedModelIds[slot]);
      });

      return nextState;
    });

    setSlotErrors((previousState) => {
      const nextState = { ...previousState };

      CLOTHING_SLOT_ORDER.forEach((slot) => {
        nextState[slot] = null;
      });

      return nextState;
    });

    void Promise.all(
      CLOTHING_SLOT_ORDER.map(async (slot) => {
        const modelId = selectedModelIds[slot];

        if (!isApiModelIdentifier(modelId)) {
          return {
            slot,
            assets: null,
            error: null,
          };
        }

        try {
          const assets = await fetchClothingModelAssets(modelId);
          return {
            slot,
            assets,
            error: null,
          };
        } catch (error) {
          const message =
            error instanceof Error
              ? error.message
              : TEXTURE_LOAD_ERROR_MESSAGE;

          return {
            slot,
            assets: null,
            error: message,
          };
        }
      }),
    ).then((results) => {
      if (cancelled) {
        return;
      }

      setSlotAssets((previousState) => {
        const nextState = { ...previousState };

        results.forEach(({ slot, assets }) => {
          nextState[slot] = assets;
        });

        return nextState;
      });

      setSlotLoading((previousState) => {
        const nextState = { ...previousState };

        results.forEach(({ slot }) => {
          nextState[slot] = false;
        });

        return nextState;
      });

      setSlotErrors((previousState) => {
        const nextState = { ...previousState };

        results.forEach(({ slot, error }) => {
          nextState[slot] = error;
        });

        return nextState;
      });

      setSelectedTextureUrls((previousState) => {
        const nextState = { ...previousState };

        results.forEach(({ slot, assets }) => {
          nextState[slot] = resolveSelectedTextureUrl(
            assets,
            previousState[slot],
          );
        });

        return nextState;
      });
    });

    return () => {
      cancelled = true;
    };
  }, [
    selectedModelIds.top,
    selectedModelIds.bottom,
    selectedModelIds.shoes,
  ]);

  const selectTexture = useCallback((slot: ClothingSlot, textureUrl: string | null) => {
    setSelectedTextureUrls((previousState) => ({
      ...previousState,
      [slot]: textureUrl,
    }));
  }, []);

  return {
    slotAssets,
    slotLoading,
    slotErrors,
    selectedTextureUrls,
    selectTexture,
  } as const;
}
