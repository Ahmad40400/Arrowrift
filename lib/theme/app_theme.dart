import 'dart:math';

import 'package:flutter/material.dart';

// ============================================================================
// ARROWRIFT THEMES  —  single source of truth for every theme palette.
//
// 'classic' is the original look of the game (free, always owned).
// The other 5 themes are premium: every new player gets ONE free trial per
// theme, after that the theme must be bought (Eco.themePrice coins).
// ============================================================================

enum BackdropStyle { none, stars, petals, bubbles, leaves, sunrays }

class ArrowTheme {
  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final bool isDark;

  // Core palette
  final Color bg; // screen background (top)
  final Color bg2; // screen background (bottom, gradient)
  final Color brand; // buttons / headings / main surfaces
  final Color ink; // main text colour
  final Color accent; // highlight (RIFT word, warnings, selected states)
  final Color card; // cards / panels
  final Color cardAlt; // inputs, chips, soft panels
  final Color line; // borders / dividers
  final Color muted; // secondary text

  // Board
  final Color boardBg;
  final Color boardBorder;
  final Color boardDot;
  final Color arrowInk;
  final Color danger;

  // Level map
  final Color lockedBg;
  final Color lockedText;
  final Color pathColor;

  final BackdropStyle backdrop;
  final Color backdropTint; // colour of the decorative shapes

  // Preview swatches (shown on the shop card)
  final List<Color> swatch;

  const ArrowTheme({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.isDark,
    required this.bg,
    required this.bg2,
    required this.brand,
    required this.ink,
    required this.accent,
    required this.card,
    required this.cardAlt,
    required this.line,
    required this.muted,
    required this.boardBg,
    required this.boardBorder,
    required this.boardDot,
    required this.arrowInk,
    required this.danger,
    required this.lockedBg,
    required this.lockedText,
    required this.pathColor,
    required this.backdrop,
    required this.backdropTint,
    required this.swatch,
  });

  bool get isClassic => id == 'classic';
}

class AppTheme {
  AppTheme._();

