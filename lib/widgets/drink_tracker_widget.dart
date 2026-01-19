import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays the drink tracker leaderboard
class DrinkTrackerWidget extends StatelessWidget {
  final DrinkTracker tracker;
  final List<Player> players;
  final bool compact;

  const DrinkTrackerWidget({
    super.key,
    required this.tracker,
    required this.players,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => tracker.getDrinks(b.id).compareTo(tracker.getDrinks(a.id)));

    if (compact) {
      return _buildCompact(sortedPlayers);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: AppTheme.neonBox(
        color: AppTheme.neonPink,
        borderRadius: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.neonPink.withOpacity(0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Text('🍺', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  'DRINK TRACKER',
                  style: AppTheme.neonText(
                    color: AppTheme.neonPink,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getTotalDrinks()} total',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Players list
          if (sortedPlayers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No drinks yet!',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedPlayers.length,
              itemBuilder: (context, index) {
                final player = sortedPlayers[index];
                final drinks = tracker.getDrinks(player.id);
                final isLeader = index == 0 && drinks > 0;
                final isSober = drinks == 0;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLeader
                        ? AppTheme.neonPink.withOpacity(0.2)
                        : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: isLeader
                        ? Border.all(color: AppTheme.neonPink.withOpacity(0.5))
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Rank
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isLeader ? AppTheme.neonPink : Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Trophy for leader
                      if (isLeader) ...[
                        const Text('🏆', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                      ],

                      // Player name
                      Expanded(
                        child: Text(
                          player.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isLeader ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),

                      // Drink count
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...List.generate(
                            drinks.clamp(0, 5),
                            (_) => const Padding(
                              padding: EdgeInsets.only(right: 2),
                              child: Text('🍺', style: TextStyle(fontSize: 14)),
                            ),
                          ),
                          if (drinks > 5)
                            Text(
                              '+${drinks - 5}',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          if (isSober)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.neonGreen.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'SOBER',
                                style: TextStyle(
                                  color: AppTheme.neonGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCompact(List<Player> sortedPlayers) {
    final leader = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;
    final leaderDrinks = leader != null ? tracker.getDrinks(leader.id) : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.neonPink.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonPink.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🍺', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          if (leader != null && leaderDrinks > 0) ...[
            Text(
              '${leader.name}: $leaderDrinks',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            const Text('🏆', style: TextStyle(fontSize: 12)),
          ] else
            const Text(
              'All sober!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  int _getTotalDrinks() {
    int total = 0;
    for (final player in players) {
      total += tracker.getDrinks(player.id);
    }
    return total;
  }
}

/// Drink event notification widget
class DrinkEventNotification extends StatefulWidget {
  final String playerName;
  final String reason;
  final int drinks;
  final VoidCallback? onComplete;

  const DrinkEventNotification({
    super.key,
    required this.playerName,
    required this.reason,
    this.drinks = 1,
    this.onComplete,
  });

  @override
  State<DrinkEventNotification> createState() => _DrinkEventNotificationState();
}

class _DrinkEventNotificationState extends State<DrinkEventNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
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
        return Opacity(
          opacity: _opacityAnimation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value.clamp(0.0, 2.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.neonPink.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonPink.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      widget.drinks,
                      (_) => const Text('🍺', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.playerName} DRINKS!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.reason,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
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
