import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../models/arrow_model.dart';
import '../providers/game_provider.dart';
import '../services/tutorial_manager.dart';
import '../theme/app_theme.dart';

/// Wraps the whole app (inside MaterialApp.builder).
///
/// While `GameProvider.tutorialStep > 0` it paints a dark layer over every
/// screen with a "spotlight hole" around the widget the player must tap.
/// Touches that land on the hole go straight to the real widget underneath;
/// everything else is absorbed. So the player can only progress by tapping
/// the real highlighted button.
///
/// v2 (smooth + accurate):
///  * the spotlight only opens once the target has STOPPED moving (no more
///    jumping while a screen is still sliding in) and then blooms in softly
///  * the spotlight glides from tab to tab (Stats -> Arcade -> Shop -> ...)
///  * the pointing hand is custom drawn: its fingertip lands exactly on the
///    target, it taps (press + ripple) in a loop, and it is small
///  * on the arrow step the hole follows the real arrow cells (not a big
///    rectangle) and only a tap on THAT arrow is accepted
///  * card slides between top/bottom and fades between steps
class GuidedTourOverlay extends StatelessWidget {
  final Widget child;

  /// Small "Skip" link on the card (safety exit). Set to false to force
  /// players to finish the tour.
  final bool allowSkip;

  const GuidedTourOverlay({
    super.key,
    required this.child,
    this.allowSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    final int step = context.select<GameProvider, int>((g) => g.tutorialStep);

    // NOTE: the app child is ALWAYS slot 0, so the Navigator is never
    // re-created when the tour starts or ends.
    return Stack(
      children: [
        Positioned.fill(child: child),
        if (step > 0) Positioned.fill(child: _TourLayer(allowSkip: allowSkip)),
      ],
    );
  }
}

/// What the tour measured for the current step.
class _Target {
  /// Bounding rect of the spotlight (already padded).
  final Rect rect;

  /// Arrow step only: one rect per arrow cell (already padded).
  final List<Rect> cells;

  /// Exact point the fingertip must touch.
  final Offset anchor;

  const _Target({
    required this.rect,
    required this.cells,
    required this.anchor,
  });
}

class _TourLayer extends StatefulWidget {
  final bool allowSkip;
  const _TourLayer({required this.allowSkip});

  @override
  State<_TourLayer> createState() => _TourLayerState();
}

class _TourLayerState extends State<_TourLayer>
    with SingleTickerProviderStateMixin {
  // How long a target must stand still before the spotlight opens.
  static const double _settleSeconds = 0.16;
  static const double _cardHeightEstimate = 210;

  late final Ticker _ticker;
  double _time = 0;
  int _step = 0;

  Rect? _raw; // last measured rect
  double _stableFor = 0; // seconds the target has not moved
  Rect? _shown; // smoothed spotlight rect (null = no spotlight yet)
  List<Rect> _cells = const [];
  Offset _anchor = Offset.zero;
  double _appear = 0; // 0..1 spotlight bloom
  double _lockFade = 1; // 1 = dim visible, 0 = gone (after arrow cleared)
  double _nudge = 0; // 1..0 "you tapped the wrong place" feedback

  Rect? _board;
  int _gridN = 0;
  bool _cardAtBottom = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // TICK: measure, settle, smooth
  // ------------------------------------------------------------------
  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final GameProvider game = context.read<GameProvider>();
    final double now = elapsed.inMicroseconds / 1000000.0;
    final double dt = (now - _time).clamp(0.0, 0.05).toDouble();
    _time = now;

    // ---- step changed ----
    if (game.tutorialStep != _step) {
      final int prev = _step;
      _step = game.tutorialStep;
      _raw = null;
      _stableFor = 0;
      final bool tabToTab =
          TutorialManager.tabIndexForStep(prev) >= 0 &&
          TutorialManager.tabIndexForStep(_step) >= 0;
      if (!tabToTab) {
        // new screen: wait for it to settle, then bloom the spotlight in.
        _shown = null;
        _cells = const [];
        _appear = 0;
      }
      // tabToTab: keep _shown, the spotlight glides to the next tab.
    }

    final TutorialStepData? data = TutorialManager.dataFor(_step);
    final bool locked = game.tutorialInputLocked;

    _lockFade = locked
        ? math.max(0.0, _lockFade - dt / 0.28)
        : math.min(1.0, _lockFade + dt / 0.2);
    _nudge = math.max(0.0, _nudge - dt / 0.55);

    _Target? t;
    if (data != null && !data.isFinal && !locked) {
      t = _measure(game, data);
    }

    if (t == null) {
      _raw = null;
      _stableFor = 0;
      if (_shown != null) {
        _appear = math.max(0.0, _appear - dt / 0.18);
        if (_appear <= 0) {
          _shown = null;
          _cells = const [];
        }
      }
    } else {
      final Rect? last = _raw;
      final bool same = last != null && _near(last, t.rect);
      _stableFor = same ? _stableFor + dt : 0;
      _raw = t.rect;

      if (_shown == null) {
        if (_stableFor >= _settleSeconds) {
          _shown = t.rect;
          _cells = t.cells;
          _anchor = t.anchor;
          _appear = 0;
        }
      } else {
        final double k = 1 - math.exp(-dt * 16);
        _shown = Rect.lerp(_shown!, t.rect, k)!;
        _cells = t.cells;
        _anchor = Offset.lerp(_anchor, t.anchor, k)!;
        _appear = math.min(1.0, _appear + dt / 0.34);
      }
    }

    setState(() {});
  }

