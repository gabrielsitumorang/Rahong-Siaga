import 'package:flutter/material.dart';

/// Design Token System: Royal Purple & Pale Gold with Deep Oceanic Contrasts.
/// Dirancang dengan standar UI/UX Enterprise Luxury & Command Center.
class AppColors {
  // ── 1. Royal Purple Spectrum (Primary Authority) ──
  static const Color royalPurpleDeep = Color(0xFF1A0B2E);    // Latar pekat ungu kerajaan
  static const Color royalPurpleSurface = Color(0xFF24123E); // Kartu & Surface utama
  static const Color royalPurpleElevated = Color(0xFF321A53);// Surface mengambang / popover
  static const Color royalPurplePrimary = Color(0xFF6B21A8); // Aksen utama aktif
  static const Color royalPurpleRadiant = Color(0xFF9333EA); // Highlight & tombol CTA
  static const Color royalPurpleGlow = Color(0x339333EA);    // Efek neon glow

  // ── 2. Pale Gold / Champagne Spectrum (Prestige & Highlighting) ──
  static const Color paleGold = Color(0xFFF3E5AB);           // Emas pucat mewah (Pale Gold murni)
  static const Color paleGoldMuted = Color(0xFFD4C38C);      // Emas pucat sekunder / border
  static const Color goldRadiant = Color(0xFFFACC15);        // Emas terang untuk indikator
  static const Color goldDeep = Color(0xFFB45309);           // Emas pekat untuk shadow
  static const Color goldGlow = Color(0x26F3E5AB);           // Glow emas transparan

  // ── 3. Contrast Dark Blue / Midnight Navy (Kedalaman Laut & Sungai) ──
  static const Color midnightNavy = Color(0xFF090D1A);       // Kontras biru gelap terdalam
  static const Color navySurface = Color(0xFF111827);        // Kartu kontras bernuansa gelap
  static const Color oceanicBlue = Color(0xFF0284C7);        // Representasi aliran sungai
  static const Color riverCyan = Color(0xFF38BDF8);          // Sensor air & telemetri

  // ── 4. Latar Bernuansa Lembut & Gelap (Soft Ambient Background) ──
  static const Color backgroundBase = Color(0xFF0D0714);     // Latar lembut ungu obsidian
  static const Color surfaceCard = Color(0xFF1B112B);        // Latar kartu dengan saturasi ungu halus
  static const Color borderSubtle = Color(0xFF34234E);       // Border halus pemisah elemen
  static const Color borderGold = Color(0x40F3E5AB);         // Border aksen emas tipis

  // ── 5. Status Bencana (Harmonis dengan Emas & Ungu) ──
  static const Color statusAman = Color(0xFF10B981);         // Emerald Gem (Aman: 0 - 35)
  static const Color statusWaspada = Color(0xFFEAB308);      // Pale Gold Imperial (Waspada: 36 - 60)
  static const Color statusSiaga = Color(0xFFF97316);        // Amber Topaz (Siaga: 61 - 80)
  static const Color statusAwas = Color(0xFFE11D48);         // Royal Crimson Ruby (Awas: 81 - 100)

  // ── 6. Tipografi & Hierarki Teks ──
  static const Color textHeader = Color(0xFFFAF7F2);         // Putih gading lembut
  static const Color textPrimary = Color(0xFFEAE5D9);        // Champagne putih lembut
  static const Color textSecondary = Color(0xFFAFA3C4);      // Ungu keabu-abuan elegan
  static const Color textMuted = Color(0xFF75678F);          // Teks redup

  // ── 7. Gradien Visual Mewah ──
  static const LinearGradient royalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B1566), Color(0xFF180A29)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBF4D4), Color(0xFFD4BE77)],
  );

  static const LinearGradient alertCrimsonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFBE123C), Color(0xFF4C0519)],
  );
}
