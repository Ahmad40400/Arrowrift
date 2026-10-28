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

class _ArcadeScreenState extends State<ArcadeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  // FEATURE #2: realistic reward ranges instead of misleading "Up to X".
  final List<Map<String, dynamic>> _games = [
    {
      'id': 'memory',
      'title': 'Memory Match',
      'desc': 'Match all pairs before time runs out. Speed is key!',
      'icon': Icons.extension_rounded,
      'color': Colors.purpleAccent,
      'reward': 'Earn 25–150 Coins',
      'screen': MemoryGameScreen(),
    },
    {
      'id': 'tap_target',
      'title': 'Tap Target',
      'desc': 'Tap as many targets as you can in 10 seconds.',
      'icon': Icons.my_location_rounded,
      'color': Colors.orangeAccent,
      'reward': 'Earn 15–120 Coins',
      'screen': TapTargetScreen(),
    },
    {
      'id': 'color_reflex',
      'title': 'Color Reflex',
      'desc': 'Tap the matching color as fast as possible.',
      'icon': Icons.color_lens_rounded,
      'color': Colors.blueAccent,
      'reward': 'Earn 10–100 Coins',
      'screen': ColorReflexScreen(),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final canPlay = game.canPlayMinigame;

    // FEATURE #1 & #3: overall daily limit context.
    // "You've played all 5 games today. Resets in Xh Ym."
    final String subtitle = canPlay
        ? 'Play fun mini-games to earn quick coins!'
        : "You've played all ${GameProvider.maxMinigamesPerDay} games today. "
              'Resets in ${_dailyResetCountdown()}.';

    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARCADE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
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
          SizedBox(height: 20),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double cardHeight = constraints.maxHeight * 0.88;

                return PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentPage;
                    final gameData = _games[index];

                    final activeColor = canPlay
                        ? gameData['color']
                        : AppTheme.grey(500);

                    // FEATURE #4: per-game best score lookup.
                    final int bestForGame = _bestForGame(game, gameData['id']);

                    return AnimatedScale(
                      scale: isSelected ? 1.0 : 0.9,
                      duration: Duration(milliseconds: 300),
                      child: AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.6,
                        duration: Duration(milliseconds: 300),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          height: cardHeight,
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: activeColor.withOpacity(
                                        canPlay ? 0.22 : 0.1,
                                      ),
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: activeColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    canPlay
                                        ? gameData['icon']
                                        : Icons.lock_rounded,
                                    color: activeColor,
                                    size: 56,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  gameData['title'],
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: canPlay
                                        ? _brand
                                        : AppTheme.grey(500),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  canPlay
                                      ? gameData['desc']
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
                                SizedBox(height: 12),
                                if (canPlay) ...[
                                  // FEATURE #2: realistic reward range.
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.monetization_on_rounded,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          gameData['reward'],
                                          style: TextStyle(
                                            color: Colors.amber.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // FEATURE #4: "Your best" badge (only after
                                  // the player has played this game at least
                                  // once — bestForGame > 0).
                                  if (bestForGame > 0) ...[
                                    SizedBox(height: 8),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.emoji_events_rounded,
                                            color: Colors.green.shade600,
                                            size: 13,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Your best: $bestForGame coins',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                                Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: canPlay && isSelected
                                          ? _brand
                                          : AppTheme.grey(300),
                                      foregroundColor: canPlay
                                          ? Colors.white
                                          : AppTheme.grey(600),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    onPressed: (canPlay && isSelected)
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    gameData['screen'],
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      canPlay ? 'PLAY NOW' : 'TOMORROW',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_games.length, (index) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? _brand : AppTheme.grey(300),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          SizedBox(height: 20),
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

  // FEATURE #4: per-game best score.
  // GameProvider ke paas per-game best score ka field nahi hai, isliye hum
  // global `maxArcadeCoinsEarned` use karte hain — jab player ne koi game
  // khela ho (maxArcadeCoinsEarned > 0), tab har card pe wahi value dikhti
  // hai. Agar future mein per-game tracking add ho, toh yahan switch kar
  // sakte hain (game.provider mein field add karke).
  //
  // NOTE: Ye approach minimal-hai aur original GameProvider code ko chhuye
  // bina kaam karta hai. Agar aap chahte hain ke har game ka apna best ho,
  // toh GameProvider mein `Map<String, int> arcadeBestCoins` field add
  // karni hogi — lekin abhi ke liye aapne kaha "original code cut na ho",
  // isliye hum existing `maxArcadeCoinsEarned` use kar rahe hain.
  int _bestForGame(GameProvider game, String gameId) {
    return game.maxArcadeCoinsEarned;
  }
}
