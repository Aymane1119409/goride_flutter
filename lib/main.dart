import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app_scope.dart';
import 'app/routes.dart';
import 'app/tema.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/ride_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/vehicle_repository.dart';
import 'firebase_options.dart';
import 'ui/auth/forgot_password_screen.dart';
import 'ui/auth/login_screen.dart';
import 'ui/auth/register_screen.dart';
import 'ui/community/new_review_screen.dart';
import 'ui/history/ride_detail_screen.dart';
import 'ui/home/home_shell.dart';

Future<void> main() async {
  // Serve prima di usare plugin nativi (Firebase) prima di runApp.
  WidgetsFlutterBinding.ensureInitialized();
  // Stesso progetto Firebase dell'app Kotlin (go-ride-a24f7):
  // utenti, corse e recensioni sono condivisi tra le due app.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GoRideApp());
}

/// Widget radice. È Stateful perché crea UNA volta i repository e li tiene
/// in vita per tutta la durata dell'app.
class GoRideApp extends StatefulWidget {
  const GoRideApp({super.key});

  @override
  State<GoRideApp> createState() => _GoRideAppState();
}

class _GoRideAppState extends State<GoRideApp> {
  // Le dipendenze vanno solo "in giù": schermate → Repository → dati.
  final _vehicleRepository = VehicleRepository();
  final _userRepository = UserRepository();
  final _rideRepository = RideRepository();
  final _reviewRepository = ReviewRepository();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      vehicleRepository: _vehicleRepository,
      userRepository: _userRepository,
      rideRepository: _rideRepository,
      reviewRepository: _reviewRepository,
      child: MaterialApp(
        title: 'GoRide',
        debugShowCheckedModeBanner: false,
        theme: creaTema(),
        // Con `initialRoute` NON si usa `home` (nota della lezione 3.4).
        // Se c'è già una sessione Firebase, si va diritti alla mappa.
        initialRoute: _userRepository.isLoggato ? Routes.home : Routes.login,
        routes: {
          Routes.login: (context) => const LoginScreen(),
          Routes.register: (context) => const RegisterScreen(),
          Routes.forgotPassword: (context) => const ForgotPasswordScreen(),
          Routes.home: (context) => const HomeShell(),
          Routes.rideDetail: (context) => const RideDetailScreen(),
          Routes.newReview: (context) => const NewReviewScreen(),
        },
      ),
    );
  }
}
