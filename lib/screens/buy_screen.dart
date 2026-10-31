import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../economy/economy_config.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../theme/grid_styles.dart';

Color get _brand => AppTheme.brand;
Color get _accent => AppTheme.accent;
Color get _card => AppTheme.card;
Color get _ink => AppTheme.ink;

class BuyScreen extends StatelessWidget {
  const BuyScreen({super.key});

  // Remembers open/closed state across rebuilds (context.watch rebuilds a lot).
  static bool _themeSectionExpanded = false;
  static bool _gridSectionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'SHOP',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: _ink,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Buy power-ups and store them for later use.',
            style: TextStyle(color: AppTheme.dim(54), fontSize: 14),
          ),
          SizedBox(height: 32),

          Text(
            'POWER-UPS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.dim(45),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),

          // 1. Time Freeze
          _buildShopItem(
            context: context,
            title: 'Time Freeze',
            desc: 'Stops the timer for 15 seconds.',
            icon: Icons.ac_unit_rounded,
            color: Colors.lightBlue,
            cost: Eco.freezeCoinPrice,
            inventory: game.freezeInventory,
            onBuy: () {
              if (game.totalPoints >= Eco.freezeCoinPrice) {
                game.buyFreezeItem();
                _showSuccessPopup(
                  context,
                  'Time Freeze',
                  Icons.ac_unit_rounded,
                  Colors.lightBlue,
                );
              } else {
                _showErrorPopup(context, 'Not enough coins!');
              }
            },
          ),
          SizedBox(height: 12),

          // 2. Extra Life
          _buildShopItem(
            context: context,
            title: 'Extra Life',
            desc: 'Adds one extra heart during a level.',
            icon: Icons.favorite_rounded,
            color: _accent,
            cost: Eco.healthCoinPrice,
            inventory: game.healthInventory,
            onBuy: () {
              if (game.totalPoints >= Eco.healthCoinPrice) {
                game.buyHealthItem();
                _showSuccessPopup(
                  context,
                  'Extra Life',
                  Icons.favorite_rounded,
                  _accent,
                );
              } else {
                _showErrorPopup(context, 'Not enough coins!');
              }
            },
          ),
          SizedBox(height: 12),

          // 3. Auto Solve (Mega Power)
          _buildMegaPowerItem(context, game),

          SizedBox(height: 12),

          // 4. Streak Freeze
          _buildStreakFreezeShopItem(context, game),

          SizedBox(height: 32),

          Text(
            'EXCHANGE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.dim(45),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),

          _buildDiamondToCoinExchangeItem(context, game),

          SizedBox(height: 32),

          Text(
            'DAILY BLIND GIFT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.dim(45),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),

          _buildLuckyDrawItem(context, game),

          SizedBox(height: 32),

          _buildFoldableThemesSection(context, game),

          SizedBox(height: 20),
          _buildFoldableGridsSection(context, game),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==================================================================
  // STREAK FREEZE — FEATURE #1 + #5: AUTO-USE explanation + chip
  // ==================================================================
  Widget _buildStreakFreezeShopItem(BuildContext context, GameProvider game) {
    final int held = game.streakFreezeHeld;
    final int maxHeld = Eco.streakFreezeMaxHeld;
    final bool canBuy =
        held < maxHeld && game.totalPoints >= Eco.streakFreezeCoinPrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.ac_unit_rounded,
              color: Colors.lightBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Streak Freeze',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.grey(300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$held / $maxHeld',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // FEATURE #5: "AUTO-USE" chip — clarifies working.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.lightBlue.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.autorenew_rounded,
                        color: Colors.lightBlue,
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'AUTO-USE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Colors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // FEATURE #1: clear auto-use explanation.
                Text(
                  'Automatically used when you miss a day — saves your '
                  'streak without any manual action.',
                  style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canBuy ? _brand : AppTheme.grey(300),
              foregroundColor: canBuy ? Colors.white : AppTheme.grey(600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: canBuy
                ? () {
                    if (game.buyStreakFreeze()) {
                      _showSuccessPopup(
                        context,
                        'Streak Freeze',
                        Icons.ac_unit_rounded,
                        Colors.lightBlue,
                      );
                    } else {
                      _showErrorPopup(context, 'Not enough coins!');
                    }
                  }
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _fmtCoins(Eco.streakFreezeCoinPrice),
                  style: const TextStyle(
                    fontSize: 12,
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

  // ==================================================================
  // THEMES — FEATURE #2: "NEW" badge on collapsed header
  // ==================================================================
  Widget _buildFoldableThemesSection(BuildContext context, GameProvider game) {
    final int ownedCount = AppTheme.all
        .where((t) => game.isThemeUnlocked(t.id))
        .length;
    final int totalCount = AppTheme.all.length;
    // FEATURE #2: "NEW" badge sirf tab dikhe jab user ne koi premium theme
    // unlock nahi kiya (sirf classic ke paas hai) — naya user ko discover karne
    // mein help karta hai. Ek baar koi theme khareed le, badge chala jayega.
    final bool showNewBadge = ownedCount <= 1;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final bool expanded = _themeSectionExpanded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _themeSectionExpanded = !_themeSectionExpanded;
                setLocalState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.palette_rounded, color: _brand, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'CUSTOM THEMES',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.dim(45),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              // FEATURE #2: "NEW" badge for discovery.
                              if (showNewBadge) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pinkAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$ownedCount / $totalCount owned  •  tap to '
                            '${expanded ? 'collapse' : 'expand'}',
                            style: TextStyle(
                              color: AppTheme.dim(54),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.dim(54),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- REGULAR category ----------------
                    _buildThemeCategoryHeader(game, premium: false),
                    const SizedBox(height: 12),
                    for (final t in AppTheme.regular) ...[
                      _buildThemeCard(context, game, t),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    // ---------------- PREMIUM category ----------------
                    _buildThemeCategoryHeader(game, premium: true),
                    const SizedBox(height: 12),
                    for (final t in AppTheme.premium) ...[
                      _buildThemeCard(context, game, t),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        );
      },
    );
  }

  // Gold used for everything "premium" in the shop.
  static const Color _premiumGold = Color(0xFFE0A100);
  static const Color _premiumGoldDeep = Color(0xFFB8860B);

  Widget _buildThemeCategoryHeader(GameProvider game, {required bool premium}) {
    final List<ArrowTheme> list = premium ? AppTheme.premium : AppTheme.regular;
    final int owned = list.where((t) => game.isThemeUnlocked(t.id)).length;
    final int minPrice = list
        .where((t) => !t.isClassic)
        .map((t) => t.price)
        .reduce((a, b) => a < b ? a : b);
    final String trial =
        'Try every theme for FREE once (${Eco.themePreviewSeconds ~/ 60} min). ';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: premium
            ? _premiumGold.withOpacity(0.10)
            : _brand.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: premium
              ? _premiumGold.withOpacity(0.55)
              : _brand.withOpacity(0.18),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (premium)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD54F), _premiumGoldDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              else
                Icon(Icons.palette_outlined, color: _brand, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  premium ? 'PREMIUM THEMES' : 'REGULAR THEMES',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: premium ? _premiumGold : _ink,
                  ),
                ),
              ),
              Text(
                '$owned / ${list.length} owned',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dim(54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            premium
                ? 'Exclusive high-end looks with rich animated-style '
                      'backgrounds. $trial'
                      'Own forever from ${_fmtCoins(minPrice)} coins.'
                : '$trial'
                      'Love it? Own it forever for '
                      '${_fmtCoins(Eco.themePrice)} coins.',
            style: TextStyle(color: AppTheme.dim(54), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCrownBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), _premiumGoldDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: Colors.white,
        size: 12,
      ),
    );
  }

  static String _fmtCoins(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Widget _buildThemeCard(
    BuildContext context,
    GameProvider game,
    ArrowTheme t,
  ) {
    final bool owned = game.isThemeUnlocked(t.id);
    final bool isOnScreen = game.currentTheme.id == t.id;
    final bool isTrialRunning = game.previewThemeId == t.id;
    final bool isActive =
        owned && game.activeThemeId == t.id && !game.isPreviewingTheme;
    final bool trialUsed = game.hasTriedTheme(t.id);

    String status;
    Color statusColor;
    if (isTrialRunning) {
      status = 'TRIAL RUNNING';
      statusColor = Colors.orange;
    } else if (isActive) {
      status = 'ACTIVE';
      statusColor = Colors.green;
    } else if (owned) {
      status = 'OWNED';
      statusColor = Colors.green;
    } else if (trialUsed) {
      status = 'TRIAL USED';
      statusColor = AppTheme.dim(54);
    } else {
      status = '1 FREE TRIAL';
      statusColor = Colors.orange;
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOnScreen
              ? t.brand
              : (t.isPremium
                    ? _premiumGold.withOpacity(0.55)
                    : Colors.transparent),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: t.isPremium
                ? _premiumGold.withOpacity(0.16)
                : Colors.black.withOpacity(0.04),
            blurRadius: t.isPremium ? 18 : 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: CustomPaint(painter: _ThemeThumbPainter(t)),
                    ),
                  ),
                  if (t.isPremium)
                    Positioned(
                      top: -6,
                      left: -6,
                      child: _buildPremiumCrownBadge(),
                    ),
                ],
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(t.icon, color: t.brand, size: 18),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            t.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: _ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      t.tagline,
                      style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        for (final c in t.swatch) ...[
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.grey(300),
                                width: 1,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (owned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? AppTheme.grey(300) : _brand,
                  foregroundColor: isActive ? AppTheme.dim(54) : Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isActive ? null : () => game.setActiveTheme(t.id),
                icon: Icon(
                  isActive ? Icons.check_circle_rounded : Icons.brush_rounded,
                  size: 18,
                ),
                label: Text(
                  isActive ? 'APPLIED' : 'APPLY THEME',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isTrialRunning ? _accent : _brand,
                      side: BorderSide(
                        color: (trialUsed && !isTrialRunning)
                            ? AppTheme.grey(300)
                            : (isTrialRunning ? _accent : _brand),
                        width: 2,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isTrialRunning
                        ? () => game.endThemePreview()
                        : (trialUsed || game.isPreviewingTheme
                              ? null
                              : () {
                                  if (game.startThemePreview(t.id)) {
                                    _showSuccessPopup(
                                      context,
                                      t.name,
                                      t.icon,
                                      t.brand,
                                      title: 'Free trial started!',
                                      message:
                                          'Try ${t.name} for '
                                          '${Eco.themePreviewSeconds ~/ 60} minutes. '
                                          'Open a level to see the full look!',
                                    );
                                  }
                                }),
                    icon: Icon(
                      isTrialRunning
                          ? Icons.stop_circle_outlined
                          : Icons.visibility_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isTrialRunning
                          ? 'END TRIAL'
                          : (trialUsed ? 'TRIAL USED' : 'TRY FREE'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _confirmBuyTheme(context, game, t),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        SizedBox(width: 5),
                        Text(
                          _fmtCoins(t.price),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _confirmBuyTheme(BuildContext context, GameProvider game, ArrowTheme t) {
    if (game.totalPoints < t.price) {
      _showErrorPopup(
        context,
        'Not enough coins! ${t.name} costs ${_fmtCoins(t.price)} coins.',
      );
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
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
                Icon(t.icon, color: t.brand, size: 56),
                SizedBox(height: 14),
                Text(
                  'Unlock ${t.name}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'It will be yours forever and applied right away.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.dim(54)),
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                    SizedBox(width: 6),
                    Text(
                      _fmtCoins(t.price),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.grey(300),
                          foregroundColor: _ink,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final ok = game.buyTheme(t.id);
                          Navigator.pop(dialogContext);
                          if (ok) {
                            _showSuccessPopup(
                              context,
                              t.name,
                              t.icon,
                              t.brand,
                              title: 'Theme unlocked!',
                              message: '${t.name} is now applied to your game.',
                            );
                          } else {
                            _showErrorPopup(context, 'Not enough coins!');
                          }
                        },
                        child: Text(
                          'UNLOCK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================================================================
  // CUSTOM GRIDS — same flow as themes: free trial / buy / apply
  // ==================================================================
  Widget _buildFoldableGridsSection(BuildContext context, GameProvider game) {
    final int ownedCount = GridStyles.all
        .where((g) => game.isGridUnlocked(g.id))
        .length;
    final int totalCount = GridStyles.all.length;
    final bool showNewBadge = ownedCount <= 1;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        final bool expanded = _gridSectionExpanded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _gridSectionExpanded = !_gridSectionExpanded;
                setLocalState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.grid_on_rounded, color: _brand, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'CUSTOM GRIDS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.dim(45),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              if (showNewBadge) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pinkAccent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$ownedCount / $totalCount owned  •  tap to '
                            '${expanded ? 'collapse' : 'expand'}',
                            style: TextStyle(
                              color: AppTheme.dim(54),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.dim(54),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGridCategoryHeader(game, premium: false),
                    const SizedBox(height: 12),
                    for (final g in GridStyles.regular) ...[
                      _buildGridCard(context, game, g),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    _buildGridCategoryHeader(game, premium: true),
                    const SizedBox(height: 12),
                    for (final g in GridStyles.premium) ...[
                      _buildGridCard(context, game, g),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              crossFadeState: expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 280),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridCategoryHeader(GameProvider game, {required bool premium}) {
    final List<GridStyle> list = premium
        ? GridStyles.premium
        : GridStyles.regular;
    final int owned = list.where((g) => game.isGridUnlocked(g.id)).length;
    final int minPrice = list
        .where((g) => !g.isDefault)
        .map((g) => g.price)
        .reduce((a, b) => a < b ? a : b);
    final String trial =
        'Try every grid for FREE once (${Eco.gridPreviewSeconds ~/ 60} min). ';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: premium
            ? _premiumGold.withOpacity(0.10)
            : _brand.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: premium
              ? _premiumGold.withOpacity(0.55)
              : _brand.withOpacity(0.18),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (premium)
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD54F), _premiumGoldDeep],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                )
              else
                Icon(Icons.grid_view_rounded, color: _brand, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  premium ? 'PREMIUM GRIDS' : 'REGULAR GRIDS',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: premium ? _premiumGold : _ink,
                  ),
                ),
              ),
              Text(
                '$owned / ${list.length} owned',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dim(54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            premium
                ? 'Exclusive board shapes for a fresh challenge. $trial'
                      'Own forever from ${_fmtCoins(minPrice)} coins.'
                : '$trial'
                      'Love it? Own it forever for '
                      '${_fmtCoins(Eco.gridPrice)} coins.',
            style: TextStyle(color: AppTheme.dim(54), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, GameProvider game, GridStyle g) {
    final bool owned = game.isGridUnlocked(g.id);
    final bool isOnScreen = game.currentGrid.id == g.id;
    final bool isTrialRunning = game.previewGridId == g.id;
    final bool isActive =
        owned && game.activeGridId == g.id && !game.isPreviewingGrid;
    final bool trialUsed = game.hasTriedGrid(g.id);
    final Color tint = AppTheme.brand;

    String status;
    Color statusColor;
    if (isTrialRunning) {
      status = 'TRIAL RUNNING';
      statusColor = Colors.orange;
    } else if (isActive) {
      status = 'ACTIVE';
      statusColor = Colors.green;
    } else if (owned) {
      status = 'OWNED';
      statusColor = Colors.green;
    } else if (trialUsed) {
      status = 'TRIAL USED';
      statusColor = AppTheme.dim(54);
    } else {
      status = '1 FREE TRIAL';
      statusColor = Colors.orange;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isOnScreen
              ? tint
              : (g.isPremium
                    ? _premiumGold.withOpacity(0.55)
                    : Colors.transparent),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: g.isPremium
                ? _premiumGold.withOpacity(0.16)
                : Colors.black.withOpacity(0.04),
            blurRadius: g.isPremium ? 18 : 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: CustomPaint(
                        painter: _GridThumbPainter(g, AppTheme.active),
                      ),
                    ),
                  ),
                  if (g.isPremium)
                    Positioned(
                      top: -6,
                      left: -6,
                      child: _buildPremiumCrownBadge(),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(g.icon, color: tint, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            g.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: _ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      g.tagline,
                      style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (owned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? AppTheme.grey(300) : _brand,
                  foregroundColor: isActive ? AppTheme.dim(54) : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isActive ? null : () => game.setActiveGrid(g.id),
                icon: Icon(
                  isActive
                      ? Icons.check_circle_rounded
                      : Icons.grid_view_rounded,
                  size: 18,
                ),
                label: Text(
                  isActive ? 'APPLIED' : 'APPLY GRID',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isTrialRunning ? _accent : _brand,
                      side: BorderSide(
                        color: (trialUsed && !isTrialRunning)
                            ? AppTheme.grey(300)
                            : (isTrialRunning ? _accent : _brand),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isTrialRunning
                        ? () => game.endGridPreview()
                        : (trialUsed || game.isPreviewingGrid
                              ? null
                              : () {
                                  if (game.startGridPreview(g.id)) {
                                    _showSuccessPopup(
                                      context,
                                      g.name,
                                      g.icon,
                                      tint,
                                      title: 'Free trial started!',
                                      message:
                                          'Try ${g.name} for '
                                          '${Eco.gridPreviewSeconds ~/ 60} minutes. '
                                          'Open a level to see the full look!',
                                    );
                                  }
                                }),
                    icon: Icon(
                      isTrialRunning
                          ? Icons.stop_circle_outlined
                          : Icons.visibility_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isTrialRunning
                          ? 'END TRIAL'
                          : (trialUsed ? 'TRIAL USED' : 'TRY FREE'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _confirmBuyGrid(context, game, g),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _fmtCoins(g.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _confirmBuyGrid(BuildContext context, GameProvider game, GridStyle g) {
    if (game.totalPoints < g.price) {
      _showErrorPopup(
        context,
        'Not enough coins! ${g.name} costs ${_fmtCoins(g.price)} coins.',
      );
      return;
    }
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(g.icon, color: _brand, size: 56),
                const SizedBox(height: 14),
                Text(
                  'Unlock ${g.name}?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'It will be yours forever and applied right away.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.dim(54)),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _fmtCoins(g.price),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.grey(300),
                          foregroundColor: _ink,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          final ok = game.buyGrid(g.id);
                          Navigator.pop(dialogContext);
                          if (ok) {
                            _showSuccessPopup(
                              context,
                              g.name,
                              g.icon,
                              _brand,
                              title: 'Grid unlocked!',
                              message:
                                  '${g.name} is now applied to your board.',
                            );
                          } else {
                            _showErrorPopup(context, 'Not enough coins!');
                          }
                        },
                        child: const Text(
                          'UNLOCK',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiamondToCoinExchangeItem(
    BuildContext context,
    GameProvider game,
  ) {
    final bool canAfford = game.totalDiamonds >= 300;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.currency_exchange_rounded,
              color: Colors.indigo,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exchange Diamonds',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '300',
                      style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                    ),
                    Icon(Icons.diamond_rounded, color: Colors.cyan, size: 14),
                    Text(
                      '  ➡  ',
                      style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                    ),
                    Text(
                      '2,500',
                      style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                    ),
                    Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.amber,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? _brand : AppTheme.grey(300),
              foregroundColor: canAfford ? Colors.white : AppTheme.grey(600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: canAfford
                ? () => _showDiamondExchangeDialog(context, game)
                : null,
            child: Text(
              'EXCHANGE',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDiamondExchangeDialog(BuildContext context, GameProvider game) {
    int selectedDiamonds = 300;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final int coinsToReceive = (selectedDiamonds ~/ 300) * 2500;
            final bool canExchange = game.totalDiamonds >= selectedDiamonds;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Exchange Diamonds',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '300 Diamonds = 2,500 Coins',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.dim(54),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Minimum: 300 Diamonds',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [300, 600, 900, 1200].map((amount) {
                        final isSelected = selectedDiamonds == amount;
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedDiamonds = amount);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? _brand : AppTheme.grey(100),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? _brand : AppTheme.grey(300),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.diamond_rounded,
                                  color: isSelected
                                      ? Colors.cyan
                                      : Colors.cyan.shade700,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '$amount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : _brand,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.grey(50),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You Pay:',
                                style: TextStyle(
                                  color: AppTheme.dim(54),
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$selectedDiamonds',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.cyan,
                                    ),
                                  ),
                                  Icon(
                                    Icons.diamond_rounded,
                                    color: Colors.cyan,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'You Receive:',
                                style: TextStyle(
                                  color: AppTheme.dim(54),
                                  fontSize: 14,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$coinsToReceive',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  Icon(
                                    Icons.monetization_on_rounded,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your Balance: ${game.totalDiamonds} Diamonds',
                      style: TextStyle(
                        fontSize: 12,
                        color: canExchange ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.grey(200),
                              foregroundColor: _brand,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canExchange
                                  ? Colors.green
                                  : AppTheme.grey(300),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: canExchange
                                ? () {
                                    final success = game
                                        .exchangeDiamondsForCoins(
                                          selectedDiamonds,
                                        );
                                    Navigator.pop(dialogContext);
                                    if (success) {
                                      _showSuccessPopup(
                                        context,
                                        '$coinsToReceive Coins',
                                        Icons.monetization_on_rounded,
                                        Colors.amber,
                                      );
                                    }
                                  }
                                : null,
                            child: Text(
                              'EXCHANGE',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessPopup(
    BuildContext context,
    String itemName,
    IconData icon,
    Color color, {
    String? title,
    String? message,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
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
                Icon(icon, color: color, size: 64),
                SizedBox(height: 16),
                Text(
                  title ?? 'Success!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  message ?? '$itemName has been added to your inventory.',
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

  void _showErrorPopup(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () {
          if (Navigator.canPop(context)) Navigator.pop(context);
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
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Oops!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  message,
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

  // ==================================================================
  // LUCKY DRAW — FEATURE #3: "Possible rewards" list added below card
  // ==================================================================
  Widget _buildLuckyDrawItem(BuildContext context, GameProvider game) {
    bool canDraw = game.canPlayLuckyDraw;

    return Column(
      children: [
        GestureDetector(
          onTap: canDraw ? () => _showLuckyDrawDialog(context, game) : null,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canDraw
                    ? [Colors.pink.shade100, Colors.purple.shade50]
                    : [AppTheme.grey(200), AppTheme.grey(100)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: canDraw ? Colors.pink.shade300 : AppTheme.grey(300),
                width: 2,
              ),
              boxShadow: canDraw
                  ? [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: canDraw
                        ? Colors.pink.withOpacity(0.2)
                        : AppTheme.grey(300),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    color: canDraw ? Colors.pinkAccent : AppTheme.grey(500),
                    size: 32,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lucky Draw',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _ink,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        canDraw
                            ? 'Tap to open your blind gift!'
                            : 'Come back tomorrow for a new gift.',
                        style: TextStyle(
                          fontSize: 12,
                          color: canDraw
                              ? AppTheme.dim(54)
                              : AppTheme.grey(500),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canDraw)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'OPEN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // FEATURE #3: "Possible rewards" — transparency for user.
        const SizedBox(height: 10),
        _buildLuckyDrawOdds(),
      ],
    );
  }

  // FEATURE #3: Odds list — GameProvider.drawLuckyGift() ke actual logic se
  // derive kiya. type = random.nextInt(3) → 1/3 each (diamonds / coins /
  // power). Power type ke andar: [freeze, life, auto-solve] shuffle +
  // luckyAutoSolveKeepOutOf10 (1/10) check.
  //
  //   Diamonds : 1/3       ≈ 33.3%
  //   Coins    : 1/3       ≈ 33.3%
  //   Power    : 1/3       ≈ 33.3%
  //     └ freeze    ≈ 12.2%
  //     └ life      ≈ 12.2%
  //     └ auto-solve ≈ 8.9%   (1/10 of the power branch)
  //
  // User ko sirf approximate chance dikhana hai (exact % nahi), isliye
  // friendly buckets use kar rahe hain: Common / Uncommon / Rare.
  Widget _buildLuckyDrawOdds() {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.ac_unit_rounded,
        'color': Colors.lightBlue,
        'label': 'Time Freeze',
        'chance': 'Common',
      },
      {
        'icon': Icons.favorite_rounded,
        'color': Colors.redAccent,
        'label': 'Extra Life',
        'chance': 'Common',
      },
      {
        'icon': Icons.monetization_on_rounded,
        'color': Colors.amber,
        'label': '${Eco.luckyCoins} Coins',
        'chance': 'Common',
      },
      {
        'icon': Icons.diamond_rounded,
        'color': Colors.cyan,
        'label': '${Eco.luckyDiamonds} Diamonds',
        'chance': 'Uncommon',
      },
      {
        'icon': Icons.auto_fix_high_rounded,
        'color': Colors.deepPurpleAccent,
        'label': 'Auto-Solve',
        'chance': 'Rare',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.grey(50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.grey(200), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.dim(54),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Possible rewards',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.dim(87),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: items.map((item) {
              final Color chanceColor;
              switch (item['chance']) {
                case 'Rare':
                  chanceColor = Colors.deepPurple;
                  break;
                case 'Uncommon':
                  chanceColor = Colors.cyan.shade700;
                  break;
                default:
                  chanceColor = Colors.green.shade700;
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.grey(300), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: chanceColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item['chance'] as String,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: chanceColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showLuckyDrawDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isLoading = true;
        Map<String, dynamic>? giftData;

        return StatefulBuilder(
          builder: (context, setState) {
            if (isLoading) {
              Future.delayed(Duration(milliseconds: 2000), () {
                setState(() {
                  isLoading = false;
                  giftData = game.drawLuckyGift();
                });
              });

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.pinkAccent),
                      SizedBox(height: 24),
                      Text(
                        'Your gift is coming...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              IconData iconData = Icons.card_giftcard_rounded;
              if (giftData!['icon'] == 'diamond')
                iconData = Icons.diamond_rounded;
              if (giftData!['icon'] == 'coin')
                iconData = Icons.monetization_on_rounded;
              if (giftData!['icon'] == 'freeze')
                iconData = Icons.ac_unit_rounded;
              if (giftData!['icon'] == 'health')
                iconData = Icons.favorite_rounded;
              if (giftData!['icon'] == 'auto_solve')
                iconData = Icons.auto_fix_high_rounded;

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'CONGRATULATIONS!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You won:',
                        style: TextStyle(fontSize: 14, color: AppTheme.dim(54)),
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: giftData!['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconData,
                          size: 64,
                          color: giftData!['color'],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        giftData!['title'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: giftData!['color'],
                        ),
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brand,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'AWESOME!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildMegaPowerItem(BuildContext context, GameProvider game) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.isClassic ? Colors.deepPurple.shade50 : AppTheme.cardAlt,
            _card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.deepPurple.shade100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
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
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_fix_high_rounded,
                  color: Colors.deepPurpleAccent,
                  size: 32,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Auto-Solve Level',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _ink,
                          ),
                        ),
                        if (game.autoSolveInventory > 0) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Owned: ${game.autoSolveInventory}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Instantly clears the whole board.',
                      style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (game.totalDiamonds >= Eco.autoSolveDiamondPrice) {
                      game.buyAutoSolveItem(withDiamonds: true);
                      _showSuccessPopup(
                        context,
                        'Auto-Solve',
                        Icons.auto_fix_high_rounded,
                        Colors.deepPurpleAccent,
                      );
                    } else {
                      _showErrorPopup(context, 'Not enough diamonds!');
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.diamond_rounded, color: Colors.cyan, size: 16),
                      SizedBox(width: 6),
                      Text(
                        '${Eco.autoSolveDiamondPrice}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _card,
                    foregroundColor: _brand,
                    side: BorderSide(color: _brand, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (game.totalPoints >= Eco.autoSolveCoinPrice) {
                      game.buyAutoSolveItem(withDiamonds: false);
                      _showSuccessPopup(
                        context,
                        'Auto-Solve',
                        Icons.auto_fix_high_rounded,
                        Colors.deepPurpleAccent,
                      );
                    } else {
                      _showErrorPopup(context, 'Not enough coins!');
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${Eco.autoSolveCoinPrice ~/ 1000}k',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem({
    required BuildContext context,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required int cost,
    required int inventory,
    required VoidCallback onBuy,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _ink,
                      ),
                    ),
                    if (inventory > 0) ...[
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Owned: $inventory',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: AppTheme.dim(54)),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brand,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: onBuy,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.amber,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text('$cost', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // FEATURE #4: "Coming Soon" badge ki jagah ETA (timeline) badge.
  Widget _buildComingSoonItem({
    required String title,
    required IconData icon,
    required Color color,
    String eta = 'Coming Soon',
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.grey(200)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.grey(100),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.grey(400), size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.grey(500),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              eta,
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small preview of a theme: background, board panel, dots and two arrows.
class _ThemeThumbPainter extends CustomPainter {
  final ArrowTheme t;
  _ThemeThumbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.bg, t.bg2],
        ).createShader(rect),
    );
    // premium themes show a mini version of their real backdrop
    if (t.isPremium) ThemeBackdropPainter(t).paint(canvas, size);

    final double m = size.width * 0.12;
    final board = RRect.fromRectAndRadius(
      Rect.fromLTWH(m, m, size.width - m * 2, size.height - m * 2),
      Radius.circular(10),
    );
    canvas.drawRRect(
      board,
      Paint()..color = t.isClassic ? Colors.white : t.boardBg,
    );
    canvas.drawRRect(
      board,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = t.isClassic ? AppTheme.grey(300) : t.boardBorder,
    );

    final dot = Paint()..color = t.isClassic ? AppTheme.grey(300) : t.boardDot;
    const int n = 4;
    final double gx = (size.width - m * 2) / n;
    final double gy = (size.height - m * 2) / n;
    for (int y = 0; y < n; y++) {
      for (int x = 0; x < n; x++) {
        canvas.drawCircle(
          Offset(m + (x + 0.5) * gx, m + (y + 0.5) * gy),
          1.6,
          dot,
        );
      }
    }

    final line = Paint()
      ..color = t.arrowInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final head = Paint()..color = t.arrowInk;

    final p1 = Path()
      ..moveTo(m + 0.5 * gx, m + 0.5 * gy)
      ..lineTo(m + 2.5 * gx, m + 0.5 * gy)
      ..lineTo(m + 2.5 * gx, m + 1.5 * gy);
    canvas.drawPath(p1, line);
    final tip1 = Offset(m + 2.5 * gx, m + 1.5 * gy + 5);
    canvas.drawPath(
      Path()
        ..moveTo(tip1.dx, tip1.dy)
        ..lineTo(tip1.dx - 4, tip1.dy - 7)
        ..lineTo(tip1.dx + 4, tip1.dy - 7)
        ..close(),
      head,
    );

    final accentLine = Paint()
      ..color = t.isClassic ? t.accent : t.brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final accentHead = Paint()..color = accentLine.color;
    final p2 = Path()
      ..moveTo(m + 0.5 * gx, m + 3.5 * gy)
      ..lineTo(m + 2.2 * gx, m + 3.5 * gy);
    canvas.drawPath(p2, accentLine);
    final tip2 = Offset(m + 2.2 * gx + 5, m + 3.5 * gy);
    canvas.drawPath(
      Path()
        ..moveTo(tip2.dx, tip2.dy)
        ..lineTo(tip2.dx - 7, tip2.dy - 4)
        ..lineTo(tip2.dx - 7, tip2.dy + 4)
        ..close(),
      accentHead,
    );
  }

  @override
  bool shouldRepaint(covariant _ThemeThumbPainter old) => old.t.id != t.id;
}

/// Small preview of a grid SHAPE: no boxes, only arrows that fill the shape
/// (exactly how the real board looks).
class _GridThumbPainter extends CustomPainter {
  final GridStyle g;
  final ArrowTheme t;
  _GridThumbPainter(this.g, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [t.bg, t.bg2],
        ).createShader(rect),
    );

    const int n = 11;
    final double m = size.width * 0.07;
    final double cs = (size.width - m * 2) / n;

    List<List<bool>> mask = GridStyles.buildMask(g, n);
    if (mask.isEmpty) {
      mask = List.generate(n, (_) => List<bool>.filled(n, true));
    }

    final line = Paint()
      ..color = t.arrowInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final head = Paint()..color = t.arrowInk;

    canvas.save();
    canvas.translate(m, m);
    // fill every row with short arrows (alternating direction)
    for (int y = 0; y < n; y++) {
      int x = 0;
      int k = 0;
      while (x < n) {
        if (!mask[y][x]) {
          x++;
          continue;
        }
        int e = x;
        while (e + 1 < n && mask[y][e + 1] && e - x < 2) {
          e++;
        }
        if (e > x) {
          final bool right = (k + y) % 2 == 0;
          final double cy = (y + 0.5) * cs;
          final double x0 = (x + 0.5) * cs;
          final double x1 = (e + 0.5) * cs;
          final double hx = right ? x1 : x0;
          final double dir = right ? 1 : -1;
          canvas.drawLine(
            Offset(right ? x0 : x1, cy),
            Offset(hx - dir * cs * 0.15, cy),
            line,
          );
          canvas.drawPath(
            Path()
              ..moveTo(hx + dir * cs * 0.2, cy)
              ..lineTo(hx - dir * cs * 0.1, cy - cs * 0.26)
              ..lineTo(hx - dir * cs * 0.1, cy + cs * 0.26)
              ..close(),
            head,
          );
          k++;
        }
        x = e + 1;
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GridThumbPainter old) =>
      old.g.id != g.id || old.t.id != t.id;
}
