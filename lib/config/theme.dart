import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF2D3142),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2D3142),
        secondary: Color(0xFFFF6B6B),
        surface: Colors.white,
        background: Color(0xFFF8F9FA),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF2D3142),
        onBackground: Color(0xFF2D3142),
      ),
      
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3142),
          letterSpacing: -0.5,
        ),
        displayMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3142),
          letterSpacing: -0.3,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: Color(0xFF4F5D75),
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: Color(0xFF6C757D),
        ),
      ),
      
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF2D3142)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D3142),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF6B6B),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2D3142), width: 2),
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF51CF66);
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF51CF66).withOpacity(0.5);
          }
          return Colors.grey[300];
        }),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE9ECEF),
        selectedColor: const Color(0xFF2D3142),
        deleteIconColor: const Color(0xFF6C757D),
        labelStyle: const TextStyle(color: Color(0xFF2D3142)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
  
  // Colores personalizados
  static const Color mirrorGlass = Color(0xFFE9ECEF);
  static const Color gogginsBrutal = Color(0xFFFF6B6B);
  static const Color motivationalSoft = Color(0xFF51CF66);
  static const Color stickyNoteYellow = Color(0xFFFFC107);
  static const Color primaryDark = Color(0xFF2D3142);
  static const Color backgroundLight = Color(0xFFF8F9FA);
}
