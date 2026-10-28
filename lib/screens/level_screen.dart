import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../services/audio_manager.dart';
import '../services/tutorial_manager.dart';
import 'game_screen.dart';
import '../theme/app_theme.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _lockedBg => AppTheme.lockedBg;
Color get _lockedText => AppTheme.lockedText;
Color get _bg => AppTheme.bg;
Color get _pathColor => AppTheme.pathColor;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

class LevelScreen extends StatefulWidget {
  final bool isProMode;
  const LevelScreen({super.key, required this.isProMode});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  // Scroll controller: screen khulte hi user ke current (unlocked) level
  // par le jata hai, taake user ko scroll na karna paray.
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    AudioManager().restoreMusicVolume();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  // Given level ki row ko screen ke beech mein laane ka scroll offset.
  double _offsetForLevel({
    required int level,
    required int totalLevels,
    required int cols,
    required double cardH,
    required double spacing,
    required double viewportH,
  }) {
    const double padTop = 10;
    const double padBottom = 40;
    final double extent = cardH + spacing;
    final int rows = (totalLevels / cols).ceil();
    final int safeLevel = math.max(1, math.min(level, totalLevels));
    final int row = (safeLevel - 1) ~/ cols;
    final double itemTop = padTop + row * extent;
    final double target = itemTop + cardH / 2 - viewportH / 2;
    final double maxScroll = math.max(
      0.0,
      padTop + rows * extent + padBottom - viewportH,
    );
    return math.max(0.0, math.min(target, maxScroll));
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final int totalLevels = widget.isProMode
        ? GameProvider.maxProLevel
        : GameProvider.maxClassicLevel;
    final int unlockedLevel = widget.isProMode
        ? game.proUnlockedLevel
        : game.classicUnlockedLevel;

    return ThemedScaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isProMode ? 'PRO LEVELS' : 'CLASSIC LEVELS',
          style: TextStyle(
            color: _ink,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        // Yahan se Coins wala box hata diya gaya hai
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const int cols = 3;
          const double hPad = 24;
          const double spacing = 24;
          final double availableWidth = constraints.maxWidth - hPad * 2;

          final double cardW = (availableWidth - spacing * (cols - 1)) / cols;
          final double cardH = cardW * 1.05;
          final int rows = (totalLevels / cols).ceil();

          // Sirf pehli baar controller banta hai, user ke current level par.
          _scrollController ??= ScrollController(
            initialScrollOffset: _offsetForLevel(
              level: unlockedLevel,
              totalLevels: totalLevels,
              cols: cols,
              cardH: cardH,
              spacing: spacing,
              viewportH: constraints.maxHeight,
            ),
          );

          return ListView.builder(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 40),
            itemExtent: cardH + spacing,
            cacheExtent: cardH * 3,
            itemCount: rows,
            itemBuilder: (context, row) {
              final int start = row * cols;
              final int end = math.min(start + cols, totalLevels);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RowPathPainter(
                        row: row,
                        cardW: cardW,
                        cardH: cardH,
                        spacing: spacing,
                        cols: cols,
                        maxLevel: totalLevels,
                      ),
                    ),
                  ),
                  for (int index = start; index < end; index++)
                    Positioned(
                      left:
                          (row.isEven
                              ? (index % cols)
                              : (cols - 1 - (index % cols))) *
                          (cardW + spacing),
                      top: 0,
                      width: cardW,
                      height: cardH,
                      // key only on Classic Level 1 (tutorial highlight target)
                      child: KeyedSubtree(
                        key: (!widget.isProMode && index == 0)
                            ? TutorialManager.level1CardKey
                            : null,
                        child: _LevelCard(
                          levelNum: index + 1,
                          game: game,
                          isPro: widget.isProMode,
                          unlockedLevel: unlockedLevel,
                          onTap: () => _handleTap(context, game, index + 1),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, GameProvider game, int levelNum) {
    final int unlocked = widget.isProMode
        ? game.proUnlockedLevel
        : game.classicUnlockedLevel;

    if (levelNum <= unlocked) {
      // TUTORIAL: Level 1 tapped -> game step. Step is set BEFORE loadLevel
      // so the timer stays frozen (see GameProvider._startTimer).
      if (!widget.isProMode &&
          levelNum == 1 &&
          game.tutorialStep == TutorialManager.stepLevel1) {
        game.setTutorialStep(TutorialManager.stepGameArrow);
      }
      if (widget.isProMode) {
        game.loadProLevel(levelNum);
      } else {
        game.loadLevel(levelNum);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: TutorialManager.gameRouteName),
          builder: (_) => GameScreen(),
        ),
      );
      return;
    }

    if (levelNum == unlocked + 1) {
      final success = game.unlockLevelWithPoints(levelNum, widget.isProMode);
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: TutorialManager.gameRouteName),
            builder: (_) => GameScreen(),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough coins! You need ${game.getLevelCost(levelNum, pro: widget.isProMode)} coins.',
          ),
          backgroundColor: _accent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Level Locked!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You must complete Level $unlocked first before unlocking Level $levelNum.\n\nPlease play in sequence.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int levelNum;
  final GameProvider game;
  final bool isPro;
  final int unlockedLevel;
  final VoidCallback onTap;

  _LevelCard({
    required this.levelNum,
    required this.game,
    required this.isPro,
    required this.unlockedLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = levelNum <= unlockedLevel;
    final isCurrent = levelNum == game.currentLevel && game.isProMode == isPro;
    final cost = game.getLevelCost(levelNum, pro: isPro);

    final record = game.getRecordForLevel(levelNum, isPro: isPro);
    final bestTime = (record != null && record.bestTimeSeconds > 0)
        ? GameProvider.formatBestTime(record.bestTimeSeconds)
        : '--:--';
    final bestCoins = (record != null && record.bestCoins > 0)
        ? record.bestCoins.toString()
        : '0';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? _card : _lockedBg,
          borderRadius: BorderRadius.circular(24),
          border: isCurrent
              ? Border.all(color: _brand, width: 2.5)
              : Border.all(color: Colors.transparent, width: 0),
          boxShadow: isUnlocked
              ? [
                  if (isCurrent)
                    BoxShadow(
                      color: _accent.withOpacity(0.25),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$levelNum',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isUnlocked ? _brand : _lockedText,
                height: 1.0,
              ),
            ),
            SizedBox(height: 4),
            if (isUnlocked) ...[
              Text(
                'Time $bestTime',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.blueGrey(400),
                ),
              ),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.amber,
                    size: 10,
                  ),
                  SizedBox(width: 2),
                  Text(
                    bestCoins,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.amber,
                    size: 12,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$cost',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _lockedText,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().scale(
      delay: Duration(milliseconds: levelNum <= 30 ? levelNum * 5 : 0),
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }
}

class _RowPathPainter extends CustomPainter {
  final int row;
  final double cardW;
  final double cardH;
  final double spacing;
  final int cols;
  final int maxLevel;
  final String themeId = AppTheme.active.id;
  _RowPathPainter({
    required this.row,
    required this.cardW,
    required this.cardH,
    required this.spacing,
    required this.cols,
    required this.maxLevel,
  });

  Offset _center(int i) {
    final int r = i ~/ cols;
    final int posInRow = i % cols;
    final int col = r.isEven ? posInRow : (cols - 1 - posInRow);
    return Offset(
      col * (cardW + spacing) + cardW / 2,
      (r - row) * (cardH + spacing) + cardH / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = _pathColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double gap = (cardW / 2) + 6;
    final int first = row * cols;
    final int last = math.min(first + cols, maxLevel - 1);

    for (int i = first; i < last; i++) {
      final p0 = _center(i);
      final p1 = _center(i + 1);
      final isHorizontal = (p0.dy - p1.dy).abs() < 1.0;
      if (isHorizontal) {
        final isRight = p1.dx > p0.dx;
        final start = Offset(p0.dx + (isRight ? gap : -gap), p0.dy);
        final end = Offset(p1.dx + (isRight ? -gap : gap), p1.dy);
        canvas.drawLine(start, end, pathPaint);
        _drawArrows(
          canvas,
          Offset((start.dx + end.dx) / 2, start.dy),
          isRight,
          pathPaint.color,
        );
      } else {
        final isRightEdge = p0.dx > p1.dx;
        final start = Offset(p0.dx, p0.dy + (p1.dy > p0.dy ? gap : -gap));
        final end = Offset(p1.dx, p1.dy + (p1.dy > p0.dy ? -gap : gap));
        final controlX = isRightEdge
            ? start.dx + (spacing / 2) + 12
            : start.dx - (spacing / 2) - 12;
        final controlY = (start.dy + end.dy) / 2;
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(controlX, controlY, end.dx, end.dy);
        canvas.drawPath(path, pathPaint);
        const t = 0.5;
        final x =
            (1 - t) * (1 - t) * start.dx +
            2 * (1 - t) * t * controlX +
            t * t * end.dx;
        final y =
            (1 - t) * (1 - t) * start.dy +
            2 * (1 - t) * t * controlY +
            t * t * end.dy;
        _drawDiamond(canvas, Offset(x, y));
      }
    }
  }

  void _drawDiamond(Canvas canvas, Offset center) {
    final p = Paint()
      ..color = _accent.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - 5)
      ..lineTo(center.dx + 5, center.dy)
      ..lineTo(center.dx, center.dy + 5)
      ..lineTo(center.dx - 5, center.dy)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawCircle(center, 1.5, Paint()..color = Colors.white);
  }

  void _drawArrows(Canvas canvas, Offset center, bool pointRight, Color color) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    for (int i = -1; i <= 1; i += 2) {
      final dx = center.dx + (pointRight ? (i * 3) : -(i * 3));
      final path = Path();
      if (pointRight) {
        path.moveTo(dx - 3.5, center.dy - 4.5);
        path.lineTo(dx, center.dy);
        path.lineTo(dx - 3.5, center.dy + 4.5);
      } else {
        path.moveTo(dx + 3.5, center.dy - 4.5);
        path.lineTo(dx, center.dy);
        path.lineTo(dx + 3.5, center.dy + 4.5);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _RowPathPainter oldDelegate) =>
      oldDelegate.themeId != themeId;
}
