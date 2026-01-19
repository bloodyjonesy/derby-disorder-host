import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Displays the current hot seat player
class HotSeatIndicator extends StatefulWidget {
  final String playerName;
  final bool isCompact;

  const HotSeatIndicator({
    super.key,
    required this.playerName,
    this.isCompact = false,
  });

  @override
  State<HotSeatIndicator> createState() => _HotSeatIndicatorState();
}

class _HotSeatIndicatorState extends State<HotSeatIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompact();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = math.sin(_controller.value * 2 * math.pi) * 0.1 + 1.0;
        final glowIntensity = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;

        return Transform.scale(
          scale: pulse,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.neonOrange.withOpacity(0.3),
                  Colors.red.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.neonOrange,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonOrange.withOpacity(glowIntensity * 0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fire animation
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFlame(0),
                    const SizedBox(width: 8),
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 8),
                    _buildFlame(0.5),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Title
                Text(
                  'HOT SEAT',
                  style: AppTheme.neonText(
                    color: AppTheme.neonOrange,
                    fontSize: 20,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Player name
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Rule
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Must bet on the FAVORITE!\nIf they lose, take a drink! 🍺',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompact() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowIntensity = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.neonOrange.withOpacity(0.3),
                Colors.red.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.neonOrange.withOpacity(0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonOrange.withOpacity(glowIntensity * 0.4),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'HOT SEAT: ${widget.playerName}',
                style: const TextStyle(
                  color: AppTheme.neonOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlame(double offset) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final flicker = math.sin((_controller.value + offset) * 4 * math.pi) * 5;
        return Transform.translate(
          offset: Offset(0, flicker),
          child: const Text('🔥', style: TextStyle(fontSize: 20)),
        );
      },
    );
  }
}

/// Hot seat announcement overlay
class HotSeatAnnouncement extends StatefulWidget {
  final String playerName;
  final VoidCallback? onComplete;

  const HotSeatAnnouncement({
    super.key,
    required this.playerName,
    this.onComplete,
  });

  @override
  State<HotSeatAnnouncement> createState() => _HotSeatAnnouncementState();
}

class _HotSeatAnnouncementState extends State<HotSeatAnnouncement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.1), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: -0.05), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -0.05, end: 0.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 70),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete?.call());
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
          scale: _scaleAnimation.value.clamp(0.0, 2.0),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Fire emojis ring
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🔥', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 8),
                    Text('🔥', style: TextStyle(fontSize: 40)),
                    SizedBox(width: 8),
                    Text('🔥', style: TextStyle(fontSize: 40)),
                  ],
                ),
                const SizedBox(height: 16),
                
                Text(
                  'HOT SEAT',
                  style: AppTheme.neonText(
                    color: AppTheme.neonOrange,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: AppTheme.neonOrange.withOpacity(0.8),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppTheme.neonOrange, width: 2),
                  ),
                  child: Text(
                    widget.playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'Must bet on the favorite!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
