import logging

import numpy as np
import torch
from PIL.Image import Image as PILImage
from torchvision import transforms

from app.core.settings import Settings
from app.domain.entities import InspectionResult
from app.infrastructure.ml.color_extractor import extract_colors
from app.infrastructure.ml.debug_tools import (
    SINGLE_LABEL_TASKS,
    check_model_output_sizes,
    load_bundle,
    validate_bundle_contract,
)
from app.infrastructure.ml.multitask_model import MultiHead

torch.set_grad_enabled(False)
logger = logging.getLogger(__name__)


class MultitaskClothingInspector:
    def __init__(self, settings: Settings):
        self._settings = settings
        self._device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self._bundle = load_bundle(self._settings.encoders_path)
        self._encoders = self._bundle["enc"]
        self._color_vocab = self._bundle["colors"]
        self._bundle_warnings = validate_bundle_contract(self._bundle)
        self._model = self._load_model()
        self._preprocess = transforms.Compose(
            [
                transforms.Resize((self._settings.image_size, self._settings.image_size)),
                transforms.ToTensor(),
                transforms.Normalize(
                    [0.485, 0.456, 0.406],
                    [0.229, 0.224, 0.225],
                ),
            ]
        )

    def _load_model(self) -> MultiHead:
        n_gender = max(len(self._encoders["gender"].classes_), 1)
        n_subtype = max(len(self._encoders["item_subtype"].classes_), 1)
        n_type = max(len(self._encoders["item_type"].classes_), 1)
        n_season = max(len(self._encoders["season"].classes_), 1)
        n_material = max(len(self._encoders["material"].classes_), 1)
        n_colors = len(self._color_vocab)

        model = MultiHead(
            n_gender=n_gender,
            n_subtype=n_subtype,
            n_type=n_type,
            n_season=n_season,
            n_material=n_material,
            n_colors=n_colors,
        )
        state = torch.load(self._settings.model_path, map_location="cpu")
        model.load_state_dict(state)
        model.eval().to(self._device)
        check_model_output_sizes(model, self._bundle)
        return model

    @staticmethod
    def _softmax_details(logits: torch.Tensor) -> tuple[float, int, float]:
        probabilities = torch.softmax(logits, dim=-1).squeeze(0)
        values, indices = torch.topk(probabilities, k=min(2, probabilities.numel()))
        confidence = float(values[0].item())
        second_conf = float(values[1].item()) if len(values) > 1 else 0.0
        return confidence, int(indices[0].item()), confidence - second_conf

    @staticmethod
    def _topk_rows(
        logits: torch.Tensor,
        labels: list[str],
        *,
        activation: str = "softmax",
        k: int = 3,
    ) -> list[dict[str, float | int | str]]:
        if activation == "softmax":
            probabilities = torch.softmax(logits, dim=-1).squeeze(0)
        else:
            probabilities = torch.sigmoid(logits).squeeze(0)

        values, indices = torch.topk(probabilities, k=min(k, probabilities.numel()))
        rows: list[dict[str, float | int | str]] = []
        for score, idx in zip(values.tolist(), indices.tolist()):
            rows.append(
                {
                    "idx": int(idx),
                    "label": labels[idx],
                    "prob": round(float(score), 4),
                    "logit": round(float(logits[0, idx]), 4),
                }
            )
        return rows

    @staticmethod
    def _idx_to_label(encoder, index: int) -> str | None:
        try:
            return encoder.classes_[index]
        except Exception:
            return None

    def _colors_from_logits(self, logits: torch.Tensor) -> list[str]:
        probabilities = torch.sigmoid(logits).squeeze(0).cpu().numpy()
        order = np.argsort(-probabilities)
        kept: list[str] = []

        for idx in order:
            if probabilities[idx] < self._settings.sigmoid_threshold:
                continue
            kept.append(self._color_vocab[idx])
            if len(kept) >= self._settings.max_colors:
                break

        if not kept and len(order) > 0:
            kept = [self._color_vocab[order[0]]]

        return kept

    def _should_keep(self, task: str, confidence: float, margin: float) -> bool:
        if task not in self._settings.enabled_attributes:
            return False
        confidence_threshold = self._settings.attribute_thresholds.get(task, 0.0)
        # Keep the prediction if either the confidence or the separation is acceptable.
        # The previous logic required both and suppressed too many useful differences.
        if (
            confidence < confidence_threshold
            and margin < self._settings.attribute_margin_threshold
        ):
            return False
        return True

    def inspect(
        self,
        image: PILImage,
        *,
        size: str | None = None,
        debug: bool = False,
    ) -> InspectionResult:
        batch = self._preprocess(image.convert("RGB")).unsqueeze(0).to(self._device)
        outputs = self._model(batch)
        warnings = list(self._bundle_warnings)
        confidences: dict[str, float] = {}
        margins: dict[str, float] = {}
        labels: dict[str, str | None] = {}
        suppressed_attributes: list[str] = []
        raw_predictions: dict[str, dict[str, object]] = {}

        for task in SINGLE_LABEL_TASKS:
            confidence, index, margin = self._softmax_details(outputs[task])
            confidences[task] = confidence
            margins[task] = margin
            label = self._idx_to_label(self._encoders[task], index)
            topk = self._topk_rows(outputs[task], list(self._encoders[task].classes_))
            raw_predictions[task] = {
                "predicted_index": index,
                "predicted_label": label,
                "confidence": round(confidence, 4),
                "margin": round(margin, 4),
                "topk": topk,
            }

            if self._should_keep(task, confidence, margin):
                labels[task] = label
            else:
                labels[task] = None
                suppressed_attributes.append(task)

        color_result = extract_colors(
            image=image,
            max_colors=self._settings.max_colors,
        )
        colors = color_result.colors
        color_source = color_result.source
        raw_predictions["colors"] = {
            "topk": self._topk_rows(
                outputs["colors"],
                list(self._color_vocab),
                activation="sigmoid",
            ),
            "extractor_colors": colors,
            "foreground_ratio": color_result.foreground_ratio,
            "source": color_source,
        }
        if "color" not in self._settings.enabled_attributes:
            colors = []
            color_source = "disabled"
            suppressed_attributes.append("color")
        elif self._settings.color_fallback_to_model and color_result.foreground_ratio < 0.05:
            colors = self._colors_from_logits(outputs["colors"])
            color_source = "model_fallback"
            warnings.append("Color extractor had low foreground ratio; fallback to model colors.")

        confidences["color_proxy"] = 1.0 if colors else 0.0
        margins["color_proxy"] = 1.0 if colors else 0.0
        debug_payload = None
        if debug:
            debug_payload = {
                "enabled_attributes": list(self._settings.enabled_attributes),
                "attribute_thresholds": {
                    key: round(value, 4)
                    for key, value in self._settings.attribute_thresholds.items()
                },
                "attribute_margin_threshold": round(
                    self._settings.attribute_margin_threshold,
                    4,
                ),
                "raw_predictions": raw_predictions,
                "color_extraction": {
                    "colors": color_result.colors,
                    "dominant_rgb": color_result.dominant_rgb,
                    "foreground_ratio": color_result.foreground_ratio,
                    "source": color_result.source,
                },
            }

        logger.info(
            "inspection_model_output",
            extra={
                "event_data": {
                    "kept": {task: value for task, value in labels.items() if value is not None},
                    "suppressed": suppressed_attributes,
                    "color_source": color_source,
                    "confidences": {
                        key: round(value, 4) for key, value in confidences.items()
                    },
                    "margins": {
                        key: round(value, 4) for key, value in margins.items()
                    },
                }
            },
        )
        if debug:
            logger.info(
                "inspection_raw_predictions",
                extra={"event_data": raw_predictions},
            )

        return InspectionResult(
            item_type=labels["item_type"],
            item_subtype=labels["item_subtype"],
            colors=colors,
            size=size,
            season=labels["season"],
            gender=labels["gender"],
            material=labels["material"],
            style=None,
            confidence=confidences.get("item_type", 0.0),
            confidences=confidences,
            margins=margins,
            suppressed_attributes=suppressed_attributes,
            warnings=warnings,
            color_source=color_source,
            debug=debug_payload,
        )
