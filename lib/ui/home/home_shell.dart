import 'package:flutter/material.dart';

import '../../util/colori.dart';
import '../auth/profile_screen.dart';
import '../community/community_screen.dart';
import '../history/history_screen.dart';
import '../map/map_screen.dart';

/// Le quattro sezioni principali con la `BottomNavigationBar` (lezione 3.2):
/// stesse voci del `bottom_nav_menu.xml` Kotlin.
///
/// La barra non c'è nelle schermate di login/registrazione, esattamente come
/// in MainActivity dove veniva nascosta.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indiceSelezionato = 0;

  /// Sezioni già aperte almeno una volta: le altre non vengono costruite
  /// finché l'utente non ci entra (niente caricamenti inutili all'avvio).
  final Set<int> _sezioniVisitate = {0};

  /// Cambia ogni volta che l'utente tocca "Storico": con una key nuova
  /// Flutter ricrea HistoryScreen, che rilegge le corse (anche quelle
  /// appena noleggiate dalla mappa).
  int _aperturaStorico = 0;

  List<Widget> get _sezioni => [
        const MapScreen(),
        HistoryScreen(key: ValueKey(_aperturaStorico)),
        const CommunityScreen(),
        const ProfileScreen(),
      ];

  void _onVoceToccata(int indice) {
    setState(() {
      if (indice == 1) _aperturaStorico++;
      _indiceSelezionato = indice;
      _sezioniVisitate.add(indice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack tiene in vita le sezioni e ne mostra una sola:
      // cambiando scheda non si perde lo stato (mappa, liste già caricate...).
      body: IndexedStack(
        index: _indiceSelezionato,
        children: [
          for (var i = 0; i < _sezioni.length; i++)
            _sezioniVisitate.contains(i) ? _sezioni[i] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSelezionato,
        onTap: _onVoceToccata,
        backgroundColor: Colori.bianco,
        selectedItemColor: Colori.verdePrimario,
        unselectedItemColor: Colori.grigioTesto,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mappa'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Storico'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profilo'),
        ],
      ),
    );
  }
}
