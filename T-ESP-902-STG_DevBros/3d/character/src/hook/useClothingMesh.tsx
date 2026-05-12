import { useGLTF } from "@react-three/drei";
import { useMemo } from "react";
import { SkinnedMesh } from "three";
import type { Material, Object3D, Skeleton } from "three";

const isSkinnedMeshNode = (object: Object3D): object is SkinnedMesh => {
  return (object as SkinnedMesh).isSkinnedMesh === true;
};

export function useClothingMesh(path: string, skeleton: Skeleton | null) {
  const { scene } = useGLTF(path);

  return useMemo<Object3D | null>(() => {
    if (!scene) {
      return null;
    }

    const clone = scene.clone(true);
    let skinned: SkinnedMesh | null = null;

    clone.traverse((child) => {
      if (isSkinnedMeshNode(child) && !skinned) {
        skinned = child;
      }
    });

    const meshForReturn = skinned as SkinnedMesh | null;

    if (meshForReturn) {
      meshForReturn.visible = true;
      meshForReturn.frustumCulled = false;

      const materials = Array.isArray(meshForReturn.material)
        ? meshForReturn.material
        : [meshForReturn.material];

      materials.forEach((material) => {
        if (material && "skinning" in material) {
          (material as Material & { skinning?: boolean }).skinning = true;
        }
      });
    }

    if (meshForReturn && skeleton) {
      meshForReturn.bind(skeleton, meshForReturn.bindMatrix);
      return meshForReturn;
    }

    return meshForReturn ?? clone;
  }, [scene, skeleton]);
}
