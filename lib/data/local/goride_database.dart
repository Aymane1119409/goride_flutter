import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Database locale SQLite (equivalente di `GoRideDatabase` con Room).
///
/// Una tabella, `corse`: la cache dello storico (la UI legge sempre da qui,
/// quindi lo storico funziona anche offline). Ha le stesse colonne della
/// tabella `corse` della versione Kotlin.
///
/// Singleton: il database si apre UNA volta sola. Teniamo in memoria il `Future`
/// dell'apertura: se due parti dell'app lo chiedono insieme, ricevono lo stesso
/// Future e non aprono due connessioni (è il ruolo di @Volatile + synchronized in Kotlin).
class GoRideDatabase {
  GoRideDatabase._();

  static const String _nomeDatabase = 'goride_database.db';
  static const int _versione = 1;

  static const String tabellaCorse = 'corse';

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
      },
    );
  }
}
