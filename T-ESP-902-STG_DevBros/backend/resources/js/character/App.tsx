import { useEffect, useMemo, useState } from "react";
import { attachWebviewReceiver } from "./clothing/clothingService";
import LoadingIndicator from "./components/LoadingIndicator";
import MannequinViews from "./components/MannequinViews";
import OutfitSelector from "./components/OutfitSelector";
import PoseRail from "./components/PoseRail";
import { useMannequin } from "./context/MannequinProvider";
import { useClothingAssets } from "./hook/useClothingAssets";
import { useClothingModelAssets } from "./hook/useClothingModelAssets";
import type { ClothingSlot } from "./interface/Asset";

function App() {
  const [isOutfitMenuOpen, setIsOutfitMenuOpen] = useState(false);
  const [activeSlot, setActiveSlot] = useState<ClothingSlot>("top");
  const { assets, loading: isCatalogLoading } = useClothingAssets(true);
  const { selections, selectClothing, activePoseId, selectPose } = useMannequin();

  useEffect(() => {
    try {
      attachWebviewReceiver();
    } catch {
      // ignore
    }
  }, []);

  const selectedModelIds = useMemo(
    () => ({
      top: selections.top?.id,
      bottom: selections.bottom?.id,
      shoes: selections.shoes?.id,
    }),
    [selections.bottom?.id, selections.shoes?.id, selections.top?.id],
  );

  const {
    slotAssets,
    slotLoading,
    slotErrors,
    selectedTextureUrls,
    selectTexture,
  } = useClothingModelAssets(selectedModelIds);

  const assetsBySlot = useMemo(
    () => ({
      top: assets.filter((asset) => asset.slots.includes("top")),
      bottom: assets.filter((asset) => asset.slots.includes("bottom")),
      shoes: assets.filter((asset) => asset.slots.includes("shoes")),
    }),
    [assets],
  );

  const equippedCount = Object.values(selections).filter(Boolean).length;
  const isSceneBusy = isCatalogLoading || Object.values(slotLoading).some(Boolean);

  return (
    <div className="min-h-screen bg-black text-white">
      <div className="mx-auto flex min-h-screen w-full max-w-6xl flex-col">
        <main className="flex-1 px-4 pt-4 sm:px-6 sm:pt-6">
          <section className="mx-auto h-[82svh] min-h-140 max-w-5xl sm:h-[85svh]">
            <MannequinViews selectedTextureUrls={selectedTextureUrls} />
          </section>
        </main>

        <footer className="px-4 pb-[calc(env(safe-area-inset-bottom)+1.25rem)] pt-2 sm:px-6">
          <div className="mx-auto max-w-4xl">
            <div
              className={`origin-bottom overflow-hidden transition-all duration-300 ease-out ${
                isOutfitMenuOpen
                  ? "mb-4 max-h-120 scale-100 opacity-100"
                  : "pointer-events-none max-h-0 scale-95 opacity-0"
              }`}
            >
              <OutfitSelector
                activeSlot={activeSlot}
                assetsBySlot={assetsBySlot}
                selectedAssets={selections}
                slotAssets={slotAssets}
                slotLoading={slotLoading}
                slotErrors={slotErrors}
                selectedTextureUrls={selectedTextureUrls}
                onChangeSlot={setActiveSlot}
                onClearSlot={(slot) => selectClothing(slot, null)}
                onSelectAsset={(slot, asset) => selectClothing(slot, asset)}
                onSelectTexture={selectTexture}
              />
            </div>

            <div className="flex items-center justify-center gap-3">
              <PoseRail activePoseId={activePoseId} onSelectPose={selectPose} />

              <button
                type="button"
                onClick={() => setIsOutfitMenuOpen((prev) => !prev)}
                className="inline-flex min-h-14 items-center justify-center gap-2.5 rounded-full bg-white px-7 text-sm font-medium tracking-[0.14em] text-black transition duration-300 ease-out hover:scale-[1.02] active:scale-[0.98]"
              >
                <span>Outfit</span>

                {equippedCount > 0 && (
                  <span className="flex h-5 w-5 items-center justify-center rounded-full bg-black text-[10px] font-bold text-white">
                    {equippedCount}
                  </span>
                )}

                <svg
                  width="11"
                  height="7"
                  viewBox="0 0 11 7"
                  fill="none"
                  aria-hidden="true"
                  className={`transition-transform duration-300 ${isOutfitMenuOpen ? "rotate-180" : ""}`}
                >
                  <path
                    d="M1 1L5.5 6L10 1"
                    stroke="currentColor"
                    strokeWidth="1.6"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </button>

              {isSceneBusy && <LoadingIndicator />}
            </div>
          </div>
        </footer>
      </div>
    </div>
  );
}

export default App;
