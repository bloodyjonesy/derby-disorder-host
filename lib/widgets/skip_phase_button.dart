import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Skip phase button for host controls
class SkipPhaseButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SkipPhaseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.skip_next),
      label: const Text('SKIP PHASE'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.neonRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
