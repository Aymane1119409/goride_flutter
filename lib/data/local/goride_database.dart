import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database locale SQLite (equivalente di `GoRideDatabase` con Room).
///
/// Due tabelle, come nella versione Kotlin:
///  - `corse`: cache dello storico (la UI legge sempre da qui → funziona offline)
///  - `corsa_attiva`: al massimo una riga, per ripristinare la corsa in corso
///
/// Singleton: il database si apre UNA volta sola. Teniamo in memoria il `Future`
/// dell'apertura: se due parti dell'app lo chiedono insieme, ricevono lo stesso
/// Future e non aprono due connessioni (è il ruolo di @Volatile + synchronized in Kotlin).
class GoRideDatabase {
  GoRideDatabase._();

  static const String _nomeDatabase = 'goride_database.db';
  static const int _versione = 1;

  static const String tabellaCorse = 'corse';
  static const String tabellaCorsaAttiva = 'corsa_attiva';

  static Future<Database>? _apertura;

  static Future<Database> getDatabase() => _apertura ??= _apri();

  static Future<Database> _apri() async {
    // `join` del pacchetto path costruisce il percorso giusto per ogni piattaforma.
    final percorso = join(await getDatabasesPath(), _nomeDatabase);
    return openDatabase(
      percorso,
      version: _versione,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabellaCorse (
            id TEXT PRIMARY KEY,
            userId TEXT NOT NULL,
            vehicleId TEXT NOT NULL,
            vehicleNome TEXT NOT NULL,
            vehicleTipo TEXT NOT NULL,
            startTimestamp INTEGER NOT NULL,
            endTimestamp INTEGER,
            minutiPrepagati INTEGER NOT NULL,
            tariffaSbloccoEuro REAL NOT NULL,
            tariffaAlMinutoEuro REAL NOT NULL,
            costoTotaleEuro REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $tabellaCorsaAttiva (
            id INTEGER PRIMARY KEY,
            vehicleId TEXT NOT NULL,
            vehicleNome TEXT NOT NULL,
            vehicleTipo TEXT NOT NULL,
            startTimestamp INTEGER NOT NULL,
            scadenzaTimestamp INTEGER NOT NULL,
            minutiPrepagati INTEGER NOT NULL,
            tariffaSbloccoEuro REAL NOT NULL,
            tariffaAlMinutoEuro REAL NOT NULL
          )
        ''');
      },
    );
  }
}
