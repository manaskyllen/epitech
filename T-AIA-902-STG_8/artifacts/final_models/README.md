# Final Models

Ce dossier contient uniquement les modèles finaux retenus pour le rendu et la soutenance.

`outputs/` reste le dossier des runs expérimentaux, des manifests détaillés et des graphes intermédiaires. Il est ignoré par Git et n'est pas censé être versionné.

## Contenu

- `qlearning_best.npy`
- `double_qlearning_best_A.npy`
- `double_qlearning_best_B.npy`
- `metadata.json`

## Modèle recommandé

Pour Taxi-v3, `Q-Learning` est le meilleur choix pratique pour la soutenance:

- modèle simple à expliquer;
- coût de calcul faible;
- comportement stable sur un état discret;
- très bon compromis pour un projet Epitech.

`Double Q-Learning` reste une bonne variante de comparaison.

Les modèles présents ici proviennent de vrais runs complets:

- `qlearning_best` depuis `outputs/20260612_161504_qlearningagent_7597af`
- `double_qlearning_best` depuis `outputs/20260612_161516_doubleqlearningagent_fa1abf`

## Évaluer un modèle final

Lancer:

```bash
python3 app/main.py
```

Puis:

1. choisir le mode `Evaluation only`;
2. choisir l'agent;
3. sélectionner le modèle final dans la liste;
4. lancer l'évaluation.

Le mode `Evaluation only` sait lire les modèles présents dans `artifacts/final_models/`.

## Remarques

- Les modèles finaux doivent provenir d'un run réel enregistré dans `outputs/`.
- `metadata.json` référence le run source, les hyperparamètres et les métriques principales.
- `outputs/` reste ignoré par Git pour éviter de versionner tous les runs.
- Le modèle DQN n'a pas été retenu dans cette version finale car il n'apporte pas un meilleur compromis coût / robustesse pour la soutenance.
