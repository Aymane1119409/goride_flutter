/// Profilo utente (RF8, RF8.1) — documento `users/{uid}` su Firestore.
///
/// In Kotlin si chiama `User`; qui `AppUser` per non scontrarsi con la classe
/// `User` del pacchetto firebase_auth.
/// La password NON compare qui: la gestisce solo Firebase Authentication.
class AppUser {
  final String uid;
  final String nome;
  final String cognome;
  final String email;
  final String telefono;
  final int dataRegistrazione;

  const AppUser({
    required this.uid,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.telefono,
    required this.dataRegistrazione,
  });

  String get nomeCompleto => '$nome $cognome';
}
