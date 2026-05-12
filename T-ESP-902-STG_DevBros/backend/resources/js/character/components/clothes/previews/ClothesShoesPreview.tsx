import { Canvas } from "@react-three/fiber";
import { OrbitControls } from "@react-three/drei";
import { Suspense, useState } from "react";
import { Model3d } from "../../model/Model3d";
import type { Asset } from "../../../interface/Asset";

type ClothesShoesPreviewProps = {
  asset: Asset;
  onSelect: (asset: Asset) => void;
  isActive?: boolean;
};

export default function ClothesShoesPreview({
  asset,
  onSelect,
  isActive,
}: ClothesShoesPreviewProps) {
  const [isHovered, setIsHovered] = useState(false);
  const shouldRenderPreview = Boolean(isActive || isHovered);

  return (
    <button
      type="button"
      aria-pressed={isActive}
      onClick={() => onSelect(asset)}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onFocus={() => setIsHovered(true)}
      onBlur={() => setIsHovered(false)}
      className={`w-28 h-32 rounded-xl border transition-all duration-200 focus-visible:outline-2 focus-visible:outline-offset-2 ${
        isActive
          ? "border-indigo-500 ring-2 ring-indigo-500/50"
          : "border-slate-800 hover:border-indigo-400"
      }`}
    >
      {shouldRenderPreview ? (
        <Canvas
          camera={{ position: [0, 0, 2.0], fov: 15 }}
          dpr={[1, 1.25]}
          gl={{ antialias: false, powerPreference: "low-power" }}
        >
          <ambientLight intensity={0.8} />
          <directionalLight position={[2, 2, 2]} />
          <Suspense fallback={null}>
            <Model3d path={asset.path} />
          </Suspense>
          <OrbitControls target={[0, 0.1, 0]} />
        </Canvas>
      ) : (
        <div className="flex h-full w-full items-center justify-center bg-slate-50 px-2 text-center text-xs font-medium text-slate-600">
          {asset.name}
        </div>
      )}
    </button>
  );
}
