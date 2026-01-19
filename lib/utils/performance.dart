import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Performance monitoring utilities
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Frame timing tracking
  final List<Duration> _frameTimes = [];
  static const int _maxFrameSamples = 60;
  DateTime? _lastFrameTime;
  Timer? _reportTimer;

  // FPS calculation
  double _currentFps = 60.0;
  double _averageFps = 60.0;
  int _droppedFrames = 0;

  // Getters
  double get currentFps => _currentFps;
  double get averageFps => _averageFps;
  int get droppedFrames => _droppedFrames;

  /// Start monitoring frame performance
  void startMonitoring() {
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
    _reportTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _reportPerformance();
    });
  }

  /// Stop monitoring
  void stopMonitoring() {
    _reportTimer?.cancel();
    _frameTimes.clear();
  }

  void _onFrame(Duration timestamp) {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final frameTime = now.difference(_lastFrameTime!);
      _frameTimes.add(frameTime);

      // Keep only recent samples
      while (_frameTimes.length > _maxFrameSamples) {
        _frameTimes.removeAt(0);
      }

      // Calculate FPS
      if (frameTime.inMicroseconds > 0) {
        _currentFps = 1000000 / frameTime.inMicroseconds;
      }

      // Detect dropped frames (> 16.67ms for 60fps)
      if (frameTime.inMilliseconds > 17) {
        _droppedFrames++;
      }

      // Calculate average FPS
      if (_frameTimes.isNotEmpty) {
        final totalMicroseconds =
            _frameTimes.fold<int>(0, (sum, d) => sum + d.inMicroseconds);
        final avgFrameTime = totalMicroseconds / _frameTimes.length;
        _averageFps = 1000000 / avgFrameTime;
      }
    }
    _lastFrameTime = now;

    // Schedule next frame callback
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _reportPerformance() {
    debugPrint(
      'Performance: FPS=${_averageFps.toStringAsFixed(1)}, '
      'DroppedFrames=$_droppedFrames',
    );
  }
}

/// Throttle function calls to prevent excessive updates
class Throttler {
  final Duration duration;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({this.duration = const Duration(milliseconds: 16)});

  /// Execute function with throttling
  void run(VoidCallback callback) {
    if (!_isThrottled) {
      callback();
      _isThrottled = true;
      _timer = Timer(duration, () {
        _isThrottled = false;
      });
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Debounce function calls
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Execute function with debouncing
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Object pool for reducing garbage collection
class ObjectPool<T> {
  final T Function() _factory;
  final void Function(T)? _reset;
  final List<T> _pool = [];
  final int _maxSize;

  ObjectPool({
    required T Function() factory,
    void Function(T)? reset,
    int maxSize = 100,
  })  : _factory = factory,
        _reset = reset,
        _maxSize = maxSize;

  /// Get an object from the pool or create a new one
  T acquire() {
    if (_pool.isNotEmpty) {
      return _pool.removeLast();
    }
    return _factory();
  }

  /// Return an object to the pool
  void release(T object) {
    if (_pool.length < _maxSize) {
      _reset?.call(object);
      _pool.add(object);
    }
  }

  /// Clear the pool
  void clear() {
    _pool.clear();
  }

  int get size => _pool.length;
}

/// Memory-efficient list that reuses capacity
class RecyclingList<T> {
  final List<T?> _items;
  int _count = 0;

  RecyclingList({int initialCapacity = 10})
      : _items = List<T?>.filled(initialCapacity, null, growable: true);

  int get length => _count;
  bool get isEmpty => _count == 0;

  void add(T item) {
    if (_count < _items.length) {
      _items[_count] = item;
    } else {
      _items.add(item);
    }
    _count++;
  }

  T operator [](int index) {
    if (index >= _count) throw RangeError.index(index, this);
    return _items[index] as T;
  }

  void clear() {
    for (var i = 0; i < _count; i++) {
      _items[i] = null;
    }
    _count = 0;
  }

  Iterable<T> get values sync* {
    for (var i = 0; i < _count; i++) {
      yield _items[i] as T;
    }
  }
}
