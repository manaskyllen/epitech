enum SCREEN {
  SUITCASE,
  LAUNCHPAGE,
  PRELOGIN,
  LOGIN,
  PROFILE,
  SETTINGS,
  PARAMETRE,
  REGISTER,
  TRAVEL,
  MYCHARACTER,
  HOMEPAGE,
  VALIDATEEMAIL,
  FORGOTPASSWORD,
  NEWPASSWORD,
  PASSWORDCHANGED,
  VALIDATERESETPASSWORD,
  OUTFIT,
  SCANNER,
  SCANNERSUCCESSFULL,
}

extension MainRouterExtension on SCREEN {
  String get path {
    switch (this) {
      case SCREEN.LAUNCHPAGE:
        return '/';
      case SCREEN.PRELOGIN:
        return '/prelogin';
      case SCREEN.LOGIN:
        return '/login';
      case SCREEN.HOMEPAGE:
        return '/homepage';
      case SCREEN.OUTFIT:
        return '/outfit';
      case SCREEN.PROFILE:
        return '/profile';
      case SCREEN.SETTINGS:
        return '/settings';
      case SCREEN.REGISTER:
        return '/register';
      case SCREEN.TRAVEL:
        return '/travel';
      case SCREEN.PARAMETRE:
        return '/products/:id'; // la c est juste pour montrer à quoi ressemble un Id
      case SCREEN.MYCHARACTER:
        return '/mycharacter';
      case SCREEN.VALIDATEEMAIL:
        return '/validateemail';
      case SCREEN.FORGOTPASSWORD:
        return '/forgotpassword';
      case SCREEN.NEWPASSWORD:
        return '/newpassword';
      case SCREEN.PASSWORDCHANGED:
        return '/passwordchanged';
      case SCREEN.VALIDATERESETPASSWORD:
        return '/validateresetpassword';
      case SCREEN.SCANNER:
        return '/scanner';
      case SCREEN.SCANNERSUCCESSFULL:
        return '/scannersuccessfull';
      case SCREEN.SUITCASE:
        return '/my-suitcases';
    }
  }
}
