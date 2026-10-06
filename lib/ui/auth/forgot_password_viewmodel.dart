import '../../data/repositories/goride_exception.dart';
import '../../data/repositories/user_repository.dart';
import '../common/view_model.dart';
import 'login_viewmodel.dart' show formatoEmail;

/// ViewModel del recupero password (RF7.1).
class ForgotPasswordViewModel extends ViewModel {
  ForgotPasswordViewModel(this._repository);

  final UserRepository _repository;

  bool _isLoading = false;
  String? _messaggio;
  bool _emailInviata = false;

  bool get isLoading => _isLoading;
  String? get messaggio => _messaggio;
  bool get emailInviata => _emailInviata;

  Future<void> inviaEmail(String email) async {
    final indirizzo = email.trim();
    if (indirizzo.isEmpty || !formatoEmail.hasMatch(indirizzo)) {
      _messaggio = "Inserisci un'email valida";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _repository.inviaEmailRecupero(indirizzo);
      _messaggio = "Se l'email è registrata, riceverai il link di recupero";
      _emailInviata = true;
    } on GoRideException catch (e) {
      _messaggio = e.messaggio;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void messaggioMostrato() => _messaggio = null;
}
