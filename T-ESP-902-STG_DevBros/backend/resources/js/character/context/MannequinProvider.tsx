import { useGLTF } from "@react-three/drei";
import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import { Box3, SkinnedMesh, Vector3 } from "three";
import type { Object3D, Skeleton } from "three";
import {
  DEFAULT_MANNEQUIN_POSE_ID,
  type PoseId,
} from "../constants/mannequinPose";
import type { Asset, ClothingSlot } from "../interface/Asset";

type ClothingSelections = Record<ClothingSlot, Asset | null>;
const MANNEQUIN_PATH = "/character-assets/manequin/Mannequin.glb";

type MannequinContextValue = {
  avatar: Object3D | null;
  skeleton: Skeleton | null;
  avatarOffset: [number, number, number];
  selections: ClothingSelections;
  activePoseId: PoseId;
  selectClothing: (slot: ClothingSlot, asset: Asset | null) => void;
  selectPose: (poseId: PoseId) => void;
};

const MannequinContext = createContext<MannequinContextValue | undefined>(
  undefined,
);

const defaultSelections: ClothingSelections = {
  top: null,
  bottom: null,
  shoes: null,
};

type AvatarMeshResult = {
  avatar: Object3D | null;
  skeleton: Skeleton | null;
  avatarOffset: [number, number, number];
};

const isSkinnedMeshNode = (object: Object3D): object is SkinnedMesh => {
  return (object as SkinnedMesh).isSkinnedMesh === true;
};

function useAvatarMesh(path: string): AvatarMeshResult {
  const { scene } = useGLTF(path);

  return useMemo(() => {
    const clone = scene.clone(true);
    let skinnedMesh: SkinnedMesh | null = null;

    clone.traverse((child) => {
      if (isSkinnedMeshNode(child) && !skinnedMesh) {
        skinnedMesh = child;
        skinnedMesh.frustumCulled = false;
      }
    });

    const meshForReturn: SkinnedMesh | null =
      (skinnedMesh as SkinnedMesh | null) ?? null;
    const box = new Box3().setFromObject(clone);
    const center = box.getCenter(new Vector3());
    const avatarOffset: [number, number, number] = [
      -center.x,
      -box.min.y,
      -center.z,
    ];

    return {
      avatar: clone,
      skeleton: meshForReturn ? meshForReturn.skeleton : null,
      avatarOffset,
    };
  }, [scene]);
}

export function MannequinProvider({ children }: { children: ReactNode }) {
  const { avatar, skeleton, avatarOffset } = useAvatarMesh(MANNEQUIN_PATH);

  const [selections, setSelections] =
    useState<ClothingSelections>(defaultSelections);
  const [activePoseId, setActivePoseId] =
    useState<PoseId>(DEFAULT_MANNEQUIN_POSE_ID);

  const selectClothing = useCallback((slot: ClothingSlot, asset: Asset | null) => {
    if (!asset) {
      setSelections((prev) => ({
        ...prev,
        [slot]: null,
      }));
      return;
    }

    setSelections((prev) => {
      const next = { ...prev };
      const targetSlots = asset.slots.length ? asset.slots : [slot];

      targetSlots.forEach((slotKey) => {
        if (slotKey in next) {
          next[slotKey as ClothingSlot] = asset;
        }
      });

      return next;
    });
  }, []);

  const selectPose = useCallback((poseId: PoseId) => {
    setActivePoseId(poseId);
  }, []);

  const value = useMemo(
    () => ({
      avatar,
      skeleton,
      avatarOffset,
      selections,
      activePoseId,
      selectClothing,
      selectPose,
    }),
    [
      avatar,
      skeleton,
      avatarOffset,
      selections,
      activePoseId,
      selectClothing,
      selectPose,
    ],
  );

  return (
    <MannequinContext.Provider value={value}>
      {children}
    </MannequinContext.Provider>
  );
}

export function useMannequin() {
  const context = useContext(MannequinContext);
  if (!context) {
    throw new Error("useMannequin must be used within a MannequinProvider");
  }
  return context;
}

useGLTF.preload(MANNEQUIN_PATH);
