import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/theme.dart';

/// Check if a key is a selection key (OK/Enter/A button etc.)
bool _isSelectKey(LogicalKeyboardKey key) {
  return key == LogicalKeyboardKey.select ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      key == LogicalKeyboardKey.space ||
      key == LogicalKeyboardKey.gameButtonA ||
      key == LogicalKeyboardKey.gameButtonStart ||
      key == LogicalKeyboardKey.mediaPlay ||
      key == LogicalKeyboardKey.mediaPlayPause;
}

/// A widget that provides TV-friendly focus handling
class TVFocusable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSelect;
  final bool autofocus;
  final Color focusColor;
  final double focusBorderWidth;
  final BorderRadius borderRadius;
  final FocusNode? focusNode;
  final bool canRequestFocus;

  const TVFocusable({
    super.key,
    required this.child,
    this.onSelect,
    this.autofocus = false,
    this.focusColor = AppTheme.neonCyan,
    this.focusBorderWidth = 3.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusNode,
    this.canRequestFocus = true,
  });

  @override
  State<TVFocusable> createState() => _TVFocusableState();
}

class _TVFocusableState extends State<TVFocusable>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });
    if (hasFocus) {
      _animationController.forward();
      // Play a subtle sound feedback if available
      HapticFeedback.selectionClick();
    } else {
      _animationController.reverse();
    }
  }

  void _handleSelect() {
    if (widget.onSelect != null) {
      HapticFeedback.mediumImpact();
      widget.onSelect!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      focusable: widget.canRequestFocus,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: widget.canRequestFocus,
        onFocusChange: _handleFocusChange,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && _isSelectKey(event.logicalKey)) {
            _handleSelect();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _handleSelect,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedBuilder(
              animation: _animationController,
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
                          : Border.all(
                              color: Colors.transparent,
                              width: widget.focusBorderWidth,
                            ),
                      boxShadow: _isFocused
                          ? [
                              BoxShadow(
                                color: widget.focusColor.withOpacity(0.6 * _glowAnimation.value),
                                blurRadius: 20 * _glowAnimation.value,
                                spreadRadius: 4 * _glowAnimation.value,
                              ),
                              BoxShadow(
                                color: widget.focusColor.withOpacity(0.3 * _glowAnimation.value),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 8 * _glowAnimation.value,
                              ),
                            ]
                          : null,
                    ),
                    child: widget.child,
                  ),
                );
              },
            ),
          ),
        ),
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
