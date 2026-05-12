import { useFrame } from "@react-three/fiber";
import { useEffect, useMemo } from "react";
import { Euler, Quaternion } from "three";
import { useMannequin } from "../context/MannequinProvider";
import {
  DEFAULT_MANNEQUIN_POSE_ID,
  MANNEQUIN_POSE_MAP,
} from "../constants/mannequinPose";

const BASE_AVATAR_POSITION: [number, number, number] = [0, -0.75, 0];
const BASE_AVATAR_ROTATION: [number, number, number] = [0, 0, 0];
const BASE_AVATAR_SCALE = 0.75;

const poseEuler = new Euler();
const poseQuaternion = new Quaternion();
const targetQuaternion = new Quaternion();

const isBoneNode = (
  object: {
    isBone?: boolean;
    name?: string;
    quaternion?: Quaternion;
    traverse?: (callback: (child: unknown) => void) => void;
  },
): object is {
  isBone: true;
  name: string;
  quaternion: Quaternion;
} => {
  return object.isBone === true;
};

const collectSkeletonBones = (avatar: {
  traverse: (callback: (child: unknown) => void) => void;
}) => {
  const bones = new Map<string, { quaternion: Quaternion }>();
  const restRotations = new Map<string, Quaternion>();

  avatar.traverse((child) => {
    if (isBoneNode(child)) {
      bones.set(child.name, child);
      restRotations.set(child.name, child.quaternion.clone());
    }
  });

  return {
    bones,
    restRotations,
  };
};

export default function Mannequin3D() {
  const { avatar, avatarOffset, activePoseId } = useMannequin();

  const skeletonBones = useMemo(() => {
    if (!avatar) {
      return null;
    }

    return collectSkeletonBones(avatar);
  }, [avatar]);

  useEffect(() => {
    if (!skeletonBones) {
      return;
    }

    skeletonBones.restRotations.forEach((rotation, boneName) => {
      skeletonBones.bones.get(boneName)?.quaternion.copy(rotation);
    });
  }, [skeletonBones]);

  useFrame((_, delta) => {
    if (!skeletonBones) {
      return;
    }

    const pose =
      MANNEQUIN_POSE_MAP[activePoseId] ??
      MANNEQUIN_POSE_MAP[DEFAULT_MANNEQUIN_POSE_ID];

    skeletonBones.bones.forEach((bone, boneName) => {
      const restRotation = skeletonBones.restRotations.get(boneName);

      if (!restRotation) {
        return;
      }

      targetQuaternion.copy(restRotation);

      const poseRotation = pose.bones[boneName];

      if (poseRotation) {
        poseEuler.set(poseRotation[0], poseRotation[1], poseRotation[2]);
        poseQuaternion.setFromEuler(poseEuler);
        targetQuaternion.multiply(poseQuaternion);
      }

      bone.quaternion.slerp(targetQuaternion, 1 - Math.exp(-10 * delta));
    });
  });

  if (!avatar) {
    return null;
  }

  const position: [number, number, number] = [
    BASE_AVATAR_POSITION[0] + avatarOffset[0],
    BASE_AVATAR_POSITION[1] + avatarOffset[1],
    BASE_AVATAR_POSITION[2] + avatarOffset[2],
  ];

  return (
    <primitive
      object={avatar}
      scale={BASE_AVATAR_SCALE}
      position={position}
      rotation={BASE_AVATAR_ROTATION}
    />
  );
}
