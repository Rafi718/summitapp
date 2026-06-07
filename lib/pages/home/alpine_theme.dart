import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color surfaceAlt = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color accent = Color(0xFF111111);
  static const Color brand = Color(0xFF1A3329);
  static const Color brandDark = Color(0xFF0F2818);
  static const Color sale = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
}

class AppText {
  static TextStyle display({double size = 28, FontWeight weight = FontWeight.w700, Color? color, double height = 1.2}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? AppColors.textPrimary, height: height, letterSpacing: -0.3);
  }

  static TextStyle title({double size = 16, FontWeight weight = FontWeight.w600, Color? color}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? AppColors.textPrimary, height: 1.3);
  }

  static TextStyle body({double size = 14, FontWeight weight = FontWeight.w400, Color? color, double height = 1.5}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? AppColors.textPrimary, height: height);
  }

  static TextStyle caption({double size = 12, FontWeight weight = FontWeight.w400, Color? color}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? AppColors.textSecondary, height: 1.4);
  }

  static TextStyle label({double size = 11, FontWeight weight = FontWeight.w600, Color? color, double letterSpacing = 1.0}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? AppColors.textSecondary, letterSpacing: letterSpacing, height: 1.2);
  }

  static TextStyle button({double size = 14, FontWeight weight = FontWeight.w600, Color? color}) {
    return GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color ?? Colors.white, height: 1.2);
  }
}

class AppAssets {
  static const String hero = 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1600&q=80';
  static const String heroAlt = 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=1600&q=80';

  static const Map<int, String> categoryImages = {
    1: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400&q=80',
    2: 'https://images.unsplash.com/photo-1520256780061-e2a7b67a2a04?w=400&q=80',
    3: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&q=80',
    4: 'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?w=400&q=80',
    5: 'https://images.unsplash.com/photo-1577681616509-3a9a7b2c7a1c?w=400&q=80',
    6: 'https://images.unsplash.com/photo-1551442959-804204a214a7?w=400&q=80',
    7: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=400&q=80',
    8: 'https://images.unsplash.com/photo-1508873696983-2dfd5898f08b?w=400&q=80',
    9: 'https://images.unsplash.com/photo-1521302200778-33500795e128?w=400&q=80',
    10: 'https://images.unsplash.com/photo-1577803645773-f96470509666?w=400&q=80',
  };
}
