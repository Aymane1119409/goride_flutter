import 'package:sqflite/sqflite.dart';

import '../models/active_ride.dart';
import 'goride_database.dart';

/// Accesso alla tabella `corsa_attiva` (equivalente di `ActiveRideDao`).
class ActiveRideDao {
  Future<ActiveRide?> getCorsaAttiva() async {
    final db = await GoRideDatabase.getDatabase();
    final righe = await db.query(
      GoRideDatabase.tabellaCorsaAttiva,
      where: 'id = ?',
      whereArgs: [ActiveRide.rigaUnica],
    );
    if (righe.isEmpty) return null;
    return ActiveRide.fromMap(righe.first);
  }

  /// Chiave fissa + replace: sovrascrive sempre l'unica riga.
  Future<void> salva(ActiveRide corsa) async {
    final db = await GoRideDatabase.getDatabase();
    await db.insert(
      GoRideDatabase.tabellaCorsaAttiva,
      corsa.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cancella() async {
    final db = await GoRideDatabase.getDatabase();
    await db.delete(GoRideDatabase.tabellaCorsaAttiva);
  }
}
