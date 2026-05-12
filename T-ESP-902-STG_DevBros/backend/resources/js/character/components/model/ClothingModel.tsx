import { useMannequin } from "../../context/MannequinProvider";
import { useClothingMesh } from "../../hook/useClothingMesh";
import {
  AVATAR_POSITION,
  AVATAR_ROTATION,
  AVATAR_SCALE,
} from "../../constants/avatarTransform";

type ClothingModelProps = {
  path?: string | null;
  textureUrl?: string | null;
};

function ClothingModelInner({
  path,
  textureUrl,
}: {
  path: string;
  textureUrl?: string | null;
}) {
  const { skeleton, avatarOffset } = useMannequin();
  const mesh = useClothingMesh(path, skeleton, textureUrl);

  if (!mesh) return null;

  const position: [number, number, number] = [
    AVATAR_POSITION[0] + avatarOffset[0],
    AVATAR_POSITION[1] + avatarOffset[1],
    AVATAR_POSITION[2] + avatarOffset[2],
  ];

  return (
    <primitive
      object={mesh}
      scale={AVATAR_SCALE}
      position={position}
      rotation={AVATAR_ROTATION}
    />
  );
}

export function ClothingModel({ path, textureUrl }: ClothingModelProps) {
  if (!path) return null;
  return <ClothingModelInner path={path} textureUrl={textureUrl} />;
}
