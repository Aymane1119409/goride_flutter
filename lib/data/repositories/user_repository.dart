import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'goride_exception.dart';

/// Repository dell'utente (RF7, RF7.1, RF8, RF8.1).
///
/// Unica classe che parla con Firebase Authentication e con la collezione `users`.
/// Stessi nomi di collezione e campi dell'app Kotlin: un account creato da
/// un'app funziona anche nell'altra.
///
/// In Kotlin servivano `suspendCancellableCoroutine` per trasformare le callback
/// di Firebase in codice sequenziale. In Dart non serve: le API FlutterFire
/// restituiscono già dei `Future`, e basta usare `await`.
class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String collezioneUsers = 'users';
  static const String _campoNome = 'nome';
  static const String _campoCognome = 'cognome';
  static const String _campoEmail = 'email';
  static const String _campoTelefono = 'telefono';
  static const String _campoDataRegistrazione = 'dataRegistrazione';

  /// true se c'è una sessione attiva: decide la schermata iniziale.
  /// Firebase conserva la sessione anche dopo la chiusura dell'app.
  bool get isLoggato => _auth.currentUser != null;

  String? get uidCorrente => _auth.currentUser?.uid;

  /// RF7 — login con email e password. Restituisce l'uid.
  Future<String> login(String email, String password) async {
    try {
      final risultato = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = risultato.user?.uid;
      if (uid == null) throw const GoRideException('Utente non valido');
      return uid;
    } on FirebaseAuthException catch (e) {
      throw GoRideException(_traduciErroreLogin(e.code));
    }
  }

  /// RF8 — registrazione: crea l'account in Authentication, poi salva il
  /// profilo in Firestore. La password resta SOLO in Authentication.
  Future<String> registra({
    required String nome,
    required String cognome,
    required String email,
    required String telefono,
    required String password,
  }) async {
    try {
      final risultato = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = risultato.user?.uid;
      if (uid == null) throw const GoRideException('Registrazione fallita');

      await _db.collection(collezioneUsers).doc(uid).set({
        _campoNome: nome,
        _campoCognome: cognome,
        _campoEmail: email,
        _campoTelefono: telefono,
        _campoDataRegistrazione: DateTime.now().millisecondsSinceEpoch,
      });
      return uid;
    } on FirebaseAuthException catch (e) {
      throw GoRideException(_traduciErroreRegistrazione(e.code));
    } on FirebaseException {
      throw const GoRideException('Registrazione non riuscita. Riprova.');
    }
  }

  /// RF7.1 — recupero password: la mail la manda Firebase.
  Future<void> inviaEmailRecupero(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      throw const GoRideException('Invio non riuscito. Riprova.');
    }
  }

  /// Profilo dell'utente loggato (RF8.1).
  Future<AppUser> getProfilo() async {
    final uid = uidCorrente;
    if (uid == null) throw const GoRideException('Nessun utente loggato');
    try {
      final documento = await _db.collection(collezioneUsers).doc(uid).get();
      final dati = documento.data();
      if (dati == null) throw const GoRideException('Profilo non trovato');
      return AppUser(
        uid: uid,
        nome: dati[_campoNome] as String? ?? '',
        cognome: dati[_campoCognome] as String? ?? '',
        email: dati[_campoEmail] as String? ?? '',
        telefono: dati[_campoTelefono] as String? ?? '',
        dataRegistrazione: (dati[_campoDataRegistrazione] as num?)?.toInt() ?? 0,
      );
    } on FirebaseException {
      throw const GoRideException('Impossibile caricare il profilo');
    }
  }

  /// RF8.1 — modifica dei dati anagrafici (non email né password).
  Future<void> aggiornaProfilo({
    required String nome,
    required String cognome,
    required String telefono,
  }) async {
    final uid = uidCorrente;
    if (uid == null) throw const GoRideException('Nessun utente loggato');
    try {
      await _db.collection(collezioneUsers).doc(uid).update({
        _campoNome: nome,
        _campoCognome: cognome,
        _campoTelefono: telefono,
      });
    } on FirebaseException {
      throw const GoRideException('Salvataggio non riuscito');
    }
  }

  Future<void> logout() => _auth.signOut();

  // Stessi messaggi dell'app Kotlin (LoginViewModel / RegisterViewModel),
  // ma basati sul codice d'errore invece che sul testo inglese.
  String _traduciErroreLogin(String codice) {
    switch (codice) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'invalid-email':
        return 'Email o password errate';
      case 'user-not-found':
        return 'Nessun account con questa email';
      case 'network-request-failed':
        return 'Nessuna connessione. Controlla la rete.';
      case 'too-many-requests':
        return 'Troppi tentativi. Riprova più tardi.';
      default:
        return 'Accesso non riuscito. Riprova.';
    }
  }

  String _traduciErroreRegistrazione(String codice) {
    switch (codice) {
      case 'email-already-in-use':
        return 'Esiste già un account con questa email';
      case 'invalid-email':
        return 'Email non valida';
      case 'network-request-failed':
        return 'Nessuna connessione. Controlla la rete.';
      default:
        return 'Registrazione non riuscita. Riprova.';
    }
  }
}
