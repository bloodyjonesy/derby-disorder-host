import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/socket_service.dart';
import '../widgets/widgets.dart';
import '../graphics/graphics.dart';
import '../utils/theme.dart';

/// Main home screen that manages all game phases
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Connect socket on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocketService>().connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final raceProvider = context.watch<RaceProvider>();

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // Handle global key events for TV navigation
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape ||
                event.logicalKey == LogicalKeyboardKey.goBack) {
              // Handle back navigation if needed
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A2E),
                    Color(0xFF16213E),
                    Color(0xFF0A0A1A),
                  ],
                ),
              ),
            ),

            // Main content based on game state
            _buildContent(roomProvider, raceProvider),

            // Top bar with room code and phase
            if (roomProvider.hasRoom) _buildTopBar(roomProvider),

            // Skip phase button
            if (roomProvider.hasRoom &&
                roomProvider.gameState != GameState.lobby)
              Positioned(
                right: 16,
                bottom: 16,
                child: SkipPhaseButton(
                  onPressed: roomProvider.skipPhase,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(RoomProvider roomProvider, RaceProvider raceProvider) {
    if (!roomProvider.hasRoom || roomProvider.gameState == GameState.lobby) {
      return LobbyScreen(
        roomCode: roomProvider.roomCode,
        players: roomProvider.players,
        onCreateRoom: roomProvider.createRoom,
        onStartGame: roomProvider.startGame,
        isLoading: roomProvider.isLoading,
      );
    }

    switch (roomProvider.gameState) {
      case GameState.paddock:
      case GameState.wager:
      case GameState.sabotage:
        return _buildPaddockView(roomProvider);
      case GameState.racing:
        return _buildRacingView(roomProvider, raceProvider);
      case GameState.results:
        return _buildResultsView(roomProvider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTopBar(RoomProvider roomProvider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RoomCodeDisplay(roomCode: roomProvider.roomCode),
              PhaseIndicator(
                gameState: roomProvider.gameState,
                timer: roomProvider.timer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaddockView(RoomProvider roomProvider) {
    final isSabotage = roomProvider.gameState == GameState.sabotage;
    
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Row(
        children: [
          // Left side - Player bets panel (only during sabotage)
          if (isSabotage)
            Container(
              width: 320,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.neonBox(
                color: AppTheme.neonPink,
                borderRadius: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 TARGET INFO',
                    style: AppTheme.neonText(
                      color: AppTheme.neonPink,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: roomProvider.players.length,
                      itemBuilder: (context, index) {
                        final player = roomProvider.players[index];
                        final bet = roomProvider.getBet(player.id);
                        final betParticipant = bet != null
                            ? roomProvider.getParticipant(bet.participantId)
                            : null;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.neonCyan.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      player.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonGreen.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '\$${player.balance}',
                                      style: TextStyle(
                                        color: player.balance > 0
                                            ? AppTheme.neonGreen
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (bet != null && betParticipant != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      betParticipant.icon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        betParticipant.name,
                                        style: TextStyle(
                                          color: Color(int.parse(
                                            betParticipant.color
                                                .replaceFirst('#', '0xFF'),
                                          )),
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonYellow.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '\$${bet.amount}',
                                        style: const TextStyle(
                                          color: AppTheme.neonYellow,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'No bet placed',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          
          // Center - Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getPhaseMessage(roomProvider.gameState),
                    style: AppTheme.neonText(
                      color: AppTheme.neonPink,
                      fontSize: 32,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Show participants grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: roomProvider.participants.map((participant) {
                      // Count bets on this participant during sabotage
                      final betsOnThis = isSabotage
                          ? roomProvider.players.where((p) {
                              final bet = roomProvider.getBet(p.id);
                              return bet?.participantId == participant.id;
                            }).toList()
                          : <Player>[];
                      
                      return Container(
                        width: 150,
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.neonBox(
                          color: Color(int.parse(
                            participant.color.replaceFirst('#', '0xFF'),
                          )),
                          borderRadius: 12,
                        ),
                        child: Column(
                          children: [
                            Text(
                              participant.icon,
                              style: const TextStyle(fontSize: 48),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              participant.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Show who bet on this participant during sabotage
                            if (isSabotage && betsOnThis.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: betsOnThis.map((player) {
                                    final bet = roomProvider.getBet(player.id);
                                    return Text(
                                      '${player.name}: \$${bet?.amount ?? 0}',
                                      style: const TextStyle(
                                        color: AppTheme.neonYellow,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          // Right side spacer to balance layout during sabotage
          if (isSabotage) const SizedBox(width: 320),
        ],
      ),
    );
  }

  Widget _buildRacingView(RoomProvider roomProvider, RaceProvider raceProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left leaderboard - Players (full height)
          Container(
            margin: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
            child: PlayerLeaderboard(
              players: roomProvider.players,
              bets: roomProvider.room?.bets ?? {},
              participants: roomProvider.participants,
              expandToFill: true,
            ),
          ),

          // Center - Race track
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: RaceView(
                participants: roomProvider.participants,
                positions: raceProvider.positions,
                leaderId: raceProvider.leaderId,
              ),
            ),
          ),

          // Right leaderboard - Race standings (full height)
          Container(
            margin: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
            child: RaceLeaderboard(
              participants: roomProvider.participants,
              positions: raceProvider.positions,
              expandToFill: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(RoomProvider roomProvider) {
    final raceResult = roomProvider.raceResult;
    if (raceResult == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.neonCyan),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaceResultsOverlay(
            raceResult: raceResult,
            participants: roomProvider.participants,
          ),
          const SizedBox(height: 32),
          // Show chaos meter
          ChaosMeter(value: roomProvider.chaosMeter),
        ],
      ),
    );
  }

  String _getPhaseMessage(GameState state) {
    switch (state) {
      case GameState.paddock:
        return 'STUDY THE RACERS!';
      case GameState.wager:
        return 'PLACE YOUR BETS!';
      case GameState.sabotage:
        return 'TIME FOR SABOTAGE!';
      default:
        return '';
    }
  }
}
