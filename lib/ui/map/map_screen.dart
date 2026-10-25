import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app/app_scope.dart';
import '../../data/models/ride.dart';
import '../../data/models/vehicle.dart';
import '../../data/remote/mock_vehicle_data_source.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';
import '../common/widget_comuni.dart';
import 'vehicle_detail_sheet.dart';

/// Sezione "Mappa" (RF1–RF5): mezzi disponibili su Google Maps e noleggio.
///
/// I mezzi arrivano da un `Future` e vengono mostrati con un `FutureBuilder`
/// (lezione 3.5): mentre il Future è in corso mostra lo spinner, quando arriva
/// la lista disegna i marker.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Il Future si crea UNA volta sola (non dentro build): altrimenti a ogni
  /// ridisegno ripartirebbe il caricamento.
  Future<List<Vehicle>>? _mezzi;

  /// Durate acquistabili, come nell'app Kotlin.
  static const List<int> _durate = [15, 30, 60];

  static const CameraPosition _vistaIniziale = CameraPosition(
    target: LatLng(MockVehicleDataSource.anconaLat, MockVehicleDataSource.anconaLon),
    zoom: MockVehicleDataSource.zoomDefault,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Qui (e non in initState) si può leggere l'InheritedWidget AppScope.
    _mezzi ??= AppScope.of(context).vehicleRepository.getMezziDisponibili();
  }

  void _ricarica() {
    setState(() {
      _mezzi = AppScope.of(context).vehicleRepository.getMezziDisponibili();
    });
  }

  /// Tap su un marker: apre il dettaglio dal basso. Se l'utente preme
  /// "Noleggia" il bottom sheet restituisce true e si passa al noleggio.
  Future<void> _apriDettaglio(Vehicle mezzo) async {
    final noleggia = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colori.bianco,
      builder: (context) => VehicleDetailSheet(mezzo: mezzo),
    );
    if (noleggia == true && mounted) await _noleggia(mezzo);
  }

  /// Prezzo del noleggio = tariffa di sblocco + minuti × tariffa al minuto.
  double _prezzo(Vehicle mezzo, int minuti) =>
      mezzo.tariffaSbloccoEuro + minuti * mezzo.tariffaAlMinutoEuro;

  /// RF5 — l'utente sceglie la durata, il prezzo è calcolato subito e la
  /// corsa viene registrata nello storico. Non c'è nessun timer.
  Future<void> _noleggia(Vehicle mezzo) async {
    // 1. Scelta della durata: accanto a ogni durata c'è il prezzo.
    final minuti = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Quanto tempo ti serve?'),
        children: [
          for (final durata in _durate)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, durata),
              child: Text(
                '$durata minuti — ${Formatters.euro(_prezzo(mezzo, durata))}',
              ),
            ),
        ],
      ),
    );
    if (minuti == null || !mounted) return; // chiuso senza scegliere

    // 2. La corsa nasce già conclusa: durata e prezzo sono fissi.
    final scope = AppScope.of(context);
    final uid = scope.userRepository.uidCorrente;
    if (uid == null) return;
    final inizio = DateTime.now().millisecondsSinceEpoch;
    final corsa = Ride(
      id: '${uid}_$inizio',
      userId: uid,
      vehicleId: mezzo.id,
      vehicleNome: mezzo.nome,
      vehicleTipo: mezzo.tipo,
      startTimestamp: inizio,
      endTimestamp: inizio + minuti * 60000,
      minutiPrepagati: minuti,
      tariffaSbloccoEuro: mezzo.tariffaSbloccoEuro,
      tariffaAlMinutoEuro: mezzo.tariffaAlMinutoEuro,
      costoTotaleEuro: _prezzo(mezzo, minuti),
    );

    // 3. Salvataggio: prima il database locale, poi Firestore.
    await scope.rideRepository.salvaCorsa(corsa);
    if (mounted) {
      mostraMessaggio(context, 'Noleggio registrato: lo trovi nello storico');
    }
  }

  /// Trasforma i mezzi in marker: arancioni le e-bike, verdi le classiche (RF2),
  /// con batteria e tariffa già nel fumetto (RF2.1, RF3).
  Set<Marker> _creaMarker(List<Vehicle> mezzi) {
    return {
      for (final mezzo in mezzi)
        Marker(
          markerId: MarkerId(mezzo.id),
          position: LatLng(mezzo.lat, mezzo.lon),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            mezzo.isEbike ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: mezzo.nome,
            snippet: mezzo.isEbike
                ? '${mezzo.batteriaPercentuale}% · ${mezzo.autonomiaKm?.toInt()} km'
                    ' · ${mezzo.tariffaAlMinutoEuro} €/min'
                : 'Bici classica · ${mezzo.tariffaAlMinutoEuro} €/min',
          ),
          onTap: () => _apriDettaglio(mezzo),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Vehicle>>(
        future: _mezzi,
        builder: (context, snapshot) {
          final mezzi = snapshot.data ?? const <Vehicle>[];
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _vistaIniziale,
                markers: _creaMarker(mezzi),
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),
              // Caricamento in corso
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: CircularProgressIndicator(color: Colori.verdePrimario),
                ),
              // Errore: messaggio con il tasto per riprovare
              if (snapshot.hasError)
                Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Impossibile caricare i mezzi.'),
                          TextButton(
                            onPressed: _ricarica,
                            child: const Text('Riprova'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
