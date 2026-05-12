from pathlib import Path
from bing_image_downloader import downloader

OUTPUT_DIR = Path("backend/dataset/images_negatives")

KEYWORDS = [
    "car",
    "truck",
    "motorcycle",
    "bicycle",
    "bus",
    "dog",
    "cat",
    "bird",
    "horse",
    "cow",
    "pizza",
    "burger",
    "salad",
    "fruit basket",
    "cake",
    "mountain",
    "beach",
    "forest",
    "river",
    "city street",
    "living room",
    "kitchen",
    "bathroom",
    "bedroom",
    "office desk",
    "computer desk",
    "laptop",
    "phone",
    "tablet",
    "television",
]

LIMIT_PER_KEYWORD = 250

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

for keyword in KEYWORDS:
    print(f"⬇️ Téléchargement : {keyword}")
    downloader.download(
        keyword,
        limit=LIMIT_PER_KEYWORD,
        output_dir=str(OUTPUT_DIR),
        adult_filter_off=True,
        force_replace=False,
        timeout=30,
        verbose=True,
    )

print("✅ Téléchargement des négatifs terminé")