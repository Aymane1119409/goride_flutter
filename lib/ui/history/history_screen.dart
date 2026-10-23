import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/ride.dart';
import '../../data/repositories/ride_repository.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'ride_card.dart';

/// Sezione "Storico" (RF10).
///
/// Lo storico è uno `Stream` letto dal database locale e mostrato con uno
/// `StreamBuilder` (lezione 3.5): ogni volta che una corsa viene salvata, lo
/// Stream emette la lista nuova e la schermata si ridisegna da sola.
/// All'apertura scarica anche le corse da Firestore (sincronizzazione).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late RideRepository _repository;
  String? _uid;

  /// Creato una sola volta: se lo creassimo in build, a ogni ridisegno
  /// lo StreamBuilder ripartirebbe da zero.
  Stream<List<Ride>>? _storico;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_storico == null) {
      final scope = AppScope.of(context);
      _repository = scope.rideRepository;
      _uid = scope.userRepository.uidCorrente;
      _storico = _repository.osservaStorico(_uid ?? '');
      _sincronizza();
    }
  }

  /// Scarica le corse da Firestore e le salva nel database locale:
  /// lo Stream qui sopra se ne accorge e aggiorna la lista.
  Future<void> _sincronizza() async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _repository.sincronizzaDaFirestore(uid);
    } catch (_) {
      // Senza rete restano visibili le corse già salvate in locale.
      if (mounted) {
        mostraMessaggio(context, 'Impossibile aggiornare lo storico',
            azione: 'Riprova', onAzione: _sincronizza);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colori.grigioSfondo,
      body: Column(
        children: [
          const Intestazione('Le tue corse'),
          Expanded(
            child: StreamBuilder<List<Ride>>(
              stream: _storico,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Caricamento(visibile: true);
                final corse = snapshot.data!;
                if (corse.isEmpty) {
                  return const StatoVuoto(
                    titolo: 'Nessuna corsa',
                    messaggio: 'Le corse che farai compariranno qui',
                  );
                }
                // Trascinando verso il basso si risincronizza con Firestore.
                return RefreshIndicator(
                  onRefresh: _sincronizza,
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
