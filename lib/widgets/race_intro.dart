import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Race intro animation with participant showcase and countdown
class RaceIntro extends StatefulWidget {
  final List<Participant> participants;
  final VoidCallback? onComplete;

  const RaceIntro({
    super.key,
    required this.participants,
    this.onComplete,
  });

  @override
  State<RaceIntro> createState() => _RaceIntroState();
}

class _RaceIntroState extends State<RaceIntro>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _countdownController;
  
  int _currentCountdown = 3;
  bool _showGo = false;
  bool _introComplete = false;
  int _currentParticipantIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Intro sequence controller (participant showcase)
    _introController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.participants.length * 400 + 500),
    );
    
    // Countdown controller
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _startSequence();
  }

  void _startSequence() async {
    // Safety check
    if (widget.participants.isEmpty) {
      widget.onComplete?.call();
      return;
    }

    // Brief delay before starting
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Show ALL participants
    for (var i = 0; i < widget.participants.length; i++) {
      if (!mounted) return;
      setState(() => _currentParticipantIndex = i);
      await Future.delayed(const Duration(milliseconds: 400));
    }
    
    // Pause after showcase
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (!mounted) return;
    setState(() => _introComplete = true);
    
    // Full countdown sequence
    for (var i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _currentCountdown = i);
      _countdownController.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 800));
    }
    
    // GO!
    if (!mounted) return;
    setState(() => _showGo = true);
    _countdownController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Complete
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _introController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Stack(
        children: [
          // Background particles
          CustomPaint(
            painter: _IntroBgPainter(
              progress: _introComplete ? _countdownController.value : 0,
            ),
            size: Size.infinite,
          ),
          
          // Participant showcase (before countdown)
          if (!_introComplete)
            _buildParticipantShowcase(),
          
          // Countdown overlay
          if (_introComplete)
            _buildCountdown(),
        ],
      ),
    );
  }

  Widget _buildParticipantShowcase() {
    // Safety check for empty participants
    if (widget.participants.isEmpty) {
      return const Center(
        child: Text(
          'Loading racers...',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    // Ensure index is within bounds
    final safeIndex = _currentParticipantIndex.clamp(0, widget.participants.length - 1);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            "TODAY'S RACERS",
            style: AppTheme.neonText(
              color: AppTheme.neonYellow,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 40),
          
          // Current participant with animation
          TweenAnimationBuilder<double>(
            key: ValueKey(safeIndex),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              final participant = widget.participants[safeIndex];
              final color = _parseColor(participant.color);
              
              return Transform.scale(
                scale: 0.5 + value * 0.5,
                child: Opacity(
                  opacity: value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Large icon
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          participant.icon,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        participant.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: color,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(0.6),
                          ),
                        ),
                        child: Text(
                          participant.type.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          
          // Progress indicator (show all participants)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.participants.asMap().entries.map((entry) {
              final safeCurrentIndex = _currentParticipantIndex.clamp(0, widget.participants.length - 1);
              final isActive = entry.key == safeCurrentIndex;
              final isPast = entry.key < safeCurrentIndex;
              final color = _parseColor(entry.value.color);
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isActive || isPast ? color : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Center(
      child: AnimatedBuilder(
        animation: _countdownController,
        builder: (context, child) {
          final scale = 1.0 + (1 - _countdownController.value) * 0.5;
          final opacity = 1.0 - (_countdownController.value * 0.5);
          
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_showGo) ...[
                    Text(
                      '$_currentCountdown',
                      style: TextStyle(
                        color: _currentCountdown == 1 
                            ? AppTheme.neonPink 
                            : (_currentCountdown == 2 
                                ? AppTheme.neonYellow 
                                : AppTheme.neonCyan),
                        fontSize: 180,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: (_currentCountdown == 1 
                                ? AppTheme.neonPink 
                                : (_currentCountdown == 2 
                                    ? AppTheme.neonYellow 
                                    : AppTheme.neonCyan)).withOpacity(0.8),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'GO!',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 140,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppTheme.neonGreen.withOpacity(0.8),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🏁 🏁 🏁',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.neonCyan;
    }
  }
}

class _IntroBgPainter extends CustomPainter {
  final double progress;
  final math.Random _random = math.Random(42);

  _IntroBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw racing lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2;

    for (var i = 0; i < 20; i++) {
      final y = size.height * (_random.nextDouble() * 0.8 + 0.1);
      final startX = -100.0 + (progress * 200) + i * 50;
      final endX = startX + 80;
      
      canvas.drawLine(
        Offset(startX % size.width, y),
        Offset(endX % size.width, y),
        linePaint,
      );
    }

    // Draw corner decorations
    final cornerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.neonCyan.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, 200, 200));

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(200, 0);
    path.lineTo(0, 200);
    path.close();
    canvas.drawPath(path, cornerPaint);
  }

  @override
  bool shouldRepaint(_IntroBgPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