  // ----------------------------------------------------------------- THEMES
  static const ArrowTheme classic = ArrowTheme(
    id: 'classic',
    name: 'Classic',
    tagline: 'The original Arrowrift look.',
    icon: Icons.arrow_outward_rounded,
    isDark: false,
    bg: Color(0xFFFAFBFC),
    bg2: Color(0xFFFAFBFC),
    brand: Color(0xFF1B1B3A),
    ink: Color(0xFF1B1B3A),
    accent: Color(0xFFFF4B5C),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFF3F4F6),
    line: Color(0xFFE0E0E0),
    muted: Color(0x8A000000),
    boardBg: Color(0x00000000),
    boardBorder: Color(0x00000000),
    boardDot: Color(0x00000000),
    arrowInk: Color(0xFF1B1B3A),
    danger: Color(0xFFE53935),
    lockedBg: Color(0xFFE8EBEE),
    lockedText: Color(0xFF7B8794),
    pathColor: Color(0xFFE2E8F0),
    backdrop: BackdropStyle.none,
    backdropTint: Color(0x00000000),
    swatch: [Color(0xFFFAFBFC), Color(0xFF1B1B3A), Color(0xFFFF4B5C)],
  );

  static const ArrowTheme midnight = ArrowTheme(
    id: 'midnight',
    name: 'Midnight Neon',
    tagline: 'Cyber-night glow with neon arrows.',
    icon: Icons.nights_stay_rounded,
    isDark: true,
    bg: Color(0xFF0B0D22),
    bg2: Color(0xFF1B1048),
    brand: Color(0xFF7C5CFF),
    ink: Color(0xFFEDEBFF),
    accent: Color(0xFFFF3D9A),
    card: Color(0xFF171B3C),
    cardAlt: Color(0xFF222758),
    line: Color(0xFF343A7A),
    muted: Color(0xFF9AA0D6),
    boardBg: Color(0xFF10143A),
    boardBorder: Color(0xFF00E5FF),
    boardDot: Color(0xFF3A4296),
    arrowInk: Color(0xFF6FF3FF),
    danger: Color(0xFFFF3D9A),
    lockedBg: Color(0xFF222758),
    lockedText: Color(0xFF7E86C9),
    pathColor: Color(0xFF343A7A),
    backdrop: BackdropStyle.stars,
    backdropTint: Color(0xFFB8B2FF),
    swatch: [Color(0xFF0B0D22), Color(0xFF7C5CFF), Color(0xFF00E5FF)],
  );

  static const ArrowTheme sakura = ArrowTheme(
    id: 'sakura',
    name: 'Sakura Blossom',
    tagline: 'Soft pink petals and calm rose tones.',
    icon: Icons.local_florist_rounded,
    isDark: false,
    bg: Color(0xFFFFF3F7),
    bg2: Color(0xFFFFD9E6),
    brand: Color(0xFFC2185B),
    ink: Color(0xFF4A1530),
    accent: Color(0xFFFF6F91),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFFFE8F0),
    line: Color(0xFFF7C3D5),
    muted: Color(0xFF9C6580),
    boardBg: Color(0xFFFFFAFC),
    boardBorder: Color(0xFFF4A6C0),
    boardDot: Color(0xFFF8CFDD),
    arrowInk: Color(0xFF7A1F4D),
    danger: Color(0xFFD81B60),
    lockedBg: Color(0xFFFBDDE7),
    lockedText: Color(0xFFB07A93),
    pathColor: Color(0xFFF7C3D5),
    backdrop: BackdropStyle.petals,
    backdropTint: Color(0xFFFF9DBB),
    swatch: [Color(0xFFFFD9E6), Color(0xFFC2185B), Color(0xFFFF6F91)],
  );

  static const ArrowTheme ocean = ArrowTheme(
    id: 'ocean',
    name: 'Ocean Breeze',
    tagline: 'Cool aqua waves and deep sea blues.',
    icon: Icons.water_rounded,
    isDark: false,
    bg: Color(0xFFE9F9FD),
    bg2: Color(0xFFBDE9F5),
    brand: Color(0xFF00698F),
    ink: Color(0xFF073B54),
    accent: Color(0xFFFF7A59),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFDDF3F9),
    line: Color(0xFFABDCEB),
    muted: Color(0xFF5B8499),
    boardBg: Color(0xFFF6FDFF),
    boardBorder: Color(0xFF6CC7DF),
    boardDot: Color(0xFFBFE6F1),
    arrowInk: Color(0xFF0A3F61),
    danger: Color(0xFFE5484D),
    lockedBg: Color(0xFFCDEAF3),
    lockedText: Color(0xFF6F98AA),
    pathColor: Color(0xFFABDCEB),
    backdrop: BackdropStyle.bubbles,
    backdropTint: Color(0xFF58BCD8),
    swatch: [Color(0xFFBDE9F5), Color(0xFF00698F), Color(0xFFFF7A59)],
  );

  static const ArrowTheme forest = ArrowTheme(
    id: 'forest',
    name: 'Emerald Forest',
    tagline: 'Fresh leaves, moss greens and golden light.',
    icon: Icons.park_rounded,
    isDark: false,
    bg: Color(0xFFF0F9F1),
    bg2: Color(0xFFCDEBD3),
    brand: Color(0xFF1F7A45),
    ink: Color(0xFF123524),
    accent: Color(0xFFE9A23B),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFE2F3E5),
    line: Color(0xFFB7DEC1),
    muted: Color(0xFF5E8A6D),
    boardBg: Color(0xFFF8FFF9),
    boardBorder: Color(0xFF7BC68F),
    boardDot: Color(0xFFC5E6CD),
    arrowInk: Color(0xFF14432A),
    danger: Color(0xFFD9483B),
    lockedBg: Color(0xFFD6EBDB),
    lockedText: Color(0xFF739B80),
    pathColor: Color(0xFFB7DEC1),
    backdrop: BackdropStyle.leaves,
    backdropTint: Color(0xFF63B87C),
    swatch: [Color(0xFFCDEBD3), Color(0xFF1F7A45), Color(0xFFE9A23B)],
  );

  static const ArrowTheme sunset = ArrowTheme(
    id: 'sunset',
    name: 'Golden Sunset',
    tagline: 'Warm amber sky with a glowing horizon.',
    icon: Icons.wb_twilight_rounded,
    isDark: false,
    bg: Color(0xFFFFF6E8),
    bg2: Color(0xFFFFD2B0),
    brand: Color(0xFFC2410C),
    ink: Color(0xFF4A1D0B),
    accent: Color(0xFFE11D48),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFFFEBD6),
    line: Color(0xFFF8CBA4),
    muted: Color(0xFFA06A4C),
    boardBg: Color(0xFFFFFBF4),
    boardBorder: Color(0xFFF5A15E),
    boardDot: Color(0xFFFAD9BC),
    arrowInk: Color(0xFF7C2D12),
    danger: Color(0xFFE11D48),
    lockedBg: Color(0xFFFBDCC0),
    lockedText: Color(0xFFB88561),
    pathColor: Color(0xFFF8CBA4),
    backdrop: BackdropStyle.sunrays,
    backdropTint: Color(0xFFFFA25C),
    swatch: [Color(0xFFFFD2B0), Color(0xFFC2410C), Color(0xFFE11D48)],
  );

  /// Display order in the shop (classic first, then the 5 premium themes).
  static const List<ArrowTheme> all = [
    classic,
    midnight,
    sakura,
    ocean,
    forest,
    sunset,
  ];

  /// Only the 5 premium (buyable) themes.
  static List<ArrowTheme> get premium =>
      all.where((t) => !t.isClassic).toList();

  static ArrowTheme byId(String? id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return classic;
  }

  // ----------------------------------------------------------- ACTIVE THEME
  /// The theme currently on screen. GameProvider updates this and then calls
  /// notifyListeners(), so every screen that watches the provider rebuilds.
  static ArrowTheme active = classic;

  static Color get bg => active.bg;
  static Color get bg2 => active.bg2;
  static Color get brand => active.brand;
  static Color get ink => active.ink;
  static Color get accent => active.accent;
  static Color get card => active.card;
  static Color get cardAlt => active.cardAlt;
  static Color get line => active.line;
  static Color get muted => active.muted;
  static Color get danger => active.danger;
  static Color get arrowInk => active.arrowInk;
  static Color get lockedBg => active.lockedBg;
  static Color get lockedText => active.lockedText;
  static Color get pathColor => active.pathColor;
  static bool get isDark => active.isDark;
  static bool get isClassic => active.isClassic;

  // --- helpers that keep the ORIGINAL (classic) colours pixel-identical and
  // only change colours when a premium theme is active.

  /// Replacement for Colors.grey.shadeN / Colors.grey
  static Color grey(int shade) {
    if (isClassic) return Colors.grey[shade]!;
    if (shade <= 100) return active.cardAlt;
    if (shade <= 300) return active.line;
    return active.muted;
  }

  /// Replacement for Colors.blueGrey.shadeN / Colors.blueGrey
  static Color blueGrey(int shade) {
    if (isClassic) return Colors.blueGrey[shade]!;
    return active.muted;
  }

  /// Replacement for Colors.blackNN text colours (38 / 45 / 54 / 87).
  static Color dim(int level) {
    if (isClassic) {
      switch (level) {
        case 38:
          return Colors.black38;
        case 45:
          return Colors.black45;
        case 54:
          return Colors.black54;
        case 87:
          return Colors.black87;
        default:
          return Colors.black54;
      }
    }
    return level >= 80 ? active.ink : active.muted;
  }
}

