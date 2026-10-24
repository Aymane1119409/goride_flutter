import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../local/active_ride_dao.dart';
import '../local/ride_dao.dart';
import '../models/active_ride.dart';
import '../models/ride.dart';
import '../models/vehicle.dart';

/// Repository delle corse (RF10, RF11). Due sorgenti che lavorano insieme:
///  - Firestore è la fonte di verità remota (collezione `rides`)
///  - SQLite è la cache locale, così lo storico si vede anche offline
///
/// La UI osserva SEMPRE il database locale: pattern "single source of truth".
class RideRepository {
  RideRepository({RideDao? rideDao, ActiveRideDao? activeRideDao})
      : _rideDao = rideDao ?? RideDao(),
        _activeRideDao = activeRideDao ?? ActiveRideDao();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final RideDao _rideDao;
  final ActiveRideDao _activeRideDao;

  static const String collezioneRides = 'rides';
  static const String _campoUserId = 'userId';
  static const String _campoStart = 'startTimestamp';

  /// "Campanello" che suona ogni volta che la tabella `corse` cambia.
  /// In Room la LiveData del DAO si aggiornava da sola; sqflite non lo fa,
  /// quindi avvisiamo noi gli ascoltatori dopo ogni scrittura.
  final StreamController<void> _corseCambiate = StreamController<void>.broadcast();

  /// RF10 — storico OSSERVABILE (Stream, lezione 3.5).
  /// Emette subito la lista attuale, poi una lista nuova a ogni modifica.
  Stream<List<Ride>> osservaStorico(String userId) {
    late final StreamController<List<Ride>> controller;
    StreamSubscription<void>? iscrizione;

    Future<void> emetti() async {
      final corse = await _rideDao.getCorseUtente(userId);
      if (!controller.isClosed) controller.add(corse);
    }

    controller = StreamController<List<Ride>>(
      onListen: () {
        iscrizione = _corseCambiate.stream.listen((_) => emetti());
        emetti();
      },
      onCancel: () => iscrizione?.cancel(),
    );
    return controller.stream;
  }

  /// Scarica le corse da Firestore e aggiorna la cache locale.
  /// Non consegna i dati a nessuno: li deposita nel database, e chi osserva
  /// lo storico riceve automaticamente la lista aggiornata.
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
    _corseCambiate.add(null);
  }

  /// Salva una corsa conclusa. Prima il database locale, poi Firestore:
  /// la corsa compare subito nello storico anche se la rete è lenta o assente.
  Future<void> salvaCorsa(Ride ride) async {
    await _rideDao.inserisci(ride);
    _corseCambiate.add(null);

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

  Future<Ride?> getCorsaById(String id) => _rideDao.getCorsaById(id);

  /// true se nel database locale ci sono già corse dell'utente.
  /// Serve allo storico per decidere se mostrare l'errore di sincronizzazione.
  Future<bool> haCorseLocali(String userId) async {
    final corse = await _rideDao.getCorseUtente(userId);
    return corse.isNotEmpty;
  }

  // ---------- Corsa attiva: ripristino se Android chiude l'app ----------

  Future<void> salvaCorsaAttiva({
    required Vehicle vehicle,
    required int startTimestamp,
    required int scadenzaTimestamp,
    required int minutiPrepagati,
  }) {
    return _activeRideDao.salva(
      ActiveRide(
        vehicleId: vehicle.id,
        vehicleNome: vehicle.nome,
        vehicleTipo: vehicle.tipo.codice,
        startTimestamp: startTimestamp,
        scadenzaTimestamp: scadenzaTimestamp,
        minutiPrepagati: minutiPrepagati,
        tariffaSbloccoEuro: vehicle.tariffaSbloccoEuro,
        tariffaAlMinutoEuro: vehicle.tariffaAlMinutoEuro,
      ),
    );
  }

  Future<ActiveRide?> getCorsaAttiva() => _activeRideDao.getCorsaAttiva();

  Future<void> cancellaCorsaAttiva() => _activeRideDao.cancella();

  void dispose() => _corseCambiate.close();
}
