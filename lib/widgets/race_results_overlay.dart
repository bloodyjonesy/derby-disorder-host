import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

/// Displays race results overlay
class RaceResultsOverlay extends StatelessWidget {
  final RaceResult raceResult;
  final List<Participant> participants;

  const RaceResultsOverlay({
    super.key,
    required this.raceResult,
    required this.participants,
  });

  Participant? _getParticipant(String id) {
    try {
      return participants.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topThree = raceResult.finishOrder.take(3).toList();

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.neonBox(
        color: AppTheme.neonYellow,
        borderRadius: 16,
        glowSpread: 8,
        glowBlur: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🏆 RACE RESULTS 🏆',
            style: AppTheme.neonText(
              color: AppTheme.neonYellow,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Top 3 finishers
          ...topThree.asMap().entries.map((entry) {
            final index = entry.key;
            final participantId = entry.value;
            final participant = _getParticipant(participantId);

            if (participant == null) return const SizedBox.shrink();

            final medals = ['🥇', '🥈', '🥉'];
            final colors = [
              AppTheme.neonYellow,
              AppTheme.neonCyan,
              AppTheme.neonOrange,
            ];

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors[index].withOpacity(0.5),
                  width: index == 0 ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    medals[index],
                    style: TextStyle(fontSize: index == 0 ? 40 : 32),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    participant.icon,
                    style: TextStyle(fontSize: index == 0 ? 40 : 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${index + 1}',
                          style: TextStyle(
                            color: colors[index],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          participant.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: index == 0 ? 20 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
