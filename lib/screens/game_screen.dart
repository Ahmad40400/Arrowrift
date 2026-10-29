import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import 'dart:math';

import '../economy/economy_config.dart';
import '../providers/game_provider.dart';
import '../services/audio_manager.dart';
import '../services/tutorial_manager.dart';
import '../widgets/arrows_board.dart';
import '../theme/app_theme.dart';

Color get _ink => AppTheme.isClassic ? Color(0xFF1B1B3A) : AppTheme.ink;
Color get _brand => AppTheme.isClassic ? Color(0xFF2B2F77) : AppTheme.brand;
Color get _accent => AppTheme.isClassic ? Color(0xFFE53935) : AppTheme.accent;
Color get _bg => AppTheme.isClassic ? Color(0xFFF5F7FA) : AppTheme.bg;
Color get _card => AppTheme.card;
const Color _bossRed = Color(0xFFD32F2F);
Color get _textBrand => AppTheme.isClassic ? Color(0xFF2B2F77) : AppTheme.ink;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final ConfettiController _confettiController;
  bool _tutorialExitScheduled = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    AudioManager().lowerMusicVolume();
  }

  void _scheduleTutorialExit() {
    if (_tutorialExitScheduled) return;
    _tutorialExitScheduled = true;
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final game = context.read<GameProvider>();
      if (game.tutorialStep != TutorialManager.stepGameArrow) {
        _tutorialExitScheduled = false;
        return;
      }
      _confettiController.stop();
      game.setTutorialStep(TutorialManager.stepStats);
      Navigator.of(context).popUntil(
        (route) =>
            route.settings.name == TutorialManager.modeSelectionRouteName ||
            route.isFirst,
      );
    });
  }

  void _goBack() {
    final game = context.read<GameProvider>();
    game.leaveLevel();
    game.saveDataNow();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  String _resultMessage(GameProvider g) {
    if (g.isDailyChallenge) return 'Daily Challenge bonus!';
    if (g.usedAutoSolve) {
      return 'Auto-Solved: reduced reward, no achievements.';
    }
    if (g.isReplayReward) {
      if (g.replayImprovementBonus > 0) {
        return 'New best stars! +${g.replayImprovementBonus} improvement bonus.';
      }
      if (g.replayLimitHit) {
        return 'Daily replay coin limit reached. Beat your best stars for bonus!';
      }
      return 'Replay: small reward. Beat your best stars for a bonus!';
    }
    if (g.usedFreezeThisLevel && g.levelStars == Eco.freezeMaxStars) {
      return 'Time Freeze used: max ${Eco.freezeMaxStars} stars.';
    }
    if (g.levelStars == 3) return 'Great speed! Max coins!';
    if (g.levelStars == 2) return 'Good! Finish faster for 3 stars.';
    return 'Too slow. Coins reduced.';
  }

  void _showNotEnoughCoinsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              'Not Enough Coins',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'You do not have enough coins to buy this power-up or unlock the next level. Play more levels or buy from Shop!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold, color: _textBrand),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    if (game.isLevelComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_confettiController.state == ConfettiControllerState.stopped) {
          _confettiController.play();
        }
      });
    }

    if (game.isLevelComplete &&
        game.tutorialStep == TutorialManager.stepGameArrow) {
      _scheduleTutorialExit();
    }

    final bool hidePowerUps =
        game.isGameOver || game.isLevelFailed || game.isLevelComplete;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          game.leaveLevel();
          game.saveDataNow();
        }
      },
      child: ThemedScaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ---------------- TOP BAR ----------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _goBack,
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _textBrand,
                              size: 24,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              game.isDailyChallenge
                                  ? 'DAILY'
                                  : (game.isProMode
                                        ? 'PRO ${game.currentLevel}'
                                        : 'Level ${game.currentLevel}'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                            Text(
                              game.isBossNow
                                  ? 'BOSS LEVEL'
                                  : game.getDifficultyText(game.currentLevel),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: game.isBossNow ? 1.5 : 0,
                                color: game.isBossNow
                                    ? _bossRed
                                    : AppTheme.blueGrey(500),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: game.isTimeFrozen
                                ? Colors.lightBlue.withOpacity(0.2)
                                : (game.timeLeft < 5
                                      ? _accent.withOpacity(0.1)
                                      : _card),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: game.isTimeFrozen
                                  ? Colors.lightBlue
                                  : (game.timeLeft < 5
                                        ? _accent
                                        : Colors.transparent),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                game.isTimeFrozen
                                    ? Icons.ac_unit_rounded
                                    : Icons.timer_rounded,
                                size: 20,
                                color: game.isTimeFrozen
                                    ? Colors.lightBlue
                                    : (game.timeLeft < 5
                                          ? _accent
                                          : AppTheme.blueGrey(500)),
                              ),
                              SizedBox(width: 8),
                              Text(
                                game.isTimeFrozen
                                    ? 'FROZEN'
                                    : '${game.timeLeft}s',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: game.isTimeFrozen
                                      ? Colors.lightBlue
                                      : (game.timeLeft < 5 ? _accent : _ink),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ---------------- BOSS BANNER ----------------
                  if (game.isBossNow)
                    Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _bossRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _bossRed, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: _bossRed,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'BOSS  •  No Freeze  •  Dense Board',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _bossRed,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .shake(hz: 3, duration: 500.ms),

                  // ---------------- STATS ROW ----------------
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.navigation_rounded,
                                size: 20,
                                color: AppTheme.blueGrey(500),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${game.moves}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(3, (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < game.lives
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: index < game.lives
                                    ? _accent
                                    : AppTheme.grey(300),
                                size: 32,
                              ),
                            );
                          }),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.monetization_on_rounded,
                                size: 20,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${game.totalPoints}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(child: ArrowsBoard()),

                  // ---------------- BOTTOM BUTTONS (POWER-UPS) ----------------
                  if (!game.isDailyChallenge && !hidePowerUps)
                    Padding(
                      padding: EdgeInsets.only(bottom: 24, left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBottomButton(
                            icon: Icons.ac_unit_rounded,
                            color: Colors.lightBlue,
                            label: 'Freeze',
                            cost: Eco.freezeCoinPrice,
                            inventory: game.freezeInventory,
                            disabled: game.isBossNow,
                            onTap: () {
                              if (game.isLevelFailed ||
                                  game.isGameOver ||
                                  game.isLevelComplete) {
                                return;
                              }
                              if (game.isBossNow) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Boss level: Freeze is not allowed!',
                                    ),
                                    backgroundColor: _bossRed,
                                  ),
                                );
                                return;
                              }
                              if (game.isTimeFrozen) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Time is already frozen!'),
                                    backgroundColor: Colors.lightBlue,
                                  ),
                                );
                                return;
                              }
                              if (game.freezeInventory == 0 &&
                                  game.totalPoints < Eco.freezeCoinPrice) {
                                _showNotEnoughCoinsDialog(context);
                                return;
                              }
                              game.useTimeFreeze();
                            },
                          ),
                          _buildBottomButton(
                            icon: Icons.favorite_rounded,
                            color: _accent,
                            label: 'Life',
                            cost: Eco.healthCoinPrice,
                            inventory: game.healthInventory,
                            onTap: () {
                              if (game.isLevelFailed ||
                                  game.isGameOver ||
                                  game.isLevelComplete) {
                                return;
                              }
                              if (game.lives >= 3) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Text(
                                      'Health Full',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      'Your health is already full!',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'OK',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _textBrand,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              if (game.healthInventory == 0 &&
                                  game.totalPoints < Eco.healthCoinPrice) {
                                _showNotEnoughCoinsDialog(context);
                                return;
                              }
                              game.useHealth();
                            },
                          ),
                          _buildBottomButton(
                            icon: Icons.auto_fix_high_rounded,
                            color: Colors.deepPurpleAccent,
                            label: 'Solve',
                            cost: Eco.autoSolveDiamondPrice,
                            isDiamondCost: true,
                            inventory: game.autoSolveInventory,
                            onTap: () {
                              if (game.isLevelFailed ||
                                  game.isGameOver ||
                                  game.isLevelComplete) {
                                return;
                              }
                              if (game.autoSolveInventory == 0 &&
                                  game.totalDiamonds <
                                      Eco.autoSolveDiamondPrice &&
                                  game.totalPoints < Eco.autoSolveCoinPrice) {
                                _showNotEnoughCoinsDialog(context);
                                return;
                              }
                              game.useAutoSolve();
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // ---------------- CONFETTI ----------------
              IgnorePointer(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: pi / 2,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.02,
                    numberOfParticles: 40,
                    gravity: 0.15,
                    colors: [
                      Color(0xFF2B2F77),
                      Color(0xFFE53935),
                      Colors.amber,
                      Colors.green,
                      Colors.blueAccent,
                      Colors.pinkAccent,
                    ],
                    shouldLoop: true,
                    createParticlePath: (size) {
                      final path = Path();
                      final double radius = size.width / 2;
                      final double innerRadius = radius / 2.5;
                      const int numPoints = 5;
                      final double angle = (2 * pi) / numPoints;
                      for (int i = 0; i < numPoints * 2; i++) {
                        final double r = i.isEven ? radius : innerRadius;
                        final double a = i * angle - pi / 2;
                        final double x = r * cos(a);
                        final double y = r * sin(a);
                        if (i == 0)
                          path.moveTo(x, y);
                        else
                          path.lineTo(x, y);
                      }
                      path.close();
                      return path;
                    },
                  ),
                ),
              ),

              // ---------------- LEVEL COMPLETE DIALOG ----------------
              if (game.isLevelComplete)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(24),
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 40),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_rounded,
                          size: 64,
                          color: Colors.amber,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Level Complete!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _ink,
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildTimeTakenRow(game),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  3,
                                  (i) => Icon(
                                    i < game.levelStars
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: Colors.amber,
                                    size: 32,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _resultMessage(game),
                                style: TextStyle(
                                  color:
                                      (game.levelStars == 3 &&
                                          !game.usedAutoSolve &&
                                          !game.isReplayReward)
                                      ? Colors.green
                                      : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '+${game.levelPointsEarned} Coins',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                        SizedBox(height: 20),

                        if (game.isDailyChallenge)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              _confettiController.stop();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (game.isLastLevel)
                          Column(
                            children: [
                              Text(
                                'You finished every level!',
                                style: TextStyle(
                                  color: AppTheme.blueGrey(500),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  _confettiController.stop();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Back to Levels',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (game.canAffordNextLevel())
                          Column(
                            children: [
                              Text(
                                'Unlock Next Level - ${game.getLevelCost(game.currentLevel + 1)} Coins',
                                style: TextStyle(
                                  color: AppTheme.blueGrey(500),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  _confettiController.stop();
                                  bool success = game
                                      .unlockAndProceedToNextLevel();
                                  if (!success) {
                                    _showNotEnoughCoinsDialog(context);
                                  }
                                },
                                child: Text(
                                  'Next Level',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              Text(
                                'Need ${game.getLevelCost(game.currentLevel + 1)} Coins to unlock next level',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_rounded,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Short on Coins?',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.dim(87),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Play Arcade or exchange Diamonds to earn more.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.dim(54),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brand,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  _confettiController.stop();
                                  game.restartLevel();
                                },
                                child: Text(
                                  'Replay to Earn More',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                ),

              // ---------------- GAME OVER DIALOG ----------------
              if (game.isGameOver || game.isLevelFailed)
                Align(
                  alignment: Alignment.center,
                  child:
                      Container(
                        padding: EdgeInsets.all(32),
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 40),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              game.isLevelFailed
                                  ? Icons.timer_off_rounded
                                  : Icons.sentiment_dissatisfied_rounded,
                              size: 64,
                              color: _accent,
                            ),
                            SizedBox(height: 16),
                            Text(
                              game.isLevelFailed ? 'Time Up!' : 'You Lose!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _ink,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              game.isLevelFailed
                                  ? 'You ran out of time.'
                                  : 'All hearts are gone.',
                              style: TextStyle(color: AppTheme.dim(54)),
                            ),
                            SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.grey(200),
                                    foregroundColor: _ink,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Main Menu'),
                                ),
                                if (!game.isDailyChallenge)
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _accent,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      game.restartLevel();
                                    },
                                    child: Text('Restart'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().scale(
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTakenRow(GameProvider game) {
    final bool isReplayOrAuto = game.usedAutoSolve;
    final int current = game.timeTaken;

    final record = game.getRecordForLevel(
      game.currentLevel,
      isPro: game.isProMode,
    );
    final int best = record?.bestTimeSeconds ?? 0;

    if (isReplayOrAuto || game.isDailyChallenge) {
      return Text(
        'Time Taken: ${current}s',
        style: TextStyle(fontWeight: FontWeight.bold, color: _ink),
      );
    }

    final bool isNewBest = best == 0 || current <= best;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Time Taken: ${current}s',
          style: TextStyle(fontWeight: FontWeight.bold, color: _ink),
        ),
        if (isNewBest) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'NEW BEST!',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.green.shade700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ] else if (best > 0) ...[
          const SizedBox(width: 8),
          Text(
            'Best: ${best}s',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.dim(54),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
    int? cost,
    int inventory = 0,
    bool isDiamondCost = false,
    bool disabled = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _card,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  disabled ? Icons.lock_rounded : icon,
                  color: disabled ? Colors.grey : color,
                  size: 28,
                ),
              ),
            ),
            if (inventory > 0)
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    '$inventory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (cost != null && inventory == 0 && !disabled)
              Positioned(
                top: 2,
                right: -18,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _brand,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDiamondCost
                            ? Icons.diamond_rounded
                            : Icons.monetization_on_rounded,
                        color: isDiamondCost ? Colors.cyan : Colors.amber,
                        size: 10,
                      ),
                      SizedBox(width: 2),
                      Text(
                        '$cost',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.dim(54),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
