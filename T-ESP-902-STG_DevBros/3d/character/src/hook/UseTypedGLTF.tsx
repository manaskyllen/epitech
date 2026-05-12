import { useGLTF } from "@react-three/drei";
import type { GltfInterface } from "../interface/GltfInterface";


export function useTypedGLTF(path: string) {
    return useGLTF(path) as unknown as GltfInterface
}