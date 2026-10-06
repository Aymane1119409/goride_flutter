import 'dart:async';

import '../../data/models/ride.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../common/view_model.dart';

/// ViewModel dello storico (RF10). Stessa logica di `HistoryViewModel.kt`.
///
/// Due cose indipendenti:
///  - OSSERVA lo storico dal database locale (Stream) → la lista si aggiorna da sola
///  - SINCRONIZZA da Firestore → scrive nel database, e lo Stream emette
class HistoryViewModel extends ViewModel {
  HistoryViewModel(this._rideRepository, this._userRepository) {
    final uid = _userRepository.uidCorrente ?? '';
    _iscrizione = _rideRepository.osservaStorico(uid).listen((corse) {
      _corse = corse;
      notifyListeners();
    });
    sincronizza();
  }

  final RideRepository _rideRepository;
  final UserRepository _userRepository;
  StreamSubscription<List<Ride>>? _iscrizione;

  /// null finché il database non ha risposto la prima volta.
  List<Ride>? _corse;
  bool _isLoading = false;
  String? _errore;

  List<Ride>? get corse => _corse;
  bool get isLoading => _isLoading;
  String? get errore => _errore;

  Future<void> sincronizza() async {
    final uid = _userRepository.uidCorrente;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      await _rideRepository.sincronizzaDaFirestore(uid);
    } catch (_) {
      // Se abbiamo già delle corse in locale, l'errore di rete non disturba.
      if (_corse == null || _corse!.isEmpty) {
        _errore = 'Impossibile aggiornare lo storico';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void erroreMostrato() => _errore = null;

  @override
  void dispose() {
    _iscrizione?.cancel();
    super.dispose();
  }
}
