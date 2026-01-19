import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Displays the chaos meter
class ChaosMeter extends StatelessWidget {
  final int value; // 0-100

  const ChaosMeter({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0, 100) / 100.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.neonBox(
        color: AppTheme.neonRed,
        borderRadius: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHAOS METER',
            style: AppTheme.neonText(
              color: AppTheme.neonRed,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.neonRed.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                children: [
                  // Background gradient
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 200 * normalizedValue,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonOrange,
                          AppTheme.neonRed,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonRed.withOpacity(0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
