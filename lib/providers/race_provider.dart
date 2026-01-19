import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/socket_service.dart';

/// Provider for managing race state and animations
class RaceProvider extends ChangeNotifier {
  final SocketService _socketService;

  RaceSnapshot? _currentSnapshot;
  RaceResult? _raceResult;
  final Map<String, double> _animatedPositions = {};
  bool _isRacing = false;
  bool _isPaused = false; // Pause updates during intro

  // Subscriptions
  StreamSubscription<RaceSnapshot>? _snapshotSubscription;
  StreamSubscription<RaceResult>? _resultSubscription;

  RaceProvider({required SocketService socketService})
      : _socketService = socketService {
    _setupListeners();
  }

  // Getters
  RaceSnapshot? get currentSnapshot => _currentSnapshot;
  RaceResult? get raceResult => _raceResult;
  Map<String, double> get positions => _isPaused ? {} : _animatedPositions;
  bool get isRacing => _isRacing;
  bool get isPaused => _isPaused;
  String? get leaderId => _isPaused ? null : _currentSnapshot?.leader;

  void _setupListeners() {
    _snapshotSubscription = _socketService.onRaceSnapshot.listen((snapshot) {
      _currentSnapshot = snapshot;
      _isRacing = true;
      _updateAnimatedPositions(snapshot);
      notifyListeners();
    });

    _resultSubscription = _socketService.onRaceFinished.listen((result) {
      _raceResult = result;
      _isRacing = false;
      notifyListeners();
    });
  }

  void _updateAnimatedPositions(RaceSnapshot snapshot) {
    // Lerp towards target positions for smooth animation
    for (final entry in snapshot.positions.entries) {
      final current = _animatedPositions[entry.key] ?? 0.0;
      final target = entry.value;
      
      // Use faster interpolation near the finish line so racers blast through
      // Also snap to target if very close (prevents slow crawl)
      final difference = (target - current).abs();
      
      if (target >= 95 || difference < 1) {
        // Near finish or very close - use faster lerp or snap
        _animatedPositions[entry.key] = current + (target - current) * 0.4;
      } else if (target >= 80) {
        // Approaching finish - speed up
        _animatedPositions[entry.key] = current + (target - current) * 0.25;
      } else {
        // Normal smooth interpolation
        _animatedPositions[entry.key] = current + (target - current) * 0.15;
      }
      
      // Snap to 100 if target is 100 and we're close
      if (target >= 100 && _animatedPositions[entry.key]! >= 98) {
        _animatedPositions[entry.key] = 100.0;
      }
    }
  }

  /// Get position for a participant
  double getPosition(String participantId) {
    return _animatedPositions[participantId] ?? 0.0;
  }

  /// Get sorted participants by current position (for leaderboard)
  List<MapEntry<String, double>> getSortedPositions() {
    final entries = _animatedPositions.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Reset race state
  void reset() {
    _currentSnapshot = null;
    _raceResult = null;
    _animatedPositions.clear();
    _isRacing = false;
    _isPaused = false;
    notifyListeners();
  }

  /// Pause race updates (during intro)
  void pause() {
    _isPaused = true;
    _animatedPositions.clear(); // Clear positions so race starts fresh
    notifyListeners();
  }

  /// Resume race updates (after intro)
  void resume() {
    _isPaused = false;
    // Positions will update on next snapshot
    notifyListeners();
  }

  /// Start fresh - reset positions to 0 for all participants
  void startFresh(List<String> participantIds) {
    _isPaused = false;
    _animatedPositions.clear();
    for (final id in participantIds) {
      _animatedPositions[id] = 0.0;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _snapshotSubscription?.cancel();
    _resultSubscription?.cancel();
    super.dispose();
  }
}
