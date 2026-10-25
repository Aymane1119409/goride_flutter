import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../data/models/vehicle.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';

/// Dettaglio del mezzo in un bottom sheet sopra la mappa (RF2.1, RF3).
/// Equivalente di `VehicleDetailFragment` (BottomSheetDialogFragment).
///
/// Si chiude restituendo `true` se l'utente ha premuto "Noleggia":
/// sarà la mappa a chiedere la durata e a registrare il noleggio.
class VehicleDetailSheet extends StatelessWidget {
  const VehicleDetailSheet({super.key, required this.mezzo});

  final Vehicle mezzo;

  @override
  Widget build(BuildContext context) {
    final batteria = mezzo.batteriaPercentuale ?? 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              mezzo.nome,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              mezzo.isEbike ? 'Bici elettrica' : 'Bici classica',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: mezzo.isEbike ? Colori.arancioEbike : Colori.verdePrimario,
              ),
            ),
            // Batteria e autonomia solo per le e-bike (visibility GONE in Kotlin).
            if (mezzo.isEbike) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _Valore(
                      etichetta: 'Batteria',
                      valore: '$batteria%',
                      // Il colore aiuta, ma il numero resta l'informazione principale.
                      colore: Colori.batteria(batteria),
                    ),
                  ),
                  Expanded(
                    child: _Valore(
                      etichetta: 'Autonomia',
                      valore: '${(mezzo.autonomiaKm ?? 0).toStringAsFixed(0)} km',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            const Divider(height: 1, color: Colori.grigioChiaro),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Valore(
                    etichetta: 'Sblocco',
                    valore: Formatters.euro(mezzo.tariffaSbloccoEuro),
                  ),
                ),
                Expanded(
                  child: _Valore(
                    etichetta: 'Al minuto',
                    valore: Formatters.euroAlMinuto(mezzo.tariffaAlMinutoEuro),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Noleggia'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etichetta grigia + valore grande (composizione di widget, lezione 3.0).
class _Valore extends StatelessWidget {
  const _Valore({required this.etichetta, required this.valore, this.colore});

  final String etichetta;
  final String valore;
  final Color? colore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etichetta, style: stileEtichetta),
        Text(valore, style: stileValore.copyWith(color: colore)),
      ],
    );
  }
}
