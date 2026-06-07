import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlpineTheme {
  static const Color forest = Color(0xFF1F2D24);
  static const Color forestLight = Color(0xFF3A4A3E);
  static const Color forestDeep = Color(0xFF0F1A14);
  static const Color cream = Color(0xFFF4F0E8);
  static const Color creamLight = Color(0xFFFAF7F0);
  static const Color creamDark = Color(0xFFE8E1D0);
  static const Color terracotta = Color(0xFFC8552A);
  static const Color terracottaDark = Color(0xFFA6431F);
  static const Color sage = Color(0xFF6B7F65);
  static const Color sageLight = Color(0xFF9CAB94);
  static const Color stone = Color(0xFF8B8680);
  static const Color stoneLight = Color(0xFFB8B3A8);
  static const Color charcoal = Color(0xFF1A1A1A);
  static const Color ink = Color(0xFF2A2A28);
  static const Color divider = Color(0xFFDCD5C5);
  static const Color mountainBlue = Color(0xFF4A5D6B);

  static TextStyle display({
    double size = 32,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      color: color ?? charcoal,
      height: height ?? 1.05,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? ink,
      height: height ?? 1.5,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle label({
    double size = 11,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double letterSpacing = 2.0,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      color: color ?? stone,
      letterSpacing: letterSpacing,
      height: 1.2,
    );
  }

  static TextStyle mono({
    double size = 12,
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.dmMono(
      fontSize: size,
      color: color ?? charcoal,
      fontWeight: weight,
      letterSpacing: 0.5,
    );
  }
}

class AlpineAssets {
  static const String hero = 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1600&q=80';
  static const String mountainRange = 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=1600&q=80';
  static const String campfire = 'https://images.unsplash.com/photo-1487730116645-74489c95b41b?w=800&q=80';
  static const String hiker = 'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=800&q=80';
  static const String gear = 'https://images.unsplash.com/photo-1581605405669-fcdf81165afa?w=800&q=80';

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

  static const String brandEiger = 'https://images.unsplash.com/photo-1577681616509-3a9a7b2c7a1c?w=800&q=80';
}
