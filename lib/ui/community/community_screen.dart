import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'community_viewmodel.dart';
import 'review_card.dart';

/// Sezione "Community" (RF12, RF14) — equivalente di `CommunityFragment`.
/// La lista si aggiorna da sola quando qualcuno pubblica (anche dall'app Kotlin).
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  CommunityViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= CommunityViewModel(AppScope.of(context).reviewRepository);
  }

  @override
  void dispose() {
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
          const Intestazione('Community'),
          Expanded(
            child: ListenableBuilder(
              listenable: vm,
              builder: (context, _) {
                final recensioni = vm.recensioni;
                if (recensioni == null) return const Caricamento(visibile: true);
                if (recensioni.isEmpty) {
                  return const StatoVuoto(
                    titolo: 'Ancora nessuna recensione',
                    messaggio: 'Sii il primo a lasciare un commento',
                  );
                }
                return ListView.separated(
                  // spazio in fondo per non finire sotto il bottone "Scrivi"
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  itemCount: recensioni.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      ReviewCard(review: recensioni[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colori.verdePrimario,
        foregroundColor: Colori.bianco,
        icon: const Icon(Icons.edit),
        label: const Text('Scrivi'),
        onPressed: () => Navigator.pushNamed(context, Routes.newReview),
      ),
    );
  }
}
