import 'package:flutter/material.dart';
import '../models/models.dart';
import 'race_track_painter.dart';

/// Race view widget that displays the animated race track
class RaceView extends StatefulWidget {
  final List<Participant> participants;
  final Map<String, double> positions;
  final String? leaderId;

  const RaceView({
    super.key,
    required this.participants,
    required this.positions,
    this.leaderId,
  });

  @override
  State<RaceView> createState() => _RaceViewState();
}

class _RaceViewState extends State<RaceView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: RaceTrackPainter(
            participants: widget.participants,
            positions: widget.positions,
            leaderId: widget.leaderId,
            animationValue: _animationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
