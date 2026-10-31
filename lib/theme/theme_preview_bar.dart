import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'app_theme.dart';
import 'grid_styles.dart';

/// Wraps the whole app. While a free theme trial is running it shows a slim
/// bar on top of EVERY screen with the time left, an UNLOCK button and a
/// close button. The bar is part of the layout (not floating) so it never
/// covers any game UI.
class ThemePreviewShell extends StatelessWidget {
  final Widget child;
  const ThemePreviewShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final bool previewing = context.select<GameProvider, bool>(
      (g) => g.isPreviewingTheme,
    );
    final ArrowTheme t = context.select<GameProvider, ArrowTheme>(
      (g) => g.currentTheme,
    );
    final bool gridPreviewing = context.select<GameProvider, bool>(
      (g) => g.isPreviewingGrid,
    );
    final GridStyle grid = context.select<GameProvider, GridStyle>(
      (g) => g.currentGrid,
    );

    // NOTE: the tree shape is identical with/without the bar (slot 0 is either
    // the bar or an empty box) so the Navigator is never re-created.
    return Column(
      children: [
        if (!previewing && !gridPreviewing)
          const SizedBox.shrink()
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (previewing)
                Material(
                  color: t.brand,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.palette_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ValueListenableBuilder<int>(
                              valueListenable: game.previewSecondsLeft,
                              builder: (context, secs, _) {
                                final String mm = (secs ~/ 60).toString();
                                final String ss = (secs % 60)
                                    .toString()
                                    .padLeft(2, '0');
                                return Text(
                                  'Free trial: ${t.name}  •  $mm:$ss',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              if (game.totalPoints >= t.price) {
                                game.buyTheme(t.id);
                              } else {
                                ScaffoldMessenger.maybeOf(
                                  context,
                                )?.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Not enough coins! You need ${t.price} coins.',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_open_rounded,
                                    color: t.brand,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${t.price}',
                                    style: TextStyle(
                                      color: t.brand,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.monetization_on_rounded,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: game.endThemePreview,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (gridPreviewing)
                _gridBar(context, game, t, grid, topSafe: !previewing),
            ],
          ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: previewing || gridPreviewing,
            child: child,
          ),
        ),
      ],
    );
  }

  /// Slim bar for a running free GRID trial (same look as the theme bar).
  Widget _gridBar(
    BuildContext context,
    GameProvider game,
    ArrowTheme t,
    GridStyle grid, {
    required bool topSafe,
  }) {
    return Material(
      color: Color.lerp(t.brand, Colors.black, 0.18),
      child: SafeArea(
        top: topSafe,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
          child: Row(
            children: [
              const Icon(Icons.grid_on_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: game.gridPreviewSecondsLeft,
                  builder: (context, secs, _) {
                    final String mm = (secs ~/ 60).toString();
                    final String ss = (secs % 60).toString().padLeft(2, '0');
                    return Text(
                      'Free shape trial: ${grid.name}  •  $mm:$ss',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  if (game.totalPoints >= grid.price) {
                    game.buyGrid(grid.id);
                  } else {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Not enough coins! You need ${grid.price} coins.',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_open_rounded, color: t.brand, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${grid.price}',
                        style: TextStyle(
                          color: t.brand,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: game.endGridPreview,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
