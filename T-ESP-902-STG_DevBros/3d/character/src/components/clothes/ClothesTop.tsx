import { useMannequin } from "../../context/MannequinProvider";
import type { Asset } from "../../interface/Asset";
import { useClothingAssets } from "../../hook/useClothingAssets";
import ClothesTopPreview from "./previews/ClothesTopPreview";

export default function ClothesTop() {
  const { selections, selectClothing } = useMannequin();
  const { assets } = useClothingAssets();
  const items = assets.filter((asset) => asset.slots.includes("top"));

  const handleSelect = (asset: Asset) => {
    selectClothing("top", asset);
  };

  return (
    <div className="flex flex-wrap justify-center gap-3">
      {items.map((item) => (
        <ClothesTopPreview
          key={item.id}
          asset={item}
          onSelect={handleSelect}
          isActive={selections.top?.id === item.id}
        />
      ))}
    </div>
  );
}
