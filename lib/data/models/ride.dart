import 'vehicle.dart';

/// Una corsa, in corso o conclusa (RF10, RF11).
/// `endTimestamp` resta null finché la corsa è attiva.
class Ride {
  final String id;
  final String userId;
  final String vehicleId;
  final String vehicleNome;
  final VehicleType vehicleTipo;
  final int startTimestamp;
  final int? endTimestamp;
  final int minutiPrepagati;
  final double tariffaSbloccoEuro;
  final double tariffaAlMinutoEuro;
  final double costoTotaleEuro;

  const Ride({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.vehicleNome,
    required this.vehicleTipo,
    required this.startTimestamp,
    required this.endTimestamp,
    required this.minutiPrepagati,
    required this.tariffaSbloccoEuro,
    required this.tariffaAlMinutoEuro,
    required this.costoTotaleEuro,
  });

  bool get isAttiva => endTimestamp == null;

  /// Valore derivato, non salvato: non può disallinearsi da start/end.
  int get durataSecondi {
    final fine = endTimestamp;
    return fine != null ? (fine - startTimestamp) ~/ 1000 : 0;
  }

  /// Riga della tabella SQLite `corse` (stesse colonne della RideEntity di Room).
  /// È il formato che `sqflite` vuole per `db.insert` (lezione 3.5, `Dog.toMap()`).
  Map<String, Object?> toMap() => {
        'id': id,
        'userId': userId,
        'vehicleId': vehicleId,
        'vehicleNome': vehicleNome,
        'vehicleTipo': vehicleTipo.codice,
        'startTimestamp': startTimestamp,
        'endTimestamp': endTimestamp,
        'minutiPrepagati': minutiPrepagati,
        'tariffaSbloccoEuro': tariffaSbloccoEuro,
        'tariffaAlMinutoEuro': tariffaAlMinutoEuro,
        'costoTotaleEuro': costoTotaleEuro,
      };

  /// Funziona sia con le righe di SQLite sia con i documenti di Firestore,
  /// perché i nomi dei campi sono gli stessi. Ogni campo ha un ripiego:
  /// un dato malformato non deve far crashare l'app.
  factory Ride.fromMap(String id, Map<String, Object?> map) {
    return Ride(
      id: id,
      userId: map['userId'] as String? ?? '',
      vehicleId: map['vehicleId'] as String? ?? '',
      vehicleNome: map['vehicleNome'] as String? ?? '',
      vehicleTipo: VehicleType.daCodice(map['vehicleTipo'] as String?),
      startTimestamp: (map['startTimestamp'] as num?)?.toInt() ?? 0,
      endTimestamp: (map['endTimestamp'] as num?)?.toInt(),
      minutiPrepagati: (map['minutiPrepagati'] as num?)?.toInt() ?? 0,
      tariffaSbloccoEuro: (map['tariffaSbloccoEuro'] as num?)?.toDouble() ?? 0,
      tariffaAlMinutoEuro: (map['tariffaAlMinutoEuro'] as num?)?.toDouble() ?? 0,
      costoTotaleEuro: (map['costoTotaleEuro'] as num?)?.toDouble() ?? 0,
    );
  }
}