  bool _near(Rect a, Rect b) =>
      (a.left - b.left).abs() < 0.8 &&
      (a.top - b.top).abs() < 0.8 &&
      (a.right - b.right).abs() < 0.8 &&
      (a.bottom - b.bottom).abs() < 0.8;

  // ------------------------------------------------------------------
  // Find the on-screen rectangle of the widget to highlight
  // ------------------------------------------------------------------
  RenderBox? _boxOf(GlobalKey key) {
    final BuildContext? ctx = key.currentContext;
    if (ctx == null) return null;
    final RenderObject? ro = ctx.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
    return ro;
  }

  Rect? _rectOf(GlobalKey key, RenderBox overlayBox) {
    final RenderBox? box = _boxOf(key);
    if (box == null) return null;
    final Matrix4 m = box.getTransformTo(overlayBox);
    return MatrixUtils.transformRect(m, Offset.zero & box.size);
  }

  _Target? _measure(GameProvider game, TutorialStepData data) {
    final RenderObject? ro = context.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
    final RenderBox overlayBox = ro;
    final Rect screen = Offset.zero & overlayBox.size;

    if (data.target == TutorialTarget.firstArrow) {
      return _measureArrow(game, data, overlayBox, screen);
    }

    final GlobalKey? key = TutorialManager.keyForTarget(data.target);
    if (key == null) return null;
    final Rect? raw = _rectOf(key, overlayBox);
    if (raw == null || raw.isEmpty) return null;
    // Target still sliding in from off screen -> not ready yet.
    if (!screen.contains(raw.center)) return null;
    return _Target(
      rect: raw.inflate(data.holePadding),
      cells: const [],
      anchor: raw.center,
    );
  }

