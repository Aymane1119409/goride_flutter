/// Errore "leggibile" che i Repository lanciano verso le schermate.
///
/// Le schermate non devono mai vedere tipi di Firebase (FirebaseAuthException,
/// FirebaseException...): il Repository li traduce in questo errore con un
/// messaggio in italiano pronto da mostrare all'utente.
class GoRideException implements Exception {
  const GoRideException(this.messaggio);

  final String messaggio;

  @override
  String toString() => messaggio;
}
