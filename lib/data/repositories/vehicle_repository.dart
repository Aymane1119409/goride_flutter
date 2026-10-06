import '../models/vehicle.dart';
import '../remote/mock_vehicle_data_source.dart';
import 'goride_exception.dart';

/// Repository dei mezzi: l'unica porta verso i dati.
/// Oggi è un mock in memoria, domani potrebbe essere un'API REST:
/// cambierebbe solo questo file.
class VehicleRepository {
  VehicleRepository([MockVehicleDataSource? dataSource])
      : _dataSource = dataSource ?? MockVehicleDataSource();

  final MockVehicleDataSource _dataSource;

  /// Latenza finta, per vedere gli stati di caricamento durante lo sviluppo.
  static const Duration _ritardoSimulato = Duration(milliseconds: 600);

  /// Mezzi disponibili nelle vicinanze (RF1, RF2, RF2.1, RF3).
  /// `Future` + `async/await` (lezione 3.5): la UI non si blocca mai.
  Future<List<Vehicle>> getMezziDisponibili() async {
    await Future<void>.delayed(_ritardoSimulato);
    return _dataSource.getMezziDisponibili();
  }

  Future<Vehicle?> getMezzoById(String id) async => _dataSource.getMezzoById(id);

  /// Sblocco del mezzo (RF4). Nel mock verifichiamo solo che esista e sia libero.
  Future<Vehicle> sbloccaMezzo(String vehicleId) async {
    await Future<void>.delayed(_ritardoSimulato);
    final mezzo = _dataSource.getMezzoById(vehicleId);
    if (mezzo == null) throw const GoRideException('Mezzo non trovato');
    if (!mezzo.disponibile) {
      throw const GoRideException("Il mezzo non e' piu' disponibile");
    }
    return mezzo;
  }
}
