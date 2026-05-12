import { useMannequin } from "../../context/MannequinProvider";
import type { Asset } from "../../interface/Asset";
import { useClothingAssets } from "../../hook/useClothingAssets";
import ClothesBottomPreview from "./previews/ClothesBottomPreview";

export default function ClothesBottom() {
  const { selections, selectClothing } = useMannequin();
  const { assets } = useClothingAssets(true);
  const items = assets.filter((asset) => asset.slots.includes("bottom"));

  const handleSelect = (asset: Asset) => {
    selectClothing("bottom", asset);
  };

  return (
    <div className="flex flex-wrap justify-center gap-3">
      {items.map((item) => (
        <ClothesBottomPreview
          key={item.id}
          asset={item}
          onSelect={handleSelect}
          isActive={selections.bottom?.id === item.id}
        />
      ))}
    </div>
  );
}
