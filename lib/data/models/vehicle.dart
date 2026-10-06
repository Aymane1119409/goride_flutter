/// Tipologia di mezzo (RF2).
///
/// Il [codice] è la stringa salvata su Firestore: deve essere IDENTICA a quella
/// dell'app Kotlin (`VehicleType.CLASSIC` / `VehicleType.EBIKE`), altrimenti le
/// due app non leggerebbero le stesse corse.
enum VehicleType {
  classic('CLASSIC'),
  ebike('EBIKE');

  const VehicleType(this.codice);

  final String codice;

  /// Equivalente di `VehicleType.valueOf(...)`, ma senza crash su valori sconosciuti.
  static VehicleType daCodice(String? codice) {
    return VehicleType.values.firstWhere(
      (tipo) => tipo.codice == codice,
      orElse: () => VehicleType.classic,
    );
  }
}

/// Un mezzo disponibile al noleggio.
///
/// Immutabile (tutti i campi `final`). `batteriaPercentuale` e `autonomiaKm`
/// sono nullable: hanno senso solo per le e-bike (RF2.1).
class Vehicle {
  final String id;
  final String nome;
  final VehicleType tipo;
  final double lat;
  final double lon;
  final int? batteriaPercentuale;
  final double? autonomiaKm;
  final double tariffaSbloccoEuro;
  final double tariffaAlMinutoEuro;
  final bool disponibile;

  const Vehicle({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.lat,
    required this.lon,
    required this.batteriaPercentuale,
    required this.autonomiaKm,
    required this.tariffaSbloccoEuro,
    required this.tariffaAlMinutoEuro,
    required this.disponibile,
  });

  /// Comodo nella UI: evita di ripetere il confronto.
  bool get isEbike => tipo == VehicleType.ebike;
}
