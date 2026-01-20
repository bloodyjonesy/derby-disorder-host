import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/socket_service.dart';
import '../services/api_service.dart';

/// Provider for managing room state
class RoomProvider extends ChangeNotifier {
  final SocketService _socketService;
  final ApiService _apiService;

  Room? _room;
  String? _roomCode;
  bool _isLoading = false;
  String? _error;
  
  // Tournament state (v2)
  ChaosEvent? _currentChaosEvent;
  String? _tournamentChampionId;

  // Subscriptions
  StreamSubscription<Room>? _roomSubscription;
  StreamSubscription<ChaosEvent>? _chaosEventSubscription;
  StreamSubscription<List<TournamentStanding>>? _tournamentStandingsSubscription;
  StreamSubscription<String>? _tournamentCompleteSubscription;

  RoomProvider({
    required SocketService socketService,
    required ApiService apiService,
  })  : _socketService = socketService,
        _apiService = apiService {
    _setupListeners();
  }

  // Getters
  Room? get room => _room;
  String? get roomCode => _roomCode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRoom => _room != null;
  
  // Tournament getters (v2)
  ChaosEvent? get currentChaosEvent => _currentChaosEvent;
  String? get tournamentChampionId => _tournamentChampionId;
  TournamentState? get tournament => _room?.tournament;
  bool get isTournamentActive => _room?.isTournamentActive ?? false;
  int get raceNumber => _room?.raceNumber ?? 1;

  // Convenience getters
  List<Player> get players => _room?.players ?? [];
  List<Player> get realPlayers => _room?.realPlayers ?? [];
  List<Participant> get participants => _room?.participants ?? [];
  GameState get gameState => _room?.gameState ?? GameState.lobby;
  int get chaosMeter => _room?.chaosMeter ?? 0;
  int? get timer => _room?.timer;
  RaceResult? get raceResult => _room?.raceResult;

  void _setupListeners() {
    _roomSubscription = _socketService.onRoomUpdated.listen((room) {
      _room = room;
      _roomCode = room.roomCode;
      notifyListeners();
    });

    // Chaos event subscription (v2)
    _chaosEventSubscription = _socketService.onChaosEvent.listen((event) {
      _currentChaosEvent = event;
      notifyListeners();
      
      // Auto-dismiss after duration
      final duration = event.duration ?? 3;
      Future.delayed(Duration(seconds: duration + 1), () {
        if (_currentChaosEvent == event) {
          _currentChaosEvent = null;
          notifyListeners();
        }
      });
    });

    // Tournament standings subscription
    _tournamentStandingsSubscription = _socketService.onTournamentStandings.listen((standings) {
      // Standings come through ROOM_UPDATED, but we can handle extra updates here
      notifyListeners();
    });

    // Tournament complete subscription
    _tournamentCompleteSubscription = _socketService.onTournamentComplete.listen((championId) {
      _tournamentChampionId = championId;
      notifyListeners();
      
      // Clear champion display after 30 seconds
      Future.delayed(const Duration(seconds: 30), () {
        _tournamentChampionId = null;
        notifyListeners();
      });
    });
  }

  /// Create a new room
  Future<bool> createRoom() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final roomCode = await _apiService.createRoom();
      if (roomCode != null) {
        _roomCode = roomCode;
        // Auto-join as host
        _socketService.joinRoom(roomCode, 'Host');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create room';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Start the game with settings
  void startGame({Map<String, dynamic>? settings}) {
    if (_roomCode != null) {
      _socketService.startGame(_roomCode!, settings: settings);
    }
  }

  /// Skip the current phase
  void skipPhase() {
    if (_roomCode != null) {
      _socketService.skipPhase(_roomCode!);
    }
  }

  /// Get participant name for a player's bet
  String? getParticipantNameForBet(String playerId) {
    return _room?.getParticipantNameForBet(playerId);
  }

  /// Get a participant by ID
  Participant? getParticipant(String id) {
    return _room?.getParticipant(id);
  }

  /// Get a player's bet
  Bet? getBet(String playerId) {
    return _room?.getBet(playerId);
  }

  /// Get the favorite participant for this race
  Participant? get favorite => _room?.getFavorite();

  /// Check if a participant is the favorite
  bool isFavorite(String participantId) {
    return _room?.isFavorite(participantId) ?? false;
  }

  /// Clear the current chaos event
  void clearChaosEvent() {
    _currentChaosEvent = null;
    notifyListeners();
  }

  /// Clear tournament champion display
  void clearTournamentChampion() {
    _tournamentChampionId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _chaosEventSubscription?.cancel();
    _tournamentStandingsSubscription?.cancel();
    _tournamentCompleteSubscription?.cancel();
    super.dispose();
  }
}
