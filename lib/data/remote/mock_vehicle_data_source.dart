import '../models/vehicle.dart';

/// Sorgente dati fittizia per i mezzi (RF1, RF2, RF2.1, RF3).
///
/// Stessi identici mezzi dell'app Kotlin (stessi id, nomi, coordinate e tariffe):
/// così una corsa fatta da un'app e vista nello storico dell'altra è coerente.
///
/// Se un giorno arrivasse un backend vero, cambierebbe solo questa classe.
class MockVehicleDataSource {
  /// Centro di Ancona: fallback quando il permesso di posizione è negato.
  static const double anconaLat = 43.6158;
  static const double anconaLon = 13.5189;

  /// Zoom iniziale della mappa: livello "quartiere".
  static const double zoomDefault = 14;

  static const List<Vehicle> _mezzi = [
    // ---------- BICI CLASSICHE ----------
    Vehicle(
      id: 'BK-001',
      nome: 'Bici 001 - Piazza Cavour',
      tipo: VehicleType.classic,
      lat: 43.6155,
      lon: 13.5175,
      batteriaPercentuale: null, // le classiche non hanno batteria
      autonomiaKm: null,
      tariffaSbloccoEuro: 0.50,
      tariffaAlMinutoEuro: 0.15,
      disponibile: true,
    ),
    Vehicle(
      id: 'BK-002',
      nome: 'Bici 002 - Stazione Centrale',
      tipo: VehicleType.classic,
      lat: 43.6089,
      lon: 13.4972,
      batteriaPercentuale: null,
      autonomiaKm: null,
      tariffaSbloccoEuro: 0.50,
      tariffaAlMinutoEuro: 0.15,
      disponibile: true,
    ),
    Vehicle(
      id: 'BK-003',
      nome: 'Bici 003 - Porto Antico',
      tipo: VehicleType.classic,
      lat: 43.6215,
      lon: 13.5042,
      batteriaPercentuale: null,
      autonomiaKm: null,
      tariffaSbloccoEuro: 0.50,
      tariffaAlMinutoEuro: 0.15,
      disponibile: true,
    ),
    Vehicle(
      id: 'BK-004',
      nome: "Bici 004 - Universita' Monte Dago",
      tipo: VehicleType.classic,
      lat: 43.5867,
      lon: 13.5142,
      batteriaPercentuale: null,
      autonomiaKm: null,
      tariffaSbloccoEuro: 0.50,
      tariffaAlMinutoEuro: 0.15,
      disponibile: true,
    ),
    Vehicle(
      id: 'BK-005',
      nome: 'Bici 005 - Parco del Cardeto',
      tipo: VehicleType.classic,
      lat: 43.6248,
      lon: 13.5218,
      batteriaPercentuale: null,
      autonomiaKm: null,
      tariffaSbloccoEuro: 0.50,
      tariffaAlMinutoEuro: 0.15,
      disponibile: false, // già noleggiata: non compare in mappa
    ),
    // ---------- E-BIKE ----------
    Vehicle(
      id: 'EB-001',
      nome: 'E-Bike 001 - Corso Garibaldi',
      tipo: VehicleType.ebike,
      lat: 43.6142,
      lon: 13.5133,
      batteriaPercentuale: 87,
      autonomiaKm: 52.0,
      tariffaSbloccoEuro: 1.00,
      tariffaAlMinutoEuro: 0.28,
      disponibile: true,
    ),
    Vehicle(
      id: 'EB-002',
      nome: 'E-Bike 002 - Passetto',
      tipo: VehicleType.ebike,
      lat: 43.6089,
      lon: 13.5305,
      batteriaPercentuale: 42,
      autonomiaKm: 25.0,
      tariffaSbloccoEuro: 1.00,
      tariffaAlMinutoEuro: 0.28,
      disponibile: true,
    ),
    Vehicle(
      id: 'EB-003',
      nome: 'E-Bike 003 - Duomo San Ciriaco',
      tipo: VehicleType.ebike,
      lat: 43.6252,
      lon: 13.5108,
      batteriaPercentuale: 95,
      autonomiaKm: 57.0,
      tariffaSbloccoEuro: 1.00,
      tariffaAlMinutoEuro: 0.28,
      disponibile: true,
    ),
    Vehicle(
      id: 'EB-004',
      nome: 'E-Bike 004 - Mole Vanvitelliana',
      tipo: VehicleType.ebike,
      lat: 43.6178,
      lon: 13.5051,
      batteriaPercentuale: 15, // batteria scarica: caso limite per la UI
      autonomiaKm: 9.0,
      tariffaSbloccoEuro: 1.00,
      tariffaAlMinutoEuro: 0.28,
      disponibile: true,
    ),
    Vehicle(
      id: 'EB-005',
      nome: 'E-Bike 005 - Ospedale Torrette',
      tipo: VehicleType.ebike,
      lat: 43.6003,
      lon: 13.4681,
      batteriaPercentuale: 68,
      autonomiaKm: 41.0,
      tariffaSbloccoEuro: 1.00,
      tariffaAlMinutoEuro: 0.28,
      disponibile: true,
    ),
  ];

  /// Tutti i mezzi liberi da mostrare sulla mappa (RF1).
  List<Vehicle> getMezziDisponibili() =>
      _mezzi.where((mezzo) => mezzo.disponibile).toList();

  /// Un singolo mezzo per id, null se non esiste.
  Vehicle? getMezzoById(String id) {
    for (final mezzo in _mezzi) {
      if (mezzo.id == id) return mezzo;
    }
    return null;
  }
}
