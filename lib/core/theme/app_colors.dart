import 'package:flutter/material.dart';

class AppColors {
  // Primary - Lotte Giants Navy & Red
  static const Color primary = Color(0xFF062045);
  static const Color primaryDark = Color(0xFF041530);
  static const Color accent = Color(0xFFC41919);
  static const Color accentLight = Color(0xFFFF3B3B);

  // Background - Light
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundLight = Color(0xFFF0F1F6);

  // Text
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Accent Colors
  static const Color win = Color(0xFF16A34A);
  static const Color lose = Color(0xFFC41919);
  static const Color draw = Color(0xFF9E9E9E);
  static const Color gold = Color(0xFFD4A017);
  static const Color silver = Color(0xFF8E8E8E);
  static const Color bronze = Color(0xFFB87333);

  // Divider
  static const Color divider = Color(0xFFE5E7EB);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2A5C), Color(0xFF062045)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE52020), Color(0xFFC41919)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FC)],
  );

  static const LinearGradient scoreGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF062045), Color(0xFF0D2A5C)],
  );

  // KBO Team Colors
  static const Map<String, Color> teamColors = {
    '롯데': Color(0xFF062045),
    'KIA': Color(0xFFEA0029),
    'SSG': Color(0xFFCE0E2D),
    '삼성': Color(0xFF074CA1),
    '두산': Color(0xFF131230),
    '한화': Color(0xFFFF6600),
    'NC': Color(0xFF315288),
    '키움': Color(0xFF820024),
    'KT': Color(0xFF000000),
    'LG': Color(0xFFC30452),
  };

  static Color getTeamColor(String team) {
    return teamColors[team] ?? primary;
  }

  // Error
  static const Color error = Color(0xFFFF5252);
}
