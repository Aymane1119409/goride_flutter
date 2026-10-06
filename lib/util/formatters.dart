/// Funzioni di formattazione condivise (equivalente di `util/Formatters.kt`).
/// Scritte a mano per non aggiungere dipendenze (es. `intl`) non presenti negli appunti.
class Formatters {
  Formatters._();

  static const List<String> _mesi = [
    'gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno',
    'luglio', 'agosto', 'settembre', 'ottobre', 'novembre', 'dicembre',
  ];

  static String _due(int n) => n.toString().padLeft(2, '0');

  /// 1.5 → "1,50 €" (come `String.format(Locale.ITALY, "%.2f €")`).
  static String euro(double importo) {
    return '${importo.toStringAsFixed(2).replaceAll('.', ',')} €';
  }

  /// 0.28 → "0,28 €/min"
  static String euroAlMinuto(double importo) {
    return '${importo.toStringAsFixed(2).replaceAll('.', ',')} €/min';
  }

  /// 754 secondi → "12m 34s"; 3725 secondi → "1h 02m".
  static String durata(int secondi) {
    final ore = secondi ~/ 3600;
    final minuti = (secondi % 3600) ~/ 60;
    final sec = secondi % 60;
    if (ore > 0) return '${ore}h ${_due(minuti)}m';
    return '${minuti}m ${_due(sec)}s';
  }

  /// Millisecondi rimanenti → "14:32" (il timer della corsa).
  static String minutiSecondi(int millis) {
    final totaleSecondi = millis < 0 ? 0 : millis ~/ 1000;
    return '${_due(totaleSecondi ~/ 60)}:${_due(totaleSecondi % 60)}';
  }

  /// → "1 ottobre 2026, 14:05"
  static String dataOra(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${d.day} ${_mesi[d.month - 1]} ${d.year}, ${_due(d.hour)}:${_due(d.minute)}';
  }

  /// → "01/10/2026"
  static String dataBreve(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${_due(d.day)}/${_due(d.month)}/${d.year}';
  }
}
