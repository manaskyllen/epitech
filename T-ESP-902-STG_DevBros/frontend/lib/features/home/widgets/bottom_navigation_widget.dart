import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/routes/router_enum.dart';

class BottomNavigationWidget extends StatelessWidget {
  const BottomNavigationWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;

    if (location == SCREEN.HOMEPAGE.path) {
      currentIndex = 0;
    } else if (location.startsWith(SCREEN.TRAVEL.path) ||
        location.startsWith(SCREEN.SUITCASE.path)) {
      currentIndex = 1;
    } else if (location.startsWith(SCREEN.SCANNER.path) ||
        location.startsWith('/resultat-test')) {
      currentIndex = 2;
    } else if (location.startsWith(SCREEN.OUTFIT.path)) {
      currentIndex = 3;
    } else if (location.startsWith(SCREEN.MYCHARACTER.path)) {
      currentIndex = 4;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF1F1B1B),
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,

            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home, currentIndex == 0),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.luggage, currentIndex == 1),
                label: 'Travel',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(
                  Icons.add_circle_outline_rounded,
                  currentIndex == 2,
                ),
                label: 'Ajouter',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.checkroom, currentIndex == 3),
                label: 'Outfits',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person, currentIndex == 4),
                label: 'Profil',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  GoRouter.of(context).go(SCREEN.HOMEPAGE.path);
                  break;
                case 1:
                  GoRouter.of(context).go(SCREEN.TRAVEL.path);
                  break;
                case 2:
                  GoRouter.of(context).go(SCREEN.SCANNER.path);
                  break;
                case 3:
                  GoRouter.of(context).go(SCREEN.OUTFIT.path);
                  break;
                case 4:
                  GoRouter.of(context).go(SCREEN.MYCHARACTER.path);
                  break;
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData iconData, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: Colors.white),
        const SizedBox(height: 4),
        if (isSelected)
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
