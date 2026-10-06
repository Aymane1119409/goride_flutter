import '../../data/repositories/goride_exception.dart';
import '../../data/repositories/user_repository.dart';
import '../common/view_model.dart';

/// Validazione email condivisa dalle schermate di autenticazione
/// (al posto di `android.util.Patterns.EMAIL_ADDRESS`).
final RegExp formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// ViewModel del login (RF7). Stessa logica di `LoginViewModel.kt`.
class LoginViewModel extends ViewModel {
  LoginViewModel(this._repository);

  final UserRepository _repository;

  bool _isLoading = false;
  String? _errore;
  bool _loginRiuscito = false;

  // Campi privati + getter pubblici: dall'esterno lo stato si può solo LEGGERE
  // (come la coppia MutableLiveData privata / LiveData pubblica).
  bool get isLoading => _isLoading;
  String? get errore => _errore;
  bool get loginRiuscito => _loginRiuscito;

  Future<void> login(String email, String password) async {
    final emailInserita = email.trim();

    // Validazione lato client: niente chiamata di rete inutile.
    final erroreValidazione = emailInserita.isEmpty
        ? "Inserisci l'email"
        : !formatoEmail.hasMatch(emailInserita)
            ? 'Email non valida'
            : password.isEmpty
                ? 'Inserisci la password'
                : null;
    if (erroreValidazione != null) {
      _errore = erroreValidazione;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errore = null;
    notifyListeners();

    try {
      await _repository.login(emailInserita, password);
      _loginRiuscito = true;
    } on GoRideException catch (e) {
      _errore = e.messaggio;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// La schermata ha mostrato l'errore: lo "consumiamo" per non rimostrarlo.
  void erroreMostrato() => _errore = null;

  /// La schermata ha navigato: azzeriamo l'evento (anti-loop, come in Kotlin).
  void navigazioneCompletata() => _loginRiuscito = false;
}
