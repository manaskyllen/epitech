#!/bin/sh
set -e

mkdir -p storage/framework/views
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/logs
mkdir -p bootstrap/cache

# Garantir les droits d'ecriture pour PHP-FPM au runtime.
chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwX storage bootstrap/cache

# Si /var/www/html/public est un volume Docker, son contenu masque celui de
# l'image. On recopie donc les assets buildes du SHA courant avant de demarrer.
if [ -d /opt/inspiria-public ]; then
    mkdir -p public
    rm -rf public/build
    cp -a /opt/inspiria-public/. /var/www/html/public/
fi

# Générer la clé APP_KEY si manquante
if [ ! -f .env ] || ! grep -q "^APP_KEY=" .env; then
    php artisan key:generate --force
fi

# Purger et générer les caches Laravel
php artisan config:cache

# Regénérer les assets Filament si l'image a été build sans eux.
if [ ! -f public/css/filament/filament/app.css ] || [ ! -f public/js/filament/filament/app.js ]; then
    php artisan filament:assets --ansi
fi

# Exécuter les migrations automatiquement à chaque démarrage/deploiement.
if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    attempts=0
    max_attempts="${MIGRATION_MAX_ATTEMPTS:-12}"

    until php artisan migrate --force; do
        attempts=$((attempts + 1))

        if [ "$attempts" -ge "$max_attempts" ]; then
            echo "Database migrations failed after ${attempts} attempts." >&2
            exit 1
        fi

        echo "Migration attempt ${attempts}/${max_attempts} failed, retrying in 5 seconds..."
        sleep 5
    done
fi

php artisan route:cache
php artisan view:cache

if [ ! -f public/build/manifest.json ]; then
    echo "Missing Vite manifest: /var/www/html/public/build/manifest.json" >&2
    exit 1
fi

# Exécuter PHP-FPM
exec php-fpm
