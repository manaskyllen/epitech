import os
import sys
import requests
from urllib.parse import quote
from gradio_client import Client, handle_file

SPACE_ID = "Axcomma/3D-inspiria"
HF_TOKEN = "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"

if not HF_TOKEN:
    raise RuntimeError("HF_TOKEN manquant. Ex: export HF_TOKEN=hf_xxx")

def download_from_space(client: Client, url: str, out_path: str):
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)

def download(url: str, out_path: str, timeout=1200):
    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    headers = {"Authorization": f"Bearer {HF_TOKEN}"}
    r = requests.get(url, headers=headers, timeout=timeout)
    r.raise_for_status()
    with open(out_path, "wb") as f:
        f.write(r.content)


def main():
    if len(sys.argv) < 3:
        print("Usage: python generateClothes.py <photo.jpg> <out.glb>")
        sys.exit(1)

    photo_path = sys.argv[1]
    out_glb = sys.argv[2]

    if not os.path.isfile(photo_path):
        raise FileNotFoundError(photo_path)

    client = Client(SPACE_ID, hf_token=HF_TOKEN)

    result = client.predict(
        image=handle_file(photo_path),
        mv_image_front=None,
        mv_image_back=None,
        mv_image_left=None,
        mv_image_right=None,
        steps=30,
        guidance_scale=5,
        seed=1234,
        octree_resolution=256,
        check_box_rembg=True,
        num_chunks=8000,
        randomize_seed=True,
        api_name="/shape_generation"
    )

    print("[HF] result:", result)

    # ✅ EXTRACTION DIRECTE (AUCUNE FONCTION)
    try:
        tmp_path = result[0]["value"]
    except (TypeError, KeyError, IndexError):
        raise RuntimeError(f"Format result inattendu: {result}")

    if not isinstance(tmp_path, str):
        raise RuntimeError(f"Path GLB invalide: {tmp_path}")

    # Construction URL Gradio
    base = client.src
    if not base.endswith("/"):
        base += "/"

    glb_url = f"{base}file={quote(tmp_path, safe='/')}"

    print("[HF] Download:", glb_url)

    download(glb_url, out_glb)

    print("[OK] Saved:", out_glb)

if __name__ == "__main__":
    main()
