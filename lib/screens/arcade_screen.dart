import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import 'memory_game_screen.dart';
import 'tap_target_screen.dart';
import 'color_reflex_screen.dart';
import '../theme/app_theme.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.86);
  int _currentPage = 0;

  // Slow looping animation used by the little illustrations on the cards.
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  // FEATURE #2: realistic reward ranges instead of misleading "Up to X".
  // The `id` is also the key used for the PER-GAME record in GameProvider.
  final List<Map<String, dynamic>> _games = [
    {
      'id': 'memory',
      'title': 'Memory Match',
      'tag': 'BRAIN',
      'desc': 'Match all pairs before time runs out. Speed is key!',
      'icon': Icons.extension_rounded,
      'color': Colors.purpleAccent,
      'reward': 'Earn 25–150 Coins',
      'length': 'Fast = more coins',
      'screen': MemoryGameScreen(),
    },
    {
      'id': 'tap_target',
      'title': 'Tap Target',
      'tag': 'SPEED',
      'desc': 'Tap as many targets as you can in 10 seconds.',
      'icon': Icons.my_location_rounded,
      'color': Colors.orangeAccent,
      'reward': 'Earn 15–120 Coins',
      'length': '10 seconds',
      'screen': TapTargetScreen(),
    },
    {
      'id': 'color_reflex',
      'title': 'Color Reflex',
      'tag': 'FOCUS',
      'desc': 'Tap the matching color as fast as possible.',
      'icon': Icons.color_lens_rounded,
      'color': Colors.blueAccent,
      'reward': 'Earn 10–100 Coins',
      'length': '15 seconds',
      'screen': ColorReflexScreen(),
    },
  ];

  @override
  void dispose() {
    _float.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final canPlay = game.canPlayMinigame;

    final int playsLeft = math.max(
      0,
      GameProvider.maxMinigamesPerDay - game.dailyMinigamesPlayed,
    );

    // FEATURE #1 & #3: overall daily limit context.
    // "You've played all 5 games today. Resets in Xh Ym."
    final String subtitle = canPlay
        ? 'Play fun mini-games to earn quick coins!'
        : "You've played all ${GameProvider.maxMinigamesPerDay} games today. "
              'Resets in ${_dailyResetCountdown()}.';

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------------------------------------------ HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _brand.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sports_esports_rounded,
                        color: _brand,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'ARCADE',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _PlaysLeftPill(
                      playsLeft: playsLeft,
                      total: GameProvider.maxMinigamesPerDay,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: canPlay ? AppTheme.dim(54) : _accent,
                    fontSize: 14,
                    fontWeight: canPlay ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ------------------------------------------------------- CARDS
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double cardHeight = constraints.maxHeight * 0.96;

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentPage;
                    final gameData = _games[index];
                    final String id = gameData['id'] as String;

                    final Color baseColor = gameData['color'] as Color;
                    final Color activeColor = canPlay
                        ? baseColor
                        : AppTheme.grey(500);

                    // FEATURE #4: PER-GAME record (each game has its own).
                    final int bestForGame = game.bestCoinsFor(id);
                    final int playsForGame = game.playsFor(id);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: isSelected
                          ? null
                          : () => _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            ),
                      child: AnimatedScale(
                        scale: isSelected ? 1.0 : 0.9,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.6,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            height: cardHeight,
                            decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: activeColor.withOpacity(
                                  isSelected ? 0.35 : 0.12,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: activeColor.withOpacity(
                                          canPlay ? 0.28 : 0.1,
                                        ),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(31),
                              child: _CardContent(
                                id: id,
                                title: gameData['title'] as String,
                                tag: gameData['tag'] as String,
                                desc: gameData['desc'] as String,
                                icon: gameData['icon'] as IconData,
                                reward: gameData['reward'] as String,
                                length: gameData['length'] as String,
                                color: activeColor,
                                canPlay: canPlay,
                                isSelected: isSelected,
                                best: bestForGame,
                                plays: playsForGame,
                                anim: _float,
                                onPlay: (canPlay && isSelected)
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                gameData['screen'] as Widget,
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ------------------------------------------------ PAGE DOTS
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_games.length, (index) {
              final bool on = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: on ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: on ? _brand : AppTheme.grey(300),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // FEATURE #1 & #3: midnight reset countdown.
  // GameProvider.todayStamp local midnight pe flip hota hai, isliye countdown
  // bhi local midnight target karta hai — dono consistent rehte hain.
  String _dailyResetCountdown() {
    final DateTime now = DateTime.now();
    final DateTime nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final Duration remaining = nextMidnight.difference(now);

    if (remaining.inSeconds <= 0) return 'now';

    final int hours = remaining.inHours;
    final int minutes = remaining.inMinutes % 60;

    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return '<1m';
  }
}

// ============================================================================
// Card body — adapts to the real card height so it fits ANY screen size:
//  * tall card  : banner + title + description + 2 chip rows + button
//  * medium card: description hidden
//  * short card : only ONE chip row, smaller button/paddings
//  * and the whole text block is wrapped in a FittedBox, so even with a huge
//    system font size it just scales down instead of overflowing.
// ============================================================================
class _CardContent extends StatelessWidget {
  final String id;
  final String title;
  final String tag;
  final String desc;
  final IconData icon;
  final String reward;
  final String length;
  final Color color;
  final bool canPlay;
  final bool isSelected;
  final int best;
  final int plays;
  final Animation<double> anim;
  final VoidCallback? onPlay;

  const _CardContent({
    required this.id,
    required this.title,
    required this.tag,
    required this.desc,
    required this.icon,
    required this.reward,
    required this.length,
    required this.color,
    required this.canPlay,
    required this.isSelected,
    required this.best,
    required this.plays,
    required this.anim,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final double h = c.maxHeight.isFinite ? c.maxHeight : 480;
        final double w = c.maxWidth.isFinite ? c.maxWidth : 300;

        final bool showDesc = h >= 470; // roomy card
        final bool oneRow = h < 360; // very short card
        final double padTop = oneRow ? 8 : 14;
        final double padBottom = oneRow ? 10 : 18;

        return Column(
          children: [
            // colourful banner takes whatever height is left
            Expanded(
              child: _CardBanner(
                id: id,
                color: color,
                tag: tag,
                icon: icon,
                canPlay: canPlay,
                anim: anim,
              ),
            ),
            // text block: never taller than 70% of the card, scales if needed
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: h * 0.70),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: w,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, padTop, 20, padBottom),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: oneRow ? 20 : 22,
                            fontWeight: FontWeight.w900,
                            color: canPlay ? _brand : AppTheme.grey(500),
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (showDesc) ...[
                          const SizedBox(height: 6),
                          Text(
                            canPlay
                                ? desc
                                : "You've played all "
                                      '${GameProvider.maxMinigamesPerDay} '
                                      'games today.',
                            style: TextStyle(
                              fontSize: 13,
                              color: canPlay
                                  ? AppTheme.dim(54)
                                  : AppTheme.grey(500),
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: oneRow ? 8 : 12),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _InfoBlock(
                            canPlay: canPlay,
                            color: color,
                            reward: reward,
                            length: length,
                            best: best,
                            plays: plays,
                            oneRow: oneRow,
                          ),
                        ),
                        SizedBox(height: oneRow ? 8 : 14),
                        _PlayButton(
                          canPlay: canPlay,
                          isSelected: isSelected,
                          color: color,
                          height: oneRow ? 42 : 50,
                          onPressed: onPlay,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// "3/5 plays left today" pill (top right)
// ============================================================================
class _PlaysLeftPill extends StatelessWidget {
  final int playsLeft;
  final int total;
  const _PlaysLeftPill({required this.playsLeft, required this.total});

  @override
  Widget build(BuildContext context) {
    final bool empty = playsLeft <= 0;
    final Color c = empty ? AppTheme.grey(500) : _brand;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.35), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(total, (i) {
            final bool filled = i < playsLeft;
            return Container(
              margin: const EdgeInsets.only(right: 3),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? c : c.withOpacity(0.2),
              ),
            );
          }),
          const SizedBox(width: 5),
          Text(
            '$playsLeft/$total',
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Coloured banner at the top of every card (gradient + art + tag)
// ============================================================================
class _CardBanner extends StatelessWidget {
  final String id;
  final Color color;
  final String tag;
  final IconData icon;
  final bool canPlay;
  final Animation<double> anim;

  const _CardBanner({
    required this.id,
    required this.color,
    required this.tag,
    required this.icon,
    required this.canPlay,
    required this.anim,
  });

  Color _shade(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, _shade(color, 0.22)],
        ),
      ),
      child: Stack(
        children: [
          // soft decorative circles
          Positioned(right: -30, top: -30, child: _blob(110, 0.12)),
          Positioned(left: -40, bottom: -50, child: _blob(130, 0.10)),
          Positioned(left: 40, top: 18, child: _blob(14, 0.18)),
          Positioned(right: 50, bottom: 24, child: _blob(10, 0.2)),

          // the little illustration
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 10),
              child: AnimatedBuilder(
                animation: anim,
                builder: (_, __) {
                  final double t = Curves.easeInOut.transform(anim.value);
                  return Transform.translate(
                    offset: Offset(0, -6 * t),
                    child: Center(
                      child: FittedBox(fit: BoxFit.scaleDown, child: _art(t)),
                    ),
                  );
                },
              ),
            ),
          ),

          // tag chip (top-left)
          Positioned(
            left: 16,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // lock badge when the daily limit is over
          if (!canPlay)
            Positioned(
              right: 14,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.28),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _blob(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );

  Widget _art(double t) {
    switch (id) {
      case 'memory':
        return _memoryArt(t);
      case 'tap_target':
        return _tapArt(t);
      case 'color_reflex':
        return _colorArt();
      default:
        return Icon(icon, color: Colors.white, size: 64);
    }
  }

  // ---- Memory Match: a small grid of cards, a few flipped ----
  Widget _memoryArt(double t) {
    final List<IconData?> faces = [
      Icons.favorite_rounded,
      null,
      Icons.star_rounded,
      null,
      Icons.favorite_rounded,
      null,
      null,
      Icons.star_rounded,
    ];
    Widget tile(IconData? face, int i) {
      final bool up = face != null;
      return Container(
        width: 44,
        height: 52,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: up ? Colors.white : Colors.white.withOpacity(0.22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(up ? 1 : 0.5),
            width: 1.5,
          ),
          boxShadow: up
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          up ? face : Icons.question_mark_rounded,
          size: up ? 24 : 18,
          color: up ? color : Colors.white.withOpacity(0.8),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (int i = 0; i < 4; i++) tile(faces[i], i)],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (int i = 4; i < 8; i++) tile(faces[i], i)],
        ),
      ],
    );
  }

  // ---- Tap Target: concentric rings with a pulsing bullseye ----
  Widget _tapArt(double t) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 130 - 8 * t,
            height: 130 - 8 * t,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.16),
            ),
          ),
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.28),
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 8,
            child: Icon(
              Icons.touch_app_rounded,
              color: Colors.white,
              size: 38,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Color Reflex: the Stroop idea — word "RED" written in blue ink ----
  Widget _colorArt() {
    Widget dot(Color c, {bool ring = false}) => Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.white.withOpacity(ring ? 1 : 0.55),
          width: ring ? 3 : 1.5,
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Text(
            'RED',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            dot(Colors.red),
            dot(Colors.blue, ring: true),
            dot(Colors.green),
            dot(Colors.amber),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// Reward chip + per-game record chips
// ============================================================================
class _InfoBlock extends StatelessWidget {
  final bool canPlay;
  final Color color;
  final String reward;
  final String length;
  final int best;
  final int plays;
  final bool oneRow;

  const _InfoBlock({
    required this.canPlay,
    required this.color,
    required this.reward,
    required this.length,
    required this.best,
    required this.plays,
    this.oneRow = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!canPlay) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.grey(300).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bedtime_rounded, size: 14, color: AppTheme.grey(500)),
            const SizedBox(width: 6),
            Text(
              'Come back tomorrow',
              style: TextStyle(
                color: AppTheme.grey(500),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Very short cards: a single chip row only (record if it exists, else reward).
    if (oneRow) {
      return best > 0
          ? _Chip(
              icon: Icons.emoji_events_rounded,
              text: 'Best: $best coins',
              fg: Colors.green.shade700,
              iconColor: Colors.green.shade600,
              bg: Colors.green.withOpacity(0.10),
              border: Colors.green.withOpacity(0.3),
            )
          : _Chip(
              icon: Icons.monetization_on_rounded,
              text: reward,
              fg: Colors.amber.shade800,
              iconColor: Colors.amber,
              bg: Colors.amber.withOpacity(0.12),
            );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FEATURE #2: realistic reward range.
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Chip(
              icon: Icons.monetization_on_rounded,
              text: reward,
              fg: Colors.amber.shade800,
              iconColor: Colors.amber,
              bg: Colors.amber.withOpacity(0.12),
            ),
            const SizedBox(width: 8),
            _Chip(
              icon: Icons.timer_rounded,
              text: length,
              fg: AppTheme.dim(54),
              iconColor: color,
              bg: color.withOpacity(0.10),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // FEATURE #4: this game's OWN record. Before the first round it shows
        // an invite instead of a fake / shared number.
        if (best > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Chip(
                icon: Icons.emoji_events_rounded,
                text: 'Best: $best coins',
                fg: Colors.green.shade700,
                iconColor: Colors.green.shade600,
                bg: Colors.green.withOpacity(0.10),
                border: Colors.green.withOpacity(0.3),
              ),
              const SizedBox(width: 8),
              _Chip(
                icon: Icons.replay_rounded,
                text: 'Played: ${plays}x',
                fg: AppTheme.dim(54),
                iconColor: color,
                bg: color.withOpacity(0.10),
              ),
            ],
          )
        else
          _Chip(
            icon: Icons.flag_rounded,
            text: 'No record yet — set your first!',
            fg: AppTheme.dim(54),
            iconColor: color,
            bg: color.withOpacity(0.10),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color fg;
  final Color iconColor;
  final Color bg;
  final Color? border;

  const _Chip({
    required this.icon,
    required this.text,
    required this.fg,
    required this.iconColor,
    required this.bg,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: border == null ? null : Border.all(color: border!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 13),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PLAY NOW / TOMORROW button
// ============================================================================
class _PlayButton extends StatelessWidget {
  final bool canPlay;
  final bool isSelected;
  final Color color;
  final double height;
  final VoidCallback? onPressed;

  const _PlayButton({
    required this.canPlay,
    required this.isSelected,
    required this.color,
    required this.onPressed,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = canPlay && isSelected;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? _brand : AppTheme.grey(300),
          foregroundColor: canPlay ? Colors.white : AppTheme.grey(600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canPlay ? Icons.play_arrow_rounded : Icons.lock_clock_rounded,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(
              canPlay ? 'PLAY NOW' : 'TOMORROW',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
