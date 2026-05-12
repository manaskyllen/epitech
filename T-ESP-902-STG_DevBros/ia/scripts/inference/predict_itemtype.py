import os
from pathlib import Path

import joblib
import torch
from PIL import Image
from torchvision import transforms

BASE_DIR = Path(__file__).resolve().parents[2]

MODEL_PATH = Path(
    os.getenv("MODEL_PATH", str(BASE_DIR / "artifacts" / "models" / "model_itemtype.pt"))
)
IMAGE_PATH = Path(os.getenv("IMAGE_PATH", str(BASE_DIR / "image.jpg")))
DATASET_DIR = Path(os.getenv("DATASET_DIR", str(BASE_DIR / "dataset")))
CLASSES_PATH = Path(
    os.getenv(
        "CLASSES_PATH", str(BASE_DIR / "artifacts" / "encoders" / "itemtype_classes.pkl")
    )
)

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


def load_class_names() -> list[str]:
    if CLASSES_PATH.exists():
        classes = joblib.load(CLASSES_PATH)
        if isinstance(classes, list):
            return classes

    if DATASET_DIR.exists() and DATASET_DIR.is_dir():
        dirs = [d.name for d in DATASET_DIR.iterdir() if d.is_dir()]
        if dirs:
            return sorted(dirs)

    raise FileNotFoundError(
        "Unable to resolve class names from CLASSES_PATH or DATASET_DIR."
    )


class_names = load_class_names()

transform = transforms.Compose(
    [
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ]
)

model = torch.load(MODEL_PATH, map_location=DEVICE)
model.eval()

image = Image.open(IMAGE_PATH).convert("RGB")
input_tensor = transform(image).unsqueeze(0).to(DEVICE)

with torch.no_grad():
    output = model(input_tensor)
    _, predicted = torch.max(output, 1)
    predicted_class = class_names[predicted.item()]

print(f"Classe predite: {predicted_class}")
