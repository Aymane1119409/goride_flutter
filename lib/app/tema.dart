import 'package:flutter/material.dart';

import '../util/colori.dart';

/// Tema dell'app (equivalente di `Theme.GoRide` in themes.xml).
ThemeData creaTema() {
  final schema = ColorScheme.fromSeed(
    seedColor: Colori.verdePrimario,
    primary: Colori.verdePrimario,
    onPrimary: Colori.bianco,
    secondary: Colori.arancioEbike,
    onSecondary: Colori.bianco,
    error: Colori.errore,
  );

  return ThemeData(
    colorScheme: schema,
    scaffoldBackgroundColor: Colori.bianco,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colori.bianco,
      foregroundColor: Colori.nero,
      elevation: 0,
    ),
    // "Widget.GoRide.Button": 48dp di altezza minima per l'accessibilità, testo 16sp.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colori.verdePrimario,
        foregroundColor: Colori.bianco,
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        textStyle: const TextStyle(fontSize: 16),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    cardTheme: const CardThemeData(
      color: Colori.bianco,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}

/// Etichetta sopra un valore ("TextAppearance.GoRide.Etichetta").
const TextStyle stileEtichetta = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: Colori.grigioTesto,
);

/// Valore grande in grassetto ("TextAppearance.GoRide.Valore").
const TextStyle stileValore = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colori.nero,
);
