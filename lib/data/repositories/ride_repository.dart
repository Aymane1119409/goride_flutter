import 'package:cloud_firestore/cloud_firestore.dart';

import '../local/ride_dao.dart';
import '../models/ride.dart';

/// Repository delle corse (RF9, RF10). Due sorgenti che lavorano insieme:
///  - Firestore è la fonte remota (collezione `rides`)
///  - SQLite è la cache locale, così lo storico si vede anche offline
///
/// Lo storico mostrato all'utente viene sempre letto dal database locale.
class RideRepository {
  RideRepository({RideDao? rideDao}) : _rideDao = rideDao ?? RideDao();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RideDao _rideDao;

  static const String collezioneRides = 'rides';
  static const String _campoUserId = 'userId';
  static const String _campoStart = 'startTimestamp';

  /// RF9 — corse dell'utente lette dal database locale, dalla più recente.
  Future<List<Ride>> getStorico(String userId) => _rideDao.getCorseUtente(userId);

  /// Scarica le corse da Firestore e aggiorna la cache locale.
  Future<void> sincronizzaDaFirestore(String userId) async {
    final snapshot = await _db
        .collection(collezioneRides)
        .where(_campoUserId, isEqualTo: userId)
        .orderBy(_campoStart, descending: true)
        .get();

    final corse = <Ride>[];
    for (final documento in snapshot.docs) {
      try {
        corse.add(Ride.fromMap(documento.id, documento.data()));
      } catch (_) {
        // Un documento malformato non deve far fallire tutta la sincronizzazione.
      }
    }
    await _rideDao.inserisciTutte(corse);
  }

  /// Salva un noleggio. Prima il database locale, poi Firestore:
  /// la corsa compare nello storico anche se la rete è lenta o assente.
  Future<void> salvaCorsa(Ride ride) async {
    await _rideDao.inserisci(ride);
    try {
      await _db.collection(collezioneRides).doc(ride.id).set({
        'userId': ride.userId,
        'vehicleId': ride.vehicleId,
        'vehicleNome': ride.vehicleNome,
        'vehicleTipo': ride.vehicleTipo.codice,
        'startTimestamp': ride.startTimestamp,
        'endTimestamp': ride.endTimestamp,
        'minutiPrepagati': ride.minutiPrepagati,
        'tariffaSbloccoEuro': ride.tariffaSbloccoEuro,
        'tariffaAlMinutoEuro': ride.tariffaAlMinutoEuro,
        'costoTotaleEuro': ride.costoTotaleEuro,
      });
    } on FirebaseException {
      // La corsa è comunque salvata in locale.
    }
  }
}
