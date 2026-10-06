import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';
import 'goride_exception.dart';

/// Repository delle recensioni (RF12, RF13, RF14).
///
/// Usa il listener realtime di Firestore: `snapshots()` restituisce uno `Stream`
/// che emette una nuova lista ogni volta che QUALCUNO (anche dall'app Kotlin)
/// pubblica una recensione. È l'equivalente di `addSnapshotListener`.
class ReviewRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String collezioneReviews = 'reviews';
  static const int _limiteRecensioni = 100;

  static const String _campoUserId = 'userId';
  static const String _campoAutore = 'autoreNome';
  static const String _campoTipo = 'tipo';
  static const String _campoTesto = 'testo';
  static const String _campoTimestamp = 'timestamp';
  static const String _campoVehicleId = 'vehicleId';

  /// RF14 — ascolto realtime. Il listener resta attivo finché qualcuno è
  /// iscritto allo Stream: quando il ViewModel cancella l'iscrizione, Firestore
  /// smette di ascoltare (come `fermaAscolto()` in Kotlin).
  Stream<List<Review>> osservaRecensioni() {
    return _db
        .collection(collezioneReviews)
        .orderBy(_campoTimestamp, descending: true)
        .limit(_limiteRecensioni)
        .snapshots()
        .map((snapshot) {
      final recensioni = <Review>[];
      for (final doc in snapshot.docs) {
        try {
          final dati = doc.data();
          recensioni.add(Review(
            id: doc.id,
            userId: dati[_campoUserId] as String? ?? '',
            autoreNome: dati[_campoAutore] as String? ?? '',
            tipo: ReviewType.daCodice(dati[_campoTipo] as String?),
            testo: dati[_campoTesto] as String? ?? '',
            timestamp: (dati[_campoTimestamp] as num?)?.toInt() ?? 0,
            vehicleId: dati[_campoVehicleId] as String?,
          ));
        } catch (_) {
          // Un documento malformato non deve far sparire tutta la lista.
        }
      }
      return recensioni;
    });
  }

  /// RF13 — pubblica una recensione.
  Future<void> pubblicaRecensione({
    required String userId,
    required String autoreNome,
    required ReviewType tipo,
    required String testo,
    String? vehicleId,
  }) async {
    try {
      // doc() senza argomenti genera un id univoco (come UUID.randomUUID()).
      await _db.collection(collezioneReviews).doc().set({
        _campoUserId: userId,
        _campoAutore: autoreNome,
        _campoTipo: tipo.codice,
        _campoTesto: testo,
        _campoTimestamp: DateTime.now().millisecondsSinceEpoch,
        _campoVehicleId: vehicleId,
      });
    } on FirebaseException {
      throw const GoRideException('Pubblicazione non riuscita. Riprova.');
    }
  }
}
