import type { AnimationClip, Camera, Group } from "three"
import type { GLTFParser } from "three/examples/jsm/loaders/GLTFLoader.js"

export interface GltfInterface {
  animations: AnimationClip[]
  scene: Group
  scenes: Group[]
  cameras: Camera[]
  asset: {
    copyright?: string
    generator?: string
    version?: string
    minVersion?: string
    extensions?: any
    extras?: any
  }
  parser: GLTFParser
  userData: any
}