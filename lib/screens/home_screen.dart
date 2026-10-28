import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../services/audio_manager.dart';
import '../services/tutorial_manager.dart';
import '../theme/app_theme.dart';
import 'mode_selection_screen.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _bg => AppTheme.bg;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

// Soft shadow for the Play button and Streak strip
List<BoxShadow> get _softShadow => [
  BoxShadow(
    color: Colors.black.withOpacity(AppTheme.isDark ? 0.3 : 0.08),
    blurRadius: 20,
    offset: const Offset(0, 10),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // LOGIC UNCHANGED: audio init same as before.
    Future.delayed(const Duration(milliseconds: 500), () {
      final audio = AudioManager();
      if (audio.isMusicEnabled) {
        audio.playBackgroundMusic();
      }
    });
  }

  // LOGIC UNCHANGED: same navigation target.
  void _goToModes() {
    // TUTORIAL: PLAY tapped -> next step (Classic Mode card).
    final game = context.read<GameProvider>();
    if (game.tutorialStep == TutorialManager.stepPlay) {
      game.setTutorialStep(TutorialManager.stepClassicMode);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(
          name: TutorialManager.modeSelectionRouteName,
        ),
        builder: (_) => ModeSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LOGIC UNCHANGED: rebuild on theme change.
    context.select<GameProvider, String>((g) => g.currentTheme.id);
    final game = context.watch<GameProvider>();

    return ThemedScaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Background Game Vibe (Floating puzzle blocks)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _GameVibePainter()),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Area (Ab bilkul khali aur clean hai, sirf spacing ke liye)
                const SizedBox(height: 40),

                // Center Content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo Container
                        Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: _brand,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: _brand.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: CustomPaint(painter: _LogoPainter()),
                            )
                            .animate()
                            .scale(duration: 800.ms, curve: Curves.easeOutBack)
                            .shimmer(delay: 1.seconds, duration: 2.seconds),

                        const SizedBox(height: 35),

                        // Title
                        RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 52, // Bada aur attractive font
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'ARROW',
                                    style: TextStyle(
                                      color: _ink,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'RIFT',
                                    style: TextStyle(color: _accent),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.3, end: 0),

                        const SizedBox(height: 12),

                        // Tagline
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _brand.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'FIND THE WAY OUT.',
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 3,
                              color: _brand,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 60),

                        // Pulsing PLAY button
                        SizedBox(
                              key: TutorialManager.playButtonKey,
                              width: 220,
                              height: 65,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brand,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  elevation: 10,
                                  shadowColor: _brand.withOpacity(0.5),
                                ),
                                onPressed: _goToModes,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'PLAY',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 3,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 32,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate()
                            .scale(
                              delay: 600.ms,
                              duration: 500.ms,
                              curve: Curves.easeOutBack,
                            )
                            .then()
                            // Play button dhadakne ki animation (Pulse)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.05, 1.05),
                              duration: 1.seconds,
                              curve: Curves.easeInOut,
                            ),
                      ],
                    ),
                  ),
                ),

                // Bottom Area (Streak Strip)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: _buildStreakStrip(game)
                      .animate()
                      .fadeIn(delay: 800.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= STREAK STRIP =================
  Widget _buildStreakStrip(GameProvider game) {
    final int streak = game.streakCount;
    final bool claimed = game.streakClaimedToday;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line.withOpacity(0.8), width: 1.5),
        boxShadow: _softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: claimed ? Colors.orange.shade300 : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            streak > 0 ? '$streak day streak' : 'Start your daily streak!',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: claimed
                  ? Colors.green.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              claimed ? 'CLAIMED' : 'CLAIM IN GAME',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: claimed ? Colors.green.shade700 : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOGO PAINTER (Unchanged logic, just fits the new size)
// ============================================================================
class _LogoPainter extends CustomPainter {
  final String themeId = AppTheme.active.id;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final accentPaint = Paint()
      ..color = _accent
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.7);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    canvas.drawPath(path, paint);

    final tip = Offset(size.width * 0.8, size.height * 0.5);
    final arrowPath = Path()
      ..moveTo(tip.dx + 8, tip.dy)
      ..lineTo(tip.dx - 12, tip.dy - 16)
      ..lineTo(tip.dx - 12, tip.dy + 16)
      ..close();
    canvas.drawPath(arrowPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.themeId != themeId;
}

// ============================================================================
// GAME VIBE PAINTER (Background decoration)
// ============================================================================
class _GameVibePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = _brand.withOpacity(0.04);

    // Drawing soft abstract puzzle blocks / arrows in the background
    for (int i = 0; i < 15; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final blockSize = 20.0 + rnd.nextDouble() * 40.0;
      final angle = rnd.nextDouble() * pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      if (rnd.nextBool()) {
        // Draw a rounded block
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: blockSize,
              height: blockSize,
            ),
            const Radius.circular(8),
          ),
          paint,
        );
      } else {
        // Draw a faint arrow
        final path = Path()
          ..moveTo(-blockSize / 2, blockSize / 2)
          ..lineTo(0, -blockSize / 2)
          ..lineTo(blockSize / 2, blockSize / 2);
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..color = _brand.withOpacity(0.04),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
