#!/bin/bash

echo "🧹 Nettoyage..."
rm -rf coverage/
flutter clean
flutter pub get

echo "🧪 Génération du coverage..."
flutter test --coverage

echo "🔍 Extraction des dossiers avec > 50% de coverage..."
lcov --extract coverage/lcov.info \
    "lib/core/model/*" \
    "lib/core/response/*" \
    "lib/features/auth/logic/model/*" \
    "lib/features/auth/screen/password/*" \
    "lib/features/home/*" \
    "lib/features/launch/*" \
    "lib/features/suitcase/screen/*" \
    -o coverage/final.info --ignore-errors unused

echo "📊 Génération du rapport final..."
genhtml coverage/final.info -o coverage/html

open coverage/html/index.html