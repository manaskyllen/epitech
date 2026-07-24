# Taxi Driver - T-AIA Epitech

Projet d'apprentissage par renforcement sur `Taxi-v3` de Gymnasium.

Objectif: comparer une baseline aléatoire, du `Q-Learning`, du `Double Q-Learning` et, en bonus, un `DQN` NumPy, puis retenir une solution simple, défendable et exploitable pour le rendu et la soutenance.

## Vue d'ensemble

Le taxi doit apprendre à:

- récupérer le passager;
- rejoindre la destination;
- minimiser le nombre de steps;
- maximiser la récompense moyenne.

Le projet fournit:

- une interface CLI interactive;
- un mode user pour régler les hyperparamètres manuellement;
- un mode benchmark / time-limited;
- un mode `evaluation only`;
- des sauvegardes structurées par run;
- des graphiques de training et de comparaison;
- des modèles finaux versionnés dans `artifacts/final_models/`.

## Workflow global

```text
User Mode / Benchmark
        ↓
Training
        ↓
Evaluation
        ↓
outputs/<run_id>
        ↓
Sélection du meilleur modèle
        ↓
artifacts/final_models/
```

## Algorithmes

- `BruteForceAgent`: baseline aléatoire de comparaison.
- `QLearningAgent`: solution tabulaire principale.
- `DoubleQLearningAgent`: variante tabulaire pour comparer le biais de maximisation.
- `DQNAgent` : implémentation expérimentale en NumPy, utilisée comme comparaison secondaire. Elle n’a pas été retenue comme solution finale.

### Q-Learning

Le Q-Learning est un algorithme d'apprentissage par renforcement sans modèle qui apprend une table `Q(s, a)` des valeurs d'actions.  
Il est bien adapté à `Taxi-v3` parce que l'espace d'états est discret et fini, ce qui rend une approche tabulaire simple, rapide et facile à interpréter.

Équation de mise à jour:

```text
Q(s,a) ← Q(s,a) + α [ r + γ max(Q(s',a')) − Q(s,a) ]
```

- `α` = taux d'apprentissage;
- `γ` = facteur de réduction;
- `r` = récompense reçue.

## Pourquoi Q-Learning ?

`Q-Learning` a été retenu parce que:

- `Double Q-Learning` a été testé;
- `DQN` a été expérimenté;
- `Q-Learning` obtient les meilleurs résultats sur le protocole retenu;
- il est plus simple à expliquer;
- il est plus rapide à entraîner;
- il est plus facile à interpréter.

## Résultats finaux

| Agent             | Mean Reward | Mean Steps | Success Rate | Training Time | Eval Time | Model Size | Peak Memory |
| ----------------- | ----------: | ---------: | -----------: | ------------: | --------: | ---------: | ----------: |
| Q-Learning        |        7.74 |      13.26 |        100 % |        1.90 s |  0.0195 s |   24 128 B |     98.7 MB |
| Double Q-Learning |        3.84 |      16.74 |         98 % |        4.10 s |  0.0409 s |   48 256 B |    105.3 MB |
| Brute Force       |     -765.22 |     196.39 |          5 % |       13.51 s |   0.268 s |        N/A |    101.2 MB |

Le Q-Learning obtient la meilleure récompense moyenne, le plus faible nombre d’étapes, un taux de réussite de 100 %, et le meilleur compromis entre performance, simplicité et coût de calcul.

## Structure du projet

```text
.
├── app/
│   ├── agents/
│   ├── benchmark/
│   ├── config/
│   ├── env/
│   ├── evaluation/
│   ├── training/
│   └── utils/
├── artifacts/
│   └── final_models/
├── outputs/
├── saved_models/            # compatibilité legacy, non prioritaire
├── Dockerfile
├── Makefile
├── requirements.txt
└── README.md
```

## Installation

```bash
make docker-build
```

## Lancement

L'interface principale se lance via:

```bash
make docker-run
```

En développement avec montage du projet local:

```bash
make dev
```

Puis choisir le mode souhaité dans l'interface.

## Benchmark

```bash
make benchmark-quick
make benchmark-final
make benchmark-final-dqn
```

Le benchmark sauvegarde ses résultats dans `outputs/` via le système de manifests du projet.

## Evaluation only

Lancer `make docker-run` ou `make dev`, puis choisir le mode `Evaluation only`.

