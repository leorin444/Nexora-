import 'package:flutter/material.dart';

/// Nexora Design System Tokens & Theme Configuration
/// Specifications: Production Bento Grid & Intimate OS Specification v2.0
class NexoraColors {
  // Brand & Accents
  static const Color brandPrimaryLight = Color(0xFF6C5CE7);
  static const Color brandPrimaryDark = Color(0xFF8274ED);

  static const Color coupleAccentLight = Color(0xFFFD79A8);
  static const Color coupleAccentDark = Color(0xFFFF8FB8);

  static const Color vaultAccentLight = Color(0xFFE17055);
  static const Color vaultAccentDark = Color(0xFFF39C12);

  static const Color intelligenceLight = Color(0xFF0984E3);
  static const Color intelligenceDark = Color(0xFF48DBFB);

  static const Color successLight = Color(0xFF00B894);
  static const Color successDark = Color(0xFF55EFC4);

  // Surfaces & Canvas
  static const Color canvasLight = Color(0xFFF8F9FE);
  static const Color canvasDark = Color(0xFF0D0E15);

  static const Color cardSurfaceLight = Color(0xFFFFFFFF);
  static const Color cardSurfaceDark = Color(0xFF161822);

  static const Color strokeSubtleLight = Color(0xFFECEFF8);
  static const Color strokeSubtleDark = Color(0xFF222538);

  // Typography Tokens
  static const Color textPrimaryLight = Color(0xFF1E202B);
  static const Color textPrimaryDark = Color(0xFFF5F6FA);

  static const Color textSecondaryLight = Color(0xFF718096);
  static const Color textSecondaryDark = Color(0xFFA0AEC0);
}

class NexoraRadius {
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
}

class NexoraThemeExtension extends ThemeExtension<NexoraThemeExtension> {
  final Color brandPrimary;
  final Color coupleAccent;
  final Color vaultAccent;
  final Color intelligence;
  final Color success;
  final Color canvas;
  final Color cardSurface;
  final Color strokeSubtle;
  final Color textPrimary;
  final Color textSecondary;

