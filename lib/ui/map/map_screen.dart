import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/vehicle.dart';
import '../../data/remote/mock_vehicle_data_source.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'map_viewmodel.dart';
import 'vehicle_detail_sheet.dart';

/// Sezione "Mappa" (RF1, RF2) — equivalente di `MapFragment`.
///
/// È un "UI controller" puro: osserva il ViewModel, disegna i marker e gestisce
/// il permesso di posizione. La logica sta nel MapViewModel.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapViewModel? _viewModel;

  /// true quando l'utente ha concesso la posizione: mostra il pallino blu.
  bool _posizioneAbilitata = false;

  static const CameraPosition _vistaIniziale = CameraPosition(
    target: LatLng(MockVehicleDataSource.anconaLat, MockVehicleDataSource.anconaLon),
    zoom: MockVehicleDataSource.zoomDefault,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      _viewModel = MapViewModel(AppScope.of(context).vehicleRepository);
      _viewModel!.addListener(_osservaViewModel);
    }
  }

  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;

    final errore = vm.errore;
    if (errore != null) {
      mostraMessaggio(context, errore, azione: 'Riprova', onAzione: vm.caricaMezzi);
      vm.erroreMostrato();
    }

    final mezzo = vm.mezzoSelezionato;
    if (mezzo != null) {
      vm.deselezionaMezzo(); // consumiamo subito l'evento (anti-loop)
      _apriDettaglio(mezzo);
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_osservaViewModel);
    _viewModel?.dispose();
    super.dispose();
  }

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
  //  PERMESSI (pacchetto permission_handler, plugin nativo – lez. 3.0).
  //  Stessi tre casi del `when` di MapFragment:
  //  già concesso / va spiegato perché serve / va chiesto.
  // ---------------------------------------------------------------
  Future<void> _richiediPermessoPosizione() async {
    final permesso = Permission.locationWhenInUse;

    if (await permesso.isGranted) {
      _abilitaPosizioneUtente();
      return;
    }

    if (await permesso.shouldShowRequestRationale) {
      // L'utente aveva già negato una volta: spieghiamo perché serve.
      if (!mounted) return;
      mostraMessaggio(
        context,
        'Serve la tua posizione per mostrarti i mezzi più vicini. '
        'Senza, la mappa parte da Ancona centro.',
        azione: 'Consenti',
        onAzione: _chiediPermesso,
      );
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
      // e i mezzi si vedono comunque. La funzionalità degrada, non si interrompe.
      mostraMessaggio(
        context,
        'Serve la tua posizione per mostrarti i mezzi più vicini. '
        'Senza, la mappa parte da Ancona centro.',
      );
    }
  }

  void _abilitaPosizioneUtente() {
    if (!_posizioneAbilitata) setState(() => _posizioneAbilitata = true);
  }

  /// Trasforma i mezzi in marker. Marker arancioni per le e-bike, verdi per le
  /// classiche (RF2), con batteria e tariffa già nel fumetto (RF2.1, RF3).
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
          onTap: () => _viewModel!.selezionaMezzo(mezzo),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;

    return Scaffold(
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _vistaIniziale,
              markers: _creaMarker(vm.mezzi),
              myLocationEnabled: _posizioneAbilitata,
              myLocationButtonEnabled: _posizioneAbilitata,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
              // La mappa è pronta solo ora: chiediamo la posizione.
              onMapCreated: (_) => _richiediPermessoPosizione(),
            ),
            if (vm.isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colori.verdePrimario),
              ),
          ],
        ),
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
