import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/vehicle.dart';
import '../../data/remote/mock_vehicle_data_source.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'vehicle_detail_sheet.dart';

/// Sezione "Mappa" (RF1, RF2): mezzi disponibili su Google Maps.
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
  /// Il Future si crea UNA volta sola (non dentro build), come negli appunti
  /// con `initState`: altrimenti a ogni ridisegno ripartirebbe il caricamento.
  Future<List<Vehicle>>? _mezzi;

  /// true quando l'utente ha concesso la posizione: mostra il pallino blu.
  bool _posizioneAbilitata = false;

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
  /// "Sblocca e parti" il bottom sheet restituisce true e andiamo alla corsa.
  Future<void> _apriDettaglio(Vehicle mezzo) async {
    final sblocca = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colori.bianco,
      builder: (context) => VehicleDetailSheet(mezzo: mezzo),
    );
    if (sblocca == true && mounted) {
      // Rotta con nome + argomento (lezione 3.4): passiamo il Vehicle alla corsa.
      Navigator.pushNamed(context, Routes.ride, arguments: mezzo);
    }
  }

  // ---------------------------------------------------------------
  //  PERMESSO DI POSIZIONE (plugin permission_handler).
  //  Tre casi: già concesso / va spiegato perché serve / va chiesto.
  // ---------------------------------------------------------------
  static const String _spiegazionePermesso =
      'Serve la tua posizione per mostrarti i mezzi più vicini. '
      'Senza, la mappa parte da Ancona centro.';

  Future<void> _richiediPermessoPosizione() async {
    final permesso = Permission.locationWhenInUse;

    if (await permesso.isGranted) {
      _abilitaPosizioneUtente();
      return;
    }
    if (await permesso.shouldShowRequestRationale) {
      // L'utente aveva già negato una volta: spieghiamo perché serve.
      if (!mounted) return;
      mostraMessaggio(context, _spiegazionePermesso,
          azione: 'Consenti', onAzione: _chiediPermesso);
      return;
    }
    await _chiediPermesso();
  }

  Future<void> _chiediPermesso() async {
    final stato = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    if (stato.isGranted) {
      _abilitaPosizioneUtente();
    } else {
      // Se l'utente nega, l'app NON si blocca: la mappa resta su Ancona
      // e i mezzi si vedono comunque.
      mostraMessaggio(context, _spiegazionePermesso);
    }
  }

  void _abilitaPosizioneUtente() {
    if (!_posizioneAbilitata) setState(() => _posizioneAbilitata = true);
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
                myLocationEnabled: _posizioneAbilitata,
                myLocationButtonEnabled: _posizioneAbilitata,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
                // La mappa è pronta solo ora: chiediamo la posizione.
                onMapCreated: (_) => _richiediPermessoPosizione(),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colori.bianco,
        tooltip: 'Centra sulla mia posizione',
        onPressed: _richiediPermessoPosizione,
        child: const Icon(Icons.my_location, color: Colori.verdePrimario),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
