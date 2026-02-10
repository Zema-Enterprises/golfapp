import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette — matches wireframe design system
class AppColors {
  AppColors._();

  // Brand Greens
  static const primary = Color(0xFF2E7D32);       // green-main
  static const greenDark = Color(0xFF1B5E20);
  static const greenMain = Color(0xFF2E7D32);
  static const greenLight = Color(0xFF4CAF50);
  static const greenPale = Color(0xFFE8F5E9);

  // Blues
  static const secondary = Color(0xFF03A9F4);      // blue-sky
  static const blueSky = Color(0xFF03A9F4);
  static const blueLight = Color(0xFFB3E5FC);

  // Orange / Stars
  static const accent = Color(0xFFFF9800);          // orange
  static const orange = Color(0xFFFF9800);
  static const orangeLight = Color(0xFFFFE0B2);

  // Other accent colors
  static const yellow = Color(0xFFFFEB3B);
  static const purple = Color(0xFF9C27B0);
  static const red = Color(0xFFF44336);
  static const coral = Color(0xFFF44336);

  // Gray scale
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFEEEEEE);
  static const gray300 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFF9E9E9E);
  static const gray600 = Color(0xFF757575);
  static const gray700 = Color(0xFF616161);
  static const gray800 = Color(0xFF424242);
  static const white = Color(0xFFFFFFFF);

  // Semantic aliases
  static const surface = Color(0xFFF5F5F5);        // gray100
  static const background = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF424242);     // gray800
  static const textSecondary = Color(0xFF9E9E9E);   // gray500

  // Semantic status
  static const success = Color(0xFF4CAF50);         // greenLight
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF03A9F4);

  // UI Elements
  static const border = Color(0xFFE0E0E0);          // gray300
  static const divider = Color(0xFFEEEEEE);         // gray200

  // Dark Mode
  static const darkSurface = Color(0xFF1E1E2E);
  static const darkBackground = Color(0xFF121218);
  static const darkTextPrimary = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFF9E9E9E);
}

/// App spacing values
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// App border radius values
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double header = 30.0;
  static const double full = 999.0;
}

/// App shadows — matches wireframe box-shadow values
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withAlpha(20),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get drillCard => [
    BoxShadow(
      color: Colors.black.withAlpha(15),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get standard => [
    BoxShadow(
      color: Colors.black.withAlpha(38),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withAlpha(51),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// App gradients — reusable across screens
class AppGradients {
  AppGradients._();

  static const greenHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.greenMain, AppColors.greenDark],
  );

  static const welcomeScreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.greenMain, AppColors.greenDark],
  );

  static const kidMode = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.blueSky, Color(0xFF0288D1)],
  );

  static const purpleHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.purple, Color(0xFF7B1FA2)],
  );

  static const summaryScreen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.greenMain, AppColors.greenDark],
  );
}

/// App typography — Nunito (body) + Fredoka One (headings)
class AppTypography {
  AppTypography._();

  // Kid Mode - Fredoka One
  static TextStyle get kidHeadline => GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get kidBody => GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle get kidButton => GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  // App title / section headings - Fredoka One
  static TextStyle get appTitle => GoogleFonts.fredoka(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // Parent Mode - Nunito
  static TextStyle get headline => GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );

  static TextStyle get formTitle => GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );

  static TextStyle get title => GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static TextStyle get body => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static TextStyle get caption => GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get button => GoogleFonts.nunito(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get label => GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}

/// App theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.title.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.button,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.button,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.gray300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.gray300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        labelStyle: AppTypography.label.copyWith(color: AppColors.gray700),
        hintStyle: AppTypography.body.copyWith(color: AppColors.gray400),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.gray200,
        thickness: 1,
        space: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.greenMain,
        unselectedItemColor: AppColors.gray400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.title.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.button,
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
    );
  }
}
