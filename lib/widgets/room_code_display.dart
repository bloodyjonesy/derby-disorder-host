import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Displays the room code prominently
class RoomCodeDisplay extends StatelessWidget {
  final String? roomCode;

  const RoomCodeDisplay({super.key, this.roomCode});

  @override
  Widget build(BuildContext context) {
    if (roomCode == null || roomCode!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: AppTheme.neonBox(
        color: AppTheme.neonCyan,
        borderRadius: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ROOM CODE',
            style: AppTheme.neonText(
              color: AppTheme.neonCyan,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            roomCode!,
            style: AppTheme.neonText(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
