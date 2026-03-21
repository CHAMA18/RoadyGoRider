import 'package:flutter/material.dart';

class AppColors {
  static const Color ink = Color(0xFF0D1B2A);
  static const Color slate = Color(0xFF415A77);
  static const Color snow = Color(0xFFF8FAFC);
  static const Color cloud = Color(0xFFE2E8F0);
  static const Color brand = Color(0xFFE53935);
  static const Color coral = Color(0xFFFF7A59);
  static const Color gold = Color(0xFFFFB703);
  static const Color mint = Color(0xFF2A9D8F);
}

class AppTypography {
  static const double size = 18;
}

TextTheme _withUnifiedSize(TextTheme textTheme) {
  TextStyle? applySize(TextStyle? style) =>
      style?.copyWith(fontSize: AppTypography.size);

  return textTheme.copyWith(
    displayLarge: applySize(textTheme.displayLarge),
    displayMedium: applySize(textTheme.displayMedium),
    displaySmall: applySize(textTheme.displaySmall),
    headlineLarge: applySize(textTheme.headlineLarge),
    headlineMedium: applySize(textTheme.headlineMedium),
    headlineSmall: applySize(textTheme.headlineSmall),
    titleLarge: applySize(textTheme.titleLarge),
    titleMedium: applySize(textTheme.titleMedium),
    titleSmall: applySize(textTheme.titleSmall),
    bodyLarge: applySize(textTheme.bodyLarge),
    bodyMedium: applySize(textTheme.bodyMedium),
    bodySmall: applySize(textTheme.bodySmall),
    labelLarge: applySize(textTheme.labelLarge),
    labelMedium: applySize(textTheme.labelMedium),
    labelSmall: applySize(textTheme.labelSmall),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Satoshi',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      secondary: AppColors.coral,
      surface: Colors.white,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.snow,
    textTheme: _withUnifiedSize(
      base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: AppColors.cloud),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.brand.withAlpha(25),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Satoshi',
          fontSize: AppTypography.size,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.brand : AppColors.slate,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppColors.brand : AppColors.slate,
          size: 22,
        );
      }),
    ),
  );
}

ThemeData buildDarkAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Satoshi',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      brightness: Brightness.dark,
      primary: AppColors.brand,
      secondary: AppColors.coral,
      surface: const Color(0xFF0F172A),
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF020617),
    textTheme: _withUnifiedSize(
      base.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF0F172A),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: const BorderSide(color: Color(0xFF1E293B)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF020617),
      indicatorColor: AppColors.brand.withAlpha(35),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Satoshi',
          fontSize: AppTypography.size,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : const Color(0xFF94A3B8),
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? Colors.white : const Color(0xFF94A3B8),
          size: 22,
        );
      }),
    ),
  );
}