  _Target? _measureArrow(
    GameProvider game,
    TutorialStepData data,
    RenderBox overlayBox,
    Rect screen,
  ) {
    final Rect? board = _rectOf(TutorialManager.boardKey, overlayBox);
    final int? id = game.tutorialTargetArrowId;
    final int n = game.gridSize;
    if (board == null || board.isEmpty || id == null || n <= 0) return null;
    if (id < 0 || id >= game.arrows.length) return null;
    final ArrowModel a = game.arrows[id];
    if (a.cells.isEmpty) return null;
    if (!screen.contains(board.center)) return null;

    _board = board;
    _gridN = n;

    final double cw = board.width / n;
    final double ch = board.height / n;
    final double pad = data.holePadding * 0.5;

    final List<Rect> cells = <Rect>[];
    Rect? bounds;
    for (final GridCell c in a.cells) {
      final Rect r = Rect.fromLTWH(
        board.left + c.x * cw,
        board.top + c.y * ch,
        cw,
        ch,
      ).inflate(pad);
      cells.add(r);
      bounds = bounds == null ? r : bounds.expandToInclude(r);
    }

    // Fingertip lands on the middle cell of the arrow.
    final GridCell mid = a.cells[a.cells.length ~/ 2];
    final Offset anchor = Offset(
      board.left + (mid.x + 0.5) * cw,
      board.top + (mid.y + 0.5) * ch,
    );
    return _Target(rect: bounds!, cells: cells, anchor: anchor);
  }

  /// Arrow step: only a tap that really lands on the highlighted arrow
  /// clears it. A tap on a neighbouring (blocked) arrow inside the bounding
  /// box is ignored, so the player can never lose a life here by accident.
  void _onArrowAreaTap(Offset p) {
    final Rect? board = _board;
    if (board == null || _gridN <= 0) return;
    final GameProvider game = context.read<GameProvider>();
    final int? target = game.tutorialTargetArrowId;
    if (target == null) return;
    final double gx = (p.dx - board.left) / (board.width / _gridN);
    final double gy = (p.dy - board.top) / (board.height / _gridN);
    final int? hit = game.arrowAt(gx, gy);
    if (hit != null && hit == target) {
      game.tapArrow(hit);
    } else {
      _nudge = 1.0;
    }
  }

  // ------------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final GameProvider game = context.watch<GameProvider>();
    final TutorialStepData? data = TutorialManager.dataFor(game.tutorialStep);
    if (data == null) return const SizedBox.shrink();

    final bool locked = game.tutorialInputLocked;
    final bool isArrowStep = data.target == TutorialTarget.firstArrow;

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size size = constraints.biggest;
        final EdgeInsets safe = MediaQuery.of(context).padding;

        final Rect? hole = (data.isFinal || _shown == null || _appear <= 0.01)
            ? null
            : _shown;
        final double ease = Curves.easeOutCubic.transform(
          _appear.clamp(0.0, 1.0).toDouble(),
        );

        // ---- where do card and finger go? ----
        bool fingerBelow = true;
        if (hole != null) {
          final double above = hole.top - safe.top;
          final double below = size.height - hole.bottom - safe.bottom;
          _cardAtBottom = below >= above;
          const double cost = _cardHeightEstimate + 24;
          final double belowFree = below - (_cardAtBottom ? cost : 0);
          final double aboveFree = above - (_cardAtBottom ? 0 : cost);
          if (belowFree >= 70) {
            fingerBelow = true;
          } else if (aboveFree >= 70) {
            fingerBelow = false;
          } else {
            fingerBelow = belowFree >= aboveFree;
          }
        }

        // ---- spotlight shapes ----
        final double bloom = (1 - ease) * 18;
        final List<RRect> shapes = <RRect>[];
        if (hole != null) {
          if (isArrowStep && _cells.isNotEmpty) {
            final double rad = (_board == null || _gridN <= 0)
                ? data.holeRadius
                : (_board!.width / _gridN) * 0.34;
            for (final Rect c in _cells) {
              shapes.add(
                RRect.fromRectAndRadius(c.inflate(bloom), Radius.circular(rad)),
              );
            }
          } else {
            shapes.add(
              RRect.fromRectAndRadius(
                hole.inflate(bloom),
                Radius.circular(data.holeRadius),
              ),
            );
          }
        }

