export type AssetFileSource = "minio" | "public" | "unknown";

export interface AssetFileApi {
  key: string;
  filename: string;
  source: AssetFileSource | string;
  url?: string | null;
  shared_path?: string | null;
  selected?: boolean;
}

export interface ClothingModelAssetsData {
  model: AssetFileApi;
  textures: AssetFileApi[];
}

export interface ClothingModelAssetsResponse {
  data: ClothingModelAssetsData;
}
