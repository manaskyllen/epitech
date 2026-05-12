import { useGLTF } from "@react-three/drei";
import { useMemo } from "react";
import { Box3, SkinnedMesh, Vector3 } from "three";

type AssetProps = {
  path: string;
};

export function Model3d({ path }: AssetProps) {
  const { scene } = useGLTF(path);

  const { model, position, scale } = useMemo(() => {
    const clone = scene.clone(true);
    clone.traverse((child) => {
      if ((child as SkinnedMesh).isSkinnedMesh === true) {
        (child as SkinnedMesh).frustumCulled = false;
      }
    });

    const box = new Box3().setFromObject(clone);
    if (box.isEmpty()) {
      return {
        model: clone,
        position: [0, 0, 0] as [number, number, number],
        scale: 1,
      };
    }

    const center = box.getCenter(new Vector3());
    const size = box.getSize(new Vector3());
    const maxDim = Math.max(size.x, size.y, size.z) || 1;
    const fittedScale = 1.45 / maxDim;

    return {
      model: clone,
      position: [-center.x, -center.y, -center.z] as [number, number, number],
      scale: fittedScale,
    };
  }, [scene]);

  return <primitive object={model} position={position} scale={scale} />;
}
