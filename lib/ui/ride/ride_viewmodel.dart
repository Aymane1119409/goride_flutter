import 'dart:async';
import 'dart:math';

import '../../data/models/ride.dart';
import '../../data/models/vehicle.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../util/formatters.dart';
import '../common/view_model.dart';

/// ViewModel della corsa (RF4, RF5, RF6, RF6.1, RF6.2) — il pezzo più delicato.
/// Stessa logica di `RideViewModel.kt`.
///
/// Vive quanto l'app (sta nell'AppScope): così il timer non si perde se si
/// esce e si rientra nella schermata.
class RideViewModel extends ViewModel {
  RideViewModel(this._rideRepository, this._userRepository);

  final RideRepository _rideRepository;
  final UserRepository _userRepository;

  static const int _millisPerMinuto = 60000;
  static const Duration _intervalloTick = Duration(seconds: 1);

  /// Oltre questa soglia una corsa salvata è considerata abbandonata.
  static const int _tolleranzaMs = 30 * 60000;

  /// Usate dalla schermata per costruire le voci dei dialog.
  static const List<int> durateDisponibili = [15, 30, 60];
  static const List<int> estensioniDisponibili = [5, 15, 30];

  Vehicle? _mezzo;
  int _startTimestamp = 0;
  int _scadenzaTimestamp = 0;
  int _minutiPrepagatiTotali = 0;
  Timer? _timer;

  int _millisecondiRimanenti = 0;
  bool _corsaAttiva = false;
  bool _tempoScaduto = false;
  double _costoAttuale = 0;
  bool _corsaTerminata = false;

  int get millisecondiRimanenti => _millisecondiRimanenti;
  bool get corsaAttiva => _corsaAttiva;
  bool get tempoScaduto => _tempoScaduto;
  double get costoAttuale => _costoAttuale;
  bool get corsaTerminata => _corsaTerminata;
  Vehicle? get mezzoCorrente => _mezzo;

  /// Il tempo formattato è DERIVATO, non duplicato (come `.map {}` in Kotlin):
  /// non è uno stato, è una funzione dello stato, quindi non può disallinearsi.
  String get tempoFormattato => Formatters.minutiSecondi(_millisecondiRimanenti);

  static int _adesso() => DateTime.now().millisecondsSinceEpoch;

  // -----------------------------------------------------------
  //  AVVIO
  // -----------------------------------------------------------

  void avviaCorsa(Vehicle vehicle, int minutiPrepagati) {
    if (_corsaAttiva) return; // guardia anti-doppio-avvio

    _mezzo = vehicle;
    _startTimestamp = _adesso();
    _minutiPrepagatiTotali = minutiPrepagati;
    // Salviamo un ISTANTE di scadenza, non una durata.
    _scadenzaTimestamp = _startTimestamp + minutiPrepagati * _millisPerMinuto;

    _corsaAttiva = true;
    _tempoScaduto = false;
    _corsaTerminata = false;

    _salvaStatoSuDisco();
    _avviaTimer();
  }

  /// Ripristino dopo che Android ha chiuso l'app (process death).
  Future<bool> ripristinaCorsaAttiva() async {
    final salvata = await _rideRepository.getCorsaAttiva();
    if (salvata == null) return false;

    // Scaduta da troppo tempo: la consideriamo abbandonata.
    if (salvata.scadenzaTimestamp < _adesso() - _tolleranzaMs) {
      await _rideRepository.cancellaCorsaAttiva();
      return false;
    }

    // Ricostruiamo il mezzo: coordinate e batteria non servono durante la corsa.
    _mezzo = Vehicle(
      id: salvata.vehicleId,
      nome: salvata.vehicleNome,
      tipo: VehicleType.daCodice(salvata.vehicleTipo),
      lat: 0,
      lon: 0,
      batteriaPercentuale: null,
      autonomiaKm: null,
      tariffaSbloccoEuro: salvata.tariffaSbloccoEuro,
      tariffaAlMinutoEuro: salvata.tariffaAlMinutoEuro,
      disponibile: false,
    );
    _startTimestamp = salvata.startTimestamp;
    _scadenzaTimestamp = salvata.scadenzaTimestamp;
    _minutiPrepagatiTotali = salvata.minutiPrepagati;

    _corsaAttiva = true;
    _tempoScaduto = false;
    _corsaTerminata = false;
    _avviaTimer();
    return true;
  }

