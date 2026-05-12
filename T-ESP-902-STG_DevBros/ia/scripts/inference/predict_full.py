import os
from collections import Counter
from pathlib import Path

import clip
import joblib
import numpy as np
import torch
from PIL import Image
from scipy.spatial import distance
from sklearn.cluster import KMeans
from torchvision import transforms

BASE_DIR = Path(__file__).resolve().parents[2]

MODEL_PATH = Path(
    os.getenv("MODEL_PATH", str(BASE_DIR / "artifacts" / "models" / "model_itemtype.pt"))
)
CLASSES_PATH = Path(
    os.getenv(
        "CLASSES_PATH", str(BASE_DIR / "artifacts" / "encoders" / "itemtype_classes.pkl")
    )
)
IMAGE_PATH = Path(os.getenv("IMAGE_PATH", str(BASE_DIR / "image.jpg")))

DEVICE = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Device utilise: {DEVICE}")

resnet_model = torch.load(MODEL_PATH, map_location=DEVICE)
resnet_model.eval()

clip_model, clip_preprocess = clip.load("ViT-B/32", device=DEVICE)

itemtype_classes = joblib.load(CLASSES_PATH)
if not isinstance(itemtype_classes, list):
    raise ValueError("Invalid classes file format in CLASSES_PATH.")

resnet_transform = transforms.Compose(
    [
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ]
)

image = Image.open(IMAGE_PATH).convert("RGB")

COLOR_NAMES = {
    "Noir": (0, 0, 0),
    "Blanc": (255, 255, 255),
    "Rouge": (255, 0, 0),
    "Rouge fonce": (128, 0, 0),
    "Bordeaux": (160, 20, 60),
    "Rouge clair": (255, 102, 102),
    "Vert": (0, 255, 0),
    "Bleu": (0, 0, 255),
    "Jaune": (255, 255, 0),
    "Orange": (255, 165, 0),
    "Rose": (255, 192, 203),
    "Gris": (128, 128, 128),
    "Marron": (139, 69, 19),
    "Beige": (245, 245, 220),
    "Violet": (128, 0, 128),
}


def get_color_name(rgb):
    min_dist = float("inf")
    closest_color = "Inconnu"
    for name, std_rgb in COLOR_NAMES.items():
        dist = distance.euclidean(rgb, std_rgb)
        if dist < min_dist:
            min_dist = dist
            closest_color = name
    return closest_color


def get_dominant_color_kmeans(image_obj, k=3):
    resized = image_obj.resize((100, 100))
    data = np.array(resized).reshape((-1, 3))
    data = data[~((data > 240).all(axis=1))]
    if len(data) == 0:
        return "Blanc"

    kmeans = KMeans(n_clusters=k, n_init=10)
    kmeans.fit(data)
    counts = Counter(kmeans.labels_)
    dominant_idx = counts.most_common(1)[0][0]
    dominant_rgb = kmeans.cluster_centers_[dominant_idx].astype(int)
    return get_color_name(dominant_rgb)


color = get_dominant_color_kmeans(image)

image_resnet = resnet_transform(image).unsqueeze(0).to(DEVICE)
image_clip = clip_preprocess(image).unsqueeze(0).to(DEVICE)

with torch.no_grad():
    output = resnet_model(image_resnet)
    _, predicted = torch.max(output, 1)
    itemtype = itemtype_classes[predicted.item()]


def predict_clip(prompt_list):
    text_tokens = clip.tokenize(prompt_list).to(DEVICE)
    with torch.no_grad():
        image_features = clip_model.encode_image(image_clip)
        text_features = clip_model.encode_text(text_tokens)
        logits = image_features @ text_features.T
        probs = logits.softmax(dim=-1).cpu().numpy()
    return prompt_list[np.argmax(probs)]


style = predict_clip(["Style decontracte", "Style chic", "Style sport", "Style professionnel"])
season = predict_clip(["Hiver", "Printemps", "Ete", "Automne"])
gender = predict_clip(["Vetement homme", "Vetement femme", "Unisexe"])
material = predict_clip(["Fabrique en coton", "Vetement en cuir", "En jeans", "Tissu synthetique", "Soie"])

result = {
    "ItemType": itemtype,
    "Color": color,
    "Style": style,
    "Season": season,
    "Gender": gender,
    "Material": material,
}

print("\nResultat prediction complete:")
for key, value in result.items():
    print(f"{key}: {value}")
