import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Types of race animations
enum RaceAnimationType {
  overtake,
  boost,
  stumble,
  closeBattle,
  finish,
  celebration,
  leaderChange,
}

/// Represents an active animation
class ActiveAnimation {
  final RaceAnimationType type;
  final Offset position;
  final double startTime;
  final double duration;
  final List<String> participantIds;
  final String? message;

  ActiveAnimation({
    required this.type,
    required this.position,
    required this.startTime,
    this.duration = 1.5,
    this.participantIds = const [],
    this.message,
  });

  double progress(double currentTime) {
    return ((currentTime - startTime) / duration).clamp(0.0, 1.0);
  }

  bool isComplete(double currentTime) => progress(currentTime) >= 1.0;
}

/// Manages race animations
class RaceAnimationManager {
  final List<ActiveAnimation> _animations = [];
  double _currentTime = 0;

  List<ActiveAnimation> get activeAnimations => 
      _animations.where((a) => !a.isComplete(_currentTime)).toList();

  void update(double deltaTime) {
    _currentTime += deltaTime;
    _animations.removeWhere((a) => a.isComplete(_currentTime));
  }

  void triggerAnimation(RaceAnimationType type, Offset position, {
    List<String> participantIds = const [],
    String? message,
    double? duration,
  }) {
    _animations.add(ActiveAnimation(
      type: type,
      position: position,
      startTime: _currentTime,
      duration: duration ?? _getDefaultDuration(type),
      participantIds: participantIds,
      message: message,
    ));
  }

  double _getDefaultDuration(RaceAnimationType type) {
    switch (type) {
      case RaceAnimationType.overtake:
        return 1.2;
      case RaceAnimationType.boost:
        return 0.8;
      case RaceAnimationType.stumble:
        return 1.0;
      case RaceAnimationType.closeBattle:
        return 2.0;
      case RaceAnimationType.finish:
        return 2.0;
      case RaceAnimationType.celebration:
        return 3.0;
      case RaceAnimationType.leaderChange:
        return 1.5;
    }
  }

  void clear() {
    _animations.clear();
    _currentTime = 0;
  }
}

/// Painter for race effect animations
class RaceEffectsPainter extends CustomPainter {
  final List<ActiveAnimation> animations;
  final double animationValue;

  RaceEffectsPainter({
    required this.animations,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final animation in animations) {
      switch (animation.type) {
        case RaceAnimationType.overtake:
          _paintOvertake(canvas, animation, size);
          break;
        case RaceAnimationType.boost:
          _paintBoost(canvas, animation, size);
          break;
        case RaceAnimationType.stumble:
          _paintStumble(canvas, animation, size);
          break;
        case RaceAnimationType.closeBattle:
          _paintCloseBattle(canvas, animation, size);
          break;
        case RaceAnimationType.finish:
          _paintFinish(canvas, animation, size);
          break;
        case RaceAnimationType.celebration:
          _paintCelebration(canvas, animation, size);
          break;
        case RaceAnimationType.leaderChange:
          _paintLeaderChange(canvas, animation, size);
          break;
      }
    }
  }

  void _paintOvertake(Canvas canvas, ActiveAnimation animation, Size size) {
    final progress = animation.progress(animationValue * animation.duration);
    final position = animation.position;

    // Swoosh lines
    final swooshPaint = Paint()
      ..color = Colors.cyan.withOpacity((1 - progress) * 0.8)
      ..strokeWidth = 4 + (progress * 2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 3; i++) {
      final offset = i * 15.0;
      final startX = position.dx - 30 - offset + (progress * 60);
      final endX = position.dx + 30 - offset + (progress * 60);
      
      canvas.drawLine(
        Offset(startX, position.dy - 10 + i * 10),
        Offset(endX, position.dy - 5 + i * 10),
        swooshPaint,
      );
    }

    // Flash effect
    if (progress < 0.3) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity((0.3 - progress) * 2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(position, 50 * (1 + progress), flashPaint);
    }
  }

