import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../utils/theme.dart';

/// Dialog to show available updates
class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onUpdate;
  final VoidCallback onSkip;
  final VoidCallback onLater;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.onUpdate,
    required this.onSkip,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.neonCyan, width: 2),
      ),
      title: Row(
        children: [
          const Icon(Icons.system_update, color: AppTheme.neonCyan, size: 28),
          const SizedBox(width: 12),
          Text(
            'Update Available',
            style: AppTheme.neonText(
              color: AppTheme.neonCyan,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Version:',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                Text(
                  'v${updateInfo.version}',
                  style: const TextStyle(
                    color: AppTheme.neonGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Release Notes:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                updateInfo.releaseNotes.isEmpty
                    ? 'No release notes available.'
                    : updateInfo.releaseNotes,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (updateInfo.isRequired) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neonRed),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: AppTheme.neonRed, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This update is required to continue using the app.',
                      style: TextStyle(
                        color: AppTheme.neonRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!updateInfo.isRequired) ...[
          TextButton(
            onPressed: onSkip,
            child: const Text(
              'Skip This Version',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: onLater,
            child: const Text(
              'Later',
              style: TextStyle(color: AppTheme.neonCyan),
            ),
          ),
        ],
        ElevatedButton(
          onPressed: onUpdate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.neonGreen,
            foregroundColor: AppTheme.darkBackground,
          ),
          child: const Text('Update Now'),
        ),
      ],
    );
  }
}

/// Download progress dialog
class UpdateProgressDialog extends StatelessWidget {
  final double progress;
  final VoidCallback? onCancel;

  const UpdateProgressDialog({
    super.key,
    required this.progress,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.neonCyan, width: 2),
      ),
      title: Text(
        'Downloading Update',
        style: AppTheme.neonText(
          color: AppTheme.neonCyan,
          fontSize: 20,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceColor,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
          ),
          const SizedBox(height: 16),
          Text(
            '${(progress * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: onCancel != null
          ? [
              TextButton(
                onPressed: onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.neonRed),
                ),
              ),
            ]
          : null,
    );
  }
}
