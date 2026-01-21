import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// A dramatic confetti celebration overlay for race winners
class ConfettiCelebration extends StatefulWidget {
  final Widget? child;
  final bool isActive;
  final Duration duration;
  final VoidCallback? onComplete;

  const ConfettiCelebration({
    super.key,
    this.child,
    this.isActive = false,
    this.duration = const Duration(seconds: 5),
    this.onComplete,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();

  static const List<Color> _confettiColors = [
    AppTheme.neonCyan,
    AppTheme.neonPink,
    AppTheme.neonYellow,
    AppTheme.neonGreen,
    AppTheme.neonOrange,
    Colors.white,
    Color(0xFFFF6B6B), // Coral
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE66D), // Bright yellow
    Color(0xFFA855F7), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.addListener(() {
      _updateParticles();
    });
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startCelebration();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopCelebration();
    }
  }

  void _startCelebration() {
    _particles.clear();
    _generateParticles();
    _controller.forward(from: 0);
  }

  void _stopCelebration() {
    _controller.stop();
    _particles.clear();
    setState(() {});
  }

  void _generateParticles() {
    for (int i = 0; i < 150; i++) {
      _particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5,
        size: 8 + _random.nextDouble() * 12,
        color: _confettiColors[_random.nextInt(_confettiColors.length)],
        velocity: 0.5 + _random.nextDouble() * 1.0,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        horizontalDrift: (_random.nextDouble() - 0.5) * 0.3,
        shape: ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)],
        delay: _random.nextDouble() * 0.3,
      ));
    }
  }

  void _updateParticles() {
    if (!mounted) return;
    setState(() {
      for (final particle in _particles) {
        final progress = _controller.value;
        if (progress > particle.delay) {
          final adjustedProgress = (progress - particle.delay) / (1 - particle.delay);
          particle.currentY = particle.y + adjustedProgress * particle.velocity * 2;
          particle.currentX = particle.x + sin(adjustedProgress * 10) * particle.horizontalDrift;
          particle.rotation += particle.rotationSpeed * 0.1;
          particle.opacity = 1.0 - (adjustedProgress * 0.5).clamp(0, 1);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.child != null) widget.child!,
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: CelebrationConfettiPainter(
                  particles: _particles,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

enum ConfettiShape { rectangle, circle, strip }

class ConfettiParticle {
  double x;
  double y;
  double currentX;
  double currentY;
  double size;
  Color color;
  double velocity;
  double rotation;
  double rotationSpeed;
  double horizontalDrift;
  ConfettiShape shape;
  double delay;
  double opacity;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.velocity,
    required this.rotationSpeed,
    required this.horizontalDrift,
    required this.shape,
    required this.delay,
  })  : currentX = x,
        currentY = y,
        rotation = 0,
        opacity = 1.0;
}

class CelebrationConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  CelebrationConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.currentY > 1.5 || particle.opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      final centerX = particle.currentX * size.width;
      final centerY = particle.currentY * size.height;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(particle.rotation);

      switch (particle.shape) {
        case ConfettiShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6,
            ),
            paint,
          );
          break;
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case ConfettiShape.strip:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 0.3,
              height: particle.size * 1.5,
            ),
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CelebrationConfettiPainter oldDelegate) => true;
}

/// Animated victory text with glow effect
class VictoryText extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;

  const VictoryText({
    super.key,
    required this.text,
    this.color = AppTheme.neonYellow,
    this.fontSize = 48,
  });

  @override
  State<VictoryText> createState() => _VictoryTextState();
}

class _VictoryTextState extends State<VictoryText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    _glowAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                widget.color,
                widget.color.withOpacity(0.8),
                Colors.white,
                widget.color.withOpacity(0.8),
                widget.color,
              ],
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            ).createShader(bounds),
            child: Text(
              widget.text,
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: widget.color.withOpacity(_glowAnimation.value),
                    blurRadius: 20 + _glowAnimation.value * 30,
                  ),
                  Shadow(
                    color: widget.color.withOpacity(_glowAnimation.value * 0.5),
                    blurRadius: 40 + _glowAnimation.value * 40,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated medal/trophy display
class AnimatedTrophy extends StatefulWidget {
  final int rank;
  final double size;

  const AnimatedTrophy({
    super.key,
    required this.rank,
    this.size = 80,
  });

  @override
  State<AnimatedTrophy> createState() => _AnimatedTrophyState();
}

class _AnimatedTrophyState extends State<AnimatedTrophy>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bounceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.1),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.1, end: -0.1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0),
        weight: 25,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _emoji {
    switch (widget.rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏅';
    }
  }

  Color get _glowColor {
    switch (widget.rank) {
      case 1:
        return AppTheme.neonYellow;
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppTheme.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _glowColor.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _emoji,
                  style: TextStyle(fontSize: widget.size * 0.7),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sparkle effect overlay
class SparkleOverlay extends StatefulWidget {
  final Widget child;
  final bool isActive;

  const SparkleOverlay({
    super.key,
    required this.child,
    this.isActive = true,
  });

  @override
  State<SparkleOverlay> createState() => _SparkleOverlayState();
}

class _SparkleOverlayState extends State<SparkleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Sparkle> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _generateSparkles();

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _generateSparkles() {
    for (int i = 0; i < 20; i++) {
      _sparkles.add(Sparkle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 4 + _random.nextDouble() * 8,
        delay: _random.nextDouble(),
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SparklePainter(
                  sparkles: _sparkles,
                  progress: _controller.value,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class Sparkle {
  final double x;
  final double y;
  final double size;
  final double delay;

  Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
  });
}

class SparklePainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final double progress;

  SparklePainter({required this.sparkles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final adjustedProgress = (progress + sparkle.delay) % 1.0;
      final opacity = sin(adjustedProgress * pi);

      if (opacity > 0) {
        final paint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.8)
          ..style = PaintingStyle.fill;

        final x = sparkle.x * size.width;
        final y = sparkle.y * size.height;

        // Draw 4-point star
        final path = Path();
        final s = sparkle.size * (0.5 + opacity * 0.5);

        path.moveTo(x, y - s);
        path.lineTo(x + s * 0.3, y);
        path.lineTo(x, y + s);
        path.lineTo(x - s * 0.3, y);
        path.close();

        path.moveTo(x - s, y);
        path.lineTo(x, y + s * 0.3);
        path.lineTo(x + s, y);
        path.lineTo(x, y - s * 0.3);
        path.close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
