# 🚀 Inspiria - Navigation Flutter avec GoRouter

Ce projet utilise [`go_router`](https://pub.dev/packages/go_router) pour gérer la navigation dans l'application Flutter.  
Il intègre une `BottomNavigationBar` c est le widget principale si vous voulez ajouter un icon une nouvelle page (écran)

---

## 📁 Structure de la navigation

### 🔁 `GoRouter`

- Les routes sont organisées via `GoRouter`.
- On utilise un `ShellRoute` pour envelopper toutes les pages qui doivent afficher une `BottomNavigationBar` .
- Les pages "hors navigation" (ex : login) sont définies en dehors de ce shell. et en dehors de l authentification 

---

## 🧭 Exemple de structure

```dart
GoRouter(
  initialLocation: SCREEN.HOME.path,
  routes: [
    // Pages sans bottom nav
    GoRoute(
      path: SCREEN.LOGIN.path,
      builder: (context, state) => const LoginScreen(),
    ),

    // Pages avec bottom nav
    ShellRoute(
      builder: (context, state, child) {
        return Bottomnavigationwidget(child: child);
      },
      routes: [
        GoRoute(
          path: SCREEN.HOME.path,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: SCREEN.TRAVEL.path,
          builder: (context, state) => const TravelScreen(),
        ),
        GoRoute(
          path: SCREEN.SETTINGS.path,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

## Pour rajouter une nouvelle page conforme au router 

- allez dans le dossier /routes

vous avez 2 fichiers main_router, router_enum 

main_router.dart → la définition de toutes les routes (les "chemins")

router_enum.dart → une liste de toutes les pages disponibles (comme un index)


3️⃣ Lier la page dans main_router.dart
Ensuite, dans le fichier main_router.dart, tu dois utiliser cet enum pour déclarer la page.

👉 Exemple (dans le ShellRoute ou GoRoute selon ton besoin) :

```
GoRoute(
  path: SCREEN.HOME.path,
  builder: (context, state) => const HomeScreen(),
), ```
⚠️ Assure-toi d’avoir bien créé la page HomeScreen avant de la déclarer ici.


Résultat:

sur toutes les autres pages si tu veux naviguer t'as juste à faire :

```
GoRouter.of(context).go(SCREEN.HOME.path);
```
