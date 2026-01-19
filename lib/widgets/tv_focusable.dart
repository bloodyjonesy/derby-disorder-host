import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

/// A widget that provides TV-friendly focus handling
class TVFocusable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSelect;
  final bool autofocus;
  final Color focusColor;
  final double focusBorderWidth;
  final BorderRadius borderRadius;

  const TVFocusable({
    super.key,
    required this.child,
    this.onSelect,
    this.autofocus = false,
    this.focusColor = AppTheme.neonCyan,
    this.focusBorderWidth = 3.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: _handleFocusChange,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA) {
            widget.onSelect?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                border: _isFocused
                    ? Border.all(
                        color: widget.focusColor,
                        width: widget.focusBorderWidth,
                      )
                    : null,
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: widget.focusColor.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Directional focus navigation helper for TV
class TVNavigationIntent extends Intent {
  const TVNavigationIntent(this.direction);
  final TraversalDirection direction;
}

/// TV navigation actions
class TVNavigationAction extends Action<TVNavigationIntent> {
  TVNavigationAction(this.context);
  final BuildContext context;

  @override
  Object? invoke(TVNavigationIntent intent) {
    final focusNode = FocusScope.of(context);
    switch (intent.direction) {
      case TraversalDirection.up:
        focusNode.focusInDirection(TraversalDirection.up);
        break;
      case TraversalDirection.down:
        focusNode.focusInDirection(TraversalDirection.down);
        break;
      case TraversalDirection.left:
        focusNode.focusInDirection(TraversalDirection.left);
        break;
      case TraversalDirection.right:
        focusNode.focusInDirection(TraversalDirection.right);
        break;
    }
    return null;
  }
}
