import { Canvas } from "@react-three/fiber";
import { Suspense, useState } from "react";
import Mannequin3D from "./Mannequin";
import { ClothingModel } from "./model/ClothingModel";
import { useMannequin } from "../context/MannequinProvider";
import { OrbitControls } from "@react-three/drei";
import {
  fetchClothingAssets,
  fetchClothingAssetsWithFallback,
} from "../clothing/clothingService";

export default function MannequinViews() {
  const { selections } = useMannequin();
  const [apiStatus, setApiStatus] = useState("Pas de test API");
  const [isTesting, setIsTesting] = useState(false);

  const testApiDirect = async () => {
    setIsTesting(true);
    setApiStatus("Test direct en cours...");
    try {
      const assets = await fetchClothingAssets();
      setApiStatus(`Direct OK: ${assets.length} assets`);
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Erreur inconnue";
      setApiStatus(`Direct KO: ${message}`);
    } finally {
      setIsTesting(false);
    }
  };

  const testApiFallback = async () => {
    setIsTesting(true);
    setApiStatus("Test fallback en cours...");
    try {
      const assets = await fetchClothingAssetsWithFallback();
      setApiStatus(`Fallback OK: ${assets.length} assets`);
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Erreur inconnue";
      setApiStatus(`Fallback KO: ${message}`);
    } finally {
      setIsTesting(false);
    }
  };

  return (
    <div className="relative h-full w-full">
      <div className="absolute top-3 right-3 z-10 flex flex-col gap-2 rounded-lg bg-white/90 p-2 shadow">
        <button
          type="button"
          onClick={() => {
            void testApiDirect();
          }}
          disabled={isTesting}
          className="rounded-md bg-[#424242] px-3 py-2 text-xs font-semibold text-white disabled:cursor-not-allowed disabled:opacity-60"
        >
          Tester API direct
        </button>
        <button
          type="button"
          onClick={() => {
            void testApiFallback();
          }}
          disabled={isTesting}
          className="rounded-md bg-[#6B7280] px-3 py-2 text-xs font-semibold text-white disabled:cursor-not-allowed disabled:opacity-60"
        >
          Tester API fallback
        </button>
        <p className="max-w-[220px] text-[11px] leading-tight text-[#424242]">
          {apiStatus}
        </p>
      </div>
      <Canvas camera={{ position: [0, 1.1, 3.4], fov: 50 }}>
        <ambientLight intensity={0.9} />
        <directionalLight position={[2, 4, 3]} intensity={1} />
        <directionalLight position={[-2, 4, -3]} intensity={0.6} />
        <Suspense fallback={null}>
          <OrbitControls
            enablePan={false}
            enableDamping
            target={[0, 1, 0]}
            dampingFactor={0.5}
            minDistance={2.4}
            maxDistance={5.5}
          />
          <Mannequin3D />
          {selections.top && selections.top.path && (
            <ClothingModel path={selections.top.path} />
          )}
          {selections.bottom && selections.bottom.path && (
            <ClothingModel path={selections.bottom.path} />
          )}
          {selections.shoes && selections.shoes.path && (
            <ClothingModel path={selections.shoes.path} />
          )}
        </Suspense>
      </Canvas>
    </div>
  );
}
