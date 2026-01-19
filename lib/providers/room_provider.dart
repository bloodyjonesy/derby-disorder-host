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

  // Subscriptions
  StreamSubscription<Room>? _roomSubscription;

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

  // Convenience getters
  List<Player> get players => _room?.players ?? [];
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

  /// Start the game
  void startGame() {
    if (_roomCode != null) {
      _socketService.startGame(_roomCode!);
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

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