  void _paintBoost(Canvas canvas, ActiveAnimation animation, Size size) {
    final progress = animation.progress(animationValue * animation.duration);
    final position = animation.position;
    final random = math.Random(animation.startTime.toInt());

    // Flame particles
    for (var i = 0; i < 8; i++) {
      final particleProgress = (progress + i * 0.1) % 1.0;
      final angle = random.nextDouble() * math.pi * 0.5 + math.pi * 0.75;
      final distance = particleProgress * 60;
      
      final px = position.dx + math.cos(angle) * distance;
      final py = position.dy + math.sin(angle) * distance;
      
      final particlePaint = Paint()
        ..color = Color.lerp(
          Colors.orange,
          Colors.red,
          particleProgress,
        )!.withOpacity((1 - particleProgress) * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(
        Offset(px, py),
        8 * (1 - particleProgress),
        particlePaint,
      );
    }

    // Central glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity((1 - progress) * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(position, 25, glowPaint);
  }

  void _paintStumble(Canvas canvas, ActiveAnimation animation, Size size) {
    final progress = animation.progress(animationValue * animation.duration);
    final position = animation.position;

    // Spiral stars
    for (var i = 0; i < 4; i++) {
      final starAngle = progress * math.pi * 4 + (i * math.pi / 2);
      final starRadius = 30 + math.sin(progress * math.pi) * 10;
      
      final starX = position.dx + math.cos(starAngle) * starRadius;
      final starY = position.dy - 30 + math.sin(starAngle * 0.5) * 10;
      
      final starPaint = Paint()
        ..color = Colors.yellow.withOpacity((1 - progress) * 0.9);

      _drawStar(canvas, Offset(starX, starY), 8, starPaint);
    }

    // Impact lines
    if (progress < 0.3) {
      final impactPaint = Paint()
        ..color = Colors.white.withOpacity((0.3 - progress) * 2)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        final innerRadius = 20 + progress * 30;
        final outerRadius = 35 + progress * 40;
        
        canvas.drawLine(
          Offset(
            position.dx + math.cos(angle) * innerRadius,
            position.dy + math.sin(angle) * innerRadius,
          ),
          Offset(
            position.dx + math.cos(angle) * outerRadius,
            position.dy + math.sin(angle) * outerRadius,
          ),
          impactPaint,
        );
      }
    }
  }

