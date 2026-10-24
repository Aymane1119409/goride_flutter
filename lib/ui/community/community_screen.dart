import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/review.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'review_card.dart';

/// Sezione "Community" (RF12, RF14).
///
/// Le recensioni arrivano in tempo reale da Firestore come `Stream` e vengono
/// mostrate con uno `StreamBuilder`: quando qualcuno pubblica (anche dall'app
/// Kotlin) la lista si aggiorna da sola. Quando la schermata viene chiusa lo
/// StreamBuilder cancella l'iscrizione e Firestore smette di ascoltare.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  /// Creato una sola volta, non dentro build.
  Stream<List<Review>>? _recensioni;

  /// Ultimo elenco ricevuto: se Firestore non risponde resta visibile questo,
  /// senza messaggi di errore (stesso comportamento dell'app Kotlin).
  List<Review> _ultimeRecensioni = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recensioni ??= AppScope.of(context).reviewRepository.osservaRecensioni();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colori.grigioSfondo,
      body: Column(
        children: [
          const Intestazione('Community'),
          Expanded(
            child: StreamBuilder<List<Review>>(
              stream: _recensioni,
              builder: (context, snapshot) {
                if (snapshot.hasData) _ultimeRecensioni = snapshot.data!;
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Caricamento(visibile: true);
                }
                final recensioni = _ultimeRecensioni;
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
