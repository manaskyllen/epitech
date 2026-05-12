export type PoseId = "still" | "open" | "stride" | "poise";

type BoneRotation = [number, number, number];

type PoseBones = Record<string, BoneRotation>;

export type MannequinPose = {
  id: PoseId;
  label: string;
  bones: PoseBones;
};

export const DEFAULT_MANNEQUIN_POSE_ID: PoseId = "still";

export const MANNEQUIN_POSE_TOGGLE_SEQUENCE: PoseId[] = [
  "still",
  "stride",
  "poise",
];

export const MANNEQUIN_POSES: MannequinPose[] = [
  {
    id: "still",
    label: "Still",
    bones: {},
  },
  {
    id: "open",
    label: "Open",
    bones: {
      mixamorigLeftArm: [0.1, -0.3, -1.05],
      mixamorigLeftForeArm: [0.25, -0.25, -0.08],
      mixamorigRightArm: [0.1, 0.35, 1.05],
      mixamorigRightForeArm: [0.2, 0.18, 0.08],
      mixamorigSpine: [0.04, 0, 0],
    },
  },
  {
    id: "stride",
    label: "Stride",
    bones: {
      mixamorigLeftArm: [0.34, -0.12, 0.28],
      mixamorigLeftForeArm: [0.2, -0.08, -0.08],
      mixamorigRightArm: [-0.16, 0.12, -0.42],
      mixamorigRightForeArm: [0.18, 0.14, 0.08],
      mixamorigLeftUpLeg: [-0.22, 0, 0.08],
      mixamorigRightUpLeg: [0.2, 0, -0.08],
      mixamorigLeftLeg: [0.18, 0, 0],
      mixamorigRightLeg: [-0.12, 0, 0],
      mixamorigSpine: [0.05, -0.04, 0],
      mixamorigHead: [-0.04, 0.05, 0],
    },
  },
  {
    id: "poise",
    label: "Poise",
    bones: {
      mixamorigHips: [0, 0.08, 0.04],
      mixamorigSpine: [0.06, 0.08, 0],
      mixamorigSpine1: [0.08, 0.05, 0],
      mixamorigLeftArm: [0.12, -0.06, -0.56],
      mixamorigLeftForeArm: [0.42, -0.08, -0.06],
      mixamorigRightArm: [0.05, 0.12, 0.18],
      mixamorigRightForeArm: [0.18, 0.14, 0.05],
      mixamorigHead: [-0.02, 0.12, 0],
      mixamorigLeftUpLeg: [0.04, 0, 0.02],
      mixamorigRightUpLeg: [-0.06, 0, -0.02],
    },
  },
];

export const MANNEQUIN_POSE_MAP = Object.fromEntries(
  MANNEQUIN_POSES.map((pose) => [pose.id, pose]),
) as Record<PoseId, MannequinPose>;
