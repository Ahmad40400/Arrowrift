import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../models/arrow_model.dart';
import '../providers/game_provider.dart';
import '../services/tutorial_manager.dart';
import 'board_painter.dart';

class ArrowsBoard extends StatefulWidget {
  const ArrowsBoard({super.key});

  @override
  State<ArrowsBoard> createState() => _ArrowsBoardState();
}

class _ArrowsBoardState extends State<ArrowsBoard>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _clock = ValueNotifier<int>(0);
  GameProvider? _game;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  void _onTick(Duration _) {
    final now = gameClock.elapsedMilliseconds;
    _clock.value = now;
    final game = _game;
    if (game == null || !game.hasActiveAnimation(now)) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    _game = game;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_ticker.isActive &&
          game.hasActiveAnimation(gameClock.elapsedMilliseconds)) {
        _ticker.start();
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        const double pad = 16;
        final double avail = (constraints.biggest.shortestSide - pad * 2)
            .clamp(50.0, 4000.0)
            .toDouble();
        final int n = game.gridSize;
        final double cs = avail / n;
        final double boardSize = cs * n;

        return InteractiveViewer(
          minScale: 1,
          maxScale: 6,
          boundaryMargin: const EdgeInsets.all(40),
          child: Center(
            child: SizedBox(
              key: TutorialManager.boardKey, // tutorial: highlight target
              width: boardSize,
              height: boardSize,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) {
                  final id = game.arrowAt(
                    d.localPosition.dx / cs,
                    d.localPosition.dy / cs,
                  );
                  if (id != null) game.tapArrow(id);
                },
                child: CustomPaint(
                  size: Size(boardSize, boardSize),
                  painter: BoardPainter(game: game, repaint: _clock),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
