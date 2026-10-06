import '../../data/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../common/view_model.dart';

/// ViewModel della mappa (RF1, RF2). Stessa logica di `MapViewModel.kt`.
///
/// Conosce solo una `List<Vehicle>`: non sa nulla di Google Maps né di marker.
/// Trasformare i mezzi in marker è compito della schermata.
class MapViewModel extends ViewModel {
  MapViewModel(this._repository) {
    // I mezzi si caricano alla creazione del ViewModel (come `init {}`).
    caricaMezzi();
  }

  final VehicleRepository _repository;

  List<Vehicle> _mezzi = const [];
  bool _isLoading = false;
  String? _errore;
  Vehicle? _mezzoSelezionato;

  List<Vehicle> get mezzi => _mezzi;
  bool get isLoading => _isLoading;
  String? get errore => _errore;
  Vehicle? get mezzoSelezionato => _mezzoSelezionato;

  Future<void> caricaMezzi() async {
    _isLoading = true;
    _errore = null;
    notifyListeners();
    try {
      _mezzi = await _repository.getMezziDisponibili();
    } catch (_) {
      _errore = 'Impossibile caricare i mezzi. Riprova.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Il tap sul marker non apre direttamente il dettaglio: passa dal ViewModel,
  /// che "dichiara" quale mezzo è selezionato. La schermata osserva e apre.
  void selezionaMezzo(Vehicle vehicle) {
    _mezzoSelezionato = vehicle;
    notifyListeners();
  }

  /// Da chiamare subito dopo aver aperto il dettaglio, altrimenti l'evento
  /// resterebbe "vivo" e verrebbe riaperto (il bug del loop visto in Kotlin).
  void deselezionaMezzo() => _mezzoSelezionato = null;

  void erroreMostrato() => _errore = null;
}
