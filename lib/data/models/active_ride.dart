/// Corsa in corso salvata su disco (tabella SQLite `corsa_attiva`).
/// Equivalente di `ActiveRideEntity`: serve a ripristinare il timer se
/// Android chiude l'app mentre l'utente pedala.
///
/// La chiave primaria è sempre [rigaUnica] (= 1): la tabella contiene al massimo
/// una riga, e con `ConflictAlgorithm.replace` ogni salvataggio sovrascrive il
/// precedente. Lo stato incoerente è impossibile per costruzione.
class ActiveRide {
  static const int rigaUnica = 1;

  final String vehicleId;
  final String vehicleNome;
  final String vehicleTipo;
  final int startTimestamp;
  final int scadenzaTimestamp;
  final int minutiPrepagati;
  final double tariffaSbloccoEuro;
  final double tariffaAlMinutoEuro;

  const ActiveRide({
    required this.vehicleId,
    required this.vehicleNome,
    required this.vehicleTipo,
    required this.startTimestamp,
    required this.scadenzaTimestamp,
    required this.minutiPrepagati,
    required this.tariffaSbloccoEuro,
    required this.tariffaAlMinutoEuro,
  });

  Map<String, Object?> toMap() => {
        'id': rigaUnica,
        'vehicleId': vehicleId,
        'vehicleNome': vehicleNome,
        'vehicleTipo': vehicleTipo,
        'startTimestamp': startTimestamp,
        'scadenzaTimestamp': scadenzaTimestamp,
        'minutiPrepagati': minutiPrepagati,
        'tariffaSbloccoEuro': tariffaSbloccoEuro,
        'tariffaAlMinutoEuro': tariffaAlMinutoEuro,
      };

  factory ActiveRide.fromMap(Map<String, Object?> map) {
    return ActiveRide(
      vehicleId: map['vehicleId'] as String? ?? '',
      vehicleNome: map['vehicleNome'] as String? ?? '',
      vehicleTipo: map['vehicleTipo'] as String? ?? 'CLASSIC',
      startTimestamp: (map['startTimestamp'] as num?)?.toInt() ?? 0,
      scadenzaTimestamp: (map['scadenzaTimestamp'] as num?)?.toInt() ?? 0,
      minutiPrepagati: (map['minutiPrepagati'] as num?)?.toInt() ?? 0,
      tariffaSbloccoEuro: (map['tariffaSbloccoEuro'] as num?)?.toDouble() ?? 0,
      tariffaAlMinutoEuro: (map['tariffaAlMinutoEuro'] as num?)?.toDouble() ?? 0,
    );
  }
}
