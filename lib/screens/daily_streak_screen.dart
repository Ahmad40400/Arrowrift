import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../economy/economy_config.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

class DailyStreakScreen extends StatefulWidget {
  const DailyStreakScreen({super.key});

  @override
  State<DailyStreakScreen> createState() => _DailyStreakScreenState();
}

class _DailyStreakScreenState extends State<DailyStreakScreen> {
  Map<String, dynamic>? _claimedReward;
  bool _claiming = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoClaim();
    });
  }

  void _autoClaim() {
    final game = context.read<GameProvider>();
    if (game.streakClaimedToday) return;

    setState(() => _claiming = true);
    final result = game.claimStreakReward();
    setState(() {
      _claiming = false;
      _claimedReward = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final int streak = game.streakCount;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER ---
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade400, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Streak',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: _ink,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          streak > 0
                              ? '🔥 $streak day streak — keep it up!'
                              : 'Login daily for huge rewards!',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.dim(54),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- 7 DAY CALENDAR GRID (Wrap use kiya hai taake screen se bahar na jaye) ---
              _buildCalendarWrap(game),

              const SizedBox(height: 20),

              // --- CLAIMED REWARD BANNER ---
              if (_claimedReward != null)
                _buildRewardBanner(_claimedReward!)
              else if (game.streakClaimedToday)
                _buildClaimedBanner()
              else if (_claiming)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),

              const SizedBox(height: 20),

              // --- STREAK FREEZE ROW ---
              _buildFreezeRow(game),

              const SizedBox(height: 20),

              // --- CONTINUE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  // FIX: Wrap use kiya hai taake boxes screen ke bahar na niklein
  Widget _buildCalendarWrap(GameProvider game) {
    final int nextDay = game.nextStreakDay;
    final bool claimed = game.streakClaimedToday;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8, // Horizontal space between boxes
      runSpacing: 8, // Vertical space between rows
      children: List.generate(7, (i) {
        final int day = i + 1;
        final bool isPast = claimed
            ? day <= game.streakCount
            : (game.streakCount >= 7 ? false : day < nextDay);
        final bool isToday = (claimed
            ? day == game.streakCount
            : day == nextDay);
        final bool isDay7 = day == 7;

        // Color palettes
        Color bgColor = AppTheme.grey(50);
        Color borderColor = AppTheme.grey(200);
        Color textColor = AppTheme.dim(54);
        Color iconColor = AppTheme.grey(400);
        List<BoxShadow> shadows = [];

        if (isToday) {
          bgColor = _brand.withOpacity(0.05);
          borderColor = _brand;
          textColor = _brand;
          iconColor = _brand;
          shadows = [
            BoxShadow(
              color: _brand.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ];
        } else if (isPast) {
          bgColor = Colors.green.withOpacity(0.05);
          borderColor = Colors.green.withOpacity(0.3);
          textColor = Colors.green.shade800;
          iconColor = Colors.green.shade600;
        } else if (isDay7) {
          bgColor = Colors.cyan.withOpacity(0.05);
          borderColor = Colors.cyan.withOpacity(0.4);
          textColor = Colors.cyan.shade800;
          iconColor = Colors.cyan;
        }

        return SizedBox(
          width: 75, // Fixed width to fit 4 boxes per row on standard screens
          height: 95,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: isToday ? 2 : 1.5),
              boxShadow: shadows,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day $day',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Icon(
                  isDay7
                      ? Icons.diamond_rounded
                      : Icons.monetization_on_rounded,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  isDay7
                      ? '${Eco.streakDay7Diamonds}'
                      : _fmt(Eco.streakCoinForDay(day)),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Tick / Star
                if (isPast)
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 12,
                  )
                else if (isToday)
                  Icon(Icons.star_rounded, color: _accent, size: 12)
                else
                  const SizedBox(height: 12), // Placeholder
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRewardBanner(Map<String, dynamic> reward) {
    final bool isDiamonds = reward['rewardType'] == 'diamonds';
    final bool freezeUsed = reward['streakFreezeUsed'] == true;
    final int amount = reward['rewardAmount'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDiamonds
            ? Colors.cyan.withOpacity(0.1)
            : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDiamonds ? Colors.cyan.shade300 : Colors.amber.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDiamonds ? Icons.diamond_rounded : Icons.monetization_on_rounded,
            color: isDiamonds ? Colors.cyan : Colors.amber.shade700,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward Claimed!',
                  style: TextStyle(
                    color: isDiamonds
                        ? Colors.cyan.shade800
                        : Colors.amber.shade800,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDiamonds ? '+$amount Diamonds' : '+${_fmt(amount)} Coins',
                  style: TextStyle(
                    color: _ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (freezeUsed)
            Text(
              '❄ Freeze Used',
              style: TextStyle(
                fontSize: 11,
                color: Colors.lightBlue.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClaimedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green.shade600,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Today\'s reward already claimed',
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreezeRow(GameProvider game) {
    final int held = game.streakFreezeHeld;
    final int maxHeld = Eco.streakFreezeMaxHeld;
    final bool canBuy =
        held < maxHeld && game.totalPoints >= Eco.streakFreezeCoinPrice;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.grey(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.grey(200), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.ac_unit_rounded,
              color: Colors.lightBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak Freeze ($held / $maxHeld)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Protects your streak for 1 missed day.',
                  style: TextStyle(fontSize: 11, color: AppTheme.dim(54)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canBuy ? _brand : AppTheme.grey(300),
              foregroundColor: canBuy ? Colors.white : AppTheme.grey(600),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: canBuy
                ? () {
                    game.buyStreakFreeze();
                    setState(() {}); // Refresh UI instantly
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.amber,
                  size: 12,
                ),
                const SizedBox(width: 3),
                Text(
                  _fmt(Eco.streakFreezeCoinPrice),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}
