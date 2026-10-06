import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'history_viewmodel.dart';
import 'ride_card.dart';

/// Sezione "Storico" (RF10) — equivalente di `HistoryFragment`.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  HistoryViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      final scope = AppScope.of(context);
      _viewModel = HistoryViewModel(scope.rideRepository, scope.userRepository);
      _viewModel!.addListener(_osservaViewModel);
    }
  }

  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;
    final errore = vm.errore;
    if (errore != null) {
      mostraMessaggio(context, errore, azione: 'Riprova', onAzione: vm.sincronizza);
      vm.erroreMostrato();
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_osservaViewModel);
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;

    return Scaffold(
      backgroundColor: Colori.grigioSfondo,
      body: Column(
        children: [
          const Intestazione('Le tue corse'),
          Expanded(
            child: ListenableBuilder(
              listenable: vm,
              builder: (context, _) {
                final corse = vm.corse;
                if (corse == null || (corse.isEmpty && vm.isLoading)) {
                  return const Caricamento(visibile: true);
                }
                if (corse.isEmpty) {
                  return const StatoVuoto(
                    titolo: 'Nessuna corsa',
                    messaggio: 'Le corse che farai compariranno qui',
                  );
                }
                // ListView.builder: costruisce solo le righe visibili (lezione 3.2).
                return RefreshIndicator(
                  onRefresh: vm.sincronizza,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: corse.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final corsa = corse[index];
                      return RideCard(
                        ride: corsa,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.rideDetail,
                          arguments: corsa,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
