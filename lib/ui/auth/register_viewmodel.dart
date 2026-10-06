import '../../data/repositories/goride_exception.dart';
import '../../data/repositories/user_repository.dart';
import '../common/view_model.dart';
import 'login_viewmodel.dart' show formatoEmail;

/// ViewModel della registrazione (RF8). Stessa logica di `RegisterViewModel.kt`.
class RegisterViewModel extends ViewModel {
  RegisterViewModel(this._repository);

  final UserRepository _repository;

  bool _isLoading = false;
  String? _errore;
  bool _registrazioneRiuscita = false;

  bool get isLoading => _isLoading;
  String? get errore => _errore;
  bool get registrazioneRiuscita => _registrazioneRiuscita;

  Future<void> registra({
    required String nome,
    required String cognome,
    required String email,
    required String telefono,
    required String password,
    required String confermaPassword,
  }) async {
    final n = nome.trim();
    final c = cognome.trim();
    final e = email.trim();
    final t = telefono.trim();

    final erroreValidazione = _valida(n, c, e, t, password, confermaPassword);
    if (erroreValidazione != null) {
      _errore = erroreValidazione;
      notifyListeners();
      return; // esce senza toccare la rete
    }

    _isLoading = true;
    _errore = null;
    notifyListeners();

    try {
      await _repository.registra(
        nome: n,
        cognome: c,
        email: e,
        telefono: t,
        password: password,
      );
      _registrazioneRiuscita = true;
    } on GoRideException catch (eccezione) {
      _errore = eccezione.messaggio;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _valida(
    String nome,
    String cognome,
    String email,
    String telefono,
    String password,
    String conferma,
  ) {
    if (nome.isEmpty) return 'Inserisci il nome';
    if (cognome.isEmpty) return 'Inserisci il cognome';
    if (email.isEmpty) return "Inserisci l'email";
    if (!formatoEmail.hasMatch(email)) return 'Email non valida';
    if (telefono.isEmpty) return 'Inserisci il telefono';
    if (telefono.length < 8) return 'Numero di telefono troppo corto';
    if (password.length < 6) return 'La password deve avere almeno 6 caratteri';
    if (password != conferma) return 'Le password non coincidono';
    return null;
  }

  void erroreMostrato() => _errore = null;

  void navigazioneCompletata() => _registrazioneRiuscita = false;
}
