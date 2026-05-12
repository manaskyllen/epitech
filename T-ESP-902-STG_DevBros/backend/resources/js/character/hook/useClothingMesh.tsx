import { useGLTF } from "@react-three/drei";
import { useEffect, useMemo } from "react";
import { Mesh, SRGBColorSpace, SkinnedMesh, TextureLoader } from "three";
import type { Material, Object3D, Skeleton, Texture } from "three";

type TexturableMaterial = Material & {
  map?: Texture | null;
  skinning?: boolean;
  needsUpdate: boolean;
};

const TEXTURE_FLIP_Y = false;
const TEXTURE_COLOR_SPACE = SRGBColorSpace;

const isSkinnedMeshNode = (object: Object3D): object is SkinnedMesh => {
  return (object as SkinnedMesh).isSkinnedMesh === true;
};

const isMeshNode = (object: Object3D): object is Mesh => {
  return (object as Mesh).isMesh === true;
};

const materialListFromMesh = (mesh: Mesh): TexturableMaterial[] => {
  return Array.isArray(mesh.material)
    ? (mesh.material as TexturableMaterial[])
    : [mesh.material as TexturableMaterial];
};

const enableSkinningOnMesh = (mesh: Mesh) => {
  materialListFromMesh(mesh).forEach((material) => {
    if (material && "skinning" in material) {
      material.skinning = true;
      material.needsUpdate = true;
    }
  });
};

const applyTextureToScene = (root: Object3D, texture: Texture) => {
  root.traverse((child) => {
    if (!isMeshNode(child)) {
      return;
    }

    materialListFromMesh(child).forEach((material) => {
      if (!material || !("map" in material)) {
        return;
      }

      material.map = texture;
      material.needsUpdate = true;
    });
  });
};

export function useClothingMesh(
  path: string,
  skeleton: Skeleton | null,
  textureUrl?: string | null,
) {
  const { scene } = useGLTF(path);

  const mesh = useMemo<Object3D | null>(() => {
    if (!scene) {
      return null;
    }

    const clone = scene.clone(true);
    const skinnedMeshes: SkinnedMesh[] = [];

    clone.traverse((child) => {
      if (isSkinnedMeshNode(child)) {
        skinnedMeshes.push(child);
        child.visible = true;
        child.frustumCulled = false;
      }

      if (isMeshNode(child)) {
        enableSkinningOnMesh(child);
      }
    });

    if (skeleton) {
      skinnedMeshes.forEach((skinnedMesh) => {
        skinnedMesh.bind(skeleton, skinnedMesh.bindMatrix);
      });
    }

    return clone;
  }, [scene, skeleton]);

  useEffect(() => {
    if (!mesh || !textureUrl) {
      return;
    }

    const loader = new TextureLoader();
    let isCancelled = false;
    let loadedTexture: Texture | null = null;

    loader.load(textureUrl, (texture) => {
      if (isCancelled) {
        texture.dispose();
        return;
      }

      texture.flipY = TEXTURE_FLIP_Y;
      texture.colorSpace = TEXTURE_COLOR_SPACE;
      loadedTexture = texture;
      applyTextureToScene(mesh, texture);
    });

    return () => {
      isCancelled = true;
      loadedTexture?.dispose();
    };
  }, [mesh, textureUrl]);

  return mesh;
}
