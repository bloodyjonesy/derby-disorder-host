import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// An enhanced player card with avatar, rank badge, and stats
class PlayerAvatarCard extends StatefulWidget {
  final Player player;
  final int? rank;
  final String? betInfo;
  final bool isHotSeat;
  final bool isInRivalry;
  final bool isViewer;
  final int animationDelay;

  const PlayerAvatarCard({
    super.key,
    required this.player,
    this.rank,
    this.betInfo,
    this.isHotSeat = false,
    this.isInRivalry = false,
    this.isViewer = false,
    this.animationDelay = 0,
  });

  @override
  State<PlayerAvatarCard> createState() => _PlayerAvatarCardState();
}

class _PlayerAvatarCardState extends State<PlayerAvatarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Staggered animation start
    Future.delayed(Duration(milliseconds: widget.animationDelay * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine accent color based on state
    Color accentColor = AppTheme.neonCyan;
    if (widget.isViewer) {
      accentColor = AppTheme.neonPurple;
    } else if (widget.isHotSeat) {
      accentColor = AppTheme.neonOrange;
    } else if (widget.isInRivalry) {
      accentColor = AppTheme.neonYellow;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildCard(accentColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(Color accentColor) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF0F0F1A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with rank badge
          _buildAvatar(accentColor),
          
          const SizedBox(height: 12),
          
          // Player name
          Text(
            widget.player.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Status badges
          _buildStatusBadges(accentColor),
          
          const SizedBox(height: 8),
          
          // Balance pill
          _buildBalancePill(),
          
          // Bet info if available
          if (widget.betInfo != null) ...[
            const SizedBox(height: 8),
            _buildBetInfo(),
          ],

          // Hype points
          const SizedBox(height: 8),
          _buildHypeBar(),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color accentColor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar circle with glow
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accentColor.withOpacity(0.3),
                Colors.transparent,
              ],
              radius: 1.5,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A3E),
              border: Border.all(
                color: accentColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(widget.player.name),
                style: TextStyle(
                  color: accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Rank badge
        if (widget.rank != null)
          Positioned(
            bottom: -5,
            right: -5,
            child: _buildRankBadge(widget.rank!),
          ),

        // Crown for #1
        if (widget.rank == 1)
          Positioned(
            top: -15,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '👑',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),

        // Hot seat indicator
        if (widget.isHotSeat)
          Positioned(
            top: -5,
            left: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.neonOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonOrange.withOpacity(0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Text('🔥', style: TextStyle(fontSize: 14)),
            ),
          ),

        // Rivalry indicator
        if (widget.isInRivalry)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.neonYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonYellow.withOpacity(0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Text('⚔️', style: TextStyle(fontSize: 12)),
            ),
          ),
      ],
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    String badgeText;

    switch (rank) {
      case 1:
        badgeColor = AppTheme.neonYellow;
        badgeText = '🥇';
        break;
      case 2:
        badgeColor = Colors.grey.shade300;
        badgeText = '🥈';
        break;
      case 3:
        badgeColor = AppTheme.neonOrange;
        badgeText = '🥉';
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = '#$rank';
    }

    if (rank <= 3) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
          border: Border.all(color: badgeColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withOpacity(0.5),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(badgeText, style: const TextStyle(fontSize: 16)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadges(Color accentColor) {
    final badges = <Widget>[];

    if (widget.isViewer) {
      badges.add(_badge('VIEWER', AppTheme.neonPurple));
    }
    if (widget.isHotSeat) {
      badges.add(_badge('HOT SEAT', AppTheme.neonOrange));
    }
    if (widget.isInRivalry) {
      badges.add(_badge('RIVAL', AppTheme.neonYellow));
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: badges,
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBalancePill() {
    final isPositive = widget.player.balance > 0;
    final color = isPositive ? AppTheme.neonGreen : AppTheme.neonRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '\$${widget.player.balance}',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBetInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.betInfo!,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildHypeBar() {
    final hypePercent = (widget.player.hype / 100).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HYPE',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${widget.player.hype}',
              style: TextStyle(
                color: AppTheme.neonPink,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: hypePercent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonPink,
                    AppTheme.neonPurple,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPink.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}

/// A compact player list item for leaderboards
class PlayerListItem extends StatelessWidget {
  final Player player;
  final int rank;
  final String? betInfo;
  final bool isHotSeat;
  final bool isViewer;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.rank,
    this.betInfo,
    this.isHotSeat = false,
    this.isViewer = false,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    String? medal;

    switch (rank) {
      case 1:
        rankColor = AppTheme.neonYellow;
        medal = '🥇';
        break;
      case 2:
        rankColor = Colors.grey.shade300;
        medal = '🥈';
        break;
      case 3:
        rankColor = AppTheme.neonOrange;
        medal = '🥉';
        break;
      default:
        rankColor = Colors.grey;
        medal = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: rank == 1 
            ? AppTheme.neonYellow.withOpacity(0.1) 
            : Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: rank == 1 
            ? Border.all(color: AppTheme.neonYellow.withOpacity(0.3)) 
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 36,
            child: medal != null
                ? Text(medal, style: const TextStyle(fontSize: 20))
                : Text(
                    '#$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A3E),
              border: Border.all(
                color: isHotSeat 
                    ? AppTheme.neonOrange 
                    : isViewer 
                        ? AppTheme.neonPurple 
                        : AppTheme.neonCyan.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _getInitials(player.name),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name and bet
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isHotSeat) const Text('🔥 ', style: TextStyle(fontSize: 12)),
                    if (isViewer) const Text('👁 ', style: TextStyle(fontSize: 12)),
                    Flexible(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          color: rank == 1 ? AppTheme.neonYellow : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (betInfo != null)
                  Text(
                    betInfo!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Balance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: player.balance > 0
                  ? AppTheme.neonGreen.withOpacity(0.15)
                  : AppTheme.neonRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '\$${player.balance}',
              style: TextStyle(
                color: player.balance > 0 ? AppTheme.neonGreen : AppTheme.neonRed,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }
}
