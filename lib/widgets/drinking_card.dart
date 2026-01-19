import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Animated drinking card reveal
class DrinkingCardReveal extends StatefulWidget {
  final DrinkingCard card;
  final VoidCallback? onComplete;

  const DrinkingCardReveal({
    super.key,
    required this.card,
    this.onComplete,
  });

  @override
  State<DrinkingCardReveal> createState() => _DrinkingCardRevealState();
}

class _DrinkingCardRevealState extends State<DrinkingCardReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _flipAnimation = Tween<double>(begin: math.pi, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward().then((_) {
          setState(() => _isRevealed = true);
          Future.delayed(const Duration(seconds: 3), () {
            widget.onComplete?.call();
          });
        });
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
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_flipAnimation.value),
                child: _flipAnimation.value > math.pi / 2
                    ? _buildCardBack()
                    : _buildCardFront(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 300,
      height: 420,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonYellow, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonYellow.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🃏', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              'RULE CARD',
              style: AppTheme.neonText(
                color: AppTheme.neonYellow,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    final typeColor = _getTypeColor(widget.card.type);
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 300,
          height: 420,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                typeColor.withOpacity(0.3),
                Colors.black.withOpacity(0.9),
                typeColor.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: typeColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: typeColor.withOpacity(_glowAnimation.value * 0.6),
                blurRadius: 30 * _glowAnimation.value,
                spreadRadius: 10 * _glowAnimation.value,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: typeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    _getTypeLabel(widget.card.type),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Emoji
                Text(
                  widget.card.emoji,
                  style: const TextStyle(fontSize: 70),
                ),
                
                const SizedBox(height: 16),
                
                // Title
                Text(
                  widget.card.title,
                  style: AppTheme.neonText(
                    color: typeColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  widget.card.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Decorative line
                Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: typeColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(DrinkingCardType type) {
    switch (type) {
      case DrinkingCardType.betting:
        return AppTheme.neonYellow;
      case DrinkingCardType.duringRace:
        return AppTheme.neonCyan;
      case DrinkingCardType.raceEnd:
        return AppTheme.neonPink;
    }
  }

  String _getTypeLabel(DrinkingCardType type) {
    switch (type) {
      case DrinkingCardType.betting:
        return '🎰 BETTING RULE';
      case DrinkingCardType.duringRace:
        return '🏃 RACE RULE';
      case DrinkingCardType.raceEnd:
        return '🏁 RESULTS RULE';
    }
  }
}

/// Compact card display for showing active rule
class ActiveRuleCard extends StatelessWidget {
  final DrinkingCard card;

  const ActiveRuleCard({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(card.type);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(card.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                card.title,
                style: TextStyle(
                  color: typeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                card.description,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(DrinkingCardType type) {
    switch (type) {
      case DrinkingCardType.betting:
        return AppTheme.neonYellow;
      case DrinkingCardType.duringRace:
        return AppTheme.neonCyan;
      case DrinkingCardType.raceEnd:
        return AppTheme.neonPink;
    }
  }
}