  const NexoraThemeExtension({
    required this.brandPrimary,
    required this.coupleAccent,
    required this.vaultAccent,
    required this.intelligence,
    required this.success,
    required this.canvas,
    required this.cardSurface,
    required this.strokeSubtle,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  ThemeExtension<NexoraThemeExtension> copyWith({
    Color? brandPrimary,
    Color? coupleAccent,
    Color? vaultAccent,
    Color? intelligence,
    Color? success,
    Color? canvas,
    Color? cardSurface,
    Color? strokeSubtle,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return NexoraThemeExtension(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      coupleAccent: coupleAccent ?? this.coupleAccent,
      vaultAccent: vaultAccent ?? this.vaultAccent,
      intelligence: intelligence ?? this.intelligence,
      success: success ?? this.success,
      canvas: canvas ?? this.canvas,
      cardSurface: cardSurface ?? this.cardSurface,
      strokeSubtle: strokeSubtle ?? this.strokeSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  ThemeExtension<NexoraThemeExtension> lerp(
    covariant ThemeExtension<NexoraThemeExtension>? other,
    double t,
  ) {
    if (other is! NexoraThemeExtension) return this;
    return NexoraThemeExtension(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      coupleAccent: Color.lerp(coupleAccent, other.coupleAccent, t)!,
      vaultAccent: Color.lerp(vaultAccent, other.vaultAccent, t)!,
      intelligence: Color.lerp(intelligence, other.intelligence, t)!,
      success: Color.lerp(success, other.success, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      strokeSubtle: Color.lerp(strokeSubtle, other.strokeSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

class NexoraTheme {
  static const String primaryFont = 'PlusJakartaSans';
  static const String monoFont = 'JetBrainsMono';

  static NexoraThemeExtension of(BuildContext context) {
    return Theme.of(context).extension<NexoraThemeExtension>() ?? lightExtension;
  }

  static const NexoraThemeExtension lightExtension = NexoraThemeExtension(
    brandPrimary: NexoraColors.brandPrimaryLight,
    coupleAccent: NexoraColors.coupleAccentLight,
    vaultAccent: NexoraColors.vaultAccentLight,
    intelligence: NexoraColors.intelligenceLight,
    success: NexoraColors.successLight,
    canvas: NexoraColors.canvasLight,
    cardSurface: NexoraColors.cardSurfaceLight,
    strokeSubtle: NexoraColors.strokeSubtleLight,
    textPrimary: NexoraColors.textPrimaryLight,
    textSecondary: NexoraColors.textSecondaryLight,
  );

  static const NexoraThemeExtension darkExtension = NexoraThemeExtension(
    brandPrimary: NexoraColors.brandPrimaryDark,
    coupleAccent: NexoraColors.coupleAccentDark,
    vaultAccent: NexoraColors.vaultAccentDark,
    intelligence: NexoraColors.intelligenceDark,
    success: NexoraColors.successDark,
    canvas: NexoraColors.canvasDark,
    cardSurface: NexoraColors.cardSurfaceDark,
    strokeSubtle: NexoraColors.strokeSubtleDark,
    textPrimary: NexoraColors.textPrimaryDark,
    textSecondary: NexoraColors.textSecondaryDark,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: primaryFont,
      scaffoldBackgroundColor: NexoraColors.canvasLight,
      colorScheme: const ColorScheme.light(
        primary: NexoraColors.brandPrimaryLight,
        secondary: NexoraColors.coupleAccentLight,
        surface: NexoraColors.cardSurfaceLight,
        error: NexoraColors.vaultAccentLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: NexoraColors.textPrimaryLight,
      ),
      extensions: const [lightExtension],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: NexoraColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          fontFamily: primaryFont,
          color: NexoraColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: NexoraColors.cardSurfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: NexoraRadius.borderLg,
          side: const BorderSide(color: NexoraColors.strokeSubtleLight, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NexoraColors.cardSurfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: NexoraRadius.borderSm,
          borderSide: const BorderSide(color: NexoraColors.strokeSubtleLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NexoraRadius.borderSm,
          borderSide: const BorderSide(color: NexoraColors.strokeSubtleLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NexoraRadius.borderSm,
          borderSide: const BorderSide(color: NexoraColors.brandPrimaryLight, width: 1.8),
        ),
        labelStyle: const TextStyle(
          color: NexoraColors.textSecondaryLight,
          fontFamily: primaryFont,
        ),
        hintStyle: const TextStyle(
          color: NexoraColors.textSecondaryLight,
          fontFamily: primaryFont,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NexoraColors.brandPrimaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: NexoraRadius.borderSm,
          ),
          textStyle: const TextStyle(
            fontFamily: primaryFont,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        side: const BorderSide(color: NexoraColors.strokeSubtleLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: primaryFont,
      scaffoldBackgroundColor: NexoraColors.canvasDark,
      colorScheme: const ColorScheme.dark(
        primary: NexoraColors.brandPrimaryDark,
        secondary: NexoraColors.coupleAccentDark,
        surface: NexoraColors.cardSurfaceDark,
        error: NexoraColors.vaultAccentDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: NexoraColors.textPrimaryDark,
      ),
      extensions: const [darkExtension],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: NexoraColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          fontFamily: primaryFont,
          color: NexoraColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: NexoraColors.cardSurfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: NexoraRadius.borderLg,
          side: const BorderSide(color: NexoraColors.strokeSubtleDark, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NexoraColors.cardSurfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: NexoraRadius.borderSm,
          borderSide: const BorderSide(color: NexoraColors.strokeSubtleDark, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NexoraRadius.borderSm,
          borderSide: const BorderSide(color: NexoraColors.strokeSubtleDark, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NexoraRadius.borderSm,
          borderSide: const BorderSide(color: NexoraColors.brandPrimaryDark, width: 1.8),
        ),
        labelStyle: const TextStyle(
          color: NexoraColors.textSecondaryDark,
          fontFamily: primaryFont,
        ),
        hintStyle: const TextStyle(
          color: NexoraColors.textSecondaryDark,
          fontFamily: primaryFont,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NexoraColors.brandPrimaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: NexoraRadius.borderSm,
          ),
          textStyle: const TextStyle(
            fontFamily: primaryFont,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: NexoraRadius.borderSm),
        side: const BorderSide(color: NexoraColors.strokeSubtleDark),
      ),
    );
  }
}