Ce mode permet de charger un modèle déjà sauvegardé et de l'évaluer sans réentraînement.

## Hyperparamètres

### Tabulaire

- `alpha`
- `gamma`
- `epsilon`
- `epsilon_min`
- `epsilon_decay`

### DQN

- `alpha`
- `gamma`
- `epsilon`
- `epsilon_min`
- `epsilon_decay`
- `batch_size`
- `buffer_size`
- `target_update_freq`
- `hidden_sizes`

Les valeurs saisies sont vérifiées par les fonctions de validation du projet. Les valeurs aberrantes sont refusées ou signalées avec des warnings quand elles restent techniquement possibles mais mauvaises pour l'apprentissage.

## Données produites

Chaque run structuré crée un dossier:

```text
outputs/<timestamp>_<agent>_<short_uuid>/
├── manifest.json
├── model/
├── plots/
└── console.txt
```

Le `manifest.json` contient notamment:

- le `run_id`;
- le timestamp;
- le mode;
- l'agent;
- les épisodes;
- les hyperparamètres;
- les métriques d'entraînement;
- les métriques d'évaluation;
- les métriques hardware;
- les chemins relatifs vers les artefacts.

Les métriques principales suivies sont:

- récompense moyenne;
- nombre moyen de steps;
- success rate;
- temps moyen par épisode;
- temps d'entraînement;
- temps d'évaluation;
- taille du modèle;
- mémoire RSS approximative;
- temps CPU du processus.

## Graphiques

Les graphiques sont générés dans le dossier du run:

- `plots/*_rewards.png`
- `plots/*_steps.png`
- `plots/*_epsilon.png`
- `plots/comparison_*.png`
- `plots/benchmark_*.png`

Ils sont conçus pour fonctionner avec des runs courts ou longs.

## Modèles finaux versionnés

Les modèles finaux retenus sont conservés dans:

```text
artifacts/final_models/
```

Contenu actuel:

- `qlearning_best.npy`
- `double_qlearning_best_A.npy`
- `double_qlearning_best_B.npy`
- `metadata.json`
- `README.md`

Pour évaluer un modèle final:

1. lancer `make docker-run` ou `make dev`;
2. choisir `Evaluation only`;
3. choisir l'agent;
4. sélectionner l'entrée marquée `[final]`;
5. lancer l'évaluation.

Le fichier `metadata.json` relie chaque modèle final au run source dans `outputs/`.

## Environnement Gymnasium

Le projet utilise `Gymnasium` avec `Taxi-v3`.

Le wrapper local `app/env/taxi_env.py` encapsule l'environnement pour:

- uniformiser `reset` / `step` / `render`;
- simplifier le code de training et d'évaluation;
- préparer une extension custom si nécessaire plus tard.

Il n'y a pas, à ce stade, d'environnement Taxi totalement custom remplacé par une autre carte.

## Rapports et rendu

Le rapport attendu doit couvrir:

- le problème Taxi-v3;
- l'explication des états, actions et récompenses;
- le Q-Learning et sa mise à jour;
- le Double Q-Learning;
- la stratégie de benchmark;
- la comparaison des algorithmes;
- le coût de calcul;
- le choix final;
- les limites du projet;
- la conclusion.

Le rapport doit aussi s'appuyer sur:

- les manifests des runs;
- les graphes;
- les modèles finaux versionnés;
- les mesures de temps et de taille des modèles.

## Dépendances

Dépendances principales actuellement utilisées:

- `gymnasium[toy-text]`
- `numpy`
- `matplotlib`
- `pygame`

Il n'y a pas de framework deep learning externe pour le DQN actuel: l'implémentation est en NumPy.

## Fichiers utiles

- `app/main.py`
- `app/benchmark/benchmark.py`
- `app/training/trainer.py`
- `app/evaluation/evaluator.py`
- `app/utils/run_manager.py`
- `app/utils/plotting.py`
- `app/utils/input_validation.py`
- `app/utils/final_model_exporter.py`
- `app/config/config.py`
- `app/config/hyperparams.py`

## Commandes pratiques

- `make docker-build`
- `make docker-run`
- `make dev`
- `make benchmark-quick`
- `make benchmark-final`
- `make benchmark-final-dqn`

## Notes de versionnement

- `outputs/` reste ignoré par Git.
- `artifacts/final_models/` est versionné.
- Seuls les modèles finaux retenus doivent être conservés dans `artifacts/final_models/`.
