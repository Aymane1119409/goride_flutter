import 'package:flutter/material.dart';

import '../../app/tema.dart';
import '../../data/models/ride.dart';
import '../../data/models/vehicle.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';

/// Dettaglio di una corsa: durata, mezzo, costo (RF11) — `RideDetailFragment`.
/// Riceve la `Ride` come argomento della rotta con nome.
class RideDetailScreen extends StatelessWidget {
  const RideDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final corsa = ModalRoute.of(context)!.settings.arguments as Ride;
    final isEbike = corsa.vehicleTipo == VehicleType.ebike;
    const divisore = Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colori.grigioChiaro),
    );

    return Scaffold(
      backgroundColor: Colori.grigioSfondo,
      appBar: AppBar(title: const Text('Dettaglio corsa')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Costo totale', style: stileEtichetta),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.euro(corsa.costoTotaleEuro),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colori.verdePrimario,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mezzo utilizzato', style: stileEtichetta),
                  Text(
                    corsa.vehicleNome,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isEbike ? 'Bici elettrica' : 'Bici classica',
                    style: TextStyle(
                      fontSize: 14,
                      color: isEbike ? Colori.arancioEbike : Colori.verdePrimario,
                    ),
                  ),
                  divisore,
                  const Text('Durata', style: stileEtichetta),
                  Text(
                    Formatters.durata(corsa.durataSecondi),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  divisore,
                  const Text('Data e ora', style: stileEtichetta),
                  Text(
                    Formatters.dataOra(corsa.startTimestamp),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Composizione del costo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _riga('Sblocco', Formatters.euro(corsa.tariffaSbloccoEuro)),
                  const SizedBox(height: 8),
                  _riga('Al minuto', Formatters.euroAlMinuto(corsa.tariffaAlMinutoEuro)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riga(String etichetta, String valore) {
    return Row(
      children: [
        Expanded(
          child: Text(etichetta, style: const TextStyle(color: Colori.grigioTesto)),
        ),
        Text(valore),
      ],
    );
  }
}
