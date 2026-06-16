import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Global colors
  static const Color darkCharcoal = Color(0xFF121212);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color secondaryDark = Color(0xFF1E1E1E);

  // Fashion store theme colors (Sophisticated, high-fashion monochrome and gold)
  static const Color fashionPrimary = Color(0xFF1A1A1A);
  static const Color fashionAccent = Color(0xFFC5A880); // Champagne/Gold
  static const Color fashionBg = Color(0xFFFAFAFA);
  static const Color fashionCardBg = Colors.white;

  // Food delivery theme colors (Warm, spicy, appetizing orange and reds)
  static const Color foodPrimary = Color(0xFFFF5722); // Vibrant Orange
  static const Color foodAccent = Color(0xFFFFD54F); // Warm Amber
  static const Color foodBg = Color(0xFFFFFBF9);
  static const Color foodCardBg = Colors.white;

  // Groceries theme colors (Fresh, organic, botanical green)
  static const Color groceryPrimary = Color(0xFF2E7D32); // Emerald Green
  static const Color groceryAccent = Color(0xFF81C784); // Mint Accent
  static const Color groceryBg = Color(0xFFF5F9F6);
  static const Color groceryCardBg = Colors.white;

  // Base Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: darkCharcoal,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: darkCharcoal,
        secondary: Color(0xFF6200EE),
        surface: Colors.white,
        error: Color(0xFFB00020),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: darkCharcoal),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: darkCharcoal),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: darkCharcoal),
        titleTextStyle: TextStyle(color: darkCharcoal, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkCharcoal,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }

  // Base Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: darkCharcoal,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: Color(0xFFBB86FC),
        surface: secondaryDark,
        error: Color(0xFFCF6679),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCharcoal,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: secondaryDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: darkCharcoal,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}
