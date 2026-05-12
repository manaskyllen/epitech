type LoadingIndicatorProps = {
  variant?: "ring" | "dots";
  className?: string;
};

export default function LoadingIndicator({
  variant = "ring",
  className = "",
}: LoadingIndicatorProps) {
  if (variant === "dots") {
    return (
      <span
        className={`loading-dots ${className}`.trim()}
        role="status"
        aria-label="Chargement"
      >
        <span className="loading-dot" />
        <span className="loading-dot loading-dot-delay-1" />
        <span className="loading-dot loading-dot-delay-2" />
      </span>
    );
  }

  return (
    <span
      className={`loading-orbit ${className}`.trim()}
      role="status"
      aria-label="Chargement"
    >
      <span className="loading-orbit-core" />
      <span className="loading-orbit-ring" />
    </span>
  );
}
