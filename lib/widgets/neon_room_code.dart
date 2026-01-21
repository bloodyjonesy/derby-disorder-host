import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';
import '../utils/responsive.dart';

/// A dramatically styled room code display with neon glow and animations
class NeonRoomCode extends StatefulWidget {
  final String? roomCode;
  final bool showJoinUrl;
  final double letterSize;

  const NeonRoomCode({
    super.key,
    this.roomCode,
    this.showJoinUrl = true,
    this.letterSize = 80,
  });

  @override
  State<NeonRoomCode> createState() => _NeonRoomCodeState();
}

class _NeonRoomCodeState extends State<NeonRoomCode> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _entryController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void didUpdateWidget(NeonRoomCode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.roomCode != oldWidget.roomCode && widget.roomCode != null) {
      _entryController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.roomCode == null) {
      return const SizedBox.shrink();
    }

    final scale = Responsive.scale(context);

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _entryController]),
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Join URL
            if (widget.showJoinUrl)
              FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entryController,
                  curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.5),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _entryController,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                  )),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 12 * scale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonYellow.withOpacity(0.1),
                          AppTheme.neonOrange.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30 * scale),
                      border: Border.all(
                        color: AppTheme.neonYellow.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '📱',
                          style: TextStyle(fontSize: 24 * scale),
                        ),
                        SizedBox(width: 12 * scale),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'JOIN AT',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'ddcc.pw',
                              style: AppTheme.neonText(
                                color: AppTheme.neonYellow,
                                fontSize: 28 * scale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            SizedBox(height: 24 * scale),

            // Room code label
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _entryController,
                curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
              ),
              child: Text(
                'ROOM CODE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 4,
                ),
              ),
            ),

            SizedBox(height: 16 * scale),

            // Room code letters
            _buildRoomCodeLetters(),
          ],
        );
      },
    );
  }

  Widget _buildRoomCodeLetters() {
    final letters = widget.roomCode!.split('');
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: letters.asMap().entries.map((entry) {
        final index = entry.key;
        final letter = entry.value;
        
        // Staggered animation for each letter
        final startDelay = 0.3 + (index * 0.1);
        final endDelay = math.min(startDelay + 0.3, 1.0);
        
        return Padding(
          padding: EdgeInsets.only(left: index > 0 ? 8 : 0),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entryController,
              curve: Interval(startDelay, endDelay, curve: Curves.easeOut),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _entryController,
                curve: Interval(startDelay, endDelay, curve: Curves.elasticOut),
              )),
              child: _NeonLetter(
                letter: letter,
                size: widget.letterSize,
                glowIntensity: _glowAnimation.value,
                isNumber: int.tryParse(letter) != null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _NeonLetter extends StatelessWidget {
  final String letter;
  final double size;
  final double glowIntensity;
  final bool isNumber;

  const _NeonLetter({
    required this.letter,
    required this.size,
    required this.glowIntensity,
    required this.isNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Use different colors for letters vs numbers
    final color = isNumber ? AppTheme.neonPink : AppTheme.neonCyan;
    
    return Container(
      width: size * 0.75,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF0A0A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3 + glowIntensity * 0.3),
          width: 3,
        ),
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: color.withOpacity(0.2 + glowIntensity * 0.3),
            blurRadius: 15 + glowIntensity * 10,
            spreadRadius: 2 + glowIntensity * 3,
          ),
          // Inner shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: -5,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(0.1),
                  Colors.transparent,
                ],
                radius: 0.8,
              ),
            ),
          ),
          
          // Letter
          Text(
            letter,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: size * 0.55,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.6 + glowIntensity * 0.4),
                  blurRadius: 15 + glowIntensity * 10,
                ),
                Shadow(
                  color: color.withOpacity(0.4 + glowIntensity * 0.3),
                  blurRadius: 30,
                ),
                Shadow(
                  color: Colors.white.withOpacity(0.1 + glowIntensity * 0.1),
                  blurRadius: 5,
                ),
              ],
            ),
          ),

          // Scanline effect
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                painter: _ScanlinePainter(),
              ),
            ),
          ),

          // Corner LEDs
          Positioned(top: 4, left: 4, child: _led(color, glowIntensity)),
          Positioned(top: 4, right: 4, child: _led(color, glowIntensity)),
          Positioned(bottom: 4, left: 4, child: _led(color, glowIntensity)),
          Positioned(bottom: 4, right: 4, child: _led(color, glowIntensity)),
        ],
      ),
    );
  }

  Widget _led(Color color, double intensity) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5 + intensity * 0.5),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4 + intensity * 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.03);
    
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
