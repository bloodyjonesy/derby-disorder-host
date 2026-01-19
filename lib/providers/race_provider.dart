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
  Map<String, double> get positions => _animatedPositions;
  bool get isRacing => _isRacing;
  String? get leaderId => _currentSnapshot?.leader;

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
      // Smooth interpolation
      _animatedPositions[entry.key] = current + (target - current) * 0.15;
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
    notifyListeners();
  }

  @override
  void dispose() {
    _snapshotSubscription?.cancel();
    _resultSubscription?.cancel();
    super.dispose();
  }
}
