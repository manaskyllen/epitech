import type { ClothingSlot } from "../interface/Asset";

type Vector3Tuple = [number, number, number];

type DirectionalLightConfig = {
  position: Vector3Tuple;
  intensity: number;
};

type OrbitControlsConfig = {
  target: Vector3Tuple;
  dampingFactor: number;
  minDistance: number;
  maxDistance: number;
  minPolarAngle: number;
  maxPolarAngle: number;
  rotateSpeed: number;
};

type CameraConfig = {
  position: Vector3Tuple;
  fov: number;
};

export const CLOTHING_SLOT_ORDER: ClothingSlot[] = ["top", "bottom", "shoes"];

export const CLOTHING_SLOT_LABELS: Record<ClothingSlot, string> = {
  top: "Tops",
  bottom: "Bottoms",
  shoes: "Shoes",
};

export const MANNEQUIN_VIEW_CAMERA: CameraConfig = {
  position: [0, 1.12, 2.85],
  fov: 40,
};

export const MANNEQUIN_AMBIENT_LIGHT_INTENSITY = 0.82;

export const MANNEQUIN_DIRECTIONAL_LIGHTS: DirectionalLightConfig[] = [
  {
    position: [2.5, 4, 2.5],
    intensity: 1.12,
  },
  {
    position: [-2, 3.2, 1.8],
    intensity: 0.45,
  },
];

export const MANNEQUIN_ORBIT_CONTROLS: OrbitControlsConfig = {
  target: [0, 1.03, 0],
  dampingFactor: 0.08,
  minDistance: 2.7,
  maxDistance: 3.2,
  minPolarAngle: 1.15,
  maxPolarAngle: 1.95,
  rotateSpeed: 0.45,
};
