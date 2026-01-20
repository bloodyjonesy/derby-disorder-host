import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Dramatic overlay for chaos events during races
class ChaosEventOverlay extends StatefulWidget {
  final ChaosEvent event;
  final VoidCallback? onDismiss;

  const ChaosEventOverlay({
    super.key,
    required this.event,
    this.onDismiss,
  });

  @override
  State<ChaosEventOverlay> createState() => _ChaosEventOverlayState();
}

class _ChaosEventOverlayState extends State<ChaosEventOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    final duration = widget.event.duration ?? 3;
    
    _controller = AnimationController(
      duration: Duration(seconds: duration),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.1), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8), weight: 10),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getEventColor() {
    if (widget.event.isMaxChaos) return AppTheme.neonRed;
    if (widget.event.isHighIntensity) return AppTheme.neonOrange;
    if (widget.event.intensity >= 0.5) return AppTheme.neonYellow;
    return AppTheme.neonCyan;
  }

  String _getEventEmoji() {
    switch (widget.event.type.toLowerCase()) {
      case 'speed_boost':
        return '⚡';
      case 'stumble':
        return '🤪';
      case 'banana':
        return '🍌';
      case 'wind':
        return '💨';
      case 'meteor':
        return '☄️';
      case 'crowd':
        return '📣';
      case 'max_chaos':
        return '🌪️';
      default:
        return '⚠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getEventColor();
    final emoji = _getEventEmoji();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: color.withOpacity(0.1 * widget.event.intensity * _opacityAnimation.value),
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 30 * widget.event.intensity,
                            spreadRadius: 10 * widget.event.intensity,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Emoji
                          Text(
                            emoji,
                            style: TextStyle(
                              fontSize: 64 + (20 * widget.event.intensity),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Title
                          Text(
                            widget.event.isMaxChaos 
                                ? '🌪️ MAX CHAOS! 🌪️'
                                : 'CHAOS EVENT!',
                            style: AppTheme.neonText(
                              color: color,
                              fontSize: widget.event.isMaxChaos ? 36 : 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Message
                          Text(
                            widget.event.message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          // Intensity bar
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: widget.event.intensity,
                              backgroundColor: AppTheme.surfaceColor,
                              valueColor: AlwaysStoppedAnimation(color),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
