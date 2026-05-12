from ultralytics import YOLO

IMAGE_PATH = "chemin/vers/ton/image.jpg"
MODEL_PATH = "runs/detect/clothing_validator2/weights/best.pt"

model = YOLO(MODEL_PATH)
results = model(IMAGE_PATH)

boxes = results[0].boxes

if len(boxes) == 0:
    print({
        "success": False,
        "error_code": "INVALID_CLOTHING_IMAGE",
        "message": "Aucun vêtement exploitable n'a été détecté sur la photo."
    })
else:
    confidence = float(boxes.conf.max())
    print({
        "success": True,
        "validation": {
            "clothing_detected": True,
            "confidence": confidence
        }
    })