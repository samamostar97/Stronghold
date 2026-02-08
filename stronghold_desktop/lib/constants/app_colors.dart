import 'package:flutter/material.dart';

/// Design token color palette for Stronghold admin UI.
///
/// New tokens follow a semantic naming convention.
/// Legacy aliases (bg1, card, panel, muted, etc.) are preserved
/// for backward compatibility with existing screens/widgets.
abstract class AppColors {
  // ── Backgrounds ──────────────────────────────────────────────────────
  static const background = Color(0xFF0C1222);
  static const surface = Color(0xCC0F172A); // #0F172A at ~80%
  static const surfaceSolid = Color(0xFF0F172A);
  static const surfaceHover = Color(0x08FFFFFF); // white at ~3%
  static const surfaceLight = Color(0x0AFFFFFF); // white at ~4%

  // ── Borders ──────────────────────────────────────────────────────────
  static const border = Color(0x0DFFFFFF); // white at ~5%
  static const borderLight = Color(0x0AFFFFFF); // white at ~4%
  static const borderHover = Color(0x14FFFFFF); // white at ~8%

  // ── Primary (cyan) ──────────────────────────────────────────────────
  static const primary = Color(0xFF22D3EE);
  static const primaryDim = Color(0x1A22D3EE); // 10%
  static const primaryBorder = Color(0x3322D3EE); // 20%

  // ── Secondary (indigo) ──────────────────────────────────────────────
  static const secondary = Color(0xFF6366F1);
  static const secondaryDim = Color(0x1A6366F1); // 10%

  // ── Semantic ────────────────────────────────────────────────────────
  static const success = Color(0xFF34D399);
  static const successDim = Color(0x1A34D399); // 10%

  static const warning = Color(0xFFF59E0B);
  static const warningDim = Color(0x1AF59E0B); // 10%

  static const error = Color(0xFFFB7185);
  static const errorDim = Color(0x1AFB7185); // 10%

  static const accent = Color(0xFFA78BFA);
  static const accentDim = Color(0x1AA78BFA); // 10%

  static const orange = Color(0xFFF97316);
  static const orangeDim = Color(0x1AF97316); // 10%

  // ── Text ────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);
  static const textDark = Color(0xFF475569);

  // ── Legacy aliases (backward compatibility) ─────────────────────────
  // These map old field names to the closest new semantic tokens.
  // Migrate to new names in later phases.
  static const bg1 = background;
  static const bg2 = background;
  static const card = surfaceSolid;
  static const panel = surfaceSolid;
  static const muted = textMuted;
  static const accentLight = Color(0xFFFC8E9E); // lighter error variant
  static const editBlue = secondary;
  static const successDark = Color(0xFF2AB780);
  static const info = primary;
}
