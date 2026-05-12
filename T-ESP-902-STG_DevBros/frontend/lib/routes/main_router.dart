import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/core/api/token_storage.dart';
import 'package:inspiria/core/model/suitcase_model.dart';
import 'package:inspiria/features/auth/data/auth_service.dart';
import 'package:inspiria/features/auth/screen/login_screen.dart';
import 'package:inspiria/features/auth/screen/password/forgot_password.dart';
import 'package:inspiria/features/auth/screen/password/new_password.dart';
import 'package:inspiria/features/auth/screen/password/password_changed.dart';
import 'package:inspiria/features/auth/screen/pre_login_screen.dart';
import 'package:inspiria/features/auth/screen/register_screen.dart';
import 'package:inspiria/features/auth/screen/validate_email/validate_email_screen.dart';
import 'package:inspiria/features/auth/screen/validate_email/validate_password_reset_screen.dart';
import 'package:inspiria/features/character/my_character_screen.dart';
import 'package:inspiria/features/home/home_screen.dart';
import 'package:inspiria/features/home/widgets/bottom_navigation_widget.dart';
import 'package:inspiria/features/launch/data/first_launch_service.dart';
import 'package:inspiria/features/launch/launch_page_screen.dart';
import 'package:inspiria/features/outfit/screen/outfit_screen.dart';
import 'package:inspiria/features/scanner/screen/scanner_screen.dart';
import 'package:inspiria/features/scanner/screen/scanner_successfull.dart';
import 'package:inspiria/features/suitcase/screen/my_suitcases_screen.dart';
import 'package:inspiria/features/suitcase/screen/suitcase_detail_screen.dart';
import 'package:inspiria/features/suitcase/screen/suitcase_result_screen.dart';
import 'package:inspiria/features/suitcase/screen/suitcase_screen.dart';
import 'package:inspiria/routes/router_enum.dart';

final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter setupRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: SCREEN.LAUNCHPAGE.path,
    routes: [
      GoRoute(
        path: SCREEN.LAUNCHPAGE.path,
        name: SCREEN.LAUNCHPAGE.name,
        builder: (context, state) => const LaunchPageScreen(),
      ),
      GoRoute(
        path: SCREEN.LOGIN.path,
        name: SCREEN.LOGIN.name,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SCREEN.PRELOGIN.path,
        name: SCREEN.PRELOGIN.name,
        builder: (context, state) => const PreloginScreen(),
      ),
      GoRoute(
        path: SCREEN.REGISTER.path,
        name: SCREEN.REGISTER.name,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: SCREEN.VALIDATEEMAIL.path,
        name: SCREEN.VALIDATEEMAIL.name,
        builder: (context, state) => ValidateEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: SCREEN.FORGOTPASSWORD.path,
        name: SCREEN.FORGOTPASSWORD.name,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: SCREEN.NEWPASSWORD.path,
        name: SCREEN.NEWPASSWORD.name,
        builder: (context, state) => NewPasswordScreen(
          email: state.uri.queryParameters['email'] ?? '',
          otp: state.uri.queryParameters['otp'] ?? '',
        ),
      ),
      GoRoute(
        path: SCREEN.PASSWORDCHANGED.path,
        name: SCREEN.PASSWORDCHANGED.name,
        builder: (context, state) => const PasswordChangedScreen(),
      ),
      GoRoute(
        path: SCREEN.VALIDATERESETPASSWORD.path,
        name: SCREEN.VALIDATERESETPASSWORD.name,
        builder: (context, state) => ValidateResetPasswordScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return BottomNavigationWidget(child: child);
        },
        routes: [
          GoRoute(
            path: '/my-suitcases',
            name: 'MY_SUITCASES',
            builder: (context, state) => const MySuitcasesScreen(),
          ),
          GoRoute(
            path: '/suitcase-detail',
            name: 'SUITCASE_DETAIL',
            pageBuilder: (context, state) {
              final suitcase = state.extra as SuitcaseModel;
              return NoTransitionPage(
                child: SuitcaseDetailScreen(suitcase: suitcase),
              );
            },
          ),
          GoRoute(
            path: SCREEN.TRAVEL.path,
            name: SCREEN.TRAVEL.name,
            builder: (context, state) => const SuitcaseScreen(),
          ),
          GoRoute(
            path: SCREEN.SETTINGS.path,
            name: SCREEN.SETTINGS.name,
            builder: (context, state) => const LaunchPageScreen(),
          ),
          GoRoute(
            path: SCREEN.MYCHARACTER.path,
            name: SCREEN.MYCHARACTER.name,
            builder: (context, state) => const MyCharacterScreen(),
          ),
          GoRoute(
            path: SCREEN.HOMEPAGE.path,
            name: SCREEN.HOMEPAGE.name,
            builder: (context, state) => const HomePageScreen(),
          ),
          GoRoute(
            path: '/resultat-test',
            name: 'RESULTAT_TEST',
            pageBuilder: (context, state) {
              final Map<String, dynamic> data =
                  (state.extra as Map<String, dynamic>?) ?? {};
              return NoTransitionPage(
                child: SuitcaseResultScreen(resultData: data),
              );
            },
          ),
          GoRoute(
            path: SCREEN.OUTFIT.path,
            name: SCREEN.OUTFIT.name,
            builder: (context, state) => const OutfitScreen(),
          ),
          GoRoute(
            path: SCREEN.SCANNER.path,
            name: SCREEN.SCANNER.name,
            builder: (context, state) => const ScannerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: SCREEN.SCANNERSUCCESSFULL.path,
        name: SCREEN.SCANNERSUCCESSFULL.name,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return ScannerSuccessfull(data: data);
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final currentPath = state.uri.path;
      final isFirstLaunch = await FirstLaunchService.isFirstLaunch();
      
      // Vérifier s'il y a un token stocké pour savoir si l'utilisateur est connecté
      final token = await TokenStorage().getAccessToken();
      final isUserLoggedIn = token != null && token.isNotEmpty && await AuthService.me() == 200;
      
      final isLoggingIn = currentPath == SCREEN.PRELOGIN.path;
      final isRegistering = currentPath == SCREEN.REGISTER.path;

      if (isFirstLaunch && currentPath != SCREEN.LAUNCHPAGE.path) {
        return SCREEN.LAUNCHPAGE.path;
      }
      
      if (!isFirstLaunch && currentPath == SCREEN.LAUNCHPAGE.path) {
        // Après le premier lancement, aller sur le prelogin
        return SCREEN.PRELOGIN.path;
      }

      if (isUserLoggedIn && (isLoggingIn || isRegistering)) {
        // Si déjà connecté mais essaie d'aller sur login/register, aller à home
        return SCREEN.HOMEPAGE.path;
      }

      // Toutes les autres routes sont accessibles (y compris homepage en tant que guest)
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(child: Text('Page non trouvée: ${state.error}')),
    ),
  );
}