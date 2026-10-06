import 'package:flutter/material.dart';

/// Palette GoRide: verde bici + arancio energia elettrica.
/// Stessi valori di `res/values/colors.xml` dell'app Kotlin.
class Colori {
  Colori._();

  static const Color verdePrimario = Color(0xFF2E7D32);
  static const Color verdeScuro = Color(0xFF1B5E20);
  static const Color verdeChiaro = Color(0xFFA5D6A7);

  static const Color arancioEbike = Color(0xFFEF6C00);
  static const Color arancioScuro = Color(0xFFE65100);
  static const Color arancioChiaro = Color(0xFFFFCC80);

  static const Color bianco = Color(0xFFFFFFFF);
  static const Color nero = Color(0xFF000000);
  static const Color grigioSfondo = Color(0xFFF5F5F5);
  static const Color grigioTesto = Color(0xFF616161);
  static const Color grigioChiaro = Color(0xFFE0E0E0);

  /// Stato batteria (RF2.1).
  static const Color batteriaAlta = Color(0xFF2E7D32);
  static const Color batteriaMedia = Color(0xFFF9A825);
  static const Color batteriaBassa = Color(0xFFC62828);

  static const Color errore = Color(0xFFC62828);

  /// Stesse soglie di VehicleDetailFragment: >= 60 alta, >= 25 media.
  static Color batteria(int percentuale) {
    if (percentuale >= 60) return batteriaAlta;
    if (percentuale >= 25) return batteriaMedia;
    return batteriaBassa;
  }
}
