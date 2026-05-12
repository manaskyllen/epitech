import { OrbitControls } from "@react-three/drei";
import { Canvas } from "@react-three/fiber";
import { Suspense, useState } from "react";
import type { ClothingSlot } from "../interface/Asset";
import {
  MANNEQUIN_AMBIENT_LIGHT_INTENSITY,
  MANNEQUIN_DIRECTIONAL_LIGHTS,
  MANNEQUIN_ORBIT_CONTROLS,
  MANNEQUIN_VIEW_CAMERA,
} from "../constants/mannequinView";
import { useMannequin } from "../context/MannequinProvider";
import Mannequin3D from "./Mannequin";
import { ClothingModel } from "./model/ClothingModel";

type MannequinViewsProps = {
  selectedTextureUrls: Record<ClothingSlot, string | null>;
};

export default function MannequinViews({
  selectedTextureUrls,
}: MannequinViewsProps) {
  const { selections } = useMannequin();
  const [hasDragged, setHasDragged] = useState(false);

  return (
    <div
      className="relative h-full w-full overflow-hidden bg-black"
      onPointerDown={() => setHasDragged(true)}
    >
      <Canvas
        camera={MANNEQUIN_VIEW_CAMERA}
        dpr={[1, 1.5]}
        gl={{ antialias: false, powerPreference: "high-performance" }}
      >
        <color attach="background" args={["#000000"]} />
        <ambientLight intensity={MANNEQUIN_AMBIENT_LIGHT_INTENSITY} />

        {MANNEQUIN_DIRECTIONAL_LIGHTS.map((light) => (
          <directionalLight
            key={light.position.join("-")}
            position={light.position}
            intensity={light.intensity}
          />
        ))}

        <Suspense fallback={null}>
          <OrbitControls
            enablePan={false}
            enableZoom={false}
            enableDamping
            target={MANNEQUIN_ORBIT_CONTROLS.target}
            dampingFactor={MANNEQUIN_ORBIT_CONTROLS.dampingFactor}
            minDistance={MANNEQUIN_ORBIT_CONTROLS.minDistance}
            maxDistance={MANNEQUIN_ORBIT_CONTROLS.maxDistance}
            minPolarAngle={MANNEQUIN_ORBIT_CONTROLS.minPolarAngle}
            maxPolarAngle={MANNEQUIN_ORBIT_CONTROLS.maxPolarAngle}
            rotateSpeed={MANNEQUIN_ORBIT_CONTROLS.rotateSpeed}
          />

          <Mannequin3D />

          {Object.entries(selections).map(([slot, selectedAsset]) => {
            if (!selectedAsset?.path) return null;

            return (
              <ClothingModel
                key={`${slot}:${selectedAsset.path}`}
                path={selectedAsset.path}
                textureUrl={selectedTextureUrls[slot as ClothingSlot]}
              />
            );
          })}
        </Suspense>
      </Canvas>

      <div
        className={`pointer-events-none absolute inset-x-0 bottom-5 flex justify-center transition-opacity duration-700 ${
          hasDragged ? "opacity-0" : "opacity-100"
        }`}
      >
        <span className="flex items-center gap-2 rounded-full bg-white/[0.07] px-4 py-2 text-[10px] uppercase tracking-[0.2em] text-white/45 backdrop-blur-sm">
          <svg width="13" height="13" viewBox="0 0 13 13" fill="none" aria-hidden="true">
            <path d="M2 6.5C2 4.01 4.01 2 6.5 2C7.95 2 9.24 2.66 10.1 3.7" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
            <path d="M11 6.5C11 8.99 8.99 11 6.5 11C5.05 11 3.76 10.34 2.9 9.3" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round"/>
            <path d="M9 2.8L10.2 3.9L11.5 2.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M4 10.2L2.8 9.1L1.5 10.5" stroke="currentColor" strokeWidth="1.3" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
          Glisser pour tourner
        </span>
      </div>
    </div>
  );
}
