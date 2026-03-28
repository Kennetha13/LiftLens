import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0D0D14);
  static const Color surface = Color(0xFF161622);
  static const Color accent = Color(0xFFC8F53A);
  static const Color accentDark = Color(0xFF8BC820);
  static const Color orange = Color(0xFFFF9A3C);
  static const Color orangeDark = Color(0xFFFF6B35);
  static const Color red = Color(0xFFFF4B4B);
  static const Color purple = Color(0xFFA78BFA);
  static const Color purpleDark = Color(0xFF6366F1);
  static const Color purpleBright = Color(0xFFA855F7);
  static const Color white = Colors.white;
  static const Color cardBg = Color(0x0AFFFFFF);
  static const Color cardBorder = Color(0x12FFFFFF);
  static const Color glassBg = Color(0x0DFFFFFF);
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color textMuted = Color(0x66FFFFFF);
  static const Color textDimmed = Color(0x40FFFFFF);
}

class AppTextStyles {
  static const TextStyle headline = TextStyle(
    color: AppColors.white,
    fontWeight: FontWeight.w800,
    fontSize: 24,
    letterSpacing: -0.5,
  );
  static const TextStyle title = TextStyle(
    color: AppColors.white,
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );
  static const TextStyle sectionLabel = TextStyle(
    color: AppColors.textDimmed,
    fontWeight: FontWeight.w700,
    fontSize: 10,
    letterSpacing: 1.2,
  );
  static const TextStyle body = TextStyle(
    color: AppColors.white,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle caption = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );
}

class AppDecorations {
  static BoxDecoration glassCard = BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.cardBorder),
  );

  static BoxDecoration glass = BoxDecoration(
    color: AppColors.glassBg,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.glassBorder),
  );

  static BoxDecoration accentGlow = BoxDecoration(
    color: AppColors.accent,
    borderRadius: BorderRadius.circular(14),
  );
}
