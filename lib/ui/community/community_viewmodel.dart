import 'dart:async';

import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';
import '../common/view_model.dart';

/// ViewModel della community (RF12, RF14). Stessa logica di `CommunityViewModel.kt`:
/// inizia l'ascolto alla creazione, lo ferma quando viene distrutto.
class CommunityViewModel extends ViewModel {
  CommunityViewModel(ReviewRepository repository) {
    _iscrizione = repository.osservaRecensioni().listen(
      (recensioni) {
        _recensioni = recensioni;
        notifyListeners();
      },
      onError: (Object _) {
        // In caso di errore teniamo l'ultima lista ricevuta.
        _recensioni ??= const [];
        notifyListeners();
      },
    );
  }

  StreamSubscription<List<Review>>? _iscrizione;

  /// null finché Firestore non ha risposto la prima volta.
  List<Review>? _recensioni;

  List<Review>? get recensioni => _recensioni;

  /// Cancellare l'iscrizione rimuove il listener di Firestore: un listener
  /// "orfano" continuerebbe a consumare rete e quota.
  @override
  void dispose() {
    _iscrizione?.cancel();
    super.dispose();
  }
}
