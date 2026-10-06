/// Tipo di recensione (RF13). Il [codice] è quello salvato su Firestore,
/// identico all'enum Kotlin (`GUASTO`, `OPINIONE`, `CONSIGLIO`).
enum ReviewType {
  guasto('GUASTO'),
  opinione('OPINIONE'),
  consiglio('CONSIGLIO');

  const ReviewType(this.codice);

  final String codice;

  static ReviewType daCodice(String? codice) {
    return ReviewType.values.firstWhere(
      (tipo) => tipo.codice == codice,
      orElse: () => ReviewType.opinione,
    );
  }
}

/// Una recensione della community (RF12–RF14).
class Review {
  final String id;
  final String userId;
  final String autoreNome;
  final ReviewType tipo;
  final String testo;
  final int timestamp;
  final String? vehicleId;

  const Review({
    required this.id,
    required this.userId,
    required this.autoreNome,
    required this.tipo,
    required this.testo,
    required this.timestamp,
    required this.vehicleId,
  });
}
