import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Enhanced participant card for the paddock/betting phase
class ParticipantCard extends StatefulWidget {
  final Participant participant;
  final int betCount; // How many players bet on this
  final int totalBetAmount; // Total amount bet on this
  final bool isCrowdFavorite; // Has the most bets
  final bool isUnderdog; // Has the least bets
  final bool isFavorite; // Is the race favorite (best stats)
  final int animationDelay; // Stagger animation

  const ParticipantCard({
    super.key,
    required this.participant,
    this.betCount = 0,
    this.totalBetAmount = 0,
    this.isCrowdFavorite = false,
    this.isUnderdog = false,
    this.isFavorite = false,
    this.animationDelay = 0,
  });

  @override
  State<ParticipantCard> createState() => _ParticipantCardState();
}

class _ParticipantCardState extends State<ParticipantCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _statAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _statAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Stagger the entrance animation
    Future.delayed(Duration(milliseconds: widget.animationDelay * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _participantColor {
    try {
      return Color(int.parse(
        widget.participant.color.replaceFirst('#', '0xFF'),
      ));
    } catch (_) {
      return AppTheme.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _buildCard(),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _participantColor.withOpacity(0.6),
          width: widget.isCrowdFavorite ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _participantColor.withOpacity(widget.isCrowdFavorite ? 0.4 : 0.2),
            blurRadius: widget.isCrowdFavorite ? 20 : 10,
            spreadRadius: widget.isCrowdFavorite ? 4 : 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with badges
          _buildHeader(),
          
          // Icon and name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Text(
                  widget.participant.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.participant.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: _participantColor.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _buildStats(),
          ),
          
          // Bet info
          if (widget.betCount > 0) _buildBetInfo(),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.isFavorite 
            ? [AppTheme.neonGreen.withOpacity(0.5), AppTheme.neonGreen.withOpacity(0.2)]
            : [_participantColor.withOpacity(0.4), _participantColor.withOpacity(0.2)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          // FAVORITE badge - prominent display
          if (widget.isFavorite)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonGreen, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⭐', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text(
                    'FAVORITE',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('⭐', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Type badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.participant.type.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.isCrowdFavorite && !widget.isFavorite) ...[
                const SizedBox(width: 6),
                const Text('🔥', style: TextStyle(fontSize: 14)),
              ],
              if (widget.isUnderdog) ...[
                const SizedBox(width: 6),
                const Text('🐴', style: TextStyle(fontSize: 14)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return AnimatedBuilder(
      animation: _statAnimation,
      builder: (context, child) {
        return Column(
          children: [
            _buildStatBar('⚡ Speed', widget.participant.zoomies, AppTheme.neonYellow),
            const SizedBox(height: 4),
            _buildStatBar('💪 Stamina', widget.participant.chonk, AppTheme.neonGreen),
            const SizedBox(height: 4),
            _buildStatBar('🎲 Chaos', widget.participant.derp, AppTheme.neonPink),
          ],
        );
      },
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    final animatedValue = value * _statAnimation.value;
    
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Background
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Fill
              FractionallySizedBox(
                widthFactor: animatedValue / 10,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.8),
                        color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 16,
          child: Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBetInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.neonYellow.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💰', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '${widget.betCount} bet${widget.betCount > 1 ? 's' : ''} • \$${widget.totalBetAmount}',
            style: const TextStyle(
              color: AppTheme.neonYellow,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated phase title widget
class PhaseTitle extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const PhaseTitle({
    super.key,
    required this.title,
    this.subtitle = '',
    this.icon,
  });

  @override
  State<PhaseTitle> createState() => _PhaseTitleState();
}

class _PhaseTitleState extends State<PhaseTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
          scale: _pulseAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: AppTheme.neonText(
                  color: AppTheme.neonPink,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