  void _paintCloseBattle(Canvas canvas, ActiveAnimation animation, Size size) {
    final progress = animation.progress(animationValue * animation.duration);
    final position = animation.position;

    // Subtle pulse ring instead of lightning - much less intrusive
    final pulseRadius = 20 + progress * 25;
    final opacity = (1 - progress) * 0.35; // Much lower opacity

    final ringPaint = Paint()
      ..color = Colors.orange.withOpacity(opacity)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(position, pulseRadius, ringPaint);

    // Small "VS" text indicator that fades out
    if (progress < 0.5) {
      final textOpacity = (0.5 - progress) * 0.8;
      final textPainter = TextPainter(
        text: TextSpan(
          text: '⚡',
          style: TextStyle(
            fontSize: 16,
            color: Colors.orange.withOpacity(textOpacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(position.dx - textPainter.width / 2, position.dy - 35),
      );
    }
  }

  void _paintFinish(Canvas canvas, ActiveAnimation animation, Size size) {
    final progress = animation.progress(animationValue * animation.duration);
    final position = animation.position;

    // Checkered flag wave
    final flagWidth = 60.0;
    final flagHeight = 40.0;
    final waveAmplitude = 5 + math.sin(progress * math.pi * 4) * 3;

    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 6; col++) {
        final isWhite = (row + col) % 2 == 0;
        final cellWidth = flagWidth / 6;
        final cellHeight = flagHeight / 4;
        
        final waveOffset = math.sin(progress * math.pi * 4 + col * 0.5) * waveAmplitude;
        
        final cellPaint = Paint()
          ..color = (isWhite ? Colors.white : Colors.black)
              .withOpacity((1 - progress * 0.5));

        canvas.drawRect(
          Rect.fromLTWH(
            position.dx - flagWidth / 2 + col * cellWidth,
            position.dy - 50 + row * cellHeight + waveOffset,
            cellWidth,
            cellHeight,
          ),
          cellPaint,
        );
      }
    }
  }

  void _paintCelebration(Canvas canvas, ActiveAnimation animation, Size size) {
    final progress = animation.progress(animationValue * animation.duration);
    final random = math.Random(animation.startTime.toInt());

    // Confetti
    final colors = [
      Colors.pink,
      Colors.cyan,
      Colors.yellow,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    for (var i = 0; i < 50; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = -50.0;
      
      final endX = startX + (random.nextDouble() - 0.5) * 200;
      final endY = size.height + 50;
      
      final particleProgress = (progress + random.nextDouble() * 0.3).clamp(0.0, 1.0);
      
      final x = startX + (endX - startX) * particleProgress;
      final y = startY + (endY - startY) * particleProgress;
      
      final rotation = random.nextDouble() * math.pi * 2 + progress * math.pi * 4;
      
      final confettiPaint = Paint()
        ..color = colors[i % colors.length].withOpacity((1 - particleProgress) * 0.9);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawRect(
        const Rect.fromLTWH(-6, -3, 12, 6),
        confettiPaint,
      );
      canvas.restore();
    }

    // Firework bursts
    for (var burst = 0; burst < 3; burst++) {
      final burstProgress = ((progress - burst * 0.2) * 2).clamp(0.0, 1.0);
      if (burstProgress <= 0) continue;

      final burstX = size.width * (0.2 + burst * 0.3);
      final burstY = size.height * 0.3;

      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6;
        final distance = burstProgress * 80;
        
        final sparkPaint = Paint()
          ..color = colors[burst % colors.length].withOpacity((1 - burstProgress) * 0.8)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(
            burstX + math.cos(angle) * distance * 0.5,
            burstY + math.sin(angle) * distance * 0.5,
          ),
          Offset(
            burstX + math.cos(angle) * distance,
            burstY + math.sin(angle) * distance,
          ),
          sparkPaint,
        );
      }
    }
  }

  void _paintLeaderChange(Canvas canvas, ActiveAnimation animation, Size size) {
    final progress = animation.progress(animationValue * animation.duration);
    final position = animation.position;

    // Crown rising animation
    final crownY = position.dy - 40 - progress * 20;
    final crownScale = 1.0 + math.sin(progress * math.pi) * 0.3;
    
    final crownPaint = Paint()
      ..color = Colors.yellow.withOpacity((1 - progress) * 0.9)
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity((1 - progress) * 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.save();
    canvas.translate(position.dx, crownY);
    canvas.scale(crownScale);

    // Crown shape
    final path = Path();
    path.moveTo(-20, 15);
    path.lineTo(-12, -5);
    path.lineTo(-6, 8);
    path.lineTo(0, -15);
    path.lineTo(6, 8);
    path.lineTo(12, -5);
    path.lineTo(20, 15);
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, crownPaint);
    canvas.restore();

    // Sparkles
    for (var i = 0; i < 6; i++) {
      final sparkAngle = progress * math.pi * 2 + i * math.pi / 3;
      final sparkRadius = 35 + math.sin(progress * math.pi) * 15;
      
      final sparkX = position.dx + math.cos(sparkAngle) * sparkRadius;
      final sparkY = crownY + math.sin(sparkAngle) * sparkRadius * 0.5;
      
      final sparkPaint = Paint()
        ..color = Colors.white.withOpacity((1 - progress) * 0.8);

      _drawStar(canvas, Offset(sparkX, sparkY), 4, sparkPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final point = Offset(
        center.dx + size * math.cos(angle),
        center.dy + size * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RaceEffectsPainter oldDelegate) => true;
}
