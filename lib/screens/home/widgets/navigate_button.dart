import 'package:flutter/material.dart';

import '../../map/map_screen.dart';

class NavigateButton extends StatelessWidget {
  const NavigateButton({super.key});

  void _openMap(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const MapScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card.filled(
      color: scheme.primary,
      child: InkWell(
        onTap: () => _openMap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.map_rounded, size: 24, color: scheme.onPrimary),
              const SizedBox(width: 8),
              Text(
                'Navigate',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
