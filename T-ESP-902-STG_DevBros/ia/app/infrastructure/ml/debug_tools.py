from pathlib import Path

import joblib
import torch

SINGLE_LABEL_TASKS = (
    "gender",
    "item_subtype",
    "item_type",
    "season",
    "material",
)


def load_bundle(path: Path) -> dict[str, object]:
    bundle = joblib.load(path)
    if not isinstance(bundle, dict):
        raise TypeError("Encoder bundle must be a dict.")
    return bundle


def validate_bundle_contract(bundle: dict[str, object]) -> list[str]:
    warnings: list[str] = []

    encoders = bundle.get("enc")
    colors = bundle.get("colors")

    if not isinstance(encoders, dict):
        raise ValueError("Encoder bundle missing 'enc' mapping.")
    if not isinstance(colors, (list, tuple)) or not colors:
        raise ValueError("Encoder bundle missing non-empty 'colors' list.")

    for task in SINGLE_LABEL_TASKS:
        encoder = encoders.get(task)
        if encoder is None:
            raise ValueError(f"Encoder bundle missing '{task}' encoder.")
        if not hasattr(encoder, "classes_"):
            raise ValueError(f"Encoder '{task}' does not expose classes_.")
        if len(getattr(encoder, "classes_", [])) == 0:
            warnings.append(f"Encoder '{task}' has no classes.")

    return warnings


def check_model_output_sizes(model, bundle: dict[str, object]) -> None:
    encoders = bundle["enc"]
    color_vocab = bundle["colors"]
    expected_sizes = {
        "gender": len(encoders["gender"].classes_),
        "item_subtype": len(encoders["item_subtype"].classes_),
        "item_type": len(encoders["item_type"].classes_),
        "season": len(encoders["season"].classes_),
        "material": len(encoders["material"].classes_),
        "colors": len(color_vocab),
    }

    with torch.no_grad():
        sample = torch.zeros(1, 3, 224, 224)
        outputs = model(sample)

    for task, expected_size in expected_sizes.items():
        if task not in outputs:
            raise ValueError(f"Model output missing '{task}'.")
        actual_size = int(outputs[task].shape[-1])
        if actual_size != expected_size:
            raise ValueError(
                f"Model output size mismatch for '{task}': expected {expected_size}, got {actual_size}."
            )
