import os
from pathlib import Path

import joblib
import pandas as pd
import torch
import torch.nn as nn
import torch.optim as optim
from PIL import Image
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from torch.utils.data import DataLoader, Dataset
from torchvision import models, transforms
from tqdm import tqdm

BASE_DIR = Path(__file__).resolve().parents[2]

CSV_PATH = Path(
    os.getenv("CSV_PATH", str(BASE_DIR / "data" / "processed" / "deepfashion_parsed.csv"))
)
MODEL_PATH = Path(
    os.getenv("MODEL_PATH", str(BASE_DIR / "artifacts" / "models" / "model_itemtype.pt"))
)
ENCODER_PATH = Path(
    os.getenv(
        "ENCODER_PATH", str(BASE_DIR / "artifacts" / "encoders" / "itemtype_classes.pkl")
    )
)
BATCH_SIZE = int(os.getenv("BATCH_SIZE", "32"))
NUM_EPOCHS = int(os.getenv("NUM_EPOCHS", "15"))
LEARNING_RATE = float(os.getenv("LEARNING_RATE", "1e-4"))
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Device utilise: {DEVICE}")


class DeepFashionDataset(Dataset):
    def __init__(self, csv_path: Path, transform=None):
        df = pd.read_csv(csv_path)
        df = df[df["image_path"].apply(os.path.exists)].reset_index(drop=True)
        self.df = df
        self.transform = transform
        self.label_encoder = LabelEncoder()
        self.df["ItemTypeEncoded"] = self.label_encoder.fit_transform(self.df["ItemType"])
        self.classes = self.label_encoder.classes_

    def __len__(self):
        return len(self.df)

    def __getitem__(self, idx):
        row = self.df.iloc[idx]
        image = Image.open(row["image_path"]).convert("RGB")
        if self.transform:
            image = self.transform(image)
        label = row["ItemTypeEncoded"]
        return image, label


transform = transforms.Compose(
    [
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ]
)

dataset = DeepFashionDataset(CSV_PATH, transform=transform)
train_idx, val_idx = train_test_split(
    range(len(dataset)), test_size=0.1, stratify=dataset.df["ItemTypeEncoded"]
)
train_dataset = torch.utils.data.Subset(dataset, train_idx)
val_dataset = torch.utils.data.Subset(dataset, val_idx)

train_loader = DataLoader(train_dataset, batch_size=BATCH_SIZE, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=BATCH_SIZE)

print(f"Images trouvees pour l'entrainement: {len(dataset)}")
print(f"Train: {len(train_dataset)}, Val: {len(val_dataset)}")

model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
model.fc = nn.Linear(model.fc.in_features, len(dataset.classes))
model = model.to(DEVICE)

criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=LEARNING_RATE)

for epoch in range(NUM_EPOCHS):
    model.train()
    total_loss, correct, total = 0.0, 0, 0
    for images, labels in tqdm(train_loader, desc=f"Epoch {epoch + 1}/{NUM_EPOCHS}"):
        images, labels = images.to(DEVICE), labels.to(DEVICE)
        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()

        total_loss += loss.item()
        _, preds = torch.max(outputs, 1)
        correct += (preds == labels).sum().item()
        total += labels.size(0)

    train_acc = 100 * correct / total

    model.eval()
    correct, total = 0, 0
    with torch.no_grad():
        for images, labels in val_loader:
            images, labels = images.to(DEVICE), labels.to(DEVICE)
            outputs = model(images)
            _, preds = torch.max(outputs, 1)
            correct += (preds == labels).sum().item()
            total += labels.size(0)

    val_acc = 100 * correct / total
    print(
        f"Epoch {epoch + 1}/{NUM_EPOCHS} | Loss: {total_loss:.4f} | "
        f"Train Acc: {train_acc:.2f}% | Val Acc: {val_acc:.2f}%"
    )

MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
ENCODER_PATH.parent.mkdir(parents=True, exist_ok=True)

torch.save(model, MODEL_PATH)
joblib.dump(dataset.classes.tolist(), ENCODER_PATH)

print(f"Modele sauvegarde dans: {MODEL_PATH}")
print(f"Classes ItemType sauvegardees dans: {ENCODER_PATH}")
print("Entrainement termine")
