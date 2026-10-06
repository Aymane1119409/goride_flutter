import 'package:flutter/foundation.dart';

/// Base di tutti i ViewModel dell'app (pattern MVVM, slide "Architetture software").
///
/// Estende `ChangeNotifier`: quando lo stato cambia si chiama `notifyListeners()`
/// e le schermate che ascoltano si ridisegnano. È il ruolo di ViewModel + LiveData
/// nella versione Kotlin.
///
/// In più protegge da un errore classico: se l'utente chiude la schermata mentre
/// un `Future` è in corso, il ViewModel viene distrutto prima che il Future
/// finisca. Notificare dopo `dispose()` farebbe crashare l'app: qui lo ignoriamo.
abstract class ViewModel extends ChangeNotifier {
  bool _distrutto = false;

  bool get distrutto => _distrutto;

  @override
  void notifyListeners() {
    if (!_distrutto) super.notifyListeners();
  }

  @override
  void dispose() {
    _distrutto = true;
    super.dispose();
  }
}
