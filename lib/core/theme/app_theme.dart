import 'package:flutter/material.dart';

/// Design tokens extracted from Figma design
/// Light mode: node-id=92-1679
/// Dark mode: node-id=92-1730

class AppColors {
  // Primary
  static const Color primary500 = Color(0xFFFF6900);
  static const Color primary600 = Color(0xFFF54900);

  // Neutral - Light
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA1A1A1);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // Status
  static const Color successGreen = Color(0xFF00A63E);
  static const Color success50 = Color(0xFFF0FDF4);
  static const Color success500 = Color(0xFF00C950);
  static const Color success700 = Color(0xFF008236);
  static const Color errorRed = Color(0xFFFB2C36);

  // Process / Info
  static const Color process600 = Color(0xFF155DFC);
  static const Color process700 = Color(0xFF1447E6);

  // Static
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Quick-Commerce Header Gradient - Light
  static const Color headerGradientStart = Color(0xFFFFF2D6);
  static const Color headerGradientMiddle = Color(0xFFFFE5B3);
  static const Color headerGradientEnd = Color(0xFFFFF8EE);

  // Quick-Commerce Header Gradient - Dark
  static const Color headerGradientDarkStart = Color(0xFF26201B);
  static const Color headerGradientDarkMiddle = Color(0xFF1E1A17);
  static const Color headerGradientDarkEnd = Color(0xFF171717);

  static const List<Color> headerGradientLight = [
    headerGradientStart,
    headerGradientMiddle,
    headerGradientEnd,
  ];

  static const List<Color> headerGradientDark = [
    headerGradientDarkStart,
    headerGradientDarkMiddle,
    headerGradientDarkEnd,
  ];

  // Bestsellers Card Backgrounds
  static const Color bestsellerCardBg = Color(0xFFF3F5F7);
  static const Color bestsellerCardDarkBg = Color(0xFF262626);
}

/// Spacing tokens (4, 8, 12, 16, 20, 24)
class AppSpacing {
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
}

/// Border radius tokens
class AppRadius {
  static const double r4 = 4.0;
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r10 = 10.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;

  static const BorderRadius rounded4 = BorderRadius.all(Radius.circular(r4));
  static const BorderRadius rounded6 = BorderRadius.all(Radius.circular(r6));
  static const BorderRadius rounded8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius rounded10 = BorderRadius.all(Radius.circular(r10));
  static const BorderRadius rounded12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius rounded16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius rounded20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius rounded24 = BorderRadius.all(Radius.circular(r24));
}

class AppTextStyles {
  /// Text-2: Roboto 500, 20px (auth heading)
  static TextStyle text2(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      fontSize: 20,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral800,
    );
  }

  /// Text-3: Roboto 600, 18px (section headers)
  static TextStyle text3(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral900,
    );
  }

  /// Text-5: Roboto 400, 14px (body text)
  static TextStyle text5(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral800,
    );
  }

  /// Text-5 for dark mode category labels (semibold in dark)
  static TextStyle text5Category(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: isDark ? FontWeight.w600 : FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: isDark ? AppColors.neutral200 : AppColors.neutral800,
    );
  }

  /// Text-6: Roboto 400, 12px (small text)
  static TextStyle text6(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 1.17,
      color: isDark ? AppColors.neutral300 : AppColors.neutral800,
    );
  }

  /// Price text: bold 18px
  static TextStyle priceText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.17,
      color: isDark ? AppColors.white : AppColors.neutral900,
    );
  }

  /// Strikethrough price
  static TextStyle originalPriceText(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: AppColors.neutral500,
      decoration: TextDecoration.lineThrough,
    );
  }

  /// Discount text
  static TextStyle discountText(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.17,
      color: AppColors.primary500,
    );
  }

  /// Text-1: Roboto 600, 24px (large price)
  static TextStyle text1(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 24,
      height: 1.17,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  /// Text-4: Roboto 600, 16px (section headers in product detail)
  static TextStyle text4(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.17,
      color: isDark ? AppColors.neutral100 : AppColors.black,
    );
  }

  /// Body text with 1.5x line height for descriptions
  static TextStyle bodyText(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      color: isDark ? AppColors.neutral300 : AppColors.neutral800,
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.primary600,
        surface: AppColors.white,
        onSurface: AppColors.neutral900,
        outline: AppColors.neutral200,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutral50,
        selectedItemColor: AppColors.primary500,
        unselectedItemColor: AppColors.neutral800,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: AppColors.neutral100,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.neutral900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary500,
        secondary: AppColors.primary600,
        surface: AppColors.neutral900,
        onSurface: AppColors.neutral200,
        outline: AppColors.neutral800,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral900,
        foregroundColor: AppColors.neutral200,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.neutral800,
        selectedItemColor: AppColors.primary500,
        unselectedItemColor: AppColors.neutral300,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutral800,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: AppColors.neutral800,
    );
  }
}
