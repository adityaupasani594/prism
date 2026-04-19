import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: PrismColors.primary,
        onPrimary: PrismColors.onPrimary,
        primaryContainer: PrismColors.primaryContainer,
        onPrimaryContainer: PrismColors.onPrimaryContainer,
        secondary: PrismColors.secondary,
        onSecondary: PrismColors.onSecondary,
        secondaryContainer: PrismColors.secondaryContainer,
        onSecondaryContainer: PrismColors.onSecondaryContainer,
        tertiary: PrismColors.tertiary,
        onTertiary: PrismColors.onTertiary,
        tertiaryContainer: PrismColors.tertiaryContainer,
        onTertiaryContainer: PrismColors.onTertiaryContainer,
        error: PrismColors.error,
        onError: PrismColors.onError,
        errorContainer: PrismColors.errorContainer,
        onErrorContainer: PrismColors.onErrorContainer,
        background: PrismColors.surfaceBright,
        onBackground: PrismColors.onBackground,
        surface: PrismColors.surface,
        onSurface: PrismColors.onSurface,
        surfaceVariant: PrismColors.surfaceVariant,
        onSurfaceVariant: PrismColors.onSurfaceVariant,
        outline: PrismColors.outline,
        outlineVariant: PrismColors.outlineVariant,
      ),
      scaffoldBackgroundColor: PrismColors.surfaceBright,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.02,
        ),
        headlineSmall: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: GoogleFonts.manrope(
          color: PrismColors.onSurface,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.inter(
          color: PrismColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          color: PrismColors.onSurface,
        ),
        bodySmall: GoogleFonts.inter(
          color: PrismColors.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.inter(
          color: PrismColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        labelMedium: GoogleFonts.inter(
          color: PrismColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
        labelSmall: GoogleFonts.inter(
          color: PrismColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