        final List<Widget> layers = <Widget>[
          // 1) dim + spotlight + glowing ring (visual only)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _DimPainter(
                  holes: shapes,
                  baseAlpha: isArrowStep ? 0xA6 : 0xC7,
                  dimFactor: _lockFade,
                  pulse: (math.sin(_time * 4.0) + 1) / 2,
                  appear: ease,
                  nudge: _nudge,
                  ringColor: AppTheme.accent,
                ),
              ),
            ),
          ),
        ];

        // 2) touch handling
        if (locked) {
          layers.add(const Positioned.fill(child: AbsorbPointer()));
        } else if (hole != null) {
          layers.addAll(_blockers(size, hole));
          if (isArrowStep) {
            layers.add(
              Positioned.fromRect(
                rect: hole,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) =>
                      _onArrowAreaTap(hole.topLeft + d.localPosition),
                  child: const SizedBox.expand(),
                ),
              ),
            );
          }
        } else {
          layers.add(_fullBlocker());
        }

        // 3) pointing hand
        if (!locked && hole != null) {
          final double fingerOpacity = ((_appear - 0.45) / 0.45)
              .clamp(0.0, 1.0)
              .toDouble();
          layers.add(
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _FingerPainter(
                    tip: _anchor,
                    fromBelow: fingerBelow,
                    leanRight: _anchor.dx < size.width - 60,
                    phase: (_time % 1.7) / 1.7,
                    opacity: fingerOpacity,
                  ),
                ),
              ),
            ),
          );
        }

        // 4) instruction card
        if (!locked) {
          layers.add(
            _buildCard(
              game: game,
              data: data,
              safe: safe,
              waiting: !data.isFinal && hole == null,
              isArrowStep: isArrowStep,
            ),
          );
        }

        return Stack(children: layers);
      },
    );
  }

  Widget _buildCard({
    required GameProvider game,
    required TutorialStepData data,
    required EdgeInsets safe,
    required bool waiting,
    required bool isArrowStep,
  }) {
    final Alignment align = data.isFinal
        ? Alignment.center
        : (_cardAtBottom ? Alignment.bottomCenter : Alignment.topCenter);

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, safe.top + 16, 20, safe.bottom + 24),
        child: AnimatedAlign(
          alignment: align,
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeInOutCubic,
          child: Transform.translate(
            offset: Offset(math.sin(_time * 55) * 8 * _nudge, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _TourCard(
                  key: ValueKey<int>(data.step),
                  data: data,
                  waitingForTarget: waiting,
                  isArrowStep: isArrowStep,
                  allowSkip: widget.allowSkip,
                  onFinish: game.completeTutorial,
                  onSkip: game.completeTutorial,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Touch absorbers. Wrong taps also "nudge" the card + ring so the player
  // understands that only the glowing spot works.
  Widget _absorber() => Listener(
    behavior: HitTestBehavior.opaque,
    onPointerDown: (_) => _nudge = 1.0,
    child: const SizedBox.expand(),
  );

  Widget _fullBlocker() => Positioned.fill(child: _absorber());

  List<Widget> _blockers(Size size, Rect hole) {
    final double l = hole.left.clamp(0.0, size.width).toDouble();
    final double r = hole.right.clamp(0.0, size.width).toDouble();
    final double t = hole.top.clamp(0.0, size.height).toDouble();
    final double b = hole.bottom.clamp(0.0, size.height).toDouble();
    return [
      Positioned(left: 0, right: 0, top: 0, height: t, child: _absorber()),
      Positioned(left: 0, right: 0, top: b, bottom: 0, child: _absorber()),
      Positioned(
        left: 0,
        width: l,
        top: t,
        height: math.max(0.0, b - t),
        child: _absorber(),
      ),
      Positioned(
        left: r,
        right: 0,
        top: t,
        height: math.max(0.0, b - t),
        child: _absorber(),
      ),
    ];
  }
}

// ======================================================================
// CARD
// ======================================================================
class _TourCard extends StatelessWidget {
  final TutorialStepData data;
  final bool waitingForTarget;
  final bool isArrowStep;
  final bool allowSkip;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  const _TourCard({
    super.key,
    required this.data,
    required this.waitingForTarget,
    required this.isArrowStep,
    required this.allowSkip,
    required this.onFinish,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final Color brand = AppTheme.brand;
    final Color accent = AppTheme.accent;
    final Color ink = AppTheme.ink;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: brand.withAlpha(70), width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP ${data.step} OF ${TutorialManager.totalSteps}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(height: 12),
            _stepDots(brand),
            const SizedBox(height: 12),
            if (data.isFinal)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: onFinish,
                  child: const Text(
                    'Start Playing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 18, color: brand),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      waitingForTarget
                          ? 'Getting ready...'
                          : (isArrowStep
                                ? 'Tap the glowing arrow'
                                : 'Tap the glowing spot to continue'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.dim(54),
                      ),
                    ),
                  ),
                  if (allowSkip)
                    TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.grey(500),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepDots(Color brand) {
    return Row(
      children: List.generate(TutorialManager.totalSteps, (i) {
        final int stepNo = i + 1;
        final bool done = stepNo < data.step;
        final bool current = stepNo == data.step;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(
              right: i == TutorialManager.totalSteps - 1 ? 0 : 4,
            ),
            decoration: BoxDecoration(
              color: (done || current) ? brand : brand.withAlpha(40),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ======================================================================
// DIM + SPOTLIGHT + GLOWING RING
// ======================================================================
class _DimPainter extends CustomPainter {
  final List<RRect> holes;
  final int baseAlpha; // 0..255 darkness of the dim
  final double dimFactor; // 1 = full dim, 0 = invisible (fade-out)
  final double pulse; // 0..1
  final double appear; // 0..1 spotlight bloom
  final double nudge; // 0..1 wrong-tap feedback
  final Color ringColor;

  const _DimPainter({
    required this.holes,
    required this.baseAlpha,
    required this.dimFactor,
    required this.pulse,
    required this.appear,
    required this.nudge,
    required this.ringColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final int a = (baseAlpha * dimFactor).round().clamp(0, 255).toInt();

    canvas.saveLayer(bounds, Paint());
    canvas.drawRect(bounds, Paint()..color = Color.fromARGB(a, 0, 0, 0));
    final Paint clear = Paint()..blendMode = BlendMode.clear;
    for (final RRect rr in holes) {
      canvas.drawRRect(rr, clear);
    }
    canvas.restore();

    if (holes.isEmpty || appear <= 0.02 || dimFactor <= 0.02) return;

    // One outline around the whole spotlight (cells merge into one shape).
    Path? outline;
    for (final RRect rr in holes) {
      final Path p = Path()..addRRect(rr);
      outline = outline == null
          ? p
          : Path.combine(PathOperation.union, outline, p);
    }
    if (outline == null) return;

    final double boost = nudge * 4;
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7 + boost
        ..color = ringColor.withAlpha(
          ((60 + pulse * 70 + nudge * 80) * appear)
              .round()
              .clamp(0, 255)
              .toInt(),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 + pulse * 2),
    );
    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 + boost * 0.4
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white.withAlpha(
          ((170 + pulse * 85) * appear).round().clamp(0, 255).toInt(),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant _DimPainter old) => true;
}

// ======================================================================
// POINTING HAND (custom drawn, fingertip = exact target point)
// ======================================================================
//
// The hand is drawn in a tiny local coordinate system whose ORIGIN (0,0) is
// the very tip of the index finger and whose body extends towards +y.
// Rotating by PI around the origin makes it point downwards instead, so the
// tip always stays exactly on the target.
Path _buildHandPath() {
  final List<RRect> parts = <RRect>[
    RRect.fromLTRBR(-5.5, 0, 5.5, 36, const Radius.circular(5.5)), // index
    RRect.fromLTRBR(5, 18, 13.5, 42, const Radius.circular(4.2)), // middle
    RRect.fromLTRBR(12.5, 22, 21, 44, const Radius.circular(4.2)), // ring
    RRect.fromLTRBR(20, 27, 27.5, 46, const Radius.circular(3.8)), // little
    RRect.fromLTRBR(-12, 30, 27.5, 58, const Radius.circular(13)), // palm
    RRect.fromLTRBR(-18.5, 31, -6, 47, const Radius.circular(6)), // thumb
  ];
  Path p = Path();
  for (final RRect r in parts) {
    final Path q = Path()..addRRect(r);
    p = Path.combine(PathOperation.union, p, q);
  }
  return p;
}

final Path _kHandPath = _buildHandPath();

class _FingerPainter extends CustomPainter {
  /// Exact point the fingertip touches.
  final Offset tip;

  /// true  = hand comes from below and points UP at the target.
  /// false = hand comes from above and points DOWN at the target.
  final bool fromBelow;

  /// Lean the hand body to the right (false near the right screen edge).
  final bool leanRight;

  /// 0..1 loop: approach -> press (+ ripple) -> retreat -> rest.
  final double phase;

  /// 0..1 fade in.
  final double opacity;

  // Small on purpose: about 36 x 45 logical pixels.
  static const double _handScale = 0.78;
  static const double _hoverDistance = 20;

  const _FingerPainter({
    required this.tip,
    required this.fromBelow,
    required this.leanRight,
    required this.phase,
    required this.opacity,
  });

  double _ease(double t) => Curves.easeInOut.transform(t.clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;

    // ---- timeline ----
    final double p = phase;
    double reach; // 1 = hovering away from the target, 0 = touching it
    double press = 0;
    double ripple = -1;

    if (p < 0.32) {
      reach = 1 - _ease(p / 0.32);
    } else if (p < 0.52) {
      reach = 0;
      if (p < 0.38) {
        press = (p - 0.32) / 0.06;
      } else if (p < 0.46) {
        press = 1;
      } else {
        press = 1 - (p - 0.46) / 0.06;
      }
    } else if (p < 0.82) {
      reach = _ease((p - 0.52) / 0.30);
    } else {
      reach = 1;
    }
    if (p >= 0.34 && p <= 0.80) ripple = (p - 0.34) / 0.46;
    press = press.clamp(0.0, 1.0).toDouble();

    // ---- ripple under the fingertip ----
    if (ripple >= 0) {
      final double r = 5 + 24 * Curves.easeOut.transform(ripple);
      canvas.drawCircle(
        tip,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = Colors.white.withAlpha(
            (200 * (1 - ripple) * opacity).round().clamp(0, 255).toInt(),
          ),
      );
    }
    if (press > 0) {
      canvas.drawCircle(
        tip,
        7,
        Paint()
          ..color = Colors.white.withAlpha(
            (110 * press * opacity).round().clamp(0, 255).toInt(),
          ),
      );
    }

    // ---- hand ----
    final double lean = leanRight ? 0.22 : -0.22;
    final double angle = fromBelow ? -lean : math.pi + lean;

    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);
    canvas.translate(0, reach * _hoverDistance);
    canvas.scale(_handScale * (1 - 0.07 * press));

    canvas.drawShadow(
      _kHandPath,
      Colors.black.withAlpha((200 * opacity).round().clamp(0, 255).toInt()),
      4,
      false,
    );
    canvas.drawPath(
      _kHandPath,
      Paint()
        ..color = Colors.white.withAlpha(
          (255 * opacity).round().clamp(0, 255).toInt(),
        ),
    );
    canvas.drawPath(
      _kHandPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF1B1B3A)
            .withAlpha((255 * opacity).round().clamp(0, 255).toInt()),
    );
    // knuckle creases
    final Paint crease = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1B1B3A)
          .withAlpha((95 * opacity).round().clamp(0, 255).toInt());
    canvas.drawLine(const Offset(5.3, 26), const Offset(5.3, 42), crease);
    canvas.drawLine(const Offset(13, 30), const Offset(13, 44), crease);
    canvas.drawLine(const Offset(20.4, 34), const Offset(20.4, 47), crease);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FingerPainter old) => true;
}
