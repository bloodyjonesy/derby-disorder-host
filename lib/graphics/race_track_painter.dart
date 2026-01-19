import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Custom painter for the race track
class RaceTrackPainter extends CustomPainter {
  final List<Participant> participants;
  final Map<String, double> positions;
  final String? leaderId;
  final double animationValue;

  RaceTrackPainter({
    required this.participants,
    required this.positions,
    this.leaderId,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final trackRadius = math.min(size.width, size.height) * 0.35;
    final trackWidth = trackRadius * 0.25;

    // Draw background glow
    _drawBackgroundGlow(canvas, center, trackRadius);

    // Draw outer track boundary
    _drawTrackBoundary(canvas, center, trackRadius + trackWidth / 2, AppTheme.neonPink);

    // Draw track surface
    _drawTrackSurface(canvas, center, trackRadius, trackWidth);

    // Draw inner track boundary
    _drawTrackBoundary(canvas, center, trackRadius - trackWidth / 2, AppTheme.neonCyan);

    // Draw start/finish line
    _drawStartFinishLine(canvas, center, trackRadius, trackWidth);

    // Draw lane markers
    _drawLaneMarkers(canvas, center, trackRadius, trackWidth);

    // Draw participants
    _drawParticipants(canvas, center, trackRadius);
  }

  void _drawBackgroundGlow(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.neonPink.withOpacity(0.1),
          AppTheme.neonCyan.withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));

    canvas.drawCircle(center, radius * 1.5, paint);
  }

  void _drawTrackBoundary(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawTrackSurface(Canvas canvas, Offset center, double radius, double width) {
    final paint = Paint()
      ..color = AppTheme.surfaceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawCircle(center, radius, paint);
  }

  void _drawStartFinishLine(Canvas canvas, Offset center, double radius, double width) {
    final startAngle = -math.pi / 2; // Top of the circle
    final innerRadius = radius - width / 2;
    final outerRadius = radius + width / 2;

    final paint = Paint()
      ..color = AppTheme.neonGreen
      ..strokeWidth = 4.0;

    // Glow
    final glowPaint = Paint()
      ..color = AppTheme.neonGreen.withOpacity(0.5)
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final startInner = Offset(
      center.dx + innerRadius * math.cos(startAngle),
      center.dy + innerRadius * math.sin(startAngle),
    );
    final startOuter = Offset(
      center.dx + outerRadius * math.cos(startAngle),
      center.dy + outerRadius * math.sin(startAngle),
    );

    canvas.drawLine(startInner, startOuter, glowPaint);
    canvas.drawLine(startInner, startOuter, paint);

    // Checkered pattern
    final checkerSize = width / 6;
    for (var i = 0; i < 6; i++) {
      final t = i / 6;
      final pos = Offset.lerp(startInner, startOuter, t)!;
      if (i % 2 == 0) {
        canvas.drawCircle(pos, checkerSize / 2, Paint()..color = Colors.white);
      }
    }
  }

  void _drawLaneMarkers(Canvas canvas, Offset center, double radius, double width) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw dashed center line
    const dashLength = 10.0;
    const gapLength = 15.0;
    const totalLength = dashLength + gapLength;
    final circumference = 2 * math.pi * radius;
    final numDashes = (circumference / totalLength).floor();

    for (var i = 0; i < numDashes; i++) {
      final startAngle = (i * totalLength) / radius;
      final endAngle = ((i * totalLength) + dashLength) / radius;

      final startPos = Offset(
        center.dx + radius * math.cos(startAngle - math.pi / 2),
        center.dy + radius * math.sin(startAngle - math.pi / 2),
      );
      final endPos = Offset(
        center.dx + radius * math.cos(endAngle - math.pi / 2),
        center.dy + radius * math.sin(endAngle - math.pi / 2),
      );

      canvas.drawLine(startPos, endPos, paint);
    }
  }

  void _drawParticipants(Canvas canvas, Offset center, double trackRadius) {
    final participantRadius = trackRadius * 0.08;

    for (var i = 0; i < participants.length; i++) {
      final participant = participants[i];
      final position = positions[participant.id] ?? 0.0;

      // Calculate angle based on position (0-100 maps to 0-2π)
      // Start at top (-π/2) and go clockwise
      final progress = position / 100.0;
      final angle = -math.pi / 2 + (progress * 2 * math.pi);

      // Offset each lane slightly
      final laneOffset = (i - (participants.length - 1) / 2) * (trackRadius * 0.06);
      final currentRadius = trackRadius + laneOffset;

      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);

      _drawParticipant(
        canvas,
        Offset(x, y),
        participant,
        participantRadius,
        participant.id == leaderId,
      );
    }
  }

  void _drawParticipant(
    Canvas canvas,
    Offset position,
    Participant participant,
    double radius,
    bool isLeader,
  ) {
    // Parse color
    Color color;
    try {
      color = Color(int.parse(participant.color.replaceFirst('#', '0xFF')));
    } catch (_) {
      color = AppTheme.neonCyan;
    }

    // Leader glow
    if (isLeader) {
      final leaderGlow = Paint()
        ..color = AppTheme.neonYellow.withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      canvas.drawCircle(position, radius * 1.5, leaderGlow);
    }

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(position, radius * 1.2, glowPaint);

    // Background circle
    final bgPaint = Paint()
      ..color = AppTheme.cardBackground
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, radius, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(position, radius, borderPaint);

    // Draw emoji
    final textPainter = TextPainter(
      text: TextSpan(
        text: participant.icon,
        style: TextStyle(fontSize: radius * 1.2),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(RaceTrackPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        oldDelegate.participants != participants ||
        oldDelegate.leaderId != leaderId ||
        oldDelegate.animationValue != animationValue;
  }
}
