import '../../data/models/review.dart';
import '../../data/repositories/goride_exception.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../common/view_model.dart';

/// ViewModel della nuova recensione (RF13). Stessa logica di `NewReviewViewModel.kt`.
class NewReviewViewModel extends ViewModel {
  NewReviewViewModel(this._reviewRepository, this._userRepository);

  final ReviewRepository _reviewRepository;
  final UserRepository _userRepository;

  static const int _lunghezzaMinima = 10;

  ReviewType _tipoSelezionato = ReviewType.opinione;
  bool _isLoading = false;
  String? _errore;
  bool _pubblicata = false;

  ReviewType get tipoSelezionato => _tipoSelezionato;
  bool get isLoading => _isLoading;
  String? get errore => _errore;
  bool get pubblicata => _pubblicata;

  void selezionaTipo(ReviewType tipo) {
    _tipoSelezionato = tipo;
    notifyListeners();
  }

  Future<void> pubblica(String testo) async {
    final contenuto = testo.trim();
    if (contenuto.isEmpty) {
      _errore = 'Scrivi qualcosa prima di pubblicare';
      notifyListeners();
      return;
    }
    if (contenuto.length < _lunghezzaMinima) {
      _errore = 'La recensione è troppo corta';
      notifyListeners();
      return;
    }

    final uid = _userRepository.uidCorrente;
    if (uid == null) {
      _errore = 'Devi essere autenticato per pubblicare';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      // Il nome dell'autore viene copiato nella recensione: niente JOIN su Firestore.
      String autore = 'Utente GoRide';
      try {
        autore = (await _userRepository.getProfilo()).nomeCompleto;
      } on GoRideException {
        // Se il profilo non si carica pubblichiamo comunque con un nome generico.
      }
      await _reviewRepository.pubblicaRecensione(
        userId: uid,
        autoreNome: autore,
        tipo: _tipoSelezionato,
        testo: contenuto,
      );
      _pubblicata = true;
    } on GoRideException catch (e) {
      _errore = e.messaggio;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void erroreMostrato() => _errore = null;

  void navigazioneCompletata() => _pubblicata = false;
}
