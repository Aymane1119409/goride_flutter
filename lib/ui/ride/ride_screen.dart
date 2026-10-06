import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/vehicle.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';
import 'ride_viewmodel.dart';

/// Schermata della corsa con timer (RF5), alert di scadenza (RF6),
/// estensione (RF6.1) e chiusura (RF6.2) — equivalente di `RideFragment`.
///
/// Riceve il `Vehicle` come argomento della rotta con nome.
class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  RideViewModel? _viewModel;
  late Vehicle _mezzoArgomento;
  bool _dialogScadenzaAperto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel != null) return;

    _mezzoArgomento = ModalRoute.of(context)!.settings.arguments as Vehicle;
    final vm = AppScope.of(context).rideViewModel;
    _viewModel = vm;
    vm.addListener(_osservaViewModel);

    // Se una corsa è già attiva (es. siamo rientrati) NON richiediamo la durata.
    if (!vm.corsaAttiva) {
      // Aspettiamo il primo frame: i dialog si possono aprire solo a schermata pronta.
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final ripristinata = await vm.ripristinaCorsaAttiva();
        // `mounted`: la lettura dal database è asincrona, nel frattempo l'utente
        // potrebbe essere uscito (stessa idea di `isAdded` nel Fragment).
        if (!ripristinata && mounted) _mostraSceltaDurata();
      });
    }
  }

  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;

    if (vm.tempoScaduto && !_dialogScadenzaAperto) {
      _mostraAlertScadenza();
    }
    if (vm.corsaTerminata) {
      vm.navigazioneCompletata();
      // Torna alla mappa togliendo la corsa dallo stack.
      Navigator.popUntil(context, ModalRoute.withName(Routes.home));
    }
  }

  @override
  void dispose() {
    // Il ViewModel NON va distrutto qui: vive nell'AppScope.
    _viewModel?.removeListener(_osservaViewModel);
    super.dispose();
  }

  Vehicle get _mezzo => _viewModel?.mezzoCorrente ?? _mezzoArgomento;

  // ---------------------------------------------------------------
  //  DIALOG
  // ---------------------------------------------------------------

  /// "Quanto tempo vuoi acquistare?" — non si può chiudere senza scegliere.
  Future<void> _mostraSceltaDurata() async {
    final minuti = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: SimpleDialog(
          title: const Text('Quanto tempo vuoi acquistare?'),
          children: [
            for (final opzione in RideViewModel.durateDisponibili)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, opzione),
                child: Text(
                  '$opzione minuti — ${Formatters.euro(_mezzoArgomento.tariffaSbloccoEuro + opzione * _mezzoArgomento.tariffaAlMinutoEuro)}',
                ),
              ),
          ],
        ),
      ),
    );
    if (minuti != null) _viewModel!.avviaCorsa(_mezzoArgomento, minuti);
  }

  /// Alert alla scadenza: l'utente DEVE scegliere, non può ignorarlo e
  /// continuare a pedalare gratis.
  Future<void> _mostraAlertScadenza() async {
    _dialogScadenzaAperto = true;
    final estendi = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Tempo scaduto'),
          content: const Text(
            'Il tempo prepagato è terminato. Vuoi estendere la corsa o terminarla?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Termina corsa'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Estendi corsa'),
            ),
          ],
        ),
      ),
    );
    _dialogScadenzaAperto = false;
    if (!mounted) return;

    final vm = _viewModel!;
    if (estendi == true) {
      vm.alertMostrato();
      await _mostraSceltaEstensione();
    } else {
      vm.terminaCorsa();
    }
  }

  Future<void> _mostraSceltaEstensione() async {
    final mezzo = _mezzo;
    final minuti = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Quanto tempo aggiungere?'),
        children: [
          for (final opzione in RideViewModel.estensioniDisponibili)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, opzione),
              child: Text(
                '+$opzione minuti — ${Formatters.euro(opzione * mezzo.tariffaAlMinutoEuro)}',
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    final vm = _viewModel!;
    if (minuti != null) {
      vm.estendiCorsa(minuti);
    } else if (vm.corsaAttiva && vm.millisecondiRimanenti == 0) {
      // Tempo già finito e nessuna estensione scelta: riproponiamo l'alert.
      _mostraAlertScadenza();
    }
  }

  Future<void> _confermaTermine() async {
    final costo = _viewModel!.costoAttuale;
    final conferma = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminare la corsa?'),
        content: Text('Il costo finale sarà di ${Formatters.euro(costo)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Termina corsa'),
          ),
        ],
      ),
    );
    if (conferma == true && mounted) _viewModel!.terminaCorsa();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;
    const etichetta = TextStyle(color: Colori.verdeChiaro);

    // Il tasto indietro non deve far uscire dalla corsa lasciando il mezzo
    // sbloccato: intercettiamo e chiediamo conferma (OnBackPressedCallback).
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confermaTermine();
      },
      child: Scaffold(
        backgroundColor: Colori.verdePrimario,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListenableBuilder(
              listenable: vm,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  const Text(
                    'CORSA IN CORSO',
                    style: TextStyle(color: Colori.verdeChiaro, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mezzo.nome,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colori.bianco,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 72),
                  const Text('Tempo residuo', style: etichetta),
                  const SizedBox(height: 8),
                  Text(
                    vm.tempoFormattato,
                    style: const TextStyle(
                      color: Colori.bianco,
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text('Costo attuale', style: etichetta),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.euro(vm.costoAttuale),
                    style: const TextStyle(
                      color: Colori.bianco,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colori.bianco,
                        side: const BorderSide(color: Colori.bianco),
                      ),
                      onPressed: vm.corsaAttiva ? _mostraSceltaEstensione : null,
                      child: const Text('Estendi corsa'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colori.bianco,
                      foregroundColor: Colori.verdePrimario,
                    ),
                    onPressed: vm.corsaAttiva ? _confermaTermine : null,
                    child: const Text('Termina corsa'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
