import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/routes.dart';
import '../../data/models/ride.dart';
import '../../data/repositories/ride_repository.dart';
import '../../util/colori.dart';
import '../common/widget_comuni.dart';
import 'ride_card.dart';

/// Sezione "Storico" (RF9).
///
/// All'apertura scarica le corse da Firestore nel database locale e poi le
/// legge da lì. Il risultato è un `Future`, mostrato con un `FutureBuilder`
/// (lezione 3.5): spinner mentre carica, poi la lista o lo stato vuoto.
/// HomeShell ricrea questa schermata ogni volta che l'utente tocca "Storico",
/// quindi i noleggi appena fatti compaiono subito.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late RideRepository _repository;
  String? _uid;

  /// Creato una sola volta: se lo creassimo in build, a ogni ridisegno
  /// il caricamento ripartirebbe da zero.
  Future<List<Ride>>? _corse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Qui (e non in initState) si può leggere l'InheritedWidget AppScope.
    if (_corse == null) {
      final scope = AppScope.of(context);
      _repository = scope.rideRepository;
      _uid = scope.userRepository.uidCorrente;
      _corse = _carica();
    }
  }

  /// Sincronizza con Firestore e poi legge le corse dal database locale.
  /// Senza rete restano visibili le corse già salvate in locale; il messaggio
  /// di errore compare solo se non ce n'è nessuna (come nell'app Kotlin).
  Future<List<Ride>> _carica() async {
    final uid = _uid;
    if (uid == null) return const [];

    var sincronizzazioneFallita = false;
    try {
      await _repository.sincronizzaDaFirestore(uid);
    } catch (_) {
      sincronizzazioneFallita = true;
    }
    final corse = await _repository.getStorico(uid);

    if (!mounted) return corse;
    if (sincronizzazioneFallita && corse.isEmpty) {
      mostraMessaggio(context, 'Impossibile aggiornare lo storico',
          azione: 'Riprova', onAzione: _ricarica);
    }
    return corse;
  }

  void _ricarica() {
    setState(() => _corse = _carica());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colori.grigioSfondo,
      body: Column(
        children: [
          const Intestazione('Le tue corse'),
          Expanded(
            child: FutureBuilder<List<Ride>>(
              future: _corse,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Caricamento(visibile: true);
                final corse = snapshot.data!;
                if (corse.isEmpty) {
                  return const StatoVuoto(
                    titolo: 'Nessuna corsa',
                    messaggio: 'Le corse che farai compariranno qui',
                  );
                }
                return ListView.separated(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