  // -----------------------------------------------------------
  //  TIMER: non contiamo i secondi, guardiamo l'orologio
  // -----------------------------------------------------------

  void _avviaTimer() {
    // Se c'era già un timer lo fermiamo: due timer insieme farebbero
    // "correre" il cronometro a velocità doppia.
    _timer?.cancel();
    _tick();
    if (_corsaAttiva && !_tempoScaduto) {
      _timer = Timer.periodic(_intervalloTick, (_) => _tick());
    }
  }

  void _tick() {
    // Se l'app resta in background e perde dei "battiti", al tick successivo
    // scadenza - adesso dà comunque il valore giusto: il timer è auto-correttivo.
    final rimanenti = _scadenzaTimestamp - _adesso();
    _millisecondiRimanenti = max(0, rimanenti);
    _aggiornaCosto();

    if (rimanenti <= 0) {
      _timer?.cancel();
      _timer = null;
      _tempoScaduto = true;
    }
    notifyListeners();
  }

  /// costo = sblocco + ceil(minuti trascorsi) × tariffa al minuto.
  /// Un minuto iniziato è un minuto pagato; si paga il tempo USATO, non quello comprato.
  void _aggiornaCosto() {
    final vehicle = _mezzo;
    if (vehicle == null) return;
    final millisTrascorsi = _adesso() - _startTimestamp;
    final minutiTrascorsi = (millisTrascorsi / _millisPerMinuto).ceil();
    _costoAttuale =
        vehicle.tariffaSbloccoEuro + minutiTrascorsi * vehicle.tariffaAlMinutoEuro;
  }

  // -----------------------------------------------------------
  //  ESTENSIONE E CHIUSURA
  // -----------------------------------------------------------

  void estendiCorsa(int minutiAggiuntivi) {
    // Estensione anticipata: i secondi residui non si perdono.
    // Estensione dopo la scadenza: non si regala tempo negativo.
    final base = max(_scadenzaTimestamp, _adesso());
    _scadenzaTimestamp = base + minutiAggiuntivi * _millisPerMinuto;
    _minutiPrepagatiTotali += minutiAggiuntivi;
    _tempoScaduto = false;

    _salvaStatoSuDisco();
    _avviaTimer();
  }

  void terminaCorsa() {
    _timer?.cancel();
    _timer = null;
    _aggiornaCosto(); // fissa il costo finale

    final vehicle = _mezzo;
    final uid = _userRepository.uidCorrente;
    if (vehicle != null && uid != null) {
      final corsa = Ride(
        id: '${uid}_$_startTimestamp', // univoco: un utente non parte due volte nello stesso millisecondo
        userId: uid,
        vehicleId: vehicle.id,
        vehicleNome: vehicle.nome,
        vehicleTipo: vehicle.tipo,
        startTimestamp: _startTimestamp,
        endTimestamp: _adesso(),
        minutiPrepagati: _minutiPrepagatiTotali,
        tariffaSbloccoEuro: vehicle.tariffaSbloccoEuro,
        tariffaAlMinutoEuro: vehicle.tariffaAlMinutoEuro,
        costoTotaleEuro: _costoAttuale,
      );
      // Non aspettiamo (come viewModelScope.launch): prima il database locale,
      // poi Firestore. La corsa compare subito nello storico anche senza rete.
      unawaited(_salvaCorsaConclusa(corsa));
    }

    _corsaAttiva = false;
    _tempoScaduto = false;
    _corsaTerminata = true;
    notifyListeners();
  }

  Future<void> _salvaCorsaConclusa(Ride corsa) async {
    await _rideRepository.salvaCorsa(corsa);
    await _rideRepository.cancellaCorsaAttiva();
  }

  void _salvaStatoSuDisco() {
    final vehicle = _mezzo;
    if (vehicle == null) return;
    unawaited(_rideRepository.salvaCorsaAttiva(
      vehicle: vehicle,
      startTimestamp: _startTimestamp,
      scadenzaTimestamp: _scadenzaTimestamp,
      minutiPrepagati: _minutiPrepagatiTotali,
    ));
  }

  void alertMostrato() => _tempoScaduto = false;

  void navigazioneCompletata() => _corsaTerminata = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