// ============================================================================
// ThemedScaffold — drop-in replacement for Scaffold that paints the theme
// background (gradient + decorative shapes) behind the screen content.
// ============================================================================
class ThemedScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const ThemedScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.active;
    return Scaffold(
      backgroundColor: backgroundColor ?? t.bg,
      appBar: appBar,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: ThemeBackdrop(theme: t, child: body ?? const SizedBox.shrink()),
    );
  }
}

/// Gradient + decorative shapes behind a screen. Static (no animation) so it
/// costs almost nothing while playing.
class ThemeBackdrop extends StatelessWidget {
  final ArrowTheme theme;
  final Widget child;
  const ThemeBackdrop({super.key, required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    if (theme.isClassic) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.bg, theme.bg2],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _BackdropPainter(theme)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BackdropPainter extends CustomPainter {
  final ArrowTheme t;
  _BackdropPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rnd = Random(t.id.hashCode);
    switch (t.backdrop) {
      case BackdropStyle.none:
        break;
      case BackdropStyle.stars:
        _stars(canvas, size, rnd);
        break;
      case BackdropStyle.petals:
        _petals(canvas, size, rnd);
        break;
      case BackdropStyle.bubbles:
        _bubbles(canvas, size, rnd);
        break;
      case BackdropStyle.leaves:
        _leaves(canvas, size, rnd);
        break;
      case BackdropStyle.sunrays:
        _sunrays(canvas, size, rnd);
        break;
    }
  }

  void _stars(Canvas canvas, Size size, Random rnd) {
    // soft neon glows
    final glowA = Paint()
      ..shader =
          RadialGradient(
            colors: [const Color(0x557C5CFF), const Color(0x007C5CFF)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.85, size.height * 0.12),
              radius: size.width * 0.7,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.12),
      size.width * 0.7,
      glowA,
    );
    final glowB = Paint()
      ..shader =
          RadialGradient(
            colors: [const Color(0x3300E5FF), const Color(0x0000E5FF)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.1, size.height * 0.9),
              radius: size.width * 0.8,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.9),
      size.width * 0.8,
      glowB,
    );
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 70; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height;
      final double r = 0.5 + rnd.nextDouble() * 1.6;
      p.color = t.backdropTint.withOpacity(0.25 + rnd.nextDouble() * 0.6);
      canvas.drawCircle(Offset(x, y), r, p);
    }
  }

  void _petals(Canvas canvas, Size size, Random rnd) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 22; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height;
      final double w = 8 + rnd.nextDouble() * 14;
      final double rot = rnd.nextDouble() * pi;
      p.color = t.backdropTint.withOpacity(0.18 + rnd.nextDouble() * 0.22);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final path = Path()
        ..moveTo(0, -w)
        ..quadraticBezierTo(w * 0.9, -w * 0.3, 0, w)
        ..quadraticBezierTo(-w * 0.9, -w * 0.3, 0, -w)
        ..close();
      canvas.drawPath(path, p);
      canvas.restore();
    }
  }

  void _bubbles(Canvas canvas, Size size, Random rnd) {
    final fill = Paint()..style = PaintingStyle.fill;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (int i = 0; i < 26; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height;
      final double r = 5 + rnd.nextDouble() * 22;
      fill.color = t.backdropTint.withOpacity(0.07 + rnd.nextDouble() * 0.08);
      ring.color = t.backdropTint.withOpacity(0.25 + rnd.nextDouble() * 0.2);
      canvas.drawCircle(Offset(x, y), r, fill);
      canvas.drawCircle(Offset(x, y), r, ring);
    }
    // soft waves at the bottom
    for (int w = 0; w < 3; w++) {
      final wave = Paint()
        ..style = PaintingStyle.fill
        ..color = t.backdropTint.withOpacity(0.10 + w * 0.05);
      final path = Path()..moveTo(0, size.height);
      final double base = size.height * (0.90 + w * 0.03);
      for (double x = 0; x <= size.width; x += 4) {
        path.lineTo(
          x,
          base + sin((x / size.width) * 2 * pi * (1.5 + w * 0.4) + w) * 10,
        );
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, wave);
    }
  }

  void _leaves(Canvas canvas, Size size, Random rnd) {
    final p = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height;
      final double w = 10 + rnd.nextDouble() * 16;
      final double rot = rnd.nextDouble() * 2 * pi;
      p.color = t.backdropTint.withOpacity(0.14 + rnd.nextDouble() * 0.2);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final path = Path()
        ..moveTo(0, -w)
        ..quadraticBezierTo(w * 0.8, 0, 0, w)
        ..quadraticBezierTo(-w * 0.8, 0, 0, -w)
        ..close();
      canvas.drawPath(path, p);
      canvas.restore();
    }
    // rolling hills
    for (int h = 0; h < 2; h++) {
      final hill = Paint()
        ..style = PaintingStyle.fill
        ..color = t.backdropTint.withOpacity(0.12 + h * 0.07);
      final path = Path()..moveTo(0, size.height);
      final double base = size.height * (0.92 + h * 0.03);
      for (double x = 0; x <= size.width; x += 4) {
        path.lineTo(
          x,
          base + sin((x / size.width) * pi * (1.2 + h * 0.7) + h * 1.3) * 14,
        );
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, hill);
    }
  }

  void _sunrays(Canvas canvas, Size size, Random rnd) {
    final center = Offset(size.width * 0.5, size.height * 1.02);
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [const Color(0x66FFB347), const Color(0x00FFB347)],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.height * 0.7),
          );
    canvas.drawCircle(center, size.height * 0.7, glow);
    final ray = Paint()..style = PaintingStyle.fill;
    const int rays = 14;
    for (int i = 0; i < rays; i++) {
      final double a = pi + (pi / (rays - 1)) * i;
      final double a2 = a + 0.06;
      ray.color = t.backdropTint.withOpacity(i.isEven ? 0.10 : 0.05);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + cos(a) * size.height * 1.3,
          center.dy + sin(a) * size.height * 1.3,
        )
        ..lineTo(
          center.dx + cos(a2) * size.height * 1.3,
          center.dy + sin(a2) * size.height * 1.3,
        )
        ..close();
      canvas.drawPath(path, ray);
    }
    final sun = Paint()..color = const Color(0x33FFC46B);
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.1), 34, sun);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.1),
      20,
      Paint()..color = const Color(0x55FFB347),
    );
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => old.t.id != t.id;
}
