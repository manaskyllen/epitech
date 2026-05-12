import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/routes/router_enum.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) async {
        if (value == 'profile') {
          context.go(SCREEN.PROFILE.path);
        } else if (value == 'logout') {
          await TokenStorage().deleteAllTokens();
          if (context.mounted) {
            context.go(SCREEN.LOGIN.path);
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.black, size: 20),
              SizedBox(width: 8),
              Text('Profil'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Déconnexion', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.black, size: 20),
        ),
      ),
    );
  }
}
