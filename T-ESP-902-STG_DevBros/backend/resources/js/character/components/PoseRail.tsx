import {
  MANNEQUIN_POSE_MAP,
  MANNEQUIN_POSE_TOGGLE_SEQUENCE,
  type PoseId,
} from "../constants/mannequinPose";

type PoseRailProps = {
  activePoseId: PoseId;
  onSelectPose: (poseId: PoseId) => void;
};

export default function PoseRail({
  activePoseId,
  onSelectPose,
}: PoseRailProps) {
  const currentPoseIndex = MANNEQUIN_POSE_TOGGLE_SEQUENCE.indexOf(activePoseId);
  const nextPoseId =
    MANNEQUIN_POSE_TOGGLE_SEQUENCE[
      currentPoseIndex >= 0
        ? (currentPoseIndex + 1) % MANNEQUIN_POSE_TOGGLE_SEQUENCE.length
        : 0
    ];

  const currentLabel = MANNEQUIN_POSE_MAP[activePoseId]?.label ?? "Still";

  return (
    <button
      type="button"
      aria-label={`Pose actuelle : ${currentLabel}. Cliquer pour changer`}
      onClick={() => onSelectPose(nextPoseId)}
      className="inline-flex min-h-14 flex-col items-center justify-center gap-1.5 rounded-full bg-white/8 px-6 transition duration-300 ease-out hover:scale-[1.02] hover:bg-white/12 active:scale-[0.98]"
    >
      <span className="flex items-center gap-1.5 text-[11px] font-medium uppercase tracking-[0.22em] text-white">
        <svg width="11" height="11" viewBox="0 0 11 11" fill="none" aria-hidden="true">
          <path d="M9.5 2A4.5 4.5 0 1 0 10 5.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
          <path d="M7.5 0.5L9.5 2L7.5 3.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
        {currentLabel}
      </span>

      <span className="flex items-center gap-1" aria-hidden="true">
        {MANNEQUIN_POSE_TOGGLE_SEQUENCE.map((poseId) => (
          <span
            key={poseId}
            className={`h-0.75 rounded-full transition-all duration-300 ${
              poseId === activePoseId
                ? "w-4 bg-white"
                : "w-0.75 bg-white/30"
            }`}
          />
        ))}
      </span>
    </button>
  );
}
