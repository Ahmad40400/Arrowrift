import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../economy/economy_config.dart';
import '../providers/game_provider.dart';
import 'app_theme.dart';

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

    // NOTE: the tree shape is identical with/without the bar (slot 0 is either
    // the bar or an empty box) so the Navigator is never re-created.
    return Column(
      children: [
        if (!previewing)
          const SizedBox.shrink()
        else
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
                          final String ss = (secs % 60).toString().padLeft(
                            2,
                            '0',
                          );
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
                        if (game.totalPoints >= Eco.themePrice) {
                          game.buyTheme(t.id);
                        } else {
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Not enough coins! You need ${Eco.themePrice} coins.',
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
                              '${Eco.themePrice}',
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
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: previewing,
            child: child,
          ),
        ),
      ],
    );
  }
}
