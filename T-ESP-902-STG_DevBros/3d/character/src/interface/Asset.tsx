export type ClothingSlot = "top" | "bottom" | "shoes";

export interface Asset {
  id: string;
  name: string;
  category: string;
  path: string;
  slots: ClothingSlot[];
}
