import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/models/review.dart';
import '../../data/repositories/goride_exception.dart';
import '../common/widget_comuni.dart';

/// Pubblicazione di una recensione (RF13).
class NewReviewScreen extends StatefulWidget {
  const NewReviewScreen({super.key});

  @override
  State<NewReviewScreen> createState() => _NewReviewScreenState();
}

class _NewReviewScreenState extends State<NewReviewScreen> {
  static const int _lunghezzaMinima = 10;

  final _testo = TextEditingController();
  ReviewType _tipoSelezionato = ReviewType.opinione;
  bool _caricamento = false;

  @override
  void dispose() {
    _testo.dispose();
    super.dispose();
  }

  Future<void> _pubblica() async {
    final contenuto = _testo.text.trim();
    if (contenuto.isEmpty) {
      mostraMessaggio(context, 'Scrivi qualcosa prima di pubblicare');
      return;
    }
    if (contenuto.length < _lunghezzaMinima) {
      mostraMessaggio(context, 'La recensione è troppo corta');
      return;
    }

    final scope = AppScope.of(context);
    final uid = scope.userRepository.uidCorrente;
    if (uid == null) {
      mostraMessaggio(context, 'Devi essere autenticato per pubblicare');
      return;
    }

    setState(() => _caricamento = true);
    try {
      // Il nome dell'autore viene copiato nella recensione: niente JOIN su Firestore.
      var autore = 'Utente GoRide';
      try {
        autore = (await scope.userRepository.getProfilo()).nomeCompleto;
      } on GoRideException {
        // Se il profilo non si carica pubblichiamo con un nome generico.
      }
      await scope.reviewRepository.pubblicaRecensione(
        userId: uid,
        autoreNome: autore,
        tipo: _tipoSelezionato,
        testo: contenuto,
      );
      // Torna alla community, che si aggiorna da sola grazie allo Stream.
      if (mounted) Navigator.pop(context);
    } on GoRideException catch (e) {
      if (mounted) mostraMessaggio(context, e.messaggio);
    } finally {
      if (mounted) setState(() => _caricamento = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova recensione')),
      body: ListView(
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
                  selected: _tipoSelezionato == tipo,
                  onSelected: (_) => setState(() => _tipoSelezionato = tipo),
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
            onPressed: _caricamento ? null : _pubblica,
            child: const Text('Pubblica'),
          ),
          Caricamento(visibile: _caricamento),
        ],
      ),
    );
  }
}
