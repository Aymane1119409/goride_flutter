import 'package:flutter_test/flutter_test.dart';
import 'package:goride_flutter/data/models/review.dart';
import 'package:goride_flutter/data/models/ride.dart';
import 'package:goride_flutter/data/models/vehicle.dart';
import 'package:goride_flutter/util/formatters.dart';

void main() {
  test('Formatters come la versione Kotlin', () {
    expect(Formatters.euro(1.5), '1,50 €');
    expect(Formatters.euroAlMinuto(0.28), '0,28 €/min');
    expect(Formatters.durata(754), '12m 34s');
    expect(Formatters.durata(3725), '1h 02m');
    expect(Formatters.minutiSecondi(90 * 1000), '01:30');
    expect(Formatters.minutiSecondi(-5000), '00:00');
  });

  test('I codici salvati su Firestore coincidono con gli enum Kotlin', () {
    expect(VehicleType.classic.codice, 'CLASSIC');
    expect(VehicleType.ebike.codice, 'EBIKE');
    expect(VehicleType.daCodice('EBIKE'), VehicleType.ebike);
    expect(VehicleType.daCodice('???'), VehicleType.classic);
    expect(ReviewType.daCodice('GUASTO'), ReviewType.guasto);
  });

  test('Ride: andata e ritorno da Map (riga SQLite / documento Firestore)', () {
    const corsa = Ride(
      id: 'r1',
      userId: 'u1',
      vehicleId: 'EB-001',
      vehicleNome: 'E-Bike 001 - Corso Garibaldi',
      vehicleTipo: VehicleType.ebike,
      startTimestamp: 1000,
      endTimestamp: 61000,
      minutiPrepagati: 15,
      tariffaSbloccoEuro: 1.0,
      tariffaAlMinutoEuro: 0.28,
      costoTotaleEuro: 1.28,
    );
    final copia = Ride.fromMap('r1', corsa.toMap());
    expect(copia.vehicleTipo, VehicleType.ebike);
    expect(copia.durataSecondi, 60);
    expect(copia.costoTotaleEuro, 1.28);
  });
}
