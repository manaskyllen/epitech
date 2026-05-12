# Guide d'utilisation - Backend Inspiria

## 🚀 Installation et démarrage

### Configuration initiale
```bash
# Cloner le dépôt
git clone git@github.com:Inspiria-corp/backend.git

# Installer les dépendances
composer install

# Générer la clé d'application
php artisan key:generate

# Lancer les conteneurs Docker
docker-compose -f docker-compose.dev.yml up -d
```

## 🗄️ Gestion de la base de données

### Migrations
```bash
# Créer une migration
php artisan make:migration migration-name --table=users

# Appliquer les migrations
php artisan migrate

# Vérifier le statut des migrations
php artisan migrate:status

# Réinitialiser la base de données
php artisan migrate:fresh

# Réinitialiser et peupler la base
php artisan migrate:fresh --seed
```

### Génération de ressources
```bash
# Créer un modèle avec sa migration
php artisan make:model ModelName -m

# Créer une factory
php artisan make:factory NameFactory --model=Class

# Créer un seeder
php artisan make:seeder UserSeeder
```

### Peuplement de données
```bash
# Exécuter tous les seeders
php artisan db:seed

# Créer la base de données de test
php artisan create-db-test
```

## 🔧 Maintenance

### Documentation et cache
```bash
# Régénérer la documentation des routes (Scribe)
php artisan scribe:generate

# Rafraîchir le cache de configuration
php artisan config:cache
```

## 📁 Structure du projet
```
backend/
├── app/
│   ├── Console/           # Commandes Artisan personnalisées
│   ├── Exceptions/        # Gestion des exceptions et erreurs
│   ├── Http/
│   │   ├── Controllers/   # Logique métier des routes
│   │   ├── Middleware/    # Filtres de requêtes HTTP
│   │   └── Requests/      # Validation des données entrantes
│   ├── Models/            # Représentation des entités (ORM Eloquent)
│   ├── Policies/          # Gestion des autorisations
│   └── Providers/         # Configuration des services et dépendances
│
├── bootstrap/             # Initialisation du framework
│
├── config/                # Fichiers de configuration (app, db, mail, etc.)
│
├── database/
│   ├── factories/         # Génération de données factices (tests, seeds)
│   ├── migrations/        # Définitions des schémas de base de données
│   └── seeders/           # Peuplement initial de la base
│
├── public/                # Point d'entrée web (index.php)
│
├── resources/
│   ├── js/ & css/         # Fichiers front (si applicable)
│   ├── views/             # Templates Blade
│   └── lang/              # Fichiers de traduction
│
├── routes/
│   ├── api.php            # Définition des routes API
│   ├── web.php            # Routes web classiques
│   └── console.php        # Commandes Artisan personnalisées
│
├── storage/
│   ├── app/               # Fichiers générés localement
│   ├── framework/         # Cache, logs et sessions
│   └── logs/              # Logs applicatifs
│
├── tests/                 # Tests unitaires et fonctionnels
│
├── docker-compose.dev.yml # Configuration Docker de développement
│
└── composer.json          # Dépendances PHP du projet
```

## ✅ Bonnes pratiques

- **Après un `git pull`** : Toujours exécuter `composer install` si `composer.lock` a changé
- **Migrations destructives** : Ne jamais lancer `migrate:fresh` sur un environnement partagé sans coordination avec l'équipe
- **Données de test** : Utiliser les Seeders pour générer des données cohérentes et reproductibles
- **Documentation API** : Régénérer la documentation Scribe après toute modification des routes ou contrôleurs
- **Environnement** : Vérifier que le fichier `.env` contient toutes les variables nécessaires avant de démarrer le projet
- **Cache** : Rafraîchir le cache de configuration après modification des fichiers de config

## ⚠️ Points d'attention

- Les commandes `migrate:fresh` suppriment **toutes les données** de la base
- Toujours créer une sauvegarde avant des opérations destructives en production
- Les factories et seeders doivent rester cohérents avec les modèles et migrations
