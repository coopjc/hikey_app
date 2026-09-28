import 'package:flutter/material.dart';

/// Stands in for the recent-activity list when there's nothing to show, or it
/// failed to load.
class ActivityNotice extends StatelessWidget {
  const ActivityNotice({
    super.key,
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final Color foreground = isError
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;

    return Card.filled(
      color: isError ? scheme.errorContainer : scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 36, color: foreground),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
