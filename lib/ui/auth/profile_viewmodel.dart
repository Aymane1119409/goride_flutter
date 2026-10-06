import '../../data/models/app_user.dart';
import '../../data/repositories/goride_exception.dart';
import '../../data/repositories/user_repository.dart';
import '../common/view_model.dart';

/// ViewModel del profilo (RF8.1). Stessa logica di `ProfileViewModel.kt`.
class ProfileViewModel extends ViewModel {
  ProfileViewModel(this._repository) {
    // Il profilo si carica alla creazione del ViewModel (come `init {}` in Kotlin).
    _caricaProfilo();
  }

  final UserRepository _repository;

  AppUser? _utente;
  bool _isLoading = false;
  String? _messaggio;
  bool _logoutEseguito = false;

  AppUser? get utente => _utente;
  bool get isLoading => _isLoading;
  String? get messaggio => _messaggio;
  bool get logoutEseguito => _logoutEseguito;

  Future<void> _caricaProfilo() async {
    _isLoading = true;
    notifyListeners();
    try {
      _utente = await _repository.getProfilo();
    } on GoRideException {
      _messaggio = 'Impossibile caricare il profilo';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> salvaModifiche({
    required String nome,
    required String cognome,
    required String telefono,
  }) async {
    final n = nome.trim();
    final c = cognome.trim();
    final t = telefono.trim();

    String? errore;
    if (n.isEmpty) {
      errore = 'Il nome non può essere vuoto';
    } else if (c.isEmpty) {
      errore = 'Il cognome non può essere vuoto';
    } else if (t.length < 8) {
      errore = 'Numero di telefono non valido';
    }
    if (errore != null) {
      _messaggio = errore;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _repository.aggiornaProfilo(nome: n, cognome: c, telefono: t);
      _messaggio = 'Profilo aggiornato';
      await _caricaProfilo();
    } on GoRideException catch (e) {
      _messaggio = e.messaggio;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _logoutEseguito = true;
    notifyListeners();
  }

  void messaggioMostrato() => _messaggio = null;

  void navigazioneCompletata() => _logoutEseguito = false;
}
