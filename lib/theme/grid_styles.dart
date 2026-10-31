import 'dart:math';

import 'package:flutter/material.dart';

import '../economy/economy_config.dart';

// ============================================================================
// ARROWRIFT CUSTOM GRIDS  —  purchasable board SHAPES (like themes).
//
//   DEFAULT  - the original square board (free, always owned).
//   REGULAR  - Circle, Diamond, Octagon           (Eco.gridPrice coins).
//   PREMIUM  - Heart, Plus, Ring                  (Eco.premiumGridPrice coins).
//
// Every new player gets ONE free trial per grid, after that it must be bought
// with coins. A shape is just a mask on top of the normal n x n board: arrows
// are only generated on the cells INSIDE the shape, cells outside stay empty
// (arrows simply fly over them when they escape). Rules, lives, timer and
// rewards are the same as the square board.
// ============================================================================

enum GridTier { regular, premium }

enum GridKind { square, circle, diamond, octagon, heart, plus, ring }

class GridStyle {
  final String id;
  final String name;
  final String tagline;
  final IconData icon;
  final GridKind kind;
  final GridTier tier;
  final int? customPrice;

  const GridStyle({
    required this.id,
    required this.name,
    required this.tagline,
    required this.icon,
    required this.kind,
    this.tier = GridTier.regular,
    this.customPrice,
  });

  bool get isDefault => id == GridStyles.defaultId;
  bool get isPremium => tier == GridTier.premium;

  /// Coins needed to own this grid forever.
  int get price =>
      customPrice ?? (isPremium ? Eco.premiumGridPrice : Eco.gridPrice);
}

class GridStyles {
  GridStyles._();

  static const String defaultId = 'default';

  static const GridStyle defaultGrid = GridStyle(
    id: defaultId,
    name: 'Classic Square',
    tagline: 'The original square board.',
    icon: Icons.crop_square_rounded,
    kind: GridKind.square,
  );

  // ------------------------------------------------------------- REGULAR
  static const GridStyle circle = GridStyle(
    id: 'circle',
    name: 'Circle',
    tagline: 'A round board with soft edges.',
    icon: Icons.circle_outlined,
    kind: GridKind.circle,
  );

  static const GridStyle diamond = GridStyle(
    id: 'diamond',
    name: 'Diamond',
    tagline: 'A pointed gem-shaped board.',
    icon: Icons.diamond_outlined,
    kind: GridKind.diamond,
  );

  static const GridStyle octagon = GridStyle(
    id: 'octagon',
    name: 'Octagon',
    tagline: 'Square board with cut corners.',
    icon: Icons.stop_rounded,
    kind: GridKind.octagon,
  );

  // ------------------------------------------------------------- PREMIUM
  static const GridStyle heart = GridStyle(
    id: 'heart',
    name: 'Heart',
    tagline: 'Clear arrows inside a big heart.',
    icon: Icons.favorite_rounded,
    kind: GridKind.heart,
    tier: GridTier.premium,
  );

  static const GridStyle plus = GridStyle(
    id: 'plus',
    name: 'Plus',
    tagline: 'A bold cross-shaped board.',
    icon: Icons.add_rounded,
    kind: GridKind.plus,
    tier: GridTier.premium,
  );

  static const GridStyle ring = GridStyle(
    id: 'ring',
    name: 'Ring',
    tagline: 'A donut board with an empty centre.',
    icon: Icons.radio_button_unchecked_rounded,
    kind: GridKind.ring,
    tier: GridTier.premium,
  );

  static const List<GridStyle> all = [
    defaultGrid,
    circle,
    diamond,
    octagon,
    heart,
    plus,
    ring,
  ];

  /// REGULAR category = the free default + the buyable regular shapes.
  static List<GridStyle> get regular => all.where((g) => !g.isPremium).toList();

  /// PREMIUM category = the high-end shapes (higher price).
  static List<GridStyle> get premium => all.where((g) => g.isPremium).toList();

  static GridStyle byId(String? id) {
    for (final g in all) {
      if (g.id == id) return g;
    }
    return defaultGrid;
  }

  // ---------------------------------------------------------------- MASKS
  static bool _inside(GridKind kind, int x, int y, int n) {
    // normalised coordinates of the cell centre: -1 .. +1 (y grows downward)
    final double u = (x + 0.5) / n * 2 - 1;
    final double v = (y + 0.5) / n * 2 - 1;
    switch (kind) {
      case GridKind.square:
        return true;
      case GridKind.circle:
        return u * u + v * v <= 1.02;
      case GridKind.diamond:
        return u.abs() + v.abs() <= 1.12;
      case GridKind.octagon:
        return u.abs() + v.abs() <= 1.55;
      case GridKind.plus:
        return u.abs() <= 0.36 || v.abs() <= 0.36;
      case GridKind.ring:
        final double r = sqrt(u * u + v * v);
        return r >= 0.36 && r <= 1.02;
      case GridKind.heart:
        final double hx = u * 1.22;
        final double hy = 0.115 - v * 1.13;
        final double a = hx * hx + hy * hy - 1;
        return a * a * a - hx * hx * hy * hy * hy <= 0;
    }
  }

  /// Builds an n x n mask (true = playable cell inside the shape). Cells that
  /// would be completely alone (no neighbour) are removed because an arrow
  /// needs at least 2 cells. The square shape returns an empty list, which
  /// the game treats as "no mask" (original behaviour).
  static List<List<bool>> buildMask(GridStyle g, int n) {
    if (g.isDefault || n <= 0) return const [];
    final raw = List.generate(
      n,
      (y) => List<bool>.generate(n, (x) => _inside(g.kind, x, y, n)),
    );
    final out = List.generate(n, (y) => List<bool>.from(raw[y]));
    const dx = [0, 1, 0, -1];
    const dy = [-1, 0, 1, 0];
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        if (!raw[y][x]) continue;
        bool hasNeighbour = false;
        for (int d = 0; d < 4; d++) {
          final int nx = x + dx[d];
          final int ny = y + dy[d];
          if (nx < 0 || ny < 0 || nx >= n || ny >= n) continue;
          if (raw[ny][nx]) {
            hasNeighbour = true;
            break;
          }
        }
        if (!hasNeighbour) out[y][x] = false;
      }
    }
    return out;
  }

  /// Number of playable cells in a mask.
  static int cellCount(List<List<bool>> mask) {
    int c = 0;
    for (final row in mask) {
      for (final v in row) {
        if (v) c++;
      }
    }
    return c;
  }

  /// Rounded-tile path of every playable cell (used by the board painter and
  /// the shop thumbnails). [inset] shrinks every tile a little so neighbouring
  /// tiles show a thin gap.
  static Path tilesPath(List<List<bool>> mask, double cs, {double inset = 0}) {
    final Path p = Path();
    final double rad = cs * 0.22;
    for (int y = 0; y < mask.length; y++) {
      for (int x = 0; x < mask[y].length; x++) {
        if (!mask[y][x]) continue;
        p.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x * cs + inset,
              y * cs + inset,
              cs - inset * 2,
              cs - inset * 2,
            ),
            Radius.circular(rad),
          ),
        );
      }
    }
    return p;
  }
}
