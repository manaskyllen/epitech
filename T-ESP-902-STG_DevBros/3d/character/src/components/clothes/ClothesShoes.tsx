import { useMannequin } from "../../context/MannequinProvider";
import type { Asset } from "../../interface/Asset";
import { useClothingAssets } from "../../hook/useClothingAssets";
import ClothesShoesPreview from "./previews/ClothesShoesPreview";

export default function ClothesShoes() {
  const { selections, selectClothing } = useMannequin();
  const { assets } = useClothingAssets();
  const items = assets.filter((asset) => asset.slots.includes("shoes"));

  const handleSelect = (asset: Asset) => {
    selectClothing("shoes", asset);
  };

  return (
    <div className="flex flex-wrap justify-center gap-3">
      {items.map((item) => (
        <ClothesShoesPreview
          key={item.id}
          asset={item}
          onSelect={handleSelect}
          isActive={selections.shoes?.id === item.id}
        />
      ))}
    </div>
  );
}
