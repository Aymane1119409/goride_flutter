import 'package:sqflite/sqflite.dart';

import '../models/ride.dart';
import 'goride_database.dart';

/// Accesso alla tabella `corse` (equivalente di `RideDao`).
/// Usa i metodi di sqflite visti a lezione: query, insert, delete.
class RideDao {
  /// RF10 — storico dell'utente, dalla corsa più recente.
  Future<List<Ride>> getCorseUtente(String userId) async {
    final db = await GoRideDatabase.getDatabase();
    final righe = await db.query(
      GoRideDatabase.tabellaCorse,
      where: 'userId = ?',
      whereArgs: [userId], // "?" + whereArgs evita la SQL injection
      orderBy: 'startTimestamp DESC',
    );
    return righe.map((riga) => Ride.fromMap(riga['id'] as String, riga)).toList();
  }

  Future<Ride?> getCorsaById(String id) async {
    final db = await GoRideDatabase.getDatabase();
    final righe = await db.query(
      GoRideDatabase.tabellaCorse,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (righe.isEmpty) return null;
    return Ride.fromMap(id, righe.first);
  }

  Future<void> inserisci(Ride corsa) async {
    final db = await GoRideDatabase.getDatabase();
    await db.insert(
      GoRideDatabase.tabellaCorse,
      corsa.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Tutte insieme in un batch: una sola transazione invece di N scritture.
  Future<void> inserisciTutte(List<Ride> corse) async {
    final db = await GoRideDatabase.getDatabase();
    final batch = db.batch();
    for (final corsa in corse) {
      batch.insert(
        GoRideDatabase.tabellaCorse,
        corsa.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> cancellaCorseUtente(String userId) async {
    final db = await GoRideDatabase.getDatabase();
    await db.delete(
      GoRideDatabase.tabellaCorse,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
