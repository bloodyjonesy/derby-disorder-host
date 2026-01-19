import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Animated punishment wheel that spins and selects a random punishment
class PunishmentWheel extends StatefulWidget {
  final List<String> options;
  final String playerName;
  final VoidCallback? onComplete;

  const PunishmentWheel({
    super.key,
    required this.options,
    required this.playerName,
    this.onComplete,
  });

  @override
  State<PunishmentWheel> createState() => _PunishmentWheelState();
}

class _PunishmentWheelState extends State<PunishmentWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  bool _isSpinning = false;
  bool _hasResult = false;
  int _selectedIndex = 0;
  double _currentRotation = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  void _spin() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _hasResult = false;
    });

    // Calculate random result
    final random = math.Random();
    _selectedIndex = random.nextInt(widget.options.length);
    
    // Calculate rotation - multiple full spins plus landing on selected
    final sectionAngle = 2 * math.pi / widget.options.length;
    final targetAngle = sectionAngle * _selectedIndex;
    final fullSpins = 5 + random.nextInt(3); // 5-7 full spins
    final totalRotation = fullSpins * 2 * math.pi + (2 * math.pi - targetAngle);
    
    _animation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuint,
      ),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        _isSpinning = false;
        _hasResult = true;
        _currentRotation = totalRotation % (2 * math.pi);
      });
      
      // Delay before calling onComplete
      Future.delayed(const Duration(seconds: 3), () {
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              '🎡 PUNISHMENT WHEEL 🎡',
              style: AppTheme.neonText(
                color: AppTheme.neonPink,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 16),
            
            // Player name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.neonYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.neonYellow),
              ),
              child: Text(
                '${widget.playerName} is BROKE!',
                style: const TextStyle(
                  color: AppTheme.neonYellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Wheel
            SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wheel
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final rotation = _isSpinning 
                          ? _animation.value 
                          : _currentRotation;
                      return Transform.rotate(
                        angle: rotation,
                        child: child,
                      );
                    },
                    child: CustomPaint(
                      size: const Size(380, 380),
                      painter: WheelPainter(options: widget.options),
                    ),
                  ),
                  
                  // Center button
                  GestureDetector(
                    onTap: _isSpinning ? null : _spin,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2D2D2D),
                            Color(0xFF1A1A1A),
                          ],
                        ),
                        border: Border.all(color: AppTheme.neonYellow, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonYellow.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isSpinning ? '🌀' : 'SPIN',
                          style: TextStyle(
                            color: AppTheme.neonYellow,
                            fontSize: _isSpinning ? 32 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Pointer at top
                  Positioned(
                    top: -10,
                    child: CustomPaint(
                      size: const Size(30, 40),
                      painter: PointerPainter(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Result
            if (_hasResult)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.neonPink, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPink.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'YOUR FATE:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.options[_selectedIndex],
                            style: const TextStyle(
                              color: AppTheme.neonPink,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<String> options;
  final List<Color> colors = [
    const Color(0xFFE91E63), // Pink
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF4CAF50), // Green
  ];

  WheelPainter({required this.options});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = 2 * math.pi / options.length;

    for (var i = 0; i < options.length; i++) {
      final startAngle = i * sectionAngle - math.pi / 2;
      
      // Section fill
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Section border
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Text
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sectionAngle / 2);
      
      final textSpan = TextSpan(
        text: _getShortLabel(options[i]),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      canvas.translate(radius * 0.65, 0);
      canvas.rotate(math.pi / 2);
      textPainter.paint(
        canvas, 
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }

    // Outer ring
    final outerRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, outerRingPaint);
  }

  String _getShortLabel(String option) {
    // Extract just the text part (remove emoji)
    if (option.contains('shot')) return 'SHOT';
    if (option.contains('Finish')) return 'FINISH IT';
    if (option.contains('Nominate')) return 'NOMINATE';
    if (option.contains('friend')) return 'CHEERS';
    return option.split(' ').take(2).join(' ');
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) => false;
}

class PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    final paint = Paint()
      ..color = AppTheme.neonYellow
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(PointerPainter oldDelegate) => false;
}
