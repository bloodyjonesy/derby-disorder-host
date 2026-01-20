import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/socket_service.dart';
import '../widgets/widgets.dart';
import '../widgets/cheer_animation.dart';
import '../graphics/graphics.dart';
import '../utils/theme.dart';
import 'settings_screen.dart';

/// Main home screen that manages all game phases
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRaceIntro = false;
  bool _raceIntroComplete = false;
  bool _showSettings = false;
  bool _partyFeaturesInitialized = false; // Track if party features initialized this round
  GameState? _lastGameState;

  @override
  void initState() {
    super.initState();
    // Connect socket on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocketService>().connect();
    });
  }

  void _openSettings() {
    setState(() => _showSettings = true);
  }

  void _closeSettings() {
    setState(() => _showSettings = false);
  }

  void _saveSettings(GameSettings newSettings) {
    context.read<SettingsProvider>().updateSettings(newSettings);
    setState(() => _showSettings = false);
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<RoomProvider>();
    final raceProvider = context.watch<RaceProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final partyProvider = context.watch<PartyProvider>();

    // Sync hot seat with server (if available)
    if (roomProvider.room?.hotSeatPlayerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          partyProvider.syncHotSeat(roomProvider.room?.hotSeatPlayerId);
        }
      });
    }

    // Show settings screen
    if (_showSettings) {
      return Scaffold(
        body: SettingsScreen(
          initialSettings: settingsProvider.settings,
          onSave: _saveSettings,
          onCancel: _closeSettings,
        ),
      );
    }

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
            _buildContent(roomProvider, raceProvider, settingsProvider, partyProvider),

            // Top bar with room code and phase
            if (roomProvider.hasRoom) _buildTopBar(roomProvider, settingsProvider, partyProvider),

            // Skip phase button (not during racing or lobby)
            if (roomProvider.hasRoom &&
                roomProvider.gameState != GameState.lobby &&
                roomProvider.gameState != GameState.racing)
              Positioned(
                right: 16,
                bottom: 16,
                child: SkipPhaseButton(
                  onPressed: roomProvider.skipPhase,
                ),
              ),

            // Party feature overlays
            ..._buildPartyOverlays(partyProvider, roomProvider, settingsProvider),

            // Chaos event overlay (v2)
            if (roomProvider.currentChaosEvent != null)
              ChaosEventOverlay(
                event: roomProvider.currentChaosEvent!,
                onDismiss: roomProvider.clearChaosEvent,
              ),

            // Tournament champion celebration overlay (v2)
            if (roomProvider.tournamentChampionId != null && roomProvider.tournament != null)
              _buildChampionCelebration(roomProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildChampionCelebration(RoomProvider roomProvider) {
    final tournament = roomProvider.tournament!;
    final championStanding = tournament.standings.where(
      (s) => s.playerId == roomProvider.tournamentChampionId
    ).firstOrNull;
    
    if (championStanding == null) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              Text(
                'TOURNAMENT CHAMPION!',
                style: AppTheme.neonText(
                  color: AppTheme.neonYellow,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '👑 ${championStanding.playerName} 👑',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${championStanding.totalPoints} Points • ${championStanding.raceWins} Wins • \$${championStanding.totalEarnings} Earned',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 40),
              TournamentStandings(
                tournament: tournament,
                showChampion: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPartyOverlays(
    PartyProvider partyProvider,
    RoomProvider roomProvider,
    SettingsProvider settingsProvider,
  ) {
    final overlays = <Widget>[];

    // Punishment wheel overlay
    if (partyProvider.showPunishmentWheel && partyProvider.wheelPlayerName != null) {
      overlays.add(
        Positioned.fill(
          child: PunishmentWheel(
            options: settingsProvider.settings.punishmentOptions,
            playerName: partyProvider.wheelPlayerName!,
            onComplete: () => partyProvider.dismissPunishmentWheel(settingsProvider.settings),
          ),
        ),
      );
    }

    // Drinking card reveal overlay - show during PADDOCK phase
    if (partyProvider.showDrinkingCard && partyProvider.currentCard != null) {
      overlays.add(
        Positioned.fill(
          child: DrinkingCardReveal(
            card: partyProvider.currentCard!,
            onComplete: partyProvider.dismissDrinkingCard,
          ),
        ),
      );
    }

    // Hot seat announcement overlay - show during PADDOCK phase (before betting)
    if (partyProvider.showHotSeatAnnouncement && partyProvider.hotSeat.currentPlayerId != null) {
      final hotSeatPlayer = roomProvider.players.where(
        (p) => p.id == partyProvider.hotSeat.currentPlayerId,
      ).firstOrNull;
      
      if (hotSeatPlayer != null) {
        overlays.add(
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: HotSeatAnnouncement(
                  playerName: hotSeatPlayer.name,
                  onComplete: partyProvider.dismissHotSeatAnnouncement,
                ),
              ),
            ),
          ),
        );
      }
    }

    // Rivalry result overlay - show during RESULTS phase
    if (partyProvider.showRivalryResult && partyProvider.currentRivalry != null) {
      final rivalry = partyProvider.currentRivalry!;
      final player1 = roomProvider.players.where((p) => p.id == rivalry.player1Id).firstOrNull;
      final player2 = roomProvider.players.where((p) => p.id == rivalry.player2Id).firstOrNull;
      
      if (player1 != null && player2 != null) {
        overlays.add(
          Positioned.fill(
            child: GestureDetector(
              onTap: partyProvider.dismissRivalryResult,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: RivalryDisplay(
                    rivalry: rivalry,
                    player1: player1,
                    player2: player2,
                    showResult: true,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return overlays;
  }

  Widget _buildContent(
    RoomProvider roomProvider, 
    RaceProvider raceProvider,
    SettingsProvider settingsProvider,
    PartyProvider partyProvider,
  ) {
    // Detect when we transition to PADDOCK phase (start of new round)
    // This is when we should initialize party features BEFORE betting
    if (roomProvider.gameState == GameState.paddock && _lastGameState != GameState.paddock) {
      _partyFeaturesInitialized = false; // Reset for new round
      
      // Start party features for new race (BEFORE betting)
      // Schedule after build to avoid calling notifyListeners during build
      if (settingsProvider.isPartyMode && !_partyFeaturesInitialized) {
        _partyFeaturesInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final playerIds = roomProvider.players.map((p) => p.id).toList();
            partyProvider.startNewRace(playerIds, settingsProvider.settings);
          }
        });
      }
    }

    // Detect when we transition to racing phase
    if (roomProvider.gameState == GameState.racing && _lastGameState != GameState.racing) {
      _showRaceIntro = true;
      _raceIntroComplete = false;
      // Pause race updates during intro - schedule after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          raceProvider.pause();
        }
      });
    }
    
    // Reset intro state and party features flag when going back to lobby or results
    if (roomProvider.gameState == GameState.lobby || roomProvider.gameState == GameState.results) {
      _showRaceIntro = false;
      _raceIntroComplete = false;
      // Reset party features flag so next round can initialize
      if (roomProvider.gameState == GameState.results) {
        _partyFeaturesInitialized = false;
      }
    }
    
    _lastGameState = roomProvider.gameState;

    if (!roomProvider.hasRoom || roomProvider.gameState == GameState.lobby) {
      return LobbyScreen(
        roomCode: roomProvider.roomCode,
        players: roomProvider.players,
        onCreateRoom: roomProvider.createRoom,
        onStartGame: (settings) => roomProvider.startGame(
          settings: {
            'maxRaces': settings.maxRaces,
            'startingBalance': settings.startingBalance,
            'tournamentMode': settings.tournamentMode,
            'tournamentRaces': settings.tournamentRaces,
          },
        ),
        onOpenSettings: _openSettings,
        settings: settingsProvider.settings,
        isLoading: roomProvider.isLoading,
        tournament: roomProvider.tournament,
        raceNumber: roomProvider.raceNumber,
      );
    }

    switch (roomProvider.gameState) {
      case GameState.paddock:
      case GameState.wager:
      case GameState.sabotage:
        return _buildPaddockView(roomProvider, settingsProvider, partyProvider);
      case GameState.racing:
        // Show intro first, then race
        if (_showRaceIntro && !_raceIntroComplete) {
          return RaceIntro(
            participants: roomProvider.participants,
            onComplete: () {
              // Start race fresh when intro completes
              final participantIds = roomProvider.participants.map((p) => p.id).toList();
              raceProvider.startFresh(participantIds);
              
              // Tell server to start emitting race snapshots
              final roomCode = roomProvider.roomCode;
              if (roomCode != null) {
                context.read<SocketService>().hostReady(roomCode);
              }
              
              setState(() {
                _raceIntroComplete = true;
              });
            },
          );
        }
        return _buildRacingView(roomProvider, raceProvider, settingsProvider, partyProvider);
      case GameState.results:
        return _buildResultsView(roomProvider, settingsProvider, partyProvider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTopBar(RoomProvider roomProvider, SettingsProvider settingsProvider, PartyProvider partyProvider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              RoomCodeDisplay(roomCode: roomProvider.roomCode),
              const Spacer(),
              
              // Party features indicators (show during paddock/wager/sabotage phases)
              if (settingsProvider.isPartyMode && 
                  (roomProvider.gameState == GameState.paddock ||
                   roomProvider.gameState == GameState.wager ||
                   roomProvider.gameState == GameState.sabotage ||
                   roomProvider.gameState == GameState.racing)) ...[
                // Current drinking card (if any)
                if (settingsProvider.drinkingCardsEnabled && partyProvider.currentCard != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ActiveRuleCard(card: partyProvider.currentCard!),
                  ),
                
                // Hot seat indicator
                if (settingsProvider.hotSeatEnabled && partyProvider.hotSeat.currentPlayerId != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Builder(
                      builder: (context) {
                        final hotSeatPlayer = roomProvider.players.where(
                          (p) => p.id == partyProvider.hotSeat.currentPlayerId,
                        ).firstOrNull;
                        if (hotSeatPlayer == null) return const SizedBox.shrink();
                        return HotSeatIndicator(
                          playerName: hotSeatPlayer.name,
                          isCompact: true,
                        );
                      },
                    ),
                  ),
                
                // Rivalry indicator - show prominently during betting
                if (settingsProvider.rivalriesEnabled && partyProvider.currentRivalry != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Builder(
                      builder: (context) {
                        final rivalry = partyProvider.currentRivalry!;
                        final p1 = roomProvider.players.where((p) => p.id == rivalry.player1Id).firstOrNull;
                        final p2 = roomProvider.players.where((p) => p.id == rivalry.player2Id).firstOrNull;
                        if (p1 == null || p2 == null) return const SizedBox.shrink();
                        return RivalryBanner(player1Name: p1.name, player2Name: p2.name);
                      },
                    ),
                  ),
                
                // Drink tracker (compact)
                if (settingsProvider.drinkTrackerEnabled)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DrinkTrackerWidget(
                      tracker: partyProvider.drinkTracker,
                      players: roomProvider.players,
                      compact: true,
                    ),
                  ),
              ],
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PhaseIndicator(
                    gameState: roomProvider.gameState,
                    timer: roomProvider.timer,
                  ),
                  // Tournament progress (v2)
                  if (roomProvider.isTournamentActive && roomProvider.tournament != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.neonPurple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.neonPurple),
                        ),
                        child: Text(
                          '🏆 Race ${roomProvider.raceNumber} / ${roomProvider.tournament!.totalRaces}',
                          style: AppTheme.neonText(
                            color: AppTheme.neonPurple,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaddockView(RoomProvider roomProvider, SettingsProvider settingsProvider, PartyProvider partyProvider) {
    final isSabotage = roomProvider.gameState == GameState.sabotage;
    final isPaddock = roomProvider.gameState == GameState.paddock;
    
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Row(
        children: [
          // Left side - Featured Battle panel (during paddock/wager) or Target Info (sabotage)
          if (settingsProvider.isPartyMode && settingsProvider.rivalriesEnabled && 
              partyProvider.currentRivalry != null && (isPaddock || roomProvider.gameState == GameState.wager))
            Container(
              width: 320,
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Rivalry display
                  Builder(
                    builder: (context) {
                      final rivalry = partyProvider.currentRivalry!;
                      final p1 = roomProvider.players.where((p) => p.id == rivalry.player1Id).firstOrNull;
                      final p2 = roomProvider.players.where((p) => p.id == rivalry.player2Id).firstOrNull;
                      if (p1 == null || p2 == null) return const SizedBox.shrink();
                      return RivalryDisplay(
                        rivalry: rivalry,
                        player1: p1,
                        player2: p2,
                        showResult: false,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Hot seat reminder if applicable
                  if (settingsProvider.hotSeatEnabled && partyProvider.hotSeat.currentPlayerId != null)
                    Builder(
                      builder: (context) {
                        final hotSeatPlayer = roomProvider.players.where(
                          (p) => p.id == partyProvider.hotSeat.currentPlayerId,
                        ).firstOrNull;
                        if (hotSeatPlayer == null) return const SizedBox.shrink();
                        return HotSeatIndicator(
                          playerName: hotSeatPlayer.name,
                          isCompact: false,
                        );
                      },
                    ),
                ],
              ),
            )
          else if (isSabotage)
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
                        
                        // Check if in hot seat
                        final isHotSeat = settingsProvider.hotSeatEnabled && 
                            partyProvider.isInHotSeat(player.id);
                        
                        // Check if in rivalry
                        final isInRivalry = settingsProvider.rivalriesEnabled &&
                            partyProvider.currentRivalry != null &&
                            partyProvider.currentRivalry!.involves(player.id);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isHotSeat 
                                  ? AppTheme.neonOrange.withOpacity(0.5)
                                  : isInRivalry
                                      ? AppTheme.neonYellow.withOpacity(0.5)
                                      : AppTheme.neonCyan.withOpacity(0.3),
                              width: (isHotSeat || isInRivalry) ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (isHotSeat)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Text('🔥', style: TextStyle(fontSize: 14)),
                                          ),
                                        if (isInRivalry)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 4),
                                            child: Text('⚔️', style: TextStyle(fontSize: 14)),
                                          ),
                                        Expanded(
                                          child: Text(
                                            player.name,
                                            style: TextStyle(
                                              color: isHotSeat ? AppTheme.neonOrange : 
                                                     isInRivalry ? AppTheme.neonYellow : Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
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
                  const SizedBox(height: 8),
                  Text(
                    _getPhaseSubtitle(roomProvider.gameState),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Show enhanced participants grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: roomProvider.participants.asMap().entries.map((entry) {
                      final index = entry.key;
                      final participant = entry.value;
                      
                      // Count bets on this participant
                      final betsOnThis = roomProvider.players.where((p) {
                        final bet = roomProvider.getBet(p.id);
                        return bet?.participantId == participant.id;
                      }).toList();
                      
                      final totalBetAmount = betsOnThis.fold<int>(0, (sum, player) {
                        final bet = roomProvider.getBet(player.id);
                        return sum + (bet?.amount ?? 0);
                      });
                      
                      // Determine crowd favorite and underdog
                      final betCounts = <String, int>{};
                      for (final p in roomProvider.participants) {
                        betCounts[p.id] = roomProvider.players.where((player) {
                          final bet = roomProvider.getBet(player.id);
                          return bet?.participantId == p.id;
                        }).length;
                      }
                      final maxBets = betCounts.values.fold(0, (a, b) => a > b ? a : b);
                      
                      final isCrowdFavorite = betsOnThis.length == maxBets && maxBets > 0;
                      final isUnderdog = betsOnThis.isEmpty;
                      final isFavorite = roomProvider.isFavorite(participant.id);
                      
                      return ParticipantCard(
                        participant: participant,
                        betCount: betsOnThis.length,
                        totalBetAmount: totalBetAmount,
                        isCrowdFavorite: isCrowdFavorite,
                        isUnderdog: isUnderdog,
                        isFavorite: isFavorite,
                        animationDelay: index,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          // Right side spacer to balance layout
          if (isSabotage || (settingsProvider.isPartyMode && settingsProvider.rivalriesEnabled && 
              partyProvider.currentRivalry != null && (isPaddock || roomProvider.gameState == GameState.wager))) 
            const SizedBox(width: 320),
        ],
      ),
    );
  }

  Widget _buildRacingView(
    RoomProvider roomProvider, 
    RaceProvider raceProvider,
    SettingsProvider settingsProvider,
    PartyProvider partyProvider,
  ) {
    return Stack(
      children: [
        // Main racing content
        Padding(
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
                  finishOrder: raceProvider.finishOrder,
                  expandToFill: true,
                ),
              ),
            ],
          ),
        ),

        // Commentary overlay
        CommentaryOverlay(
          participants: roomProvider.participants,
          positions: raceProvider.positions,
          leaderId: raceProvider.leaderId,
          isRacing: roomProvider.gameState == GameState.racing,
        ),

        // Player reactions at bottom center
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Center(
            child: PlayerReactions(
              players: roomProvider.players,
              bets: roomProvider.room?.bets ?? {},
              participants: roomProvider.participants,
              positions: raceProvider.positions,
              leaderId: raceProvider.leaderId,
            ),
          ),
        ),

        // Cheer emoji animations
        CheerAnimation(
          cheerStream: context.read<SocketService>().onPlayerCheered,
          playerIds: roomProvider.players.map((p) => p.id).toList(),
        ),

        // Side bets display (if party mode)
        if (settingsProvider.sideBetsEnabled && partyProvider.getCurrentRaceSideBets().isNotEmpty)
          Positioned(
            top: 120,
            right: 380,
            child: SideBetsDisplay(
              sideBets: partyProvider.getCurrentRaceSideBets(),
              players: roomProvider.players,
              participants: roomProvider.participants,
            ),
          ),
      ],
    );
  }

  Widget _buildResultsView(
    RoomProvider roomProvider,
    SettingsProvider settingsProvider,
    PartyProvider partyProvider,
  ) {
    final raceResult = roomProvider.raceResult;
    if (raceResult == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.neonCyan),
      );
    }

    // Check if game is finished (reached max races)
    final room = roomProvider.room;
    final currentRace = room?.raceNumber ?? 0;
    final maxRaces = room?.settings?['maxRaces'] as int? ?? 0;
    final isGameOver = maxRaces > 0 && currentRace >= maxRaces;

    // Check for broke players who need the wheel
    final brokePlayers = roomProvider.players.where((p) => p.balance <= 0).toList();

    // Show final leaderboard if game is over
    if (isGameOver) {
      return _buildFinalLeaderboard(roomProvider);
    }

    return Stack(
      children: [
        // Full-screen results overlay with confetti
        RaceResultsOverlay(
          raceResult: raceResult,
          participants: roomProvider.participants,
          players: roomProvider.players,
          bets: roomProvider.room?.bets,
        ),
        
        // Party mode extras on results screen
        if (settingsProvider.isPartyMode) ...[
          // Drink tracker
          if (settingsProvider.drinkTrackerEnabled)
            Positioned(
              bottom: 100,
              left: 20,
              child: DrinkTrackerWidget(
                tracker: partyProvider.drinkTracker,
                players: roomProvider.players,
              ),
            ),
          
          // Spin wheel button for broke players
          if (settingsProvider.punishmentWheelEnabled && brokePlayers.isNotEmpty)
            Positioned(
              bottom: 100,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: brokePlayers.map((player) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton.icon(
                      onPressed: () => partyProvider.showWheelForPlayer(player.id, player.name),
                      icon: const Text('🎡', style: TextStyle(fontSize: 20)),
                      label: Text('${player.name} SPINS!'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // Side bets results
          if (settingsProvider.sideBetsEnabled && partyProvider.getCurrentRaceSideBets().isNotEmpty)
            Positioned(
              top: 120,
              right: 20,
              child: SideBetsDisplay(
                sideBets: partyProvider.getCurrentRaceSideBets(),
                players: roomProvider.players,
                participants: roomProvider.participants,
                showResults: true,
              ),
            ),
        ],

        // Tournament standings (v2) - show on results screen
        if (roomProvider.isTournamentActive && roomProvider.tournament != null)
          Positioned(
            top: 120,
            left: 20,
            child: TournamentStandings(
              tournament: roomProvider.tournament!,
              showChampion: false,
            ),
          ),
      ],
    );
  }

  Widget _buildFinalLeaderboard(RoomProvider roomProvider) {
    // Sort players by balance (highest first)
    final sortedPlayers = [...roomProvider.players];
    sortedPlayers.sort((a, b) => b.balance.compareTo(a.balance));

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy header
              const Text(
                '🏆',
                style: TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 16),
              Text(
                'GAME OVER!',
                style: AppTheme.neonText(
                  color: AppTheme.neonYellow,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Final Standings',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),

              // Leaderboard
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                decoration: AppTheme.neonBox(
                  color: AppTheme.neonCyan,
                  borderRadius: 16,
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: sortedPlayers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final player = entry.value;
                    final isWinner = index == 0;
                    
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
                        rankColor = Colors.orange;
                        medal = '🥉';
                        break;
                      default:
                        rankColor = Colors.grey;
                        medal = '#${index + 1}';
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isWinner 
                            ? AppTheme.neonYellow.withOpacity(0.2)
                            : Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: isWinner 
                            ? Border.all(color: AppTheme.neonYellow, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Medal/Rank
                          SizedBox(
                            width: 40,
                            child: Text(
                              medal,
                              style: TextStyle(
                                fontSize: index < 3 ? 24 : 16,
                                color: rankColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name
                          Expanded(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                color: isWinner ? AppTheme.neonYellow : Colors.white,
                                fontSize: isWinner ? 20 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Final balance
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: player.balance > 0 
                                  ? AppTheme.neonGreen.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\$${player.balance}',
                              style: TextStyle(
                                color: player.balance > 0 ? AppTheme.neonGreen : Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),

              // Winner announcement
              if (sortedPlayers.isNotEmpty)
                Column(
                  children: [
                    Text(
                      '👑 CHAMPION 👑',
                      style: AppTheme.neonText(
                        color: AppTheme.neonYellow,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sortedPlayers.first.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'with \$${sortedPlayers.first.balance}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPhaseMessage(GameState state) {
    switch (state) {
      case GameState.paddock:
        return '🏇 STUDY THE RACERS!';
      case GameState.wager:
        return '💰 PLACE YOUR BETS!';
      case GameState.sabotage:
        return '🎯 TIME FOR SABOTAGE!';
      default:
        return '';
    }
  }

  String _getPhaseSubtitle(GameState state) {
    switch (state) {
      case GameState.paddock:
        return 'Check their stats and choose wisely';
      case GameState.wager:
        return 'Put your money where your mouth is!';
      case GameState.sabotage:
        return 'Spend hype points to help or hinder';
      default:
        return '';
    }
  }
}
