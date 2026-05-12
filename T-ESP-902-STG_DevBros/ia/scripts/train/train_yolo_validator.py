from ultralytics import YOLO

def main():
    model = YOLO("yolov8n.pt")

    model.train(
        data="dataset_yolo/dataset.yaml",
        epochs=10,
        imgsz=640,
        batch=16,
        project="runs",
        name="clothing_validator"
    )

if __name__ == "__main__":
    main()