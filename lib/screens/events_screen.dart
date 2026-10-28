import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../economy/economy_config.dart';
import '../providers/game_provider.dart';
import '../services/tutorial_manager.dart';
import '../theme/app_theme.dart';
import 'level_screen.dart';

// ============================================================================
// EVENTS SCREEN
//
// Ab sirf 2 cheezein dikhti hain:
//   1) Jo event abhi CHAL RAHA hai (bada hero card, start / progress / claim).
//   2) Jo events user COMPLETE (claim) kar chuka hai (history, naya sabse upar).
// Aane wale (upcoming) events ab bilkul show nahi hote.
// Saari game logic (start, progress, claim, levels kholna) pehle jaisi hi hai.
// ============================================================================
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  // Event types that are earned by clearing levels (button opens level list).
  static const Set<String> _levelEventTypes = {
    'classic',
    'any',
    'pro',
    'pro_speed',
    'speed15',
    'speed10',
    'perfect',
    'no_power',
    'tier1',
    'tier3',
    'tier5',
    'time_morning',
    'time_night',
    'weekend',
    'clutch',
    'big_grid',
    'no_mistake',
    'replay',
    'coins',
  };

  void _openLevelsForEvent(BuildContext context, GameEvent event) {
    if (_levelEventTypes.contains(event.type)) {
      final bool pro = event.type == 'pro' || event.type == 'pro_speed';
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: TutorialManager.levelRouteName),
          builder: (_) => LevelScreen(isProMode: pro),
        ),
      );
    } else {
      // Shop / Arcade / Daily / Lucky etc. -> back to the main screens.
      Navigator.pop(context);
    }
  }

  // event.icon (string) -> real icon
  IconData _iconFor(String name) {
    switch (name) {
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'coin':
        return Icons.monetization_on_rounded;
      case 'diamond':
        return Icons.diamond_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'grid':
        return Icons.grid_view_rounded;
      case 'moon':
        return Icons.nightlight_round;
      case 'sun':
        return Icons.wb_sunny_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'cart':
        return Icons.shopping_cart_rounded;
      case 'gift':
        return Icons.card_giftcard_rounded;
      case 'gamepad':
        return Icons.sports_esports_rounded;
      case 'target':
        return Icons.gps_fixed_rounded;
      case 'palette':
        return Icons.palette_rounded;
      case 'refresh':
        return Icons.refresh_rounded;
      case 'lock':
        return Icons.lock_rounded;
      case 'calendar':
        return Icons.calendar_month_rounded;
      case 'auto':
        return Icons.auto_awesome_rounded;
      case 'danger':
        return Icons.warning_amber_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  // "Ends in 1d 4h" — current event ka bacha hua time.
  String _timeLeftText() {
    const int eventEpoch = 1700000000000;
    final int periodMs = EventConfig.eventDurationHours * 3600 * 1000;
    final int now = DateTime.now().millisecondsSinceEpoch;
    int elapsed = (now - eventEpoch) % periodMs;
    if (elapsed < 0) elapsed += periodMs;
    final Duration left = Duration(milliseconds: periodMs - elapsed);
    if (left.inHours >= 24) {
      return '${left.inDays}d ${left.inHours % 24}h left';
    }
    if (left.inHours >= 1) {
      return '${left.inHours}h ${left.inMinutes % 60}m left';
    }
    return '${left.inMinutes.clamp(1, 59)}m left';
  }

  // ------------------------------------------------------ DATE / TIME HELPERS
  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const List<String> _months = [
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

  // Device ke local time me: "Fri 30 Oct, 3:13 AM"
  String _formatDateTime(DateTime d) {
    int h = d.hour % 12;
    if (h == 0) h = 12;
    final String m = d.minute.toString().padLeft(2, '0');
    final String ap = d.hour >= 12 ? 'PM' : 'AM';
    return '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}, '
        '$h:$m $ap';
  }

  // Current event kis waqt khatam hoga (= agla event usi waqt shuru hota hai).
  int _currentEventEndMs() {
    const int eventEpoch = 1700000000000;
    final int periodMs = EventConfig.eventDurationHours * 3600 * 1000;
    final int now = DateTime.now().millisecondsSinceEpoch;
    int elapsed = (now - eventEpoch) % periodMs;
    if (elapsed < 0) elapsed += periodMs;
    return now + (periodMs - elapsed);
  }

  // "in 1d 4h" / "in 5h 20m" / "in 12m"
  String _humanLeft(Duration left) {
    if (left.inHours >= 24) {
      return 'in ${left.inDays}d ${left.inHours % 24}h';
    }
    if (left.inHours >= 1) {
      return 'in ${left.inHours}h ${left.inMinutes % 60}m';
    }
    return 'in ${left.inMinutes.clamp(1, 59)}m';
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    // Provider ka currentEvent null ho sakta hai agar event rotate hone ke
    // baad abhi tak sync nahi hua (e.g. app khuli rahi aur 48h guzar gaye).
    // Us surat me bhi sahi live event dikhao, lekin purani progress / claim
    // state us par na lagao.
    final GameEvent? providerEvent = game.currentEvent;
    final GameEvent liveEvent =
        providerEvent ??
        EventConfig.getActiveEvent(DateTime.now().millisecondsSinceEpoch);
    final bool synced = providerEvent != null;

    // Completed history: wo saare events jo user claim kar chuka hai,
    // naya sabse upar. Agar LIVE event bhi claim ho chuka hai to wo bhi
    // yahan dikhega (pehle isey skip kar diya jata tha, isi wajah se live
    // card pe "CLAIMED" aur neeche "0 completed" nazar aata tha).
    // Sirf us surat me live event skip hota hai jab provider abhi sync nahi
    // hua (purani claim state par bharosa nahi kar sakte).
    final List<GameEvent> completed = [];
    final Set<String> seen = {};
    for (final String id in game.claimedEventIds.reversed) {
      if (id == liveEvent.id && !synced) continue;
      if (!seen.add(id)) continue;
      final int idx = EventConfig.allEvents.indexWhere((e) => e.id == id);
      if (idx == -1) continue;
      completed.add(EventConfig.allEvents[idx]);
    }

    // Current event kab khatam hoga aur uske baad kaun sa event aayega.
    final int endMs = _currentEventEndMs();
    final DateTime endAt = DateTime.fromMillisecondsSinceEpoch(endMs);
    final GameEvent nextEvent = EventConfig.getActiveEvent(endMs);

    return ThemedScaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: AppTheme.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVENTS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'Complete challenges • Earn rewards',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.dim(54),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GlowBackgroundPainter()),
          ),
          SafeArea(
            top: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              children: [
                _sectionLabel(
                  'LIVE EVENT',
                  Icons.bolt_rounded,
                  AppTheme.accent,
                ).animate().fadeIn(duration: 350.ms),
                const SizedBox(height: 12),
                _buildLiveCard(
                      context: context,
                      game: game,
                      event: liveEvent,
                      synced: synced,
                      endAt: endAt,
                    )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(
                      begin: 0.08,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 14),
                _buildNextCard(
                  event: nextEvent,
                  startAt: endAt,
                ).animate().fadeIn(duration: 450.ms, delay: 100.ms),
                const SizedBox(height: 28),
                _sectionLabel(
                  'COMPLETED',
                  Icons.verified_rounded,
                  Colors.green,
                  count: completed.length,
                ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                const SizedBox(height: 12),
                if (completed.isEmpty)
                  _buildEmptyHistory().animate().fadeIn(
                    duration: 450.ms,
                    delay: 250.ms,
                  )
                else
                  ...List.generate(completed.length, (i) {
                    return _buildHistoryRow(
                          event: completed[i],
                          isFirst: i == 0,
                          isLast: i == completed.length - 1,
                        )
                        .animate()
                        .fadeIn(
                          duration: 450.ms,
                          delay: Duration(
                            milliseconds: 220 + (i * 70).clamp(0, 700),
                          ),
                        )
                        .slideX(
                          begin: 0.05,
                          end: 0,
                          duration: 450.ms,
                          curve: Curves.easeOutCubic,
                        );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ SECTION LABEL
  Widget _sectionLabel(String text, IconData icon, Color color, {int? count}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            color: AppTheme.ink,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ],
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1.5, color: AppTheme.line)),
      ],
    );
  }

  // --------------------------------------------------------------- LIVE CARD
  Widget _buildLiveCard({
    required BuildContext context,
    required GameProvider game,
    required GameEvent event,
    required bool synced,
    required DateTime endAt,
  }) {
    final bool isClaimed = synced && game.claimedEventIds.contains(event.id);
    final bool isStarted = synced && game.isEventActive;
    final int progress = synced ? game.eventProgress : 0;
    final bool isCompleted = synced && progress >= event.target;

    final Color color = AppTheme.accent;
    final Color deep = Color.lerp(color, AppTheme.brand, 0.55) ?? color;

    final String statusText = isClaimed
        ? 'CLAIMED'
        : (isCompleted
              ? 'READY TO CLAIM'
              : (isStarted ? 'IN PROGRESS' : 'LIVE NOW'));

    final String buttonText = isClaimed
        ? 'CLAIMED'
        : (isCompleted
              ? 'CLAIM REWARD'
              : (isStarted
                    ? (_levelEventTypes.contains(event.type)
                          ? 'PLAY LEVELS'
                          : 'KEEP GOING')
                    : 'START EVENT'));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, deep],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(AppTheme.isDark ? 0.35 : 0.30),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Faded arrow motif (game ki theme)
            Positioned(
              right: -26,
              top: -26,
              child: Transform.rotate(
                angle: 0.35,
                child: Icon(
                  Icons.arrow_outward_rounded,
                  size: 190,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _heroChip(
                        icon: isClaimed
                            ? Icons.check_circle_rounded
                            : Icons.local_fire_department_rounded,
                        text: statusText,
                      ),
                      const SizedBox(width: 8),
                      _heroChip(
                        icon: Icons.timer_outlined,
                        text: _timeLeftText(),
                        soft: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.45),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.check_rounded
                              : _iconFor(event.icon),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              event.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _rewardPill(event, onDark: true),
                  const SizedBox(height: 10),
                  _endsPill(endAt),
                  if (isStarted || isCompleted || isClaimed) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          'PROGRESS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$progress / ${event.target}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (progress / event.target).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted && !isClaimed
                            ? Colors.green
                            : Colors.white,
                        foregroundColor: isCompleted && !isClaimed
                            ? Colors.white
                            : deep,
                        disabledBackgroundColor: Colors.white.withOpacity(0.22),
                        disabledForegroundColor: Colors.white.withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: isClaimed
                          ? null
                          : () {
                              if (!isStarted) {
                                game.startEvent();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Event Started! Play levels to progress.',
                                    ),
                                    backgroundColor: color,
                                  ),
                                );
                              } else if (isCompleted) {
                                if (game.claimEventReward()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reward Claimed!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                // IN PROGRESS: 'PLAY LEVELS' button sach mein
                                // levels khol deta hai.
                                _openLevelsForEvent(context, event);
                              }
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isClaimed
                                ? Icons.check_circle_rounded
                                : (isCompleted
                                      ? Icons.redeem_rounded
                                      : (isStarted
                                            ? Icons.play_arrow_rounded
                                            : Icons.flag_rounded)),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              buttonText,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // "ENDS  Fri 30 Oct, 3:13 AM" — live card ke andar.
  Widget _endsPill(DateTime endAt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ENDS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.event_busy_rounded, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _formatDateTime(endAt),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- NEXT CARD
  // Agla event: naam, kab shuru hoga aur kitna time baaki hai.
  Widget _buildNextCard({required GameEvent event, required DateTime startAt}) {
    final Duration left = startAt.difference(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.line, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_iconFor(event.icon), color: AppTheme.accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UP NEXT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppTheme.dim(54),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Starts ${_formatDateTime(startAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dim(54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _humanLeft(left),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip({
    required IconData icon,
    required String text,
    bool soft = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(soft ? 0.14 : 0.24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- REWARD PILL
  Widget _rewardPill(GameEvent event, {required bool onDark}) {
    final Color textColor = onDark ? Colors.white : AppTheme.ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: onDark ? Colors.black.withOpacity(0.18) : AppTheme.cardAlt,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'REWARD',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
              color: textColor.withOpacity(0.65),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.monetization_on_rounded,
            color: Colors.amber,
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            '${event.rewardCoins}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          if (event.rewardDiamonds > 0) ...[
            const SizedBox(width: 12),
            const Icon(Icons.diamond_rounded, color: Colors.cyan, size: 18),
            const SizedBox(width: 4),
            Text(
              '${event.rewardDiamonds}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------------------------------------------- HISTORY ROWS
  Widget _buildHistoryRow({
    required GameEvent event,
    required bool isFirst,
    required bool isLast,
  }) {
    const Color green = Colors.green;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // timeline rail
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 2.5,
                  height: 22,
                  color: isFirst ? Colors.transparent : green.withOpacity(0.35),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: green,
                    boxShadow: [
                      BoxShadow(color: green.withOpacity(0.35), blurRadius: 8),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2.5,
                    color: isLast
                        ? Colors.transparent
                        : green.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: green.withOpacity(0.30),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        AppTheme.isDark ? 0.28 : 0.06,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_iconFor(event.icon), color: green, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.3,
                              color: AppTheme.dim(54),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monetization_on_rounded,
                                  color: Colors.amber,
                                  size: 15,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${event.rewardCoins}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.ink,
                                  ),
                                ),
                                if (event.rewardDiamonds > 0) ...[
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.diamond_rounded,
                                    color: Colors.cyan,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${event.rewardDiamonds}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'DONE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.green,
                        ),
                      ),
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

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.line, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_outlined,
              color: AppTheme.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No completed events yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Finish the live event and claim your reward.\nYour completed events will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppTheme.dim(54),
            ),
          ),
        ],
      ),
    );
  }
}

// Soft theme-coloured glows behind the content.
class _GlowBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Color accent = AppTheme.accent;
    final Color brand = AppTheme.brand;
    final double a = AppTheme.isDark ? 0.16 : 0.08;

    final Offset c1 = Offset(size.width * 0.9, size.height * 0.08);
    canvas.drawCircle(
      c1,
      220,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withOpacity(a), accent.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: c1, radius: 220)),
    );

    final Offset c2 = Offset(size.width * 0.05, size.height * 0.75);
    canvas.drawCircle(
      c2,
      240,
      Paint()
        ..shader = RadialGradient(
          colors: [brand.withOpacity(a * 0.8), brand.withOpacity(0.0)],
        ).createShader(Rect.fromCircle(center: c2, radius: 240)),
    );
  }

  @override
  bool shouldRepaint(covariant _GlowBackgroundPainter oldDelegate) => false;
}
