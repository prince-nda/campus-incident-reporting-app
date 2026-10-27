import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Student theme uses a light app bar; staff theme swaps in Deep Pine so
/// staff can tell at a glance that they are in the privileged role.
ThemeData buildTheme({bool staff = false}) {
  final base = ThemeData(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.pine).copyWith(
    primary: AppColors.pine,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.ink,
    error: AppColors.urgent,
    outline: AppColors.stone,
    surfaceTint: Colors.transparent,
  );
  final body = GoogleFonts.interTextTheme(base.textTheme)
      .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);
  TextStyle h(double size, [FontWeight w = FontWeight.w800]) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: w, color: AppColors.ink);
  final text = body.copyWith(
    headlineSmall: h(24),
    titleLarge: h(20),
    titleMedium: h(16, FontWeight.w700),
    titleSmall: h(14, FontWeight.w700),
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.stone),
  );
  final fg = staff ? Colors.white : AppColors.ink;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: staff ? AppColors.deepPine : AppColors.paper,
      foregroundColor: fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: h(18).copyWith(color: fg),
      systemOverlayStyle:
          staff ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.stone),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.pine, width: 1.6)),
      errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.urgent)),
      focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.urgent, width: 1.6)),
      hintStyle: const TextStyle(color: AppColors.slate),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.pine,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(64, 48),
        side: const BorderSide(color: AppColors.stone),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.pine),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.pine,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.pine.withValues(alpha: 0.12),
      labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.stone, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}