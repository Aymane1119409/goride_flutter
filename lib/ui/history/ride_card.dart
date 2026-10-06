import 'package:flutter/material.dart';

import '../../data/models/ride.dart';
import '../../data/models/vehicle.dart';
import '../../util/colori.dart';
import '../../util/formatters.dart';

/// Una riga dello storico (equivalente di item_ride.xml + RideViewHolder).
class RideCard extends StatelessWidget {
  const RideCard({super.key, required this.ride, required this.onTap});

  final Ride ride;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEbike = ride.vehicleTipo == VehicleType.ebike;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ride.vehicleNome,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    Formatters.euro(ride.costoTotaleEuro),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colori.verdePrimario,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.dataOra(ride.startTimestamp),
                style: const TextStyle(fontSize: 13, color: Colori.grigioTesto),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    isEbike ? 'Bici elettrica' : 'Bici classica',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isEbike ? Colori.arancioEbike : Colori.verdePrimario,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    Formatters.durata(ride.durataSecondi),
                    style: const TextStyle(fontSize: 13, color: Colori.grigioTesto),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
