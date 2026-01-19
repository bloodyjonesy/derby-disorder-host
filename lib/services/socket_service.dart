import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/models.dart';
import '../utils/constants.dart';

/// Socket service for real-time communication with the game server
class SocketService extends ChangeNotifier {
  io.Socket? _socket;
  bool _isConnected = false;
  String? _error;

  // Stream controllers for various events
  final _roomUpdatedController = StreamController<Room>.broadcast();
  final _gameStateChangedController = StreamController<GameState>.broadcast();
  final _raceSnapshotController = StreamController<RaceSnapshot>.broadcast();
  final _raceFinishedController = StreamController<RaceResult>.broadcast();
  final _chaosEventController =
      StreamController<Map<String, String>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _playerCheeredController = StreamController<String>.broadcast(); // playerId

  // Public streams
  Stream<Room> get onRoomUpdated => _roomUpdatedController.stream;
  Stream<GameState> get onGameStateChanged => _gameStateChangedController.stream;
  Stream<RaceSnapshot> get onRaceSnapshot => _raceSnapshotController.stream;
  Stream<RaceResult> get onRaceFinished => _raceFinishedController.stream;
  Stream<Map<String, String>> get onChaosEvent => _chaosEventController.stream;
  Stream<String> get onError => _errorController.stream;
  Stream<String> get onPlayerCheered => _playerCheeredController.stream;

  // Getters
  bool get isConnected => _isConnected;
  String? get error => _error;
  io.Socket? get socket => _socket;

  /// Connect to the socket server
  void connect({String? url}) {
    final serverUrl = url ?? AppConstants.defaultSocketUrl;

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _setupEventListeners();
    _socket!.connect();
  }

  void _setupEventListeners() {
    _socket!.onConnect((_) {
      debugPrint('Socket connected');
      _isConnected = true;
      _error = null;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected');
      _isConnected = false;
      notifyListeners();
    });

    _socket!.onConnectError((data) {
      debugPrint('Socket connect error: $data');
      _error = 'Connection error: $data';
      _isConnected = false;
      notifyListeners();
    });

    _socket!.onError((data) {
      debugPrint('Socket error: $data');
      _error = 'Socket error: $data';
      notifyListeners();
    });

    // Game events
    _socket!.on('ROOM_UPDATED', (data) {
      try {
        final room = Room.fromJson(data as Map<String, dynamic>);
        _roomUpdatedController.add(room);
      } catch (e) {
        debugPrint('Error parsing ROOM_UPDATED: $e');
      }
    });

    _socket!.on('GAME_STATE_CHANGED', (data) {
      try {
        final state = GameState.fromString(data as String);
        _gameStateChangedController.add(state);
      } catch (e) {
        debugPrint('Error parsing GAME_STATE_CHANGED: $e');
      }
    });

    _socket!.on('RACE_SNAPSHOT', (data) {
      try {
        final snapshot = RaceSnapshot.fromJson(data as Map<String, dynamic>);
        _raceSnapshotController.add(snapshot);
      } catch (e) {
        debugPrint('Error parsing RACE_SNAPSHOT: $e');
      }
    });

    _socket!.on('RACE_FINISHED', (data) {
      try {
        final result = RaceResult.fromJson(data as Map<String, dynamic>);
        _raceFinishedController.add(result);
      } catch (e) {
        debugPrint('Error parsing RACE_FINISHED: $e');
      }
    });

    _socket!.on('CHAOS_EVENT', (data) {
      try {
        final event = Map<String, String>.from(data as Map);
        _chaosEventController.add(event);
      } catch (e) {
        debugPrint('Error parsing CHAOS_EVENT: $e');
      }
    });

    _socket!.on('PLAYER_CHEERED', (data) {
      try {
        final playerId = (data as Map)['playerId'] as String;
        _playerCheeredController.add(playerId);
      } catch (e) {
        debugPrint('Error parsing PLAYER_CHEERED: $e');
      }
    });

    _socket!.on('ERROR', (data) {
      try {
        final message = (data as Map)['message'] as String;
        _error = message;
        _errorController.add(message);
        notifyListeners();
      } catch (e) {
        debugPrint('Error parsing ERROR: $e');
      }
    });
  }

  /// Join a room
  void joinRoom(String roomCode, String playerName) {
    _socket?.emit('JOIN_ROOM', {
      'roomCode': roomCode,
      'playerName': playerName,
    });
  }

  /// Start the game with optional settings
  void startGame(String roomCode, {Map<String, dynamic>? settings}) {
    final data = <String, dynamic>{'roomCode': roomCode};
    if (settings != null) {
      data['settings'] = settings;
    }
    _socket?.emit('START_GAME', data);
  }

  /// Skip the current phase
  void skipPhase(String roomCode) {
    _socket?.emit('SKIP_PHASE', {
      'roomCode': roomCode,
    });
  }

  /// Place a bet
  void placeBet(String roomCode, Bet bet) {
    _socket?.emit('PLACE_BET', {
      'roomCode': roomCode,
      'bet': bet.toJson(),
    });
  }

  /// Use an item
  void useItem(String roomCode, Item item) {
    _socket?.emit('USE_ITEM', {
      'roomCode': roomCode,
      'item': item.toJson(),
    });
  }

  /// Cheer for hype
  void cheer(String roomCode, String playerId) {
    _socket?.emit('CHEER', {
      'roomCode': roomCode,
      'playerId': playerId,
    });
  }

  /// Lock bets
  void lockBets(String roomCode, String playerId) {
    _socket?.emit('LOCK_BETS', {
      'roomCode': roomCode,
      'playerId': playerId,
    });
  }

  /// Signal host is ready to start the race (after intro animation)
  void hostReady(String roomCode) {
    debugPrint('Sending HOST_READY for $roomCode');
    _socket?.emit('HOST_READY', {
      'roomCode': roomCode,
    });
  }

  /// Disconnect from the server
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    _roomUpdatedController.close();
    _gameStateChangedController.close();
    _raceSnapshotController.close();
    _raceFinishedController.close();
    _chaosEventController.close();
    _errorController.close();
    _playerCheeredController.close();
    super.dispose();
  }
}
