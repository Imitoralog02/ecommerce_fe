import 'package:flutter/material.dart';

/// NÉORA — hệ thống màu cho trải nghiệm thời trang cao cấp.
/// Bảng màu Luxury Editorial:
/// Kem #F7F4EF · Mực #0E0E0E · Camel Gold #C8A97E · Amber #8B6840
class AppColors {
  AppColors._();

  // Backgrounds & Canvas (NÉORA Editorial Cream & Paper)
  static const Color background = Color(0xFFF7F4EF); // Kem nguyên bản --cream
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFBFAF7); // Giấy nền --paper
  static const Color studioGray = Color(0xFFF0EBE3); // --cream-dark
  static const Color cardSurface = Color(0xFFFBFAF7); // --paper
  static const Color cardBorder = Color(0xFFE2DDD8); // --border
  static const Color divider = Color(0xFFE2DDD8);
  static const Color border = cardBorder;

  // Text & Typography (NÉORA Ink & Muted)
  static const Color textPrimary = Color(
    0xFF0E0E0E,
  ); // --ink (Mực đen sang trọng)
  static const Color textSecondary = Color(0xFF6E6A64); // --muted
  static const Color textMuted = Color(0xFF8A8680); // --muted-light
  static const Color textLight = textMuted;

  // Signature NÉORA Brand Colors (Camel Gold, Amber & Editorial Red)
  static const Color brandBlack = Color(0xFF0E0E0E); // --ink
  static const Color primary = Color(0xFFC8A97E); // --warm (Camel Gold chủ đạo)
  static const Color camelGold = Color(
    0xFFC8A97E,
  ); // NÉORA Camel Gold signature
  static const Color saleRed = Color(0xFFA03A3A); // --danger
  static const Color badgeRed = Color(0xFFA03A3A);
  static const Color primaryBurgundy = Color(
    0xFF8B6840,
  ); // --warm-text (Camel chữ tương phản)
  static const Color primaryBurgundyDark = Color(0xFF74562F); // --warm-hover
  static const Color primaryBurgundySoft = Color(0xFFF5EEE4); // --warm-pale

  // VIP Gold & Luxury Badges
  static const Color goldAccent = Color(0xFFC8A97E); // --warm
  static const Color goldSoft = Color(0xFFF5EEE4); // --warm-pale
  static const Color darkCard = Color(0xFF14120E); // Charcoal sâu
  static const Color darkCardBorder = Color(0xFF2B2621);

  // Status & Utility Colors (NÉORA Olive & Earth)
  static const Color liveGreen = Color(0xFF4F7A4F); // --success
  static const Color liveGreenSoft = Color(0xFFEDF2ED);
  static const Color starYellow = Color(0xFFA8762A); // --warning
  static const Color titaniumAccent = Color(0xFF8A8680);
  static const Color warmSand = Color(0xFFE9E2D6); // --sand

  // Frosted & Overlay Tokens
  static const Color frostedGlassBg = Color(0xD9F7F4EF);
  static const Color frostedGlassBorder = Color(0xE6E2DDD8);
  static const Color frostedGlassDark = Color(0xB314120E);

  // Order Status Colors
  static const Color statusShippedBg = Color(0xFFEFF3F7);
  static const Color statusShippedText = Color(0xFF385E7D);
  static const Color statusDeliveredBg = Color(0xFFEDF2ED);
  static const Color statusDeliveredText = Color(0xFF4F7A4F);
  static const Color statusProcessingBg = Color(0xFFF7F0E6);
  static const Color statusProcessingText = Color(0xFF8B6840);

  // NÉORA semantic aliases
  static const Color warmBackground = Color(0xFFF7F4EF); // Nền kem --cream
  static const Color coralOrange = Color(
    0xFFC8A97E,
  ); // Điểm nhấn Camel Gold thay cho cam/hồng
  static const Color coralOrangeLight = Color(0xFFE8D9C4); // --warm-light
  static const Color softPeach = Color(
    0xFFF5EEE4,
  ); // --warm-pale (Nền chip nhẹ)
  static const Color mintGreen = Color(0xFF4F7A4F); // --success
  static const Color mintGreenSoft = Color(0xFFEDF2ED);
  static const Color warmYellow = Color(0xFFC8A97E);
  static const Color warmYellowSoft = Color(0xFFF5EEE4);
  static const Color friendlyText = Color(0xFF0E0E0E); // --ink
  static const Color friendlySubText = Color(0xFF6E6A64); // --muted
  static const Color friendlyBorder = Color(0xFFE2DDD8); // --border

  // Backward-compatible aliases
  static const Color lyraPrimary = coralOrange;
  static const Color lyraWarmText = primaryBurgundy;
  static const Color lyraPrimarySoft = softPeach;
  static const Color lyraBackground = warmBackground;
  static const Color lyraPaper = surface;
  static const Color lyraInk = textPrimary;
  static const Color lyraSale = saleRed;
  static const Color lyraSage = mintGreen;
}
