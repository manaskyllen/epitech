import { useMannequin } from "../context/MannequinProvider";
import {
  AVATAR_POSITION,
  AVATAR_ROTATION,
  AVATAR_SCALE,
} from "../constants/avatarTransform";

export default function Mannequin3D() {
  const { avatar, avatarOffset } = useMannequin();

  if (!avatar) {
    return null;
  }

  const position: [number, number, number] = [
    AVATAR_POSITION[0] + avatarOffset[0],
    AVATAR_POSITION[1] + avatarOffset[1],
    AVATAR_POSITION[2] + avatarOffset[2],
  ];

  return (
    <primitive
      object={avatar}
      scale={AVATAR_SCALE}
      position={position}
      rotation={AVATAR_ROTATION}
    />
  );
}
