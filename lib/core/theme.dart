import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const paletteBlue = Color(0xFFB0D0D3);
const paletteRose = Color(0xFFC08497);
const paletteCoral = Color(0xFFF7AF9D);
const paletteSand = Color(0xFFF7E3AF);
const paletteCream = Color(0xFFF3EEC3);
const paletteInk = Color(0xFF493840);
const paletteMuted = Color(0xFF725C64);

const nightBackground = Color(0xFF191A18);
const nightSurface = Color(0xFF242521);
const nightSurfaceRaised = Color(0xFF30312C);
const nightText = Color(0xFFE8E3D8);
const nightMutedText = Color(0xFFB7B0A4);
const nightRose = Color(0xFFD4A79A);
const nightSage = Color(0xFFB5C4B5);
const nightOutline = Color(0xFF4A4A42);

// Keep these visualization colors stable when changing the interface palette.
const teal = Color(0xFF089981);
const neonTeal = Color(0xFF00D2A0);
const chartGreen = Color(0xFF089981);
const chartRed = Color(0xFFF23645);
const chartGridLight = Color(0xFFE2E8F0);
const chartGridDark = Color(0xFF1E293B);

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
    seedColor: paletteRose,
    brightness: dark ? Brightness.dark : Brightness.light,
  );

  final scheme = baseScheme.copyWith(
    primary: dark ? nightRose : paletteRose,
    onPrimary: dark ? nightBackground : paletteInk,
    primaryContainer: dark ? const Color(0xFF42332F) : paletteSand,
    onPrimaryContainer: dark ? const Color(0xFFF0D8D0) : paletteInk,
    secondary: dark ? nightSage : paletteBlue,
    onSecondary: dark ? nightBackground : paletteInk,
    secondaryContainer: dark ? const Color(0xFF343B34) : paletteBlue,
    onSecondaryContainer: dark ? const Color(0xFFDCE6D9) : paletteInk,
    tertiary: dark ? const Color(0xFFD8C19B) : paletteCoral,
    onTertiary: dark ? nightBackground : paletteInk,
    tertiaryContainer: dark ? const Color(0xFF403A2F) : paletteCoral,
    onTertiaryContainer: dark ? const Color(0xFFF0E3CA) : paletteInk,
    error: dark ? const Color(0xFFE5A39B) : paletteRose,
    onError: dark ? nightBackground : paletteInk,
    errorContainer: dark ? const Color(0xFF4A302D) : paletteCoral,
    onErrorContainer: dark ? const Color(0xFFF6DAD5) : paletteInk,
    surfaceTint: dark ? nightRose : paletteRose,
    surface: dark ? nightSurface : Colors.white,
    onSurface: dark ? nightText : paletteInk,
    onSurfaceVariant: dark ? nightMutedText : paletteMuted,
    outline: dark ? nightOutline : paletteMuted,
    outlineVariant: dark ? nightOutline : paletteBlue.withValues(alpha: 0.8),
    surfaceContainerLowest: dark ? nightBackground : Colors.white,
    surfaceContainerLow: dark ? const Color(0xFF20211E) : Colors.white,
    surfaceContainer: dark ? const Color(0xFF292A25) : Colors.white,
    surfaceContainerHigh: dark ? const Color(0xFF2D2E29) : paletteCream,
    surfaceContainerHighest: dark ? nightSurfaceRaised : paletteCream,
  );

  final mainFont = GoogleFonts.plusJakartaSans().fontFamily;

  return ThemeData(
    useMaterial3: true,
    fontFamily: mainFont,
    colorScheme: scheme,
    shadowColor: dark ? Colors.black : paletteRose,
    scaffoldBackgroundColor: dark ? nightBackground : Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? nightBackground : Colors.white,
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
      filled: false,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(
          fontFamily: mainFont,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: Colors.transparent),
        textStyle: TextStyle(
          fontFamily: mainFont,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
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
