import 'package:flutter/material.dart';

/// Stands in for content that failed to load or is unavailable.
class ErrorNotice extends StatelessWidget {
  const ErrorNotice({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card.filled(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 36, color: scheme.onErrorContainer),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
