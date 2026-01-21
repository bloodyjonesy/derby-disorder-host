import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// A glassmorphic panel with frosted glass effect and optional neon border
class GlassmorphicPanel extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final double backgroundOpacity;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? boxShadow;
  final bool showGlow;

  const GlassmorphicPanel({
    super.key,
    required this.child,
    this.borderColor,
    this.borderWidth = 1.5,
    this.borderRadius = 16,
    this.blur = 10,
    this.backgroundColor,
    this.backgroundOpacity = 0.1,
    this.padding = const EdgeInsets.all(16),
    this.boxShadow,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppTheme.neonCyan;
    final effectiveBgColor = backgroundColor ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? (showGlow ? [
          BoxShadow(
            color: effectiveBorderColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ] : null),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveBgColor.withOpacity(backgroundOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: effectiveBorderColor.withOpacity(0.3),
                width: borderWidth,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveBgColor.withOpacity(backgroundOpacity + 0.05),
                  effectiveBgColor.withOpacity(backgroundOpacity),
                  effectiveBgColor.withOpacity(backgroundOpacity - 0.03),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// An animated glassmorphic card with hover effects
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isSelected;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.accentColor = AppTheme.neonCyan,
    this.onTap,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.isSelected = false,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final glowIntensity = widget.isSelected ? 1.0 : _glowAnimation.value;
            
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.1 + glowIntensity * 0.3),
                      blurRadius: 10 + glowIntensity * 20,
                      spreadRadius: glowIntensity * 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05 + glowIntensity * 0.05),
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        border: Border.all(
                          color: widget.accentColor.withOpacity(
                            widget.isSelected ? 0.8 : 0.2 + glowIntensity * 0.3
                          ),
                          width: widget.isSelected ? 2 : 1.5,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                          ],
                        ),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A section header with neon styling
class NeonSectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final IconData? icon;
  final String? subtitle;

  const NeonSectionHeader({
    super.key,
    required this.title,
    this.color = AppTheme.neonCyan,
    this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: AppTheme.neonText(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.5),
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
