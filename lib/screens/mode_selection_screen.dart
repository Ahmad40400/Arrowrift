import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../services/tutorial_manager.dart';
import 'level_screen.dart';
import 'game_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import 'buy_screen.dart';
import 'arcade_screen.dart';
import 'daily_streak_screen.dart';
import 'events_screen.dart';
import '../theme/app_theme.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _bg => AppTheme.bg;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

// Soft shadow used by every card on this screen (matches Shop / Stats cards).
List<BoxShadow> get _softShadow => [
  BoxShadow(
    color: Colors.black.withOpacity(AppTheme.isDark ? 0.28 : 0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
];

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _currentIndex = 0;
  int _seenTutorialFinishCount = 0;

  @override
  void initState() {
    super.initState();
    _seenTutorialFinishCount = context.read<GameProvider>().tutorialFinishCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowStreakPopup();
    });
  }

  Future<void> _maybeShowStreakPopup() async {
    if (!mounted) return;
    final game = context.read<GameProvider>();
    // Tutorial chal raha ho to streak popup baad me (tutorial khatam hone par).
    if (game.tutorialStep > 0) return;
    if (!game.shouldShowStreakPopup) return;
    game.markStreakPopupShown();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider<GameProvider>.value(
        value: game,
        child: const DailyStreakScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    // TUTORIAL finished ("Start Playing" / skip): back to the Home tab and
    // show the streak popup that was held back during the tutorial.
    if (game.tutorialFinishCount != _seenTutorialFinishCount) {
      _seenTutorialFinishCount = game.tutorialFinishCount;
      _currentIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeShowStreakPopup();
      });
    }

    // TUTORIAL: the tab steps (Stats, Arcade, Shop, Settings) must show the
    // tab they are talking about. Otherwise the popup describes one screen
    // while another one is visible (popup was always one step ahead).
    final int tutorialTab = TutorialManager.tabIndexForStep(game.tutorialStep);
    if (tutorialTab >= 0) _currentIndex = tutorialTab;

    return ThemedScaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, game),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(context, game),
                  ProgressScreen(),
                  ArcadeScreen(),
                  BuyScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Streak dialog ko manually kholne ke liye (gift icon).
  void _openStreakDialog(GameProvider game) {
    showDialog(
      context: context,
      builder: (_) => ChangeNotifierProvider<GameProvider>.value(
        value: game,
        child: const DailyStreakScreen(),
      ),
    );
  }

  // ===================== TOP BAR =====================
  Widget _buildTopBar(BuildContext context, GameProvider game) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          _buildThemeToggleButton(context, game),
          const SizedBox(width: 8),
          _buildHeaderIconButton(
            icon: Icons.card_giftcard_rounded,
            onTap: () => _openStreakDialog(game),
            showDot: !game.streakClaimedToday,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCurrencyPill(
                      icon: Icons.monetization_on_rounded,
                      iconColor: Colors.amber,
                      value: '${game.totalPoints}',
                      plusColor: Colors.amber.shade700,
                      onPlus: () => setState(() => _currentIndex = 3),
                    ),
                    const SizedBox(width: 8),
                    _buildCurrencyPill(
                      icon: Icons.diamond_rounded,
                      iconColor: Colors.cyan,
                      value: '${game.totalDiamonds}',
                      plusColor: Colors.cyan.shade600,
                      onPlus: () => setState(() => _currentIndex = 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _card,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.line.withOpacity(0.6)),
              boxShadow: _softShadow,
            ),
            child: Icon(icon, color: _brand, size: 20),
          ),
          if (showDot)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: _card, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPill({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color plusColor,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 5, 5),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line.withOpacity(0.6)),
        boxShadow: _softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: _ink,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onPlus,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: plusColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleButton(BuildContext context, GameProvider game) {
    final ArrowTheme active = game.currentTheme;
    return GestureDetector(
      onTap: () => _showThemeQuickSwitchSheet(context, game),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _card,
          shape: BoxShape.circle,
          boxShadow: _softShadow,
          border: Border.all(color: _brand.withOpacity(0.35), width: 1.5),
        ),
        child: Icon(
          active.icon,
          color: active.isClassic ? _brand : active.brand,
          size: 22,
        ),
      ),
    );
  }

  void _showThemeQuickSwitchSheet(BuildContext context, GameProvider game) {
    final List<ArrowTheme> owned = AppTheme.all
        .where((t) => game.isThemeUnlocked(t.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.grey(300),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.palette_rounded, color: _brand, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Switch Theme',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                        ),
                      ),
                    ),
                    Text(
                      '${owned.length} owned',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dim(54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick any theme you already own. Want more? Visit the Shop.',
                  style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: owned.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final ArrowTheme t = owned[index];
                      final bool isActive =
                          game.activeThemeId == t.id && !game.isPreviewingTheme;
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          if (isActive) {
                            Navigator.pop(sheetContext);
                            return;
                          }
                          game.setActiveTheme(t.id);
                          Navigator.pop(sheetContext);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardAlt,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isActive ? t.brand : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [t.bg, t.bg2],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Icon(
                                  t.icon,
                                  color: t.isClassic ? t.brand : t.arrowInk,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: _ink,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.tagline,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppTheme.dim(54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.brand,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppTheme.grey(400),
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (owned.length <= 1) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.amber.shade800,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'You only own the Classic theme. Unlock more in the Shop!',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.dim(87),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Theme accent ko card ke gradient ke liye gehra karta hai (white text readable rahe).
  Color _deep(Color c, double drop) {
    final hsl = HSLColor.fromColor(c);
    final double l = (hsl.lightness.clamp(0.0, 0.5).toDouble() - drop)
        .clamp(0.12, 0.5)
        .toDouble();
    return hsl.withLightness(l).toColor();
  }

  // Softer, richer version of a colour (used for the card gradients).
  Color _rich(Color c, double lightness, double saturation) {
    return HSLColor.fromColor(c)
        .withLightness(lightness)
        .withSaturation(saturation)
        .toColor();
  }

  // ===================== HOME TAB =====================
  //
  // 🔧 BULLETPROOF LAYOUT (logic unchanged):
  //   - SingleChildScrollView lagaya hai: chhoti screens pe content scroll hoga,
  //     kabhi overflow nahi hoga.
  //   - ConstrainedBox(minHeight: available height) lagaya hai taake badi
  //     screens pe content vertically fill ho aur scroll na dikhe.
  //   - Mode cards ab Expanded ke bajaye fixed-height SizedBox ke andar hain.
  //     Agar zyada jagah bachi ho toh Centre align honge, kam ho toh scroll.
  Widget _buildHomeTab(BuildContext context, GameProvider game) {
    final int todaySeed = game.todayStamp;
    final bool isCompleted = game.lastDailyCompletedDate == todaySeed;
    final bool isDailyPro = todaySeed % 2 == 0;
    final int dailyLevelNum = (todaySeed % (isDailyPro ? 40 : 60)) + 1;

    final double classicProgress =
        ((game.classicUnlockedLevel - 1) / GameProvider.maxClassicLevel)
            .clamp(0.0, 1.0)
            .toDouble();
    final double proProgress =
        ((game.proUnlockedLevel - 1) / GameProvider.maxProLevel)
            .clamp(0.0, 1.0)
            .toDouble();

    final bool showComingSoon =
        game.classicUnlockedLevel <= 10 && game.proUnlockedLevel <= 10;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Chhoti screens pe mode cards ki minimum height 260dp hai.
        // Agar available height kaafi hai, cards minimum ke saath expand
        // honge; agar kam hai, scroll ho jayega.
        const double _minModeCardHeight = 260;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleBlock(game),
                  const SizedBox(height: 16),

                  // Daily Card (intrinsic height, safe)
                  _buildDailyCard(
                    context,
                    game,
                    isCompleted: isCompleted,
                    isDailyPro: isDailyPro,
                    dailyLevelNum: dailyLevelNum,
                  ).animate().slideY(
                    begin: 0.2,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 16),

                  // Mode Cards — fixed minimum height so they never squash,
                  // and if space allows they grow to fill available room.
                  _buildModeCardsRow(
                    context: context,
                    game: game,
                    minHeight: _minModeCardHeight,
                    availableHeight: constraints.maxHeight,
                    classicProgress: classicProgress,
                    proProgress: proProgress,
                  ),

                  // Tips / Banner Section
                  const SizedBox(height: 16),
                  if (showComingSoon)
                    _buildComingSoonBanner()
                  else
                    _buildProTipsBanner(game),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Mode cards row — apna height khud decide karta hai (bina overflow).
  Widget _buildModeCardsRow({
    required BuildContext context,
    required GameProvider game,
    required double minHeight,
    required double availableHeight,
    required double classicProgress,
    required double proProgress,
  }) {
    // Agar screen bahut lambi hai (tablet / big phone), cards thodi si badi
    // dikhein — lekin 360 se zyada nahi, warna art stretched lagega.
    final double rowHeight = minHeight.clamp(minHeight, 360.0).toDouble();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SizedBox(
          height: rowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildModeCard(
                  title: 'Classic Mode',
                  subtitle: '2000 Levels\nEasy to Legendary',
                  art: _buildCubeArt(),
                  gradient: const [Color(0xFF5B7CFA), Color(0xFF3A56D4)],
                  buttonColor: const Color(0xFF29B6F6),
                  progress: classicProgress,
                  progressLabel: 'Lv ${game.classicUnlockedLevel}',
                  tutorialKey: TutorialManager.classicCardKey,
                  onTap: () {
                    // TUTORIAL: Classic card tapped -> Level 1 step.
                    if (game.tutorialStep == TutorialManager.stepClassicMode) {
                      game.setTutorialStep(TutorialManager.stepLevel1);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(
                          name: TutorialManager.levelRouteName,
                        ),
                        builder: (_) => LevelScreen(isProMode: false),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildModeCard(
                  title: 'Pro Mode',
                  subtitle: '500 Levels\nExtreme Challenge',
                  art: _buildFlameArt(),
                  gradient: [
                    _rich(_accent, 0.56, 0.80),
                    _rich(_accent, 0.38, 0.78),
                  ],
                  buttonColor: _accent,
                  progress: proProgress,
                  progressLabel: 'Lv ${game.proUnlockedLevel}',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: TutorialManager.levelRouteName,
                      ),
                      builder: (_) => LevelScreen(isProMode: true),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Same header pattern as Stats / Arcade / Shop / Settings tabs.
  // Right side: 3D EVENTS icon (new — original layout untouched on left).
  Widget _buildTitleBlock(GameProvider game) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                    letterSpacing: 1.2,
                  ),
                  children: [
                    const TextSpan(text: 'SELECT '),
                    TextSpan(
                      text: 'MODE',
                      style: TextStyle(color: _accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your challenge',
                style: TextStyle(color: AppTheme.dim(54), fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 2),
          child: _EventsOrbButton(
            onTap: () {
              // Event full screen par navigate karo
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EventsScreen()),
              );
            },
            hasNew: _hasUnclaimedEvent(game),
          ),
        ),
      ],
    );
  }

  // Red dot toggle — real events state check karega
  bool _hasUnclaimedEvent(GameProvider game) {
    final event = game.currentEvent;
    if (event == null) return false;
    final isCompleted = game.eventProgress >= event.target;
    final isClaimed = game.claimedEventIds.contains(event.id);
    return isCompleted && !isClaimed;
  }

  // ===================== DAILY CHALLENGE =====================
  // FEATURE #1: Countdown timer (midnight reset) — todayStamp ke saath consistent.
  Widget _buildDailyCard(
    BuildContext context,
    GameProvider game, {
    required bool isCompleted,
    required bool isDailyPro,
    required int dailyLevelNum,
  }) {
    const Color gold = Color(0xFFF59E0B);
    final Color tint = isCompleted ? Colors.green.shade500 : gold;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.alphaBlend(tint.withOpacity(0.14), _card), _card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: tint.withOpacity(isCompleted ? 0.25 : 0.35),
          width: 1.2,
        ),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          _buildChestArt(isCompleted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Daily Challenge',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tint.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isDailyPro ? 'PRO' : 'CLASSIC',
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.green.shade700
                              : Colors.amber.shade900,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        color: AppTheme.dim(54),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          isDailyPro
                              ? 'Pro Level $dailyLevelNum'
                              : 'Classic Level $dailyLevelNum',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isCompleted
                      ? 'Completed today • Next in ${_dailyResetCountdown()}'
                      : 'Win this to earn ${game.dailyChallengeReward} bonus coins!',
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.green.shade700
                        : AppTheme.dim(54),
                    fontSize: 12.5,
                    fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPlayNowButton(
                  context,
                  game,
                  isCompleted: isCompleted,
                  isDailyPro: isDailyPro,
                  dailyLevelNum: dailyLevelNum,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Midnight reset tak ka time — GameProvider.todayStamp local midnight pe
  // flip hota hai, isliye countdown bhi local midnight target karta hai.
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

  Widget _buildPlayNowButton(
    BuildContext context,
    GameProvider game, {
    required bool isCompleted,
    required bool isDailyPro,
    required int dailyLevelNum,
  }) {
    return GestureDetector(
      onTap: isCompleted
          ? null
          : () {
              game.startDailyChallenge(dailyLevelNum, isDailyPro);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GameScreen()),
              );
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: isCompleted
              ? null
              : const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          color: isCompleted ? Colors.green.withOpacity(0.12) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isCompleted)
              BoxShadow(
                color: const Color(0xFFFFB300).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted) ...[
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green.shade600,
                size: 18,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isCompleted ? 'COMPLETED FOR TODAY' : 'Play Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isCompleted
                        ? Colors.green.shade700
                        : const Color(0xFF4E2A00),
                  ),
                ),
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF4E2A00),
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChestArt(bool isCompleted) {
    final Color main = isCompleted
        ? Colors.green.shade400
        : const Color(0xFFF59E0B);
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [main.withOpacity(0.28), main.withOpacity(0.0)],
              ),
            ),
          ),
          Icon(
            Icons.inventory_2_rounded,
            size: 62,
            color: isCompleted
                ? Colors.green.shade300
                : const Color(0xFFFFB74D),
          ),
          Positioned(
            top: 4,
            left: 2,
            child: Icon(
              Icons.monetization_on_rounded,
              color: Colors.amber.shade400,
              size: 20,
            ),
          ),
          Positioned(
            bottom: 6,
            left: 0,
            child: Icon(
              Icons.monetization_on_rounded,
              color: Colors.amber.shade500,
              size: 16,
            ),
          ),
          Positioned(
            bottom: 2,
            right: 4,
            child: Icon(
              Icons.monetization_on_rounded,
              color: Colors.amber.shade400,
              size: 22,
            ),
          ),
          Positioned(
            top: 10,
            right: 0,
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.auto_awesome,
              color: isCompleted
                  ? Colors.green.shade500
                  : Colors.amber.shade300,
              size: isCompleted ? 20 : 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCubeArt() {
    Widget cube(Color c, double size, double angle) {
      return Transform.rotate(
        angle: angle,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: 92,
      height: 84,
      child: Stack(
        children: [
          Positioned(
            left: 26,
            top: 0,
            child: cube(const Color(0xFF29B6F6), 30, -0.15),
          ),
          Positioned(
            left: 54,
            top: 10,
            child: cube(const Color(0xFFEF5350), 30, 0.12),
          ),
          Positioned(
            left: 4,
            top: 26,
            child: cube(const Color(0xFF66BB6A), 30, -0.1),
          ),
          Positioned(
            left: 34,
            top: 34,
            child: cube(const Color(0xFFFFCA28), 32, 0.1),
          ),
          Positioned(
            left: 62,
            top: 44,
            child: cube(const Color(0xFFEC407A), 26, -0.12),
          ),
        ],
      ),
    );
  }

  Widget _buildFlameArt() {
    return SizedBox(
      width: 92,
      height: 84,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              colors: [Color(0xFFFFF176), Color(0xFFFF5252)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(rect),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 72,
              color: Colors.white,
            ),
          ),
          const Positioned(
            top: 4,
            right: 6,
            child: Icon(Icons.auto_awesome, color: Colors.white70, size: 14),
          ),
          const Positioned(
            bottom: 10,
            left: 6,
            child: Icon(Icons.auto_awesome, color: Colors.white70, size: 12),
          ),
        ],
      ),
    );
  }

  // FEATURE #2: Ek hi affordance — poora card tappable.
  //
  // 🔧 Layout fix: card ke andar ab FittedBox(scaleDown) wrap hai taake agar
  // height kam ho toh saara content proportionally shrink ho jaye — kuch
  // cut/overflow na ho.
  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required Widget art,
    required List<Color> gradient,
    required Color buttonColor,
    required VoidCallback onTap,
    double progress = 0.0,
    String progressLabel = '',
    Key? tutorialKey,
  }) {
    return GestureDetector(
      key: tutorialKey,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // soft decorative circles (depth without noise)
              Positioned(
                top: -34,
                right: -34,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.09),
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              // 🔧 FittedBox ke saath content ko wrap kiya taake chhoti
              // heights pe bhi poora content scale ho jaye (never cut).
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 102,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: 112,
                                  height: 102,
                                  child: art,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bar_chart_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    subtitle,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (progressLabel.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 6,
                                      backgroundColor: Colors.white.withOpacity(
                                        0.22,
                                      ),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  progressLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Single affordance: poora card tappable, ye strip
                          // sirf visual cue hai (button jaisa behavior nahi —
                          // koi separate onTap nahi).
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: _deep(buttonColor, 0.1),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: _deep(buttonColor, 0.1),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideX(
      begin: 0.1,
      delay: 100.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildComingSoonBanner() {
    final Color teal = Colors.teal.shade600;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(teal.withOpacity(0.10), _card),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: teal.withOpacity(0.25), width: 1.2),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: teal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.card_giftcard_rounded, color: teal, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Levels Coming Soon!',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2000 Classic + 500 Pro levels are live. More on the way!',
                  style: TextStyle(
                    color: AppTheme.dim(54),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.2,
      delay: 200.ms,
      duration: 400.ms,
      curve: Curves.easeOutBack,
    );
  }

  // =========================================================================
  // NEW: DAILY PRO TIPS BANNER (For Old Users)
  // =========================================================================
  Widget _buildProTipsBanner(GameProvider game) {
    final List<Map<String, dynamic>> tips = [
      {
        'icon': Icons.lightbulb_rounded,
        'color': Colors.amber,
        'title': 'Save Power-ups',
        'text': 'Time Freeze and Auto-Solve are best saved for levels with massive grids.',
      },
      {
        'icon': Icons.sports_esports_rounded,
        'color': Colors.purpleAccent,
        'title': 'Need Coins Fast?',
        'text': 'Play the Arcade minigames daily. You can earn up to 150 coins in just a few seconds!',
      },
      {
        'icon': Icons.timer_rounded,
        'color': Colors.blue,
        'title': 'Speed is Key',
        'text': 'Finish levels within the first 30% of the time to guarantee a 3-Star rating and maximum coins.',
      },
      {
        'icon': Icons.diamond_rounded,
        'color': Colors.cyan,
        'title': 'Diamonds are Valuable',
        'text': 'Save your diamonds for Auto-Solve, or exchange them for coins when you are stuck on unlocking a level.',
      },
      {
        'icon': Icons.calendar_today_rounded,
        'color': Colors.orange,
        'title': 'Don\'t Break the Streak!',
        'text': 'Open the game daily to claim huge coin and diamond rewards on the 7th day.',
      },
    ];

    // FIX: todayStamp ko game object se access kiya hai aur error hata diya hai
    final int todaySeed = game.todayStamp;
    final Map<String, dynamic> todayTip = tips[todaySeed % tips.length];
    final Color tint = todayTip['color'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(tint.withOpacity(0.08), _card),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tint.withOpacity(0.2), width: 1.2),
        boxShadow: _softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tint.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(todayTip['icon'] as IconData, color: tint, size: 22),
          ),
          const SizedBox(width: 12),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tip of the Day Header
                Text(
                  'TIP OF THE DAY',
                  style: TextStyle(
                    color: tint,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                // Title
                Text(
                  todayTip['title'] as String,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // Description
                Text(
                  todayTip['text'] as String,
                  style: TextStyle(
                    color: AppTheme.dim(54),
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  // ===================== BOTTOM NAV =====================
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.line.withOpacity(0.6)),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Expanded(child: _buildNavItem(Icons.home_rounded, 'Home', 0)),
          Expanded(child: _buildNavItem(Icons.bar_chart_rounded, 'Stats', 1)),
          Expanded(
            child: _buildNavItem(Icons.sports_esports_rounded, 'Arcade', 2),
          ),
          Expanded(child: _buildNavItem(Icons.shopping_bag_rounded, 'Shop', 3)),
          Expanded(child: _buildNavItem(Icons.settings_rounded, 'Settings', 4)),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    final Color fg = isSelected ? Colors.white : AppTheme.grey(400);
    return GestureDetector(
      key: TutorialManager.navKeyForIndex(index),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _currentIndex = index);
        // TUTORIAL: only the highlighted tab moves the tour forward.
        context.read<GameProvider>().onTutorialTabSelected(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _brand : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 24),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EVENTS ORB BUTTON
// ============================================================================
class _EventsOrbButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool hasNew;

  const _EventsOrbButton({required this.onTap, this.hasNew = false});

  @override
  State<_EventsOrbButton> createState() => _EventsOrbButtonState();
}

class _EventsOrbButtonState extends State<_EventsOrbButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: SizedBox(
        width: 76,
        height: 76,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, child) {
            final double t = Curves.easeInOut.transform(_c.value);
            final double scale = 1.0 + t * 0.04;
            return Transform.scale(scale: scale, child: child);
          },
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: const Size(76, 76),
                painter: _EventsCalendarPainter(),
              ),
              if (widget.hasNew)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: _card, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventsCalendarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2 - 4);
    final double scale = size.width / 76.0;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF4B5C).withOpacity(0.15),
          const Color(0xFFFF4B5C).withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 30 * scale));
    canvas.drawCircle(center, 30 * scale, glowPaint);

    _drawSparkle(
      canvas,
      center + Offset(-24 * scale, 6 * scale),
      4 * scale,
      const Color(0xFFFFB300),
    );
    _drawSparkle(
      canvas,
      center + Offset(24 * scale, -2 * scale),
      5 * scale,
      const Color(0xFFFFB300),
    );
    _drawSparkle(
      canvas,
      center + Offset(18 * scale, 16 * scale),
      3 * scale,
      const Color(0xFFFF4B5C),
    );
    _drawSparkle(
      canvas,
      center + Offset(-18 * scale, -12 * scale),
      3 * scale,
      const Color(0xFFFFB300),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    final calRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: 38 * scale,
        height: 34 * scale,
      ),
      Radius.circular(8 * scale),
    );

    canvas.save();
    canvas.clipRRect(calRect);
    canvas.drawRect(
      Rect.fromLTRB(-19 * scale, -17 * scale, 19 * scale, -4 * scale),
      Paint()..color = const Color(0xFFFF4B5C),
    );
    canvas.drawRect(
      Rect.fromLTRB(-19 * scale, -4 * scale, 19 * scale, 17 * scale),
      Paint()..color = const Color(0xFFFFF3E0),
    );
    canvas.restore();

    canvas.drawRRect(
      calRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * scale
        ..color = const Color(0xFFE53935),
    );

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 * scale
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF3F3D56);
    canvas.drawLine(
      Offset(-10 * scale, -19 * scale),
      Offset(-10 * scale, -14 * scale),
      ringPaint,
    );
    canvas.drawLine(
      Offset(10 * scale, -19 * scale),
      Offset(10 * scale, -14 * scale),
      ringPaint,
    );

    _drawStar(
      canvas,
      Offset(0, 5 * scale),
      10 * scale,
      const Color(0xFFFF4B5C),
      const Color(0xFFC62828),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(center.dx, center.dy + 16 * scale);
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: 50 * scale,
        height: 18 * scale,
      ),
      Radius.circular(9 * scale),
    );

    canvas.drawRRect(
      pillRect.shift(Offset(0, 2 * scale)),
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 * scale),
    );

    final pillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF4B5C), Color(0xFFD32F2F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(pillRect.outerRect);
    canvas.drawRRect(pillRect, pillPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'EVENTS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9.5 * scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset pos, double size, Color color) {
    final path = Path();
    path.moveTo(pos.dx, pos.dy - size);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx + size, pos.dy);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy + size);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx - size, pos.dy);
    path.quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy - size);
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawStar(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    Color shadowColor,
  ) {
    final path = Path();
    final int points = 5;
    final double angle = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? radius : radius * 0.4;
      final double a = i * angle - math.pi / 2;
      final double x = center.dx + r * math.cos(a);
      final double y = center.dy + r * math.sin(a);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path.shift(Offset(0, 1)), Paint()..color = shadowColor);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
