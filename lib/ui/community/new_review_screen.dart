import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/models/review.dart';
import '../common/widget_comuni.dart';
import 'new_review_viewmodel.dart';

/// Pubblicazione di una recensione (RF13) — equivalente di `NewReviewFragment`.
class NewReviewScreen extends StatefulWidget {
  const NewReviewScreen({super.key});

  @override
  State<NewReviewScreen> createState() => _NewReviewScreenState();
}

class _NewReviewScreenState extends State<NewReviewScreen> {
  final _testo = TextEditingController();
  NewReviewViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_viewModel == null) {
      final scope = AppScope.of(context);
      _viewModel = NewReviewViewModel(scope.reviewRepository, scope.userRepository);
      _viewModel!.addListener(_osservaViewModel);
    }
  }

  void _osservaViewModel() {
    final vm = _viewModel!;
    if (!mounted) return;
    final errore = vm.errore;
    if (errore != null) {
      mostraMessaggio(context, errore);
      vm.erroreMostrato();
    }
    if (vm.pubblicata) {
      vm.navigazioneCompletata();
      Navigator.pop(context); // torna alla community, che si aggiorna da sola
    }
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_osservaViewModel);
    _viewModel?.dispose();
    _testo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel!;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuova recensione')),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Che tipo di contributo?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Selezione singola, come il ChipGroup con singleSelection.
            Wrap(
              spacing: 8,
              children: [
                for (final tipo in [
                  ReviewType.opinione,
                  ReviewType.guasto,
                  ReviewType.consiglio,
                ])
                  ChoiceChip(
                    label: Text(tipo.codice),
                    selected: vm.tipoSelezionato == tipo,
                    onSelected: (_) => vm.selezionaTipo(tipo),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _testo,
              minLines: 5,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Racconta la tua esperienza…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: vm.isLoading ? null : () => vm.pubblica(_testo.text),
              child: const Text('Pubblica'),
            ),
            Caricamento(visibile: vm.isLoading),
          ],
        ),
      ),
    );
  }
}
