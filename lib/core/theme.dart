import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const teal = Color(0xFF089981); // TradingView signature emerald
const neonTeal = Color(0xFF00D2A0);
const ink = Color(0xFF0F172A);
const slate = Color(0xFF64748B);
const chartGreen = Color(0xFF089981);
const chartRed = Color(0xFFF23645);

const assetColors = [
  Color(0xFF3B82F6), // Vibrant Blue (Stocks)
  Color(0xFF8B5CF6), // Royal Violet (Mutual funds)
  Color(0xFFF59E0B), // Warm Amber (Fixed deposits)
];

const categoryColors = [
  Color(0xFF089981), // Groceries - Emerald
  Color(0xFF3B82F6), // Dining - Blue
  Color(0xFF8B5CF6), // Shopping - Purple
  Color(0xFFF59E0B), // Transport - Amber
  Color(0xFF06B6D4), // Home - Cyan
  Color(0xFFEC4899), // Health - Pink
  Color(0xFF64748B), // Subscriptions - Slate
];

ThemeData appTheme(bool dark) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: teal,
    brightness: dark ? Brightness.dark : Brightness.light,
  );

  final scheme = baseScheme.copyWith(
    primary: dark ? neonTeal : teal,
    surface: dark ? const Color(0xFF131A24) : Colors.white,
    onSurface: dark ? const Color(0xFFF1F5F9) : ink,
    onSurfaceVariant: dark ? const Color(0xFF94A3B8) : slate,
    outlineVariant: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
    surfaceContainerHighest: dark ? const Color(0xFF1A2332) : const Color(0xFFF1F5F9),
  );

  final mainFont = GoogleFonts.plusJakartaSans().fontFamily;

  return ThemeData(
    useMaterial3: true,
    fontFamily: mainFont,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? const Color(0xFF0A0E14) : const Color(0xFFF8FAFC),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? const Color(0xFF0A0E14) : const Color(0xFFF8FAFC),
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: mainFont,
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.6),
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(color: scheme.outlineVariant),
        textStyle: TextStyle(fontFamily: mainFont, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}