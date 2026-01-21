import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../utils/theme.dart';
import 'room_code_display.dart';
import 'player_leaderboard.dart';
import 'tv_focusable.dart';

/// Lobby screen widget with TV remote support
class LobbyScreen extends StatefulWidget {
  final String? roomCode;
  final List<Player> players;
  final VoidCallback onCreateRoom;
  final void Function(GameSettings settings) onStartGame;
  final VoidCallback? onOpenSettings;
  final GameSettings? settings;
  final bool isLoading;
  final TournamentState? tournament; // Active tournament state
  final int raceNumber; // Current race number

  const LobbyScreen({
    super.key,
    this.roomCode,
    required this.players,
    required this.onCreateRoom,
    required this.onStartGame,
    this.onOpenSettings,
    this.settings,
    this.isLoading = false,
    this.tournament,
    this.raceNumber = 0,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final FocusNode _createRoomFocusNode = FocusNode();
  final FocusNode _startGameFocusNode = FocusNode();
  final FocusNode _settingsFocusNode = FocusNode();

  bool get isTournamentInProgress => widget.tournament != null && widget.tournament!.isActive;

  @override
  void initState() {
    super.initState();
    // Request focus on the appropriate button after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestInitialFocus();
    });
  }

  @override
  void didUpdateWidget(LobbyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-request focus when room state changes
    if (oldWidget.roomCode != widget.roomCode || 
        oldWidget.players.length != widget.players.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestInitialFocus();
      });
    }
  }

  void _requestInitialFocus() {
    if (!mounted) return;
    
    if (widget.roomCode == null && !widget.isLoading) {
      // Focus on Create Room button
      _createRoomFocusNode.requestFocus();
    } else if (widget.roomCode != null && widget.players.isNotEmpty) {
      // Focus on Start Game button
      _startGameFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _createRoomFocusNode.dispose();
    _startGameFocusNode.dispose();
    _settingsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Stack(
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
                if (widget.settings != null) _buildGameModeIndicator(),

                const SizedBox(height: 32),

                // Room code or create button
                if (widget.roomCode == null) ...[
                  if (widget.isLoading)
                    const CircularProgressIndicator(color: AppTheme.neonCyan)
                  else
                    TVFocusable(
                      focusNode: _createRoomFocusNode,
                      focusColor: AppTheme.neonCyan,
                      onSelect: widget.onCreateRoom,
                      child: ElevatedButton.icon(
                        onPressed: widget.onCreateRoom,
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
                  
                  RoomCodeDisplay(roomCode: widget.roomCode, showJoinUrl: false),
                  const SizedBox(height: 32),

                  // Tournament standings (if in tournament)
                  if (isTournamentInProgress) ...[
                    _buildTournamentStandings(),
                    const SizedBox(height: 24),
                  ],

                  // Player list
                  PlayerLeaderboard(
                    players: widget.players,
                    bets: const {},
                    participants: const [],
                  ),
                  const SizedBox(height: 32),

                  // Start button or waiting message
                  if (widget.players.isEmpty)
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
                      focusNode: _startGameFocusNode,
                      focusColor: isTournamentInProgress ? AppTheme.neonPurple : AppTheme.neonGreen,
                      onSelect: widget.settings != null ? () => widget.onStartGame(widget.settings!) : null,
                      child: ElevatedButton.icon(
                        onPressed: widget.settings != null ? () => widget.onStartGame(widget.settings!) : null,
                        icon: Text(
                          isTournamentInProgress ? '🏆' : '🏁', 
                          style: const TextStyle(fontSize: 24),
                        ),
                        label: Text(isTournamentInProgress ? 'NEXT RACE' : 'START GAME'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTournamentInProgress ? AppTheme.neonPurple : AppTheme.neonGreen,
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
        if (widget.onOpenSettings != null)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: TVFocusable(
                focusNode: _settingsFocusNode,
                focusColor: AppTheme.neonCyan,
                onSelect: widget.onOpenSettings,
                child: IconButton.filled(
                  onPressed: widget.onOpenSettings,
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
      ),
    );
  }

  Widget _buildTournamentStandings() {
    if (widget.tournament == null) return const SizedBox.shrink();
    
    final standings = List<TournamentStanding>.from(widget.tournament!.standings)
      ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.neonPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonPurple.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'TOURNAMENT STANDINGS',
                style: AppTheme.neonText(
                  color: AppTheme.neonPurple,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🏆', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Race ${widget.raceNumber} of ${widget.tournament!.totalRaces}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // Standings list
          ...standings.asMap().entries.map((entry) {
            final index = entry.key;
            final standing = entry.value;
            
            Color rankColor;
            String medal;
            switch (index) {
              case 0:
                rankColor = AppTheme.neonYellow;
                medal = '🥇';
                break;
              case 1:
                rankColor = Colors.grey[300]!;
                medal = '🥈';
                break;
              case 2:
                rankColor = AppTheme.neonOrange;
                medal = '🥉';
                break;
              default:
                rankColor = Colors.grey;
                medal = '#${index + 1}';
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: index == 0 
                    ? AppTheme.neonYellow.withOpacity(0.1)
                    : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: index == 0 
                    ? Border.all(color: AppTheme.neonYellow.withOpacity(0.5))
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      medal,
                      style: TextStyle(
                        fontSize: index < 3 ? 20 : 14,
                        color: rankColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      standing.playerName,
                      style: TextStyle(
                        color: index == 0 ? AppTheme.neonYellow : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: rankColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${standing.totalPoints} pts',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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

  Widget _buildGameModeIndicator() {
    final mode = widget.settings?.gameMode ?? GameMode.regular;
    
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
      onSelect: widget.onOpenSettings,
      child: GestureDetector(
        onTap: widget.onOpenSettings,
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
