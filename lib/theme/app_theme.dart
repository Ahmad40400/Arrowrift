import 'dart:math';

import 'package:flutter/material.dart';

import '../economy/economy_config.dart';

// ============================================================================
// ARROWRIFT THEMES  —  single source of truth for every theme palette.
//
// 'classic' is the original look of the game (free, always owned).
//
// Two shop categories:
//   REGULAR  - Midnight, Sakura, Ocean, Forest, Sunset (Eco.themePrice coins).
//   PREMIUM  - Royal Gold, Aurora, Cyber Grid, Lava Ember, Frozen Crystal,
//              Rose Gold (richer backdrops, higher price).
//
// Every new player gets ONE free trial per theme (regular AND premium), after
// that the theme must be bought with coins (ArrowTheme.price).
// ============================================================================

enum BackdropStyle {
  none,
  stars,
  petals,
  bubbles,
  leaves,
  sunrays,
  // --- premium backdrops
  goldDust,
  aurora,
  cyberGrid,
  embers,
  crystals,
  roseShimmer,
}

/// Which shop category a theme belongs to.
enum ThemeTier { regular, premium }

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

  // Shop category + optional own price (null = default price of the tier).
  final ThemeTier tier;
  final int? customPrice;

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
    this.tier = ThemeTier.regular,
    this.customPrice,
  });

  bool get isClassic => id == 'classic';
  bool get isPremium => tier == ThemeTier.premium;

  /// Coins needed to own this theme forever.
  int get price =>
      customPrice ?? (isPremium ? Eco.premiumThemePrice : Eco.themePrice);
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

  // ======================================================== PREMIUM THEMES
  static const ArrowTheme royalGold = ArrowTheme(
    id: 'royalgold',
    name: 'Royal Gold',
    tagline: 'Black velvet, pure gold and sparkling dust.',
    icon: Icons.workspace_premium_rounded,
    isDark: true,
    bg: Color(0xFF0A0A0C),
    bg2: Color(0xFF241A08),
    brand: Color(0xFFB07D14),
    ink: Color(0xFFF8EFD2),
    accent: Color(0xFFFFD86B),
    card: Color(0xFF17140E),
    cardAlt: Color(0xFF241F13),
    line: Color(0xFF4A3D1C),
    muted: Color(0xFFB8A56A),
    boardBg: Color(0xFF100E09),
    boardBorder: Color(0xFFE2B93B),
    boardDot: Color(0xFF4A3D1C),
    arrowInk: Color(0xFFFFD86B),
    danger: Color(0xFFFF5A4F),
    lockedBg: Color(0xFF241F13),
    lockedText: Color(0xFF8C7A45),
    pathColor: Color(0xFF4A3D1C),
    backdrop: BackdropStyle.goldDust,
    backdropTint: Color(0xFFFFD86B),
    swatch: [Color(0xFF0A0A0C), Color(0xFFE2B93B), Color(0xFFFFD86B)],
    tier: ThemeTier.premium,
    customPrice: 25000,
  );

  static const ArrowTheme aurora = ArrowTheme(
    id: 'aurora',
    name: 'Aurora Borealis',
    tagline: 'Dancing northern lights over a polar night.',
    icon: Icons.auto_awesome_rounded,
    isDark: true,
    bg: Color(0xFF03111A),
    bg2: Color(0xFF0B2B3B),
    brand: Color(0xFF0F8F82),
    ink: Color(0xFFE6FFF9),
    accent: Color(0xFFB388FF),
    card: Color(0xFF0C2230),
    cardAlt: Color(0xFF123246),
    line: Color(0xFF1E4D63),
    muted: Color(0xFF8FC7C4),
    boardBg: Color(0xFF071B27),
    boardBorder: Color(0xFF3DF5C0),
    boardDot: Color(0xFF1E4D63),
    arrowInk: Color(0xFF7CFFD8),
    danger: Color(0xFFFF6B8A),
    lockedBg: Color(0xFF123246),
    lockedText: Color(0xFF5E9AA0),
    pathColor: Color(0xFF1E4D63),
    backdrop: BackdropStyle.aurora,
    backdropTint: Color(0xFF3DF5C0),
    swatch: [Color(0xFF03111A), Color(0xFF3DF5C0), Color(0xFFB388FF)],
    tier: ThemeTier.premium,
    customPrice: 18000,
  );

  static const ArrowTheme cyber = ArrowTheme(
    id: 'cyber',
    name: 'Cyber Grid',
    tagline: 'Retro-future neon sun over a glowing grid.',
    icon: Icons.electric_bolt_rounded,
    isDark: true,
    bg: Color(0xFF0D0221),
    bg2: Color(0xFF2A0745),
    brand: Color(0xFFD81B8C),
    ink: Color(0xFFF5E9FF),
    accent: Color(0xFF00F0FF),
    card: Color(0xFF1A0B2E),
    cardAlt: Color(0xFF271244),
    line: Color(0xFF4B1F7A),
    muted: Color(0xFFA98BD6),
    boardBg: Color(0xFF120626),
    boardBorder: Color(0xFFFF2BD6),
    boardDot: Color(0xFF4B1F7A),
    arrowInk: Color(0xFF00F0FF),
    danger: Color(0xFFFFE600),
    lockedBg: Color(0xFF271244),
    lockedText: Color(0xFF7D5FB0),
    pathColor: Color(0xFF4B1F7A),
    backdrop: BackdropStyle.cyberGrid,
    backdropTint: Color(0xFFFF2BD6),
    swatch: [Color(0xFF0D0221), Color(0xFFD81B8C), Color(0xFF00F0FF)],
    tier: ThemeTier.premium,
    customPrice: 22000,
  );

  static const ArrowTheme lava = ArrowTheme(
    id: 'lava',
    name: 'Lava Ember',
    tagline: 'Molten glow with rising fire sparks.',
    icon: Icons.local_fire_department_rounded,
    isDark: true,
    bg: Color(0xFF140404),
    bg2: Color(0xFF38100A),
    brand: Color(0xFFD9480F),
    ink: Color(0xFFFFEDE0),
    accent: Color(0xFFFFB020),
    card: Color(0xFF241008),
    cardAlt: Color(0xFF341810),
    line: Color(0xFF5C2A16),
    muted: Color(0xFFD39A7C),
    boardBg: Color(0xFF1A0A06),
    boardBorder: Color(0xFFFF7A1A),
    boardDot: Color(0xFF5C2A16),
    arrowInk: Color(0xFFFFB347),
    danger: Color(0xFFFF3B3B),
    lockedBg: Color(0xFF341810),
    lockedText: Color(0xFF9A6247),
    pathColor: Color(0xFF5C2A16),
    backdrop: BackdropStyle.embers,
    backdropTint: Color(0xFFFF8A3D),
    swatch: [Color(0xFF140404), Color(0xFFD9480F), Color(0xFFFFB020)],
    tier: ThemeTier.premium,
    customPrice: 20000,
  );

  static const ArrowTheme crystal = ArrowTheme(
    id: 'crystal',
    name: 'Frozen Crystal',
    tagline: 'Icy facets, snowflakes and cool sapphire.',
    icon: Icons.ac_unit_rounded,
    isDark: false,
    bg: Color(0xFFF4FBFF),
    bg2: Color(0xFFD3E9F9),
    brand: Color(0xFF2563EB),
    ink: Color(0xFF0B2545),
    accent: Color(0xFF8B5CF6),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFE6F3FC),
    line: Color(0xFFBBDDF2),
    muted: Color(0xFF5F7F9E),
    boardBg: Color(0xFFF8FDFF),
    boardBorder: Color(0xFF7DB9F5),
    boardDot: Color(0xFFC4E1F5),
    arrowInk: Color(0xFF0B3A7A),
    danger: Color(0xFFE5484D),
    lockedBg: Color(0xFFD3E8F6),
    lockedText: Color(0xFF7C9BB5),
    pathColor: Color(0xFFBBDDF2),
    backdrop: BackdropStyle.crystals,
    backdropTint: Color(0xFF7DB9F5),
    swatch: [Color(0xFFD3E9F9), Color(0xFF2563EB), Color(0xFF8B5CF6)],
    tier: ThemeTier.premium,
    customPrice: 15000,
  );

  static const ArrowTheme roseGold = ArrowTheme(
    id: 'rosegold',
    name: 'Rose Gold Luxe',
    tagline: 'Blush shimmer with champagne sparkles.',
    icon: Icons.diamond_rounded,
    isDark: false,
    bg: Color(0xFFFFF8F4),
    bg2: Color(0xFFF5D6CB),
    brand: Color(0xFFA85A66),
    ink: Color(0xFF3B1F26),
    accent: Color(0xFFD4A15A),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFFBEAE4),
    line: Color(0xFFEBC9BE),
    muted: Color(0xFF9B7078),
    boardBg: Color(0xFFFFFBF9),
    boardBorder: Color(0xFFD9A08F),
    boardDot: Color(0xFFF0D4CB),
    arrowInk: Color(0xFF6B2F3B),
    danger: Color(0xFFD6334F),
    lockedBg: Color(0xFFF3D7CE),
    lockedText: Color(0xFFB9928A),
    pathColor: Color(0xFFEBC9BE),
    backdrop: BackdropStyle.roseShimmer,
    backdropTint: Color(0xFFE8B4A5),
    swatch: [Color(0xFFF5D6CB), Color(0xFFA85A66), Color(0xFFD4A15A)],
    tier: ThemeTier.premium,
    customPrice: 15000,
  );

  /// Display order in the shop (classic first, then regular, then premium).
  static const List<ArrowTheme> all = [
    classic,
    midnight,
    sakura,
    ocean,
    forest,
    sunset,
    // premium
    crystal,
    roseGold,
    aurora,
    lava,
    cyber,
    royalGold,
  ];

  /// REGULAR category = classic (free) + the 5 original buyable themes.
  static List<ArrowTheme> get regular =>
      all.where((t) => !t.isPremium).toList();

  /// PREMIUM category = the new high-end themes (higher price).
  static List<ArrowTheme> get premium => all.where((t) => t.isPremium).toList();

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
              child: CustomPaint(painter: ThemeBackdropPainter(theme)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Public so the shop can draw a mini preview of a premium backdrop.
class ThemeBackdropPainter extends CustomPainter {
  final ArrowTheme t;
  ThemeBackdropPainter(this.t);

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
      case BackdropStyle.goldDust:
        _goldDust(canvas, size, rnd);
        break;
      case BackdropStyle.aurora:
        _aurora(canvas, size, rnd);
        break;
      case BackdropStyle.cyberGrid:
        _cyberGrid(canvas, size, rnd);
        break;
      case BackdropStyle.embers:
        _embers(canvas, size, rnd);
        break;
      case BackdropStyle.crystals:
        _crystals(canvas, size, rnd);
        break;
      case BackdropStyle.roseShimmer:
        _roseShimmer(canvas, size, rnd);
        break;
    }
  }

  // ------------------------------------------------ premium backdrop helpers
  // withAlpha-based so it works on every Flutter version (no deprecated calls).
  Color _al(Color c, double o) =>
      c.withAlpha((o.clamp(0.0, 1.0) * 255).round());

  void _glow(Canvas canvas, Offset c, double r, Color color, double o) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [_al(color, o), _al(color, 0)])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  void _sparkle(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + r * 0.12, c.dy - r * 0.12, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + r * 0.12, c.dy + r * 0.12, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - r * 0.12, c.dy + r * 0.12, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - r * 0.12, c.dy - r * 0.12, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, p);
  }

  Path _polygon(Offset c, double r, int sides, double rot) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final double a = rot + (2 * pi / sides) * i;
      final Offset pt = Offset(c.dx + cos(a) * r, c.dy + sin(a) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    return path..close();
  }

  // ROYAL GOLD: warm gold glows, fine dust and four-point sparkles.
  void _goldDust(Canvas canvas, Size size, Random rnd) {
    _glow(
      canvas,
      Offset(size.width * 0.9, size.height * 0.08),
      size.width * 0.75,
      const Color(0xFFFFC94A),
      0.30,
    );
    _glow(
      canvas,
      Offset(size.width * 0.05, size.height * 0.95),
      size.width * 0.85,
      const Color(0xFFB07D14),
      0.28,
    );
    // soft diagonal light beams
    final beam = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      beam.color = _al(t.backdropTint, 0.05 - i * 0.012);
      final double x = size.width * (0.15 + i * 0.3);
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + size.width * 0.16, 0)
          ..lineTo(x - size.width * 0.35, size.height)
          ..lineTo(x - size.width * 0.51, size.height)
          ..close(),
        beam,
      );
    }
    final dust = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height;
      final double r = 0.4 + rnd.nextDouble() * 1.5;
      dust.color = _al(t.backdropTint, 0.15 + rnd.nextDouble() * 0.5);
      canvas.drawCircle(Offset(x, y), r, dust);
    }
    final spark = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 9; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height;
      final double r = 4 + rnd.nextDouble() * 8;
      spark.color = _al(const Color(0xFFFFE9A8), 0.35 + rnd.nextDouble() * 0.4);
      _sparkle(canvas, Offset(x, y), r, spark);
    }
  }

  // AURORA: three flowing northern-light ribbons over faint stars.
  void _aurora(Canvas canvas, Size size, Random rnd) {
    final star = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 55; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height * 0.7;
      star.color = _al(Colors.white, 0.15 + rnd.nextDouble() * 0.5);
      canvas.drawCircle(Offset(x, y), 0.4 + rnd.nextDouble() * 1.1, star);
    }
    final List<Color> ribbons = [
      const Color(0xFF3DF5C0),
      const Color(0xFF4F8BFF),
      const Color(0xFFB388FF),
    ];
    for (int b = 0; b < ribbons.length; b++) {
      final double top = size.height * (0.06 + b * 0.11);
      final double thick = size.height * (0.20 - b * 0.02);
      final double amp = size.height * (0.035 + b * 0.01);
      final double freq = 1.2 + b * 0.55;
      final double phase = b * 1.7;
      final path = Path()..moveTo(0, top);
      for (double x = 0; x <= size.width; x += 4) {
        path.lineTo(
          x,
          top + sin((x / size.width) * 2 * pi * freq + phase) * amp,
        );
      }
      for (double x = size.width; x >= 0; x -= 4) {
        path.lineTo(
          x,
          top +
              thick +
              sin((x / size.width) * 2 * pi * (freq * 0.8) + phase + 1.0) *
                  amp *
                  1.4,
        );
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader =
              LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _al(ribbons[b], 0.0),
                  _al(ribbons[b], 0.34),
                  _al(ribbons[b], 0.0),
                ],
              ).createShader(
                Rect.fromLTWH(0, top - amp, size.width, thick + amp * 3),
              ),
      );
    }
    _glow(
      canvas,
      Offset(size.width * 0.5, size.height * 1.0),
      size.width * 0.9,
      const Color(0xFF14B8A6),
      0.16,
    );
  }

  // CYBER GRID: neon sun on the horizon + perspective floor grid.
  void _cyberGrid(Canvas canvas, Size size, Random rnd) {
    final double horizon = size.height * 0.64;
    final star = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 40; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * horizon * 0.9;
      star.color = _al(Colors.white, 0.12 + rnd.nextDouble() * 0.4);
      canvas.drawCircle(Offset(x, y), 0.4 + rnd.nextDouble() * 1.0, star);
    }
    // sun
    final Offset sunC = Offset(size.width * 0.5, horizon - size.width * 0.05);
    final double sunR = size.width * 0.27;
    _glow(canvas, sunC, sunR * 2.0, const Color(0xFFFF2BD6), 0.22);
    canvas.drawCircle(
      sunC,
      sunR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _al(const Color(0xFFFFE600), 0.42),
            _al(const Color(0xFFFF2BD6), 0.42),
          ],
        ).createShader(Rect.fromCircle(center: sunC, radius: sunR)),
    );
    // floor
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, size.width, size.height - horizon),
      Paint()..color = _al(const Color(0xFF0D0221), 0.55),
    );
    final lineP = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = _al(t.backdropTint, 0.42);
    canvas.drawLine(
      Offset(0, horizon),
      Offset(size.width, horizon),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _al(const Color(0xFF00F0FF), 0.7),
    );
    // horizontal lines (perspective spacing)
    final double floorH = size.height - horizon;
    for (int i = 1; i <= 9; i++) {
      final double k = (i / 9.0);
      final double y = horizon + floorH * k * k;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), lineP);
    }
    // vertical lines converge to the vanishing point
    final Offset vp = Offset(size.width * 0.5, horizon);
    for (int i = -10; i <= 10; i++) {
      final double bx = size.width * 0.5 + i * size.width * 0.16;
      canvas.drawLine(vp, Offset(bx, size.height), lineP);
    }
  }

  // LAVA EMBER: hot glow from below and rising sparks.
  void _embers(Canvas canvas, Size size, Random rnd) {
    _glow(
      canvas,
      Offset(size.width * 0.5, size.height * 1.05),
      size.width * 1.1,
      const Color(0xFFFF5A1A),
      0.42,
    );
    _glow(
      canvas,
      Offset(size.width * 0.12, size.height * 0.98),
      size.width * 0.6,
      const Color(0xFFFFB020),
      0.25,
    );
    _glow(
      canvas,
      Offset(size.width * 0.92, size.height * 0.05),
      size.width * 0.6,
      const Color(0xFFB71C1C),
      0.25,
    );
    final glowP = Paint()..style = PaintingStyle.fill;
    final coreP = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 55; i++) {
      final double x = rnd.nextDouble() * size.width;
      // more sparks near the bottom
      final double y = size.height * (1 - pow(rnd.nextDouble(), 1.8));
      final double r = 0.8 + rnd.nextDouble() * 2.6;
      glowP.color = _al(t.backdropTint, 0.10 + rnd.nextDouble() * 0.12);
      coreP.color = _al(const Color(0xFFFFD27A), 0.45 + rnd.nextDouble() * 0.5);
      canvas.drawCircle(Offset(x, y), r * 3.2, glowP);
      canvas.drawCircle(Offset(x, y), r, coreP);
    }
  }

  // FROZEN CRYSTAL: faceted ice shards, snowflakes and a cold sheen.
  void _crystals(Canvas canvas, Size size, Random rnd) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [_al(Colors.white, 0.65), _al(Colors.white, 0.0)],
        ).createShader(Offset.zero & size),
    );
    final fill = Paint()..style = PaintingStyle.fill;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 0; i < 16; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = 14 + rnd.nextDouble() * 30;
      final double rot = rnd.nextDouble() * pi;
      final int sides = i.isEven ? 6 : 4;
      fill.color = _al(t.backdropTint, 0.07 + rnd.nextDouble() * 0.07);
      edge.color = _al(t.backdropTint, 0.28 + rnd.nextDouble() * 0.2);
      final Path poly = _polygon(c, r, sides, rot);
      canvas.drawPath(poly, fill);
      canvas.drawPath(poly, edge);
      // facet lines from the centre
      for (int k = 0; k < sides; k += 2) {
        final double a = rot + (2 * pi / sides) * k;
        canvas.drawLine(
          c,
          Offset(c.dx + cos(a) * r, c.dy + sin(a) * r),
          edge..color = _al(t.backdropTint, 0.16),
        );
      }
    }
    final flake = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 20; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = 4 + rnd.nextDouble() * 7;
      flake.color = _al(Colors.white, 0.55 + rnd.nextDouble() * 0.35);
      for (int k = 0; k < 3; k++) {
        final double a = (pi / 3) * k;
        canvas.drawLine(
          Offset(c.dx - cos(a) * r, c.dy - sin(a) * r),
          Offset(c.dx + cos(a) * r, c.dy + sin(a) * r),
          flake,
        );
      }
    }
  }

  // ROSE GOLD: blush bokeh, a glossy ribbon and champagne sparkles.
  void _roseShimmer(Canvas canvas, Size size, Random rnd) {
    final Path ribbon = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.02,
        size.width,
        size.height * 0.20,
      )
      ..lineTo(size.width, size.height * 0.30)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.12,
        0,
        size.height * 0.28,
      )
      ..close();
    canvas.drawPath(
      ribbon,
      Paint()
        ..shader = LinearGradient(
          colors: [
            _al(const Color(0xFFFFFFFF), 0.0),
            _al(const Color(0xFFFFFFFF), 0.55),
            _al(const Color(0xFFD4A15A), 0.0),
          ],
        ).createShader(Offset.zero & size),
    );
    final fill = Paint()..style = PaintingStyle.fill;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 0; i < 18; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = 10 + rnd.nextDouble() * 34;
      fill.color = _al(t.backdropTint, 0.10 + rnd.nextDouble() * 0.12);
      ring.color = _al(Colors.white, 0.30 + rnd.nextDouble() * 0.25);
      canvas.drawCircle(c, r, fill);
      canvas.drawCircle(c, r, ring);
    }
    final spark = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 11; i++) {
      final Offset c = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final double r = 4 + rnd.nextDouble() * 8;
      spark.color = _al(t.accent, 0.40 + rnd.nextDouble() * 0.40);
      _sparkle(canvas, c, r, spark);
    }
    _glow(
      canvas,
      Offset(size.width * 0.15, size.height * 0.95),
      size.width * 0.8,
      const Color(0xFFE8B4A5),
      0.30,
    );
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
  bool shouldRepaint(covariant ThemeBackdropPainter old) => old.t.id != t.id;
}
