import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../economy/economy_config.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _bg => AppTheme.bg;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData unlockedIcon;
  final Color color;
  final bool Function(GameProvider game) isUnlocked;
  final double Function(GameProvider game) progress;
  final int diamondReward;
  final String category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.unlockedIcon,
    required this.color,
    required this.isUnlocked,
    required this.progress,
    this.diamondReward = 0,
    this.category = 'combat',
  });
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static final List<Achievement> achievements = [
    // ==================== COMBAT ====================
    Achievement(
      id: 'first_win',
      title: 'First Win',
      description: 'Complete 1 level',
      unlockedIcon: Icons.emoji_events_rounded,
      color: Colors.amber,
      isUnlocked: (game) => game.totalLevelsCompleted >= 1,
      progress: (game) => (game.totalLevelsCompleted / 1).clamp(0.0, 1.0),
      category: 'combat',
    ),
    Achievement(
      id: 'level_10',
      title: 'Level 10',
      description: 'Reach level 10',
      unlockedIcon: Icons.star_rounded,
      color: Colors.blueAccent,
      isUnlocked: (game) =>
          game.classicUnlockedLevel >= 10 || game.proUnlockedLevel >= 10,
      progress: (game) {
        if (game.totalLevelsCompleted == 0) return 0.0;
        return (game.classicUnlockedLevel / 10).clamp(0.0, 1.0);
      },
      category: 'combat',
    ),
    Achievement(
      id: 'pro_player',
      title: 'Pro Player',
      description: 'Complete 1 Pro level',
      unlockedIcon: Icons.local_fire_department_rounded,
      color: Colors.purpleAccent,
      isUnlocked: (game) => game.proLevelsCompleted >= 1,
      progress: (game) => (game.proLevelsCompleted / 1).clamp(0.0, 1.0),
      category: 'combat',
    ),
    Achievement(
      id: 'coin_collector',
      title: 'Coin Collector',
      description: 'Earn 5,000 coins total',
      unlockedIcon: Icons.monetization_on_rounded,
      color: Colors.orange,
      isUnlocked: (game) => game.lifetimeCoinsEarned >= 5000,
      progress: (game) => (game.lifetimeCoinsEarned / 5000).clamp(0.0, 1.0),
      category: 'combat',
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Complete a level in 8s or less',
      unlockedIcon: Icons.speed_rounded,
      color: Colors.green,
      isUnlocked: (game) =>
          game.fastestClearSeconds > 0 && game.fastestClearSeconds <= 8,
      progress: (game) =>
          (game.fastestClearSeconds > 0 && game.fastestClearSeconds <= 8)
          ? 1.0
          : 0.0,
      category: 'combat',
    ),
    Achievement(
      id: 'daily_warrior',
      title: 'Daily Warrior',
      description: 'Complete a Daily Challenge',
      unlockedIcon: Icons.calendar_today_rounded,
      color: Colors.teal,
      isUnlocked: (game) => game.hasCompletedDaily,
      progress: (game) => game.hasCompletedDaily ? 1.0 : 0.0,
      category: 'daily',
    ),
    Achievement(
      id: 'perfectionist',
      title: 'Perfectionist',
      description: 'Complete 50 levels',
      unlockedIcon: Icons.workspace_premium_rounded,
      color: Colors.pinkAccent,
      isUnlocked: (game) => game.totalLevelsCompleted >= 50,
      progress: (game) => (game.totalLevelsCompleted / 50).clamp(0.0, 1.0),
      category: 'combat',
    ),
    Achievement(
      id: 'untouchable',
      title: 'Untouchable',
      description: 'Complete a level without losing a life',
      unlockedIcon: Icons.shield_rounded,
      color: Colors.indigo,
      isUnlocked: (game) => game.perfectLevelsCount >= 1,
      progress: (game) => (game.perfectLevelsCount / 1).clamp(0.0, 1.0),
      category: 'combat',
    ),
    Achievement(
      id: 'arcade_rookie',
      title: 'Arcade Rookie',
      description: 'Win 1 Arcade game',
      unlockedIcon: Icons.sports_esports_rounded,
      color: Colors.redAccent,
      isUnlocked: (game) => game.arcadeGamesWon >= 1,
      progress: (game) => (game.arcadeGamesWon / 1).clamp(0.0, 1.0),
      category: 'arcade',
    ),
    Achievement(
      id: 'arcade_master',
      title: 'Arcade Master',
      description: 'Win 10 Arcade games',
      unlockedIcon: Icons.gamepad_rounded,
      color: Colors.deepPurpleAccent,
      isUnlocked: (game) => game.arcadeGamesWon >= 10,
      progress: (game) => (game.arcadeGamesWon / 10).clamp(0.0, 1.0),
      category: 'arcade',
    ),
    Achievement(
      id: 'minigame_pro',
      title: 'Mini-Game Pro',
      description: 'Earn 300 coins in a single game',
      unlockedIcon: Icons.military_tech_rounded,
      color: Colors.amber.shade800,
      isUnlocked: (game) => game.maxArcadeCoinsEarned >= 300,
      progress: (game) => (game.maxArcadeCoinsEarned / 300).clamp(0.0, 1.0),
      category: 'arcade',
    ),
    Achievement(
      id: 'dedicated_player',
      title: 'Dedicated Player',
      description: 'Spend 1 hour in Arcade',
      unlockedIcon: Icons.timer_rounded,
      color: Colors.cyan,
      isUnlocked: (game) => game.arcadePlayTimeSeconds >= 3600,
      progress: (game) => (game.arcadePlayTimeSeconds / 3600).clamp(0.0, 1.0),
      category: 'arcade',
    ),

    // ==================== DIAMOND TASKS ====================
    Achievement(
      id: 'd_level_100',
      title: 'Century Club',
      description: 'Reach level 100',
      unlockedIcon: Icons.workspace_premium_rounded,
      color: Colors.amber.shade600,
      isUnlocked: (game) => game.classicUnlockedLevel >= 100,
      progress: (game) => (game.classicUnlockedLevel / 100).clamp(0.0, 1.0),
      diamondReward: 50,
      category: 'combat',
    ),
    Achievement(
      id: 'd_arcade_50',
      title: 'Arcade Legend',
      description: 'Win 50 Arcade games',
      unlockedIcon: Icons.sports_esports_rounded,
      color: Colors.red.shade400,
      isUnlocked: (game) => game.arcadeGamesWon >= 50,
      progress: (game) => (game.arcadeGamesWon / 50).clamp(0.0, 1.0),
      diamondReward: 30,
      category: 'arcade',
    ),
    Achievement(
      id: 'd_coin_50k',
      title: 'Big Spender',
      description: 'Earn 50,000 coins',
      unlockedIcon: Icons.monetization_on_rounded,
      color: Colors.orange.shade800,
      isUnlocked: (game) => game.lifetimeCoinsEarned >= 50000,
      progress: (game) => (game.lifetimeCoinsEarned / 50000).clamp(0.0, 1.0),
      diamondReward: 40,
      category: 'combat',
    ),
    Achievement(
      id: 'd_perfect_20',
      title: 'Flawless',
      description: 'Complete 20 levels without losing a life',
      unlockedIcon: Icons.verified_user_rounded,
      color: Colors.blue.shade600,
      isUnlocked: (game) => game.perfectLevelsCount >= 20,
      progress: (game) => (game.perfectLevelsCount / 20).clamp(0.0, 1.0),
      diamondReward: 20,
      category: 'combat',
    ),
    Achievement(
      id: 'd_speed_50',
      title: 'Lightning Fast',
      description: 'Complete a level in 5s or less',
      unlockedIcon: Icons.flash_on_rounded,
      color: Colors.purple.shade600,
      isUnlocked: (game) =>
          game.fastestClearSeconds > 0 && game.fastestClearSeconds <= 5,
      progress: (game) =>
          (game.fastestClearSeconds > 0 && game.fastestClearSeconds <= 5)
          ? 1.0
          : 0.0,
      diamondReward: 15,
      category: 'combat',
    ),
    Achievement(
      id: 'd_playtime_5hr',
      title: 'Dedicated',
      description: 'Play for 5 hours total',
      unlockedIcon: Icons.hourglass_bottom_rounded,
      color: Colors.teal.shade600,
      isUnlocked: (game) => game.totalPlayTimeSeconds >= 18000,
      progress: (game) => (game.totalPlayTimeSeconds / 18000).clamp(0.0, 1.0),
      diamondReward: 60,
      category: 'combat',
    ),
    Achievement(
      id: 'd_pro_50',
      title: 'Extreme Master',
      description: 'Reach Pro level 50',
      unlockedIcon: Icons.local_fire_department_rounded,
      color: Colors.deepOrange.shade700,
      isUnlocked: (game) => game.proUnlockedLevel >= 50,
      progress: (game) => (game.proUnlockedLevel / 50).clamp(0.0, 1.0),
      diamondReward: 75,
      category: 'combat',
    ),
    Achievement(
      id: 'd_level_250',
      title: 'Halfway There',
      description: 'Reach level 250',
      unlockedIcon: Icons.trending_up_rounded,
      color: Colors.green.shade700,
      isUnlocked: (game) => game.classicUnlockedLevel >= 250,
      progress: (game) => (game.classicUnlockedLevel / 250).clamp(0.0, 1.0),
      diamondReward: 100,
      category: 'combat',
    ),
    Achievement(
      id: 'd_arcade_time_2hr',
      title: 'Arcade Addict',
      description: 'Spend 2 hours in Arcade',
      unlockedIcon: Icons.timer_rounded,
      color: Colors.cyan.shade700,
      isUnlocked: (game) => game.arcadePlayTimeSeconds >= 7200,
      progress: (game) => (game.arcadePlayTimeSeconds / 7200).clamp(0.0, 1.0),
      diamondReward: 25,
      category: 'arcade',
    ),
    Achievement(
      id: 'd_coin_100k',
      title: 'Rich Tycoon',
      description: 'Earn 100,000 coins',
      unlockedIcon: Icons.account_balance_wallet_rounded,
      color: Colors.yellow.shade800,
      isUnlocked: (game) => game.lifetimeCoinsEarned >= 100000,
      progress: (game) => (game.lifetimeCoinsEarned / 100000).clamp(0.0, 1.0),
      diamondReward: 100,
      category: 'combat',
    ),

    // ==================== DAILY (reset rozana) ====================
    Achievement(
      id: 'daily_grind',
      title: 'Daily Grind',
      description: 'Clear 5 new levels today (replays do not count)',
      unlockedIcon: Icons.whatshot_rounded,
      color: Colors.deepOrange,
      isUnlocked: (game) => game.dailyLevelsCompleted >= 5,
      progress: (game) => (game.dailyLevelsCompleted / 5).clamp(0.0, 1.0),
      diamondReward: Eco.dailyTaskDiamonds,
      category: 'daily',
    ),
    Achievement(
      id: 'daily_arcade',
      title: 'Daily Arcade',
      description: 'Win 3 Arcade games today',
      unlockedIcon: Icons.sports_esports_rounded,
      color: Colors.pinkAccent,
      isUnlocked: (game) => game.dailyArcadeGamesWon >= 3,
      progress: (game) => (game.dailyArcadeGamesWon / 3).clamp(0.0, 1.0),
      diamondReward: Eco.dailyTaskDiamonds,
      category: 'daily',
    ),
  ];

  static const List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All'},
    {'id': 'combat', 'label': 'Combat'},
    {'id': 'arcade', 'label': 'Arcade'},
    {'id': 'daily', 'label': 'Daily'},
  ];

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    final int classicUnlocked = game.classicUnlockedLevel;
    final double classicProgress =
        (classicUnlocked - 1) / GameProvider.maxClassicLevel;
    final int proUnlocked = game.proUnlockedLevel;
    final double proProgress = (proUnlocked - 1) / GameProvider.maxProLevel;

    final int unlockedAchievements = achievements
        .where((a) => a.isUnlocked(game))
        .length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'YOUR PROGRESS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _ink,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Track your journey to becoming a maze master.',
            style: TextStyle(color: AppTheme.dim(54), fontSize: 14),
          ),
          SizedBox(height: 24),

          // 1. COINS CARD
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.25),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Coins',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${game.totalPoints}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // 2. STATISTICS CARD
          _buildStatisticsCard(
            totalPlayTimeSeconds: game.totalPlayTimeSeconds,
            levelsCompleted: game.totalLevelsCompleted,
            achievementsUnlocked: unlockedAchievements,
            arcadePlayTimeSeconds: game.arcadePlayTimeSeconds,
          ),
          SizedBox(height: 24),

          // 3. LEVEL PROGRESS
          _buildProgressCard(
            title: 'Classic Levels',
            subtitle:
                'Unlocked: $classicUnlocked / ${GameProvider.maxClassicLevel}',
            icon: Icons.grid_view_rounded,
            color: Colors.blueAccent,
            progress: classicProgress.clamp(0.0, 1.0),
          ),
          SizedBox(height: 16),
          _buildProgressCard(
            title: 'Pro Levels',
            subtitle: 'Unlocked: $proUnlocked / ${GameProvider.maxProLevel}',
            icon: Icons.local_fire_department_rounded,
            color: _accent,
            progress: proProgress.clamp(0.0, 1.0),
          ),
          SizedBox(height: 32),

          // 4. RECENT ACHIEVEMENTS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT ACHIEVEMENTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                  letterSpacing: 1.0,
                ),
              ),
              TextButton(
                onPressed: () => _showAllAchievements(context, game),
                child: Text(
                  'View All >',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildAchievementsRow(game),
          SizedBox(height: 32),

          // 5. LOCAL LEADERBOARD (NEW DESIGN)
          _buildLeaderboardSection(context, game),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard({
    required int totalPlayTimeSeconds,
    required int levelsCompleted,
    required int achievementsUnlocked,
    required int arcadePlayTimeSeconds,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.access_time_filled_rounded,
            gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            value: _formatPlayTime(totalPlayTimeSeconds),
            label: 'Total Time',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.sports_esports_rounded,
            gradientColors: [Color(0xFFFF8E53), Color(0xFFFE6B8B)],
            value: _formatPlayTime(arcadePlayTimeSeconds),
            label: 'Arcade Time',
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.emoji_events_rounded,
            gradientColors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
            value: '$achievementsUnlocked',
            label: 'Badges',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required List<Color> gradientColors,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.4),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.dim(54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 50, color: AppTheme.grey(200));
  }

  String _formatPlayTime(int totalSeconds) {
    if (totalSeconds < 60) return '${totalSeconds}s';
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      if (minutes > 0) return '${hours}h ${minutes}m';
      return '${hours}h';
    }
    return '${minutes}m';
  }

  Widget _buildAchievementsRow(GameProvider game) {
    final List<Achievement> unlocked = achievements
        .where((a) => a.isUnlocked(game))
        .toList();

    List<Achievement> displayAchievements;
    if (unlocked.length >= 4) {
      displayAchievements = unlocked.sublist(unlocked.length - 4);
    } else {
      final List<Achievement> remaining = achievements
          .where((a) => !unlocked.contains(a))
          .toList();
      displayAchievements = [
        ...unlocked,
        ...remaining.take(4 - unlocked.length),
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: displayAchievements.map((achievement) {
        final bool unlocked = achievement.isUnlocked(game);
        final double progress = achievement.progress(game);

        return Expanded(
          child: _buildAchievementItem(
            achievement: achievement,
            unlocked: unlocked,
            progress: progress,
            game: game,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementItem({
    required Achievement achievement,
    required bool unlocked,
    required double progress,
    required GameProvider game,
  }) {
    bool isClaimed = game.claimedTaskIds.contains(achievement.id);
    bool canClaim = unlocked && !isClaimed && achievement.diamondReward > 0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? achievement.color.withOpacity(0.15)
                    : AppTheme.grey(200),
                border: unlocked
                    ? Border.all(
                        color: achievement.color.withOpacity(0.5),
                        width: 2,
                      )
                    : null,
              ),
            ),
            if (!unlocked && progress > 0)
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    achievement.color.withOpacity(0.5),
                  ),
                ),
              ),
            Icon(
              unlocked ? achievement.unlockedIcon : Icons.lock_rounded,
              color: unlocked ? achievement.color : AppTheme.grey(400),
              size: 32,
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          achievement.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: unlocked ? _brand : AppTheme.grey(500),
          ),
        ),
        SizedBox(height: 2),
        Text(
          unlocked ? achievement.description : 'Locked',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8,
            color: unlocked ? AppTheme.dim(45) : AppTheme.grey(400),
          ),
        ),
        if (achievement.diamondReward > 0) ...[
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: canClaim ? Colors.cyan : AppTheme.grey(300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.diamond_rounded,
                  color: canClaim ? Colors.white : AppTheme.grey(500),
                  size: 10,
                ),
                SizedBox(width: 2),
                Text(
                  canClaim ? 'CLAIM' : '${achievement.diamondReward}',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: canClaim ? Colors.white : AppTheme.grey(600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==================================================================
  // LOCAL LEADERBOARD UI (NEW DESIGN — Sirf Top 3 dikhta hai)
  // ==================================================================
  Widget _buildLeaderboardSection(BuildContext context, GameProvider game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.leaderboard_rounded, color: _brand, size: 20),
            const SizedBox(width: 8),
            Text(
              'LEADERBOARD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _ink,
                letterSpacing: 1.0,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => _showFullLeaderboard(context, game),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All >',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildLeaderboardTab(
          context: context,
          game: game,
          title: 'Top Coin Runs',
          icon: Icons.monetization_on_rounded,
          iconColor: Colors.amber,
          entries: game.leaderboardCoins,
          valueBuilder: (e) => '${e['coins']}',
          subtitleBuilder: (e) =>
              'Lv ${e['level']} • ${e['stars']}★ • ${e['time']}s',
        ),
        const SizedBox(height: 12),
        _buildLeaderboardTab(
          context: context,
          game: game,
          title: 'Fastest Clears',
          icon: Icons.speed_rounded,
          iconColor: Colors.green,
          entries: game.leaderboardSpeed,
          valueBuilder: (e) => '${e['time']}s',
          subtitleBuilder: (e) =>
              'Lv ${e['level']} • ${e['stars']}★ • ${e['coins']} coins',
        ),
        const SizedBox(height: 12),
        _buildLeaderboardTab(
          context: context,
          game: game,
          title: 'Longest Streaks',
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.deepOrange,
          entries: game.leaderboardStreak,
          valueBuilder: (e) => '${e['streak']}d',
          subtitleBuilder: (e) => _formatLeaderboardDate(e['date'] as int?),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab({
    required BuildContext context,
    required GameProvider game,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, dynamic>> entries,
    required String Function(Map<String, dynamic>) valueBuilder,
    required String Function(Map<String, dynamic>) subtitleBuilder,
  }) {
    final List<Map<String, dynamic>> top3 = entries.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              const Spacer(),
              if (entries.length > 3)
                GestureDetector(
                  onTap: () => _showSpecificLeaderboard(
                    context,
                    game,
                    title,
                    entries,
                    valueBuilder,
                    subtitleBuilder,
                  ),
                  child: Text(
                    'See top 10',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _brand.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (top3.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Play some levels to fill this!',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.dim(54),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ...List.generate(top3.length, (i) {
              final e = top3[i];
              final bool isTop3 = true;
              final Color medalColor = i == 0
                  ? const Color(0xFFFFD700) // Gold
                  : i == 1
                  ? const Color(0xFFC0C0C0) // Silver
                  : const Color(0xFFCD7F32); // Bronze

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: medalColor.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(color: medalColor, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: medalColor.withOpacity(0.95),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            valueBuilder(e),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: medalColor.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            subtitleBuilder(e),
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppTheme.dim(54),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // Top 10 dekhne ke liye ek chota sa dialog (specific category)
  void _showSpecificLeaderboard(
    BuildContext context,
    GameProvider game,
    String title,
    List<Map<String, dynamic>> entries,
    String Function(Map<String, dynamic>) valueBuilder,
    String Function(Map<String, dynamic>) subtitleBuilder,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey(300),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'TOP 10 - $title'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: _ink),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    final bool isTop3 = i < 3;
                    final Color medalColor = i == 0
                        ? const Color(0xFFFFD700)
                        : i == 1
                        ? const Color(0xFFC0C0C0)
                        : i == 2
                        ? const Color(0xFFCD7F32)
                        : AppTheme.grey(400);

                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isTop3
                                  ? medalColor.withOpacity(0.18)
                                  : AppTheme.grey(100),
                              shape: BoxShape.circle,
                              border: isTop3
                                  ? Border.all(color: medalColor, width: 2)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isTop3
                                    ? medalColor.withOpacity(0.95)
                                    : _ink,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valueBuilder(e),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isTop3
                                        ? medalColor.withOpacity(0.9)
                                        : _ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitleBuilder(e),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.dim(54),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Poora Leaderboard ek sath dekhne ke liye master button
  void _showFullLeaderboard(BuildContext context, GameProvider game) {
    String selectedTab = 'Coins';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Map<String, dynamic>> entries;
            String Function(Map<String, dynamic>) valBuilder;
            String Function(Map<String, dynamic>) subBuilder;

            if (selectedTab == 'Coins') {
              entries = game.leaderboardCoins;
              valBuilder = (e) => '${e['coins']}';
              subBuilder = (e) =>
                  'Lv ${e['level']} • ${e['stars']}★ • ${e['time']}s';
            } else if (selectedTab == 'Speed') {
              entries = game.leaderboardSpeed;
              valBuilder = (e) => '${e['time']}s';
              subBuilder = (e) =>
                  'Lv ${e['level']} • ${e['stars']}★ • ${e['coins']} coins';
            } else {
              entries = game.leaderboardStreak;
              valBuilder = (e) => '${e['streak']}d';
              subBuilder = (e) => _formatLeaderboardDate(e['date'] as int?);
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.grey(300),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'FULL LEADERBOARD',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _ink,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: _ink),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Tabs
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      children: ['Coins', 'Speed', 'Streak'].map((tab) {
                        final bool isSel = selectedTab == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedTab = tab),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSel ? _brand : _card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSel ? _brand : AppTheme.grey(300),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? Colors.white : _ink,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 16),

                  Expanded(
                    child: entries.isEmpty
                        ? Center(
                            child: Text(
                              'No records yet!',
                              style: TextStyle(
                                color: AppTheme.dim(54),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            itemCount: entries.length,
                            itemBuilder: (context, i) {
                              final e = entries[i];
                              final bool isTop3 = i < 3;
                              final Color medalColor = i == 0
                                  ? const Color(0xFFFFD700)
                                  : i == 1
                                  ? const Color(0xFFC0C0C0)
                                  : i == 2
                                  ? const Color(0xFFCD7F32)
                                  : AppTheme.grey(400);

                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _card,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isTop3
                                            ? medalColor.withOpacity(0.18)
                                            : AppTheme.grey(100),
                                        shape: BoxShape.circle,
                                        border: isTop3
                                            ? Border.all(
                                                color: medalColor,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: isTop3
                                              ? medalColor.withOpacity(0.95)
                                              : _ink,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            valBuilder(e),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: isTop3
                                                  ? medalColor.withOpacity(0.9)
                                                  : _ink,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            subBuilder(e),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.dim(54),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatLeaderboardDate(int? ms) {
    if (ms == null || ms == 0) return '';
    final DateTime d = DateTime.fromMillisecondsSinceEpoch(ms);
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _showAllAchievements(BuildContext context, GameProvider game) {
    String selectedCategory = 'all';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final List<Achievement> filtered = selectedCategory == 'all'
                ? achievements
                : achievements
                      .where((a) => a.category == selectedCategory)
                      .toList();

            final int claimableCount = achievements.where((a) {
              return a.isUnlocked(game) &&
                  !game.claimedTaskIds.contains(a.id) &&
                  a.diamondReward > 0;
            }).length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.grey(300),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'ALL ACHIEVEMENTS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _ink,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${achievements.where((a) => a.isUnlocked(game)).length}/${achievements.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final bool isSelected = selectedCategory == cat['id'];
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedCategory = cat['id']!);
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _brand : _card,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? _brand : AppTheme.grey(300),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              cat['label']!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : _ink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),

                  if (claimableCount > 0)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            int totalDiamonds = 0;
                            for (final a in achievements) {
                              final canClaim =
                                  a.isUnlocked(game) &&
                                  !game.claimedTaskIds.contains(a.id) &&
                                  a.diamondReward > 0;
                              if (canClaim) {
                                game.claimTaskReward(a.id, a.diamondReward);
                                totalDiamonds += a.diamondReward;
                              }
                            }
                            setState(() {});
                            if (totalDiamonds > 0) {
                              _showClaimSuccessPopup(context, totalDiamonds);
                            }
                          },
                          icon: Icon(Icons.diamond_rounded, size: 18),
                          label: Text(
                            'CLAIM ALL ($claimableCount)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final achievement = filtered[index];
                        final bool unlocked = achievement.isUnlocked(game);
                        final double progress = achievement.progress(game);
                        bool isClaimed = game.claimedTaskIds.contains(
                          achievement.id,
                        );
                        bool canClaim =
                            unlocked &&
                            !isClaimed &&
                            achievement.diamondReward > 0;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: unlocked
                                          ? achievement.color.withOpacity(0.15)
                                          : AppTheme.grey(200),
                                    ),
                                  ),
                                  if (!unlocked && progress > 0)
                                    SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: CircularProgressIndicator(
                                        value: progress,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.transparent,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              achievement.color.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                      ),
                                    ),
                                  Icon(
                                    unlocked
                                        ? achievement.unlockedIcon
                                        : Icons.lock_rounded,
                                    color: unlocked
                                        ? achievement.color
                                        : AppTheme.grey(400),
                                    size: 28,
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: unlocked
                                            ? _brand
                                            : AppTheme.grey(500),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      achievement.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.dim(54),
                                      ),
                                    ),
                                    if (!unlocked && progress > 0) ...[
                                      SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 4,
                                          backgroundColor: AppTheme.grey(200),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                achievement.color.withOpacity(
                                                  0.6,
                                                ),
                                              ),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${(progress * 100).toInt()}% complete',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.grey(500),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (achievement.diamondReward > 0)
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.diamond_rounded,
                                          color: Colors.cyan,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${achievement.diamondReward}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.cyan,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    if (canClaim)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.cyan,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          game.claimTaskReward(
                                            achievement.id,
                                            achievement.diamondReward,
                                          );
                                          setState(() {});
                                          _showClaimSuccessPopup(
                                            context,
                                            achievement.diamondReward,
                                          );
                                        },
                                        child: Text(
                                          'CLAIM',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      )
                                    else if (isClaimed)
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                  ],
                                )
                              else if (unlocked)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                  size: 24,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showClaimSuccessPopup(BuildContext context, int diamonds) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_rounded, color: Colors.cyan, size: 64),
                SizedBox(height: 16),
                Text(
                  'Reward Claimed!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '+$diamonds Diamonds added to your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.dim(54)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.dim(54),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
