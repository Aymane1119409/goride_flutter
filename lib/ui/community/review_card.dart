import 'package:flutter/material.dart';

import '../../data/models/review.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';

/// Card di una recensione.
///
/// In Kotlin c'erano tre layout (item_review_guasto/opinione/consiglio) scelti
/// con `getItemViewType`. In Flutter basta un widget che sceglie colore ed
/// etichetta in base al tipo: rosso = guasto, verde = opinione, arancio = consiglio.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review});

  final Review review;

  static Color colorePer(ReviewType tipo) {
    switch (tipo) {
      case ReviewType.guasto:
        return Colori.errore;
      case ReviewType.opinione:
        return Colori.verdePrimario;
      case ReviewType.consiglio:
        return Colori.arancioEbike;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colore = colorePer(review.tipo);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colore),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge colorato con il tipo (GUASTO / OPINIONE / CONSIGLIO).
            Container(
              color: colore,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                review.tipo.codice,
                style: const TextStyle(
                  color: Colori.bianco,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(review.testo, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            Text(
              '${review.autoreNome} · ${Formatters.dataBreve(review.timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colori.grigioTesto),
            ),
          ],
        ),
      ),
    );
  }
}
