# Projet IA Vetements - Backend 

## Objectif
API FastAPI qui inspecte une image de vetement et retourne des attributs (ItemType, ItemSubtype, Color, Season, Gender, Material, etc.).

## Structure backend
```text
backend/
├── app/                         # Clean architecture (API, domaine, use-cases, infrastructure)
├── artifacts/
│   ├── encoders/
│   │   ├── encoders_multitask.pkl
│   │   └── itemtype_classes.pkl
│   └── models/
│       ├── model_multitask.pt
│       └── model_itemtype.pt
├── data/
│   ├── metadata/
│   │   └── colors.json
│   └── processed/
│       └── deepfashion_parsed.csv
├── scripts/
│   ├── data/
│   │   └── parse_deepfashion.py
│   ├── inference/
│   │   ├── predict_full.py
│   │   └── predict_itemtype.py
│   └── train/
│       └── train_itemtype.py
├── Dockerfile
├── docker-compose.yml
├── docker-entrypoint.sh
├── readme.md
└── requirements.txt
```

## Lancer l'API
Depuis `backend/`:
```bash
uvicorn app.main:app --reload
```

## Endpoint d'inspection
`POST /inspect`

Query params utiles:
- `force_analysis=true`: ignore la validation photo en amont et force l'analyse du vêtement.
- `debug=true`: retourne les prédictions brutes, les seuils utilisés et les détails de l'extraction couleur dans `data.Debug`.

Exemple:
```bash
curl -X POST "http://127.0.0.1:8000/inspect?debug=true" \
  -F "file=@/chemin/vers/image.jpg"
```

## Endpoint debug complet
`GET /debug/full`

Retourne un dump JSON avec:
- toutes les variables d'environnement du process
- les settings resolves par l'application
- les chemins et metadonnees des artefacts (modele, encodeurs, YOLO)
- les informations des modeles charges dans le pipeline

Exemple:
```bash
curl "http://127.0.0.1:8000/debug/full"
```

## Logs
L'API produit maintenant des logs JSON sur la sortie standard.

Chaque requête a un `request_id`:
- automatiquement généré si absent
- renvoyé dans le header de réponse `X-Request-ID`
- injecté dans tous les logs du pipeline

Variables utiles:
- `LOG_LEVEL` (defaut: `INFO`)

Exemple de log:
```json
{
  "ts": "2026-04-20T12:00:00+00:00",
  "level": "INFO",
  "logger": "app.api.routes.inspection",
  "request_id": "a1b2c3d4e5f6",
  "message": "inspection_request",
  "data": {
    "filename": "photo.jpg",
    "debug": true,
    "image_width": 1200,
    "image_height": 1600
  }
}
```

## Entrainement ItemType
Depuis `backend/`:
```bash
python scripts/train/train_itemtype.py
```

Variables utiles:
- `CSV_PATH` (defaut: `backend/data/processed/deepfashion_parsed.csv`)
- `MODEL_PATH` (defaut: `backend/artifacts/models/model_itemtype.pt`)
- `ENCODER_PATH` (defaut: `backend/artifacts/encoders/itemtype_classes.pkl`)

## Parsing DeepFashion
Depuis `backend/`:
```bash
python scripts/data/parse_deepfashion.py --dataset-root /chemin/vers/deepfashion
```

Sortie par defaut:
- `backend/data/processed/deepfashion_parsed.csv`

## Inference scripts
Depuis `backend/`:
```bash
python scripts/inference/predict_itemtype.py
python scripts/inference/predict_full.py
```

## Docker
Depuis `backend/`:
```bash
docker compose up --build
```
Le service expose l'API sur `http://localhost:8000`.

## Makefile
Depuis `backend/`:
```bash
make help
make api
make train-itemtype
make parse-deepfashion DATASET_ROOT=/chemin/vers/deepfashion
make predict-itemtype IMAGE_PATH=/chemin/vers/image.jpg
make predict-full IMAGE_PATH=/chemin/vers/image.jpg
make docker-up
```
