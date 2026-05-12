import random
import shutil
from pathlib import Path

# =========================
# CONFIG
# =========================
INPUT_ROOT = Path("backend/dataset_obsolete/dataset")
NEGATIVE_ROOT = Path("backend/dataset/images_negatives")
OUTPUT_ROOT = Path("dataset_yolo")

MAX_POSITIVE = 6000
MAX_NEGATIVE = 6000
TRAIN_RATIO = 0.8
RANDOM_SEED = 42

VALID_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}


# =========================
# HELPERS
# =========================
def is_valid_image_file(path: Path) -> bool:
    return path.is_file() and path.suffix.lower() in VALID_EXTENSIONS


def collect_positive_images(input_root: Path) -> list[Path]:
    return [p for p in input_root.rglob("*") if is_valid_image_file(p)]


def collect_negative_images(negative_root: Path) -> list[Path]:
    if not negative_root.exists():
        return []
    return [p for p in negative_root.rglob("*") if is_valid_image_file(p)]


def ensure_output_dirs(output_root: Path) -> None:
    if output_root.exists():
        shutil.rmtree(output_root)

    for split in ["train", "val"]:
        (output_root / "images" / split).mkdir(parents=True, exist_ok=True)
        (output_root / "labels" / split).mkdir(parents=True, exist_ok=True)


def build_positive_name(path: Path, input_root: Path, index: int) -> str:
    rel_parts = path.relative_to(input_root).parts
    safe_parts = [part.replace(" ", "_") for part in rel_parts[:-1]]
    stem = path.stem.replace(" ", "_")
    ext = path.suffix.lower()
    middle = "_".join(safe_parts) if safe_parts else "root"
    return f"pos_{index:06d}_{middle}_{stem}{ext}"


def build_negative_name(path: Path, negative_root: Path, index: int) -> str:
    rel_parts = path.relative_to(negative_root).parts
    safe_parts = [part.replace(" ", "_") for part in rel_parts[:-1]]
    stem = path.stem.replace(" ", "_")
    ext = path.suffix.lower()
    middle = "_".join(safe_parts) if safe_parts else "root"
    return f"neg_{index:06d}_{middle}_{stem}{ext}"


def write_positive_label(label_path: Path) -> None:
    label_path.write_text("0 0.5 0.5 1.0 1.0\n", encoding="utf-8")


def copy_positive_samples(
    samples: list[Path],
    input_root: Path,
    output_root: Path,
    split: str,
    start_index: int
) -> list[tuple[str, str, str, str, str]]:
    rows = []

    for i, src in enumerate(samples, start=start_index):
        new_name = build_positive_name(src, input_root, i)

        dst_img = output_root / "images" / split / new_name
        dst_lbl = output_root / "labels" / split / f"{Path(new_name).stem}.txt"

        shutil.copy2(src, dst_img)
        write_positive_label(dst_lbl)

        rows.append((str(src), str(dst_img), str(dst_lbl), split, "positive"))

    return rows


def copy_negative_samples(
    samples: list[Path],
    negative_root: Path,
    output_root: Path,
    split: str,
    start_index: int
) -> list[tuple[str, str, str, str, str]]:
    rows = []

    for i, src in enumerate(samples, start=start_index):
        new_name = build_negative_name(src, negative_root, i)

        dst_img = output_root / "images" / split / new_name
        shutil.copy2(src, dst_img)

        rows.append((str(src), str(dst_img), "", split, "negative"))

    return rows


def write_dataset_yaml(output_root: Path) -> None:
    content = f"""path: {output_root.resolve()}
train: images/train
val: images/val

names:
  0: clothing
"""
    (output_root / "dataset.yaml").write_text(content, encoding="utf-8")


def write_manifest(output_root: Path, rows: list[tuple[str, str, str, str, str]]) -> None:
    manifest_path = output_root / "manifest.csv"
    with manifest_path.open("w", encoding="utf-8") as f:
        f.write("source_path,output_image,output_label,split,type\n")
        for row in rows:
            f.write(",".join(row) + "\n")


def main() -> None:
    random.seed(RANDOM_SEED)

    if not INPUT_ROOT.exists():
        raise FileNotFoundError(f"Dossier introuvable : {INPUT_ROOT}")

    ensure_output_dirs(OUTPUT_ROOT)

    positive_images = collect_positive_images(INPUT_ROOT)
    negative_images = collect_negative_images(NEGATIVE_ROOT)

    if not positive_images:
        raise RuntimeError(
            f"Aucune image positive trouvée dans {INPUT_ROOT}. "
            f"Vérifie le chemin et les extensions supportées : {VALID_EXTENSIONS}"
        )

    random.shuffle(positive_images)
    random.shuffle(negative_images)

    positive_images = positive_images[:MAX_POSITIVE]
    negative_images = negative_images[:MAX_NEGATIVE]

    pos_train_count = int(len(positive_images) * TRAIN_RATIO)
    neg_train_count = int(len(negative_images) * TRAIN_RATIO)

    positive_train = positive_images[:pos_train_count]
    positive_val = positive_images[pos_train_count:]

    negative_train = negative_images[:neg_train_count]
    negative_val = negative_images[neg_train_count:]

    manifest_rows = []

    manifest_rows += copy_positive_samples(
        positive_train, INPUT_ROOT, OUTPUT_ROOT, "train", start_index=1
    )
    manifest_rows += copy_positive_samples(
        positive_val, INPUT_ROOT, OUTPUT_ROOT, "val", start_index=len(positive_train) + 1
    )

    if negative_images:
        manifest_rows += copy_negative_samples(
            negative_train, NEGATIVE_ROOT, OUTPUT_ROOT, "train", start_index=1
        )
        manifest_rows += copy_negative_samples(
            negative_val, NEGATIVE_ROOT, OUTPUT_ROOT, "val", start_index=len(negative_train) + 1
        )

    write_dataset_yaml(OUTPUT_ROOT)
    write_manifest(OUTPUT_ROOT, manifest_rows)

    print("✅ Dataset YOLO généré")
    print(f"📁 Sortie : {OUTPUT_ROOT.resolve()}")
    print(f"🟢 Positifs retenus : {len(positive_images)}")
    print(f"   - train : {len(positive_train)}")
    print(f"   - val   : {len(positive_val)}")
    print(f"🔴 Négatifs retenus : {len(negative_images)}")
    print(f"   - train : {len(negative_train)}")
    print(f"   - val   : {len(negative_val)}")
    print(f"📄 YAML : {(OUTPUT_ROOT / 'dataset.yaml').resolve()}")
    print(f"📄 Manifest : {(OUTPUT_ROOT / 'manifest.csv').resolve()}")

    if len(negative_images) < MAX_NEGATIVE:
        print(f"\n⚠️ Il manque des négatifs : {len(negative_images)}/{MAX_NEGATIVE}")
        print("Télécharge plus d'images dans backend/dataset/images_negatives.")


if __name__ == "__main__":
    main()