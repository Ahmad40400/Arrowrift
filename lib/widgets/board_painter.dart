import 'dart:math';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import '../models/arrow_model.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

class BoardPainter extends CustomPainter {
  final GameProvider game;

  BoardPainter({required this.game, required Listenable repaint})
    : super(repaint: repaint);

  // Colours now come from the active theme (classic = the original colours).
  static Color get ink => AppTheme.arrowInk;
  static Color get danger => AppTheme.danger;

  @override
  void paint(Canvas canvas, Size size) {
    final int n = game.gridSize;
    if (n == 0) return;

    final double cs = size.width / n;
    final int now = gameClock.elapsedMilliseconds;

    // Themed board panel (rounded board + grid dots). Classic = nothing drawn,
    // so the original look is untouched.
    _paintPanel(canvas, size, cs, n);

    // Reference image jaisi patli line (Thin)
    final double lineWidth = max(cs * 0.055, 1.5);

    // Reference image jaisa chota aur sharp arrow head
    final double headBack = cs * 0.12;
    final double headFront = cs * 0.16;
    final double headHalfW = cs * 0.12;

    for (final a in game.arrows) {
      double slide = 0;
      double alpha = 1;
      Color color = ink;
      Offset shake = Offset.zero;
      final dir = Offset(a.direction.dx.toDouble(), a.direction.dy.toDouble());

      if (a.isExiting) {
        final double t = ((now - a.exitStartMs) / a.exitDurationMs)
            .clamp(0.0, 1.0)
            .toDouble();
        if (t >= 1) continue;
        slide = Curves.easeIn.transform(t) * a.exitTravelCells * cs;
        alpha = t < 0.7 ? 1.0 : 1.0 - (t - 0.7) / 0.3;
      } else if (a.shakeStartMs >= 0) {
        final double st =
            ((now - a.shakeStartMs) / GameProvider.shakeDurationMs)
                .clamp(0.0, 1.0)
                .toDouble();
        if (st < 1) {
          color = Color.lerp(ink, danger, 1 - st)!;
          final double wiggle = sin(st * pi * 4) * (1 - st) * cs * 0.22;
          shake = dir * wiggle;
        }
      }

      final centers = <Offset>[
        for (final c in a.cells) Offset((c.x + 0.5) * cs, (c.y + 0.5) * cs),
      ];
      final double bodyLen = (a.length - 1) * cs;
      final points = List<Offset>.from(centers);
      if (a.isExiting) {
        points.add(centers.last + dir * (a.exitTravelCells * cs));
      }

      final body = _slice(points, slide, slide + bodyLen - headBack);
      final headPos = centers.last + dir * slide;

      final paint = Paint()
        ..color = color.withAlpha((alpha * 255).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final fill = Paint()
        ..color = color.withAlpha((alpha * 255).round())
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(shake.dx, shake.dy);

      if (body.length >= 2) {
        final path = Path()..moveTo(body.first.dx, body.first.dy);
        for (int i = 1; i < body.length; i++) {
          path.lineTo(body[i].dx, body[i].dy);
        }
        canvas.drawPath(path, paint);
      }

      final tip = headPos + dir * headFront;
      final base = headPos - dir * headBack;
      final normal = Offset(-dir.dy, dir.dx);
      final head = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(
          base.dx + normal.dx * headHalfW,
          base.dy + normal.dy * headHalfW,
        )
        ..lineTo(
          base.dx - normal.dx * headHalfW,
          base.dy - normal.dy * headHalfW,
        )
        ..close();
      canvas.drawPath(head, fill);

      canvas.restore();
    }
  }

  void _paintPanel(Canvas canvas, Size size, double cs, int n) {
    final ArrowTheme t = AppTheme.active;
    if (t.isClassic) return;

    final double m = min(cs * 0.3, 12.0);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(-m, -m, size.width + m * 2, size.height + m * 2),
      Radius.circular(max(cs * 0.45, 14)),
    );

    // soft glow / shadow under the board
    final shadow = Paint()
      ..color = t.boardBorder.withOpacity(t.isDark ? 0.35 : 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, t.isDark ? 14 : 10);
    canvas.drawRRect(rect.shift(Offset(0, t.isDark ? 0 : 4)), shadow);

    canvas.drawRRect(rect, Paint()..color = t.boardBg);
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = t.boardBorder,
    );

    // grid dots (one per cell)
    final pts = <Offset>[
      for (int y = 0; y < n; y++)
        for (int x = 0; x < n; x++) Offset((x + 0.5) * cs, (y + 0.5) * cs),
    ];
    canvas.drawPoints(
      PointMode.points,
      pts,
      Paint()
        ..color = t.boardDot
        ..strokeWidth = max(cs * 0.09, 2)
        ..strokeCap = StrokeCap.round,
    );
  }

  List<Offset> _slice(List<Offset> pts, double from, double to) {
    final out = <Offset>[];
    if (to <= from) return out;
    double acc = 0;
    for (int i = 0; i < pts.length - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final seg = (b - a).distance;
      final s0 = acc;
      final s1 = acc + seg;
      if (seg > 0 && s1 > from && s0 < to) {
        final t0 = (max(from, s0) - s0) / seg;
        final t1 = (min(to, s1) - s0) / seg;
        final pa = Offset.lerp(a, b, t0)!;
        final pb = Offset.lerp(a, b, t1)!;
        if (out.isEmpty || (out.last - pa).distance > 0.001) out.add(pa);
        out.add(pb);
      }
      acc = s1;
    }
    return out;
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) => true;
}
