import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

/// A single animated flip digit inspired by airport/train station displays
class FlipDigit extends StatefulWidget {
  final int value;
  final Color color;
  final double size;

  const FlipDigit({
    super.key,
    required this.value,
    this.color = AppTheme.neonCyan,
    this.size = 60,
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  int _currentValue = 0;
  int _nextValue = 0;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _nextValue = widget.value;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentValue = _nextValue;
          _isFlipping = false;
        });
        _controller.reset();
      }
    });
  }

  @override
  void didUpdateWidget(FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _currentValue && !_isFlipping) {
      _startFlip(widget.value);
    }
  }

  void _startFlip(int newValue) {
    setState(() {
      _nextValue = newValue;
      _isFlipping = true;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 0.7,
      height: widget.size,
      child: Stack(
        children: [
          // Background panel with neon glow
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF0A0A1A),
                  const Color(0xFF1A1A2E),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Static bottom half
          Positioned(
            top: widget.size / 2,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildDigitText(_isFlipping ? _nextValue : _currentValue),
              ),
            ),
          ),

          // Static top half (current)
          if (!_isFlipping)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: widget.size / 2,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildDigitText(_currentValue),
                ),
              ),
            ),

          // Animated flip panels
          if (_isFlipping)
            AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final progress = _flipAnimation.value;
                
                if (progress <= 0.5) {
                  // First half: flip down the top panel showing current value
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: widget.size / 2,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(-progress * math.pi),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildDigitText(_currentValue),
                        ),
                      ),
                    ),
                  );
                } else {
                  // Second half: flip down panel revealing next value
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: widget.size / 2,
                    child: Transform(
                      alignment: Alignment.bottomCenter,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX((1 - progress) * math.pi),
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildDigitText(_nextValue),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),

          // Center divider line
          Positioned(
            top: widget.size / 2 - 1,
            left: 4,
            right: 4,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // Corner accents
          ..._buildCornerAccents(),
        ],
      ),
    );
  }

  Widget _buildDigitText(int value) {
    return SizedBox(
      height: widget.size,
      child: Center(
        child: Text(
          value.toString(),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: widget.size * 0.6,
            fontWeight: FontWeight.bold,
            color: widget.color,
            shadows: [
              Shadow(
                color: widget.color.withOpacity(0.8),
                blurRadius: 10,
              ),
              Shadow(
                color: widget.color.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCornerAccents() {
    const size = 4.0;
    return [
      Positioned(top: 2, left: 2, child: _cornerDot(size)),
      Positioned(top: 2, right: 2, child: _cornerDot(size)),
      Positioned(bottom: 2, left: 2, child: _cornerDot(size)),
      Positioned(bottom: 2, right: 2, child: _cornerDot(size)),
    ];
  }

  Widget _cornerDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

/// Animated flip counter that displays multiple digits
class AnimatedFlipCounter extends StatelessWidget {
  final int value;
  final int digitCount;
  final Color color;
  final double digitSize;
  final double spacing;

  const AnimatedFlipCounter({
    super.key,
    required this.value,
    this.digitCount = 2,
    this.color = AppTheme.neonCyan,
    this.digitSize = 60,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final digits = value.toString().padLeft(digitCount, '0').split('');
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: digits.asMap().entries.map((entry) {
        final index = entry.key;
        final digit = int.parse(entry.value);
        
        return Padding(
          padding: EdgeInsets.only(left: index > 0 ? spacing : 0),
          child: FlipDigit(
            value: digit,
            color: color,
            size: digitSize,
          ),
        );
      }).toList(),
    );
  }
}

/// Countdown timer with flip animation
class FlipCountdownTimer extends StatefulWidget {
  final int seconds;
  final Color color;
  final double size;
  final VoidCallback? onComplete;

  const FlipCountdownTimer({
    super.key,
    required this.seconds,
    this.color = AppTheme.neonCyan,
    this.size = 60,
    this.onComplete,
  });

  @override
  State<FlipCountdownTimer> createState() => _FlipCountdownTimerState();
}

class _FlipCountdownTimerState extends State<FlipCountdownTimer> {
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
  }

  @override
  void didUpdateWidget(FlipCountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.seconds != oldWidget.seconds) {
      _remainingSeconds = widget.seconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60);
    final seconds = (_remainingSeconds % 60);

    // Change color as time runs low
    Color timerColor = widget.color;
    if (_remainingSeconds <= 10) {
      timerColor = AppTheme.neonRed;
    } else if (_remainingSeconds <= 30) {
      timerColor = AppTheme.neonOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: timerColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: timerColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minutes
          AnimatedFlipCounter(
            value: minutes,
            digitCount: 2,
            color: timerColor,
            digitSize: widget.size,
          ),
          
          // Colon separator with pulsing animation
          _PulsingColon(color: timerColor, size: widget.size),
          
          // Seconds
          AnimatedFlipCounter(
            value: seconds,
            digitCount: 2,
            color: timerColor,
            digitSize: widget.size,
          ),
        ],
      ),
    );
  }
}

class _PulsingColon extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingColon({
    required this.color,
    required this.size,
  });

  @override
  State<_PulsingColon> createState() => _PulsingColonState();
}

class _PulsingColonState extends State<_PulsingColon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(_controller.value),
              SizedBox(height: widget.size * 0.2),
              _dot(_controller.value),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(double opacity) {
    return Container(
      width: widget.size * 0.15,
      height: widget.size * 0.15,
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.5 + opacity * 0.5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.3 + opacity * 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
