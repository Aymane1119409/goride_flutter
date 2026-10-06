import 'package:flutter/widgets.dart';

import '../data/repositories/review_repository.dart';
import '../data/repositories/ride_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/vehicle_repository.dart';
import '../ui/ride/ride_viewmodel.dart';

/// `InheritedWidget` in cima all'albero dei widget (lezione 3.3).
///
/// Mette a disposizione di TUTTE le schermate i repository e il RideViewModel,
/// senza doverli passare a mano da un costruttore all'altro:
///
/// ```dart
/// final scope = AppScope.of(context);
/// scope.userRepository...
/// ```
///
/// Il RideViewModel sta qui (e non dentro la schermata della corsa) perché deve
/// vivere quanto l'app: è l'equivalente di `by activityViewModels()` in Kotlin.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.vehicleRepository,
    required this.userRepository,
    required this.rideRepository,
    required this.reviewRepository,
    required this.rideViewModel,
    required super.child,
  });

  final VehicleRepository vehicleRepository;
  final UserRepository userRepository;
  final RideRepository rideRepository;
  final ReviewRepository reviewRepository;
  final RideViewModel rideViewModel;

  /// La funzione `of` richiesta dagli appunti.
  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope non trovato: deve stare sopra MaterialApp.');
    return scope!;
  }

  /// Le dipendenze vengono create una volta e non cambiano mai.
  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
