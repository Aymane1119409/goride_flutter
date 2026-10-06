import 'package:flutter/material.dart';

import '../../util/colori.dart';

/// Barra bianca con il titolo in alto (come la TextView "titolo" di
/// fragment_history.xml e fragment_community.xml).
class Intestazione extends StatelessWidget {
  const Intestazione(this.titolo, {super.key});

  final String titolo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colori.bianco,
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        bottom: false,
        child: Text(
          titolo,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Messaggio centrale quando una lista è vuota ("stato_vuoto" nei layout Kotlin).
class StatoVuoto extends StatelessWidget {
  const StatoVuoto({super.key, required this.titolo, required this.messaggio});

  final String titolo;
  final String messaggio;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titolo,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(messaggio, style: const TextStyle(color: Colori.grigioTesto)),
        ],
      ),
    );
  }
}

/// Spinner mostrato solo durante il caricamento.
class Caricamento extends StatelessWidget {
  const Caricamento({super.key, required this.visibile});

  final bool visibile;

  @override
  Widget build(BuildContext context) {
    if (!visibile) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(top: 16),
      child: Center(
        child: CircularProgressIndicator(color: Colori.verdePrimario),
      ),
    );
  }
}

/// Mostra una SnackBar (equivalente di `Snackbar.make(...)`).
void mostraMessaggio(
  BuildContext context,
  String testo, {
  String? azione,
  VoidCallback? onAzione,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(testo),
      action: azione != null && onAzione != null
          ? SnackBarAction(label: azione, onPressed: onAzione)
          : null,
    ),
  );
}
