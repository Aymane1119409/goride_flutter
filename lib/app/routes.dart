/// Nomi delle rotte (Navigazione 1.0 – Named Routes, lezione 3.4).
/// Fanno la parte del `nav_graph.xml` + Safe Args della versione Kotlin.
class Routes {
  Routes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  /// Contenitore con la BottomNavigationBar (Mappa, Storico, Community, Profilo).
  static const String home = '/home';


  /// Argomento richiesto: `Ride`.
  static const String rideDetail = '/ride-detail';

  static const String newReview = '/new-review';
}
