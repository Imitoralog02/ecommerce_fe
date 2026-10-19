import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String serifFont = 'NotoSerif';
  static const String sansFont = 'Inter';

  /// Book-style serif used by the Figma splash / onboarding headlines.
  static const String bookSerifFont = 'NotoSerif';

  static const TextStyle splashLogo = TextStyle(
    fontFamily: bookSerifFont,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle splashHeadline = TextStyle(
    fontFamily: bookSerifFont,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.22,
    color: AppColors.textPrimary,
  );

  // NÉORA Luxury Brand Masthead (Serif)
  static const TextStyle brandLogo = TextStyle(
    fontFamily: serifFont,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.8,
    color: AppColors.textPrimary,
  );

  static const TextStyle brandLogoSmall = TextStyle(
    fontFamily: serifFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.4,
    color: AppColors.textPrimary,
  );

  // Editorial Serif Headlines
  static const TextStyle editorialHeadline = TextStyle(
    fontFamily: serifFont,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.3,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle editorialTitle = TextStyle(
    fontFamily: serifFont,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // Section Headers
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: serifFont,
    fontSize: 16.5,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionSubAction = TextStyle(
    fontFamily: sansFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    decoration: TextDecoration.underline,
  );

  // Product Card Titles & Details
  static const TextStyle cardTitle = TextStyle(
    fontFamily: serifFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle productTitleLarge = TextStyle(
    fontFamily: serifFont,
    fontSize: 23,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  // Price Styling (VND currency)
  static const TextStyle price = TextStyle(
    fontFamily: sansFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle priceLarge = TextStyle(
    fontFamily: sansFont,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
    color: AppColors.primaryBurgundy,
  );

  // Body & Descriptions
  static const TextStyle body = TextStyle(
    fontFamily: sansFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFont,
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textMuted,
  );

  // Tabs & Pills
  static const TextStyle categoryTab = TextStyle(
    fontFamily: sansFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Button Labels
  static const TextStyle button = TextStyle(
    fontFamily: sansFont,
    fontSize: 13.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  // Architectural / Subtitle codes
  static const TextStyle architecturalCode = TextStyle(
    fontFamily: sansFont,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle watermarkNumber = TextStyle(
    fontFamily: serifFont,
    fontSize: 105,
    fontWeight: FontWeight.w900,
    letterSpacing: -2.0,
    height: 0.9,
    color: Color(0x0C000000),
  );
}
