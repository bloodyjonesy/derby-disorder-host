import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'room_code_display.dart';
import 'player_leaderboard.dart';
import 'tv_focusable.dart';

/// Lobby screen widget with TV remote support
class LobbyScreen extends StatelessWidget {
  final String? roomCode;
  final List<Player> players;
  final VoidCallback onCreateRoom;
  final void Function(GameSettings settings) onStartGame;
  final VoidCallback? onOpenSettings;
  final GameSettings? settings;
  final bool isLoading;

  const LobbyScreen({
    super.key,
    this.roomCode,
    required this.players,
    required this.onCreateRoom,
    required this.onStartGame,
    this.onOpenSettings,
    this.settings,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'DERBY DISORDER',
                  style: AppTheme.neonText(
                    color: AppTheme.neonPink,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'THE CHAOS CUP',
                  style: AppTheme.neonText(
                    color: AppTheme.neonCyan,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Game mode indicator
                if (settings != null) _buildGameModeIndicator(),

                const SizedBox(height: 32),

                // Room code or create button
                if (roomCode == null) ...[
                  if (isLoading)
                    const CircularProgressIndicator(color: AppTheme.neonCyan)
                  else
                    TVFocusable(
                      autofocus: true,
                      focusColor: AppTheme.neonCyan,
                      onSelect: onCreateRoom,
                      child: ElevatedButton.icon(
                        onPressed: onCreateRoom,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('CREATE ROOM'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonCyan,
                          foregroundColor: AppTheme.darkBackground,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ] else ...[
                  // Join instructions
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.neonYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neonYellow.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '📱 Players join at:',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ddcc.pw',
                          style: AppTheme.neonText(
                            color: AppTheme.neonYellow,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  RoomCodeDisplay(roomCode: roomCode, showJoinUrl: false),
                  const SizedBox(height: 32),

                  // Player list
                  PlayerLeaderboard(
                    players: players,
                    bets: const {},
                    participants: const [],
                  ),
                  const SizedBox(height: 32),

                  // Start button or waiting message
                  if (players.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Waiting for players to join...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    TVFocusable(
                      autofocus: true,
                      focusColor: AppTheme.neonGreen,
                      onSelect: settings != null ? () => onStartGame(settings!) : null,
                      child: ElevatedButton.icon(
                        onPressed: settings != null ? () => onStartGame(settings!) : null,
                        icon: const Text('🏁', style: TextStyle(fontSize: 24)),
                        label: const Text('START GAME'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          foregroundColor: AppTheme.darkBackground,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),

        // Settings button (top right)
        if (onOpenSettings != null)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TVFocusable(
                focusColor: AppTheme.neonCyan,
                onSelect: onOpenSettings,
                child: IconButton.filled(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColor,
                    foregroundColor: AppTheme.neonCyan,
                    padding: const EdgeInsets.all(16),
                  ),
                  tooltip: 'Game Settings',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameModeIndicator() {
    final mode = settings?.gameMode ?? GameMode.regular;
    
    Color color;
    String label;
    String emoji;
    
    switch (mode) {
      case GameMode.regular:
        color = AppTheme.neonCyan;
        label = 'REGULAR MODE';
        emoji = '🏇';
        break;
      case GameMode.party:
        color = AppTheme.neonPink;
        label = 'PARTY MODE';
        emoji = '🎉';
        break;
      case GameMode.custom:
        color = AppTheme.neonYellow;
        label = 'CUSTOM MODE';
        emoji = '🔧';
        break;
    }

    return TVFocusable(
      focusColor: color,
      onSelect: onOpenSettings,
      child: GestureDetector(
        onTap: onOpenSettings,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
