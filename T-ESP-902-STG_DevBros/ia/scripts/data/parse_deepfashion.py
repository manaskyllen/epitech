import argparse
import os
import re
from pathlib import Path

import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[2]


def clean_subtype(raw: str) -> str:
    subtype = raw.replace("_", " ").replace("-", " ")
    subtype = re.sub(r"[^0-9A-Za-z ]+", "", subtype)
    return re.sub(r"\s+", " ", subtype).strip()


def robust_path(dataset_root: Path, image_rel: str) -> str:
    rel = image_rel.replace("\\", "/")
    tail = rel[4:] if rel.startswith("img/") else rel

    candidates = [
        dataset_root / "img" / tail,
        dataset_root / "img" / "img" / tail,
        dataset_root / tail,
        dataset_root / "img_highres" / tail,
    ]

    for candidate in candidates:
        normalized = candidate.resolve()
        if normalized.exists():
            return str(normalized)

    return str((dataset_root / "img" / "img" / tail).resolve())


def load_categories(cate_cloth_path: Path) -> list[str]:
    with cate_cloth_path.open("r", encoding="utf-8") as file:
        lines = file.readlines()[2:]
    return [line.strip().split()[0] for line in lines]


def build_csv(dataset_root: Path, out_path: Path, keep_missing: bool = True):
    anno_coarse = dataset_root / "Anno_coarse"
    eval_dir = dataset_root / "Eval"

    cate_img_path = anno_coarse / "list_category_img.txt"
    cate_cloth_path = anno_coarse / "list_category_cloth.txt"
    split_path = eval_dir / "list_eval_partition.txt"

    categories = load_categories(cate_cloth_path)

    df_cat = pd.read_csv(
        cate_img_path,
        sep=r"\s+",
        skiprows=2,
        names=["image_name", "category_id"],
        engine="python",
    )
    df_cat["ItemType"] = df_cat["category_id"].astype(int).apply(
        lambda value: categories[value - 1]
    )
    df_cat = df_cat.drop(columns=["category_id"])

    df_split = pd.read_csv(
        split_path,
        sep=r"\s+",
        skiprows=2,
        names=["image_name", "split"],
        engine="python",
    )

    df = df_cat.merge(df_split, on="image_name", how="inner")
    df["image_path"] = df["image_name"].apply(lambda path: robust_path(dataset_root, path))
    df["ItemSubtype"] = df["image_name"].apply(
        lambda path: clean_subtype(
            path.replace("\\", "/").split("/")[-2] if "/" in path else "Unknown"
        )
    )

    if not keep_missing:
        df = df[df["image_path"].apply(os.path.exists)].copy()

    df = df[["image_name", "ItemType", "split", "image_path", "ItemSubtype"]]

    out_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(out_path, index=False)
    print(f"Ecrit: {out_path} | lignes: {len(df)}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--dataset-root",
        default=os.getenv("DEEPFASHION_DIR", str(BASE_DIR / "dataset" / "deepfashion")),
    )
    parser.add_argument(
        "--out",
        default=str(BASE_DIR / "data" / "processed" / "deepfashion_parsed.csv"),
    )
    parser.add_argument(
        "--filter-existing",
        action="store_true",
        help="Filtrer les fichiers manquants (reduit le nombre de lignes).",
    )
    args = parser.parse_args()

    build_csv(
        dataset_root=Path(args.dataset_root),
        out_path=Path(args.out),
        keep_missing=not args.filter_existing,
    )
