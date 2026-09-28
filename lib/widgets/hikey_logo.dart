import 'package:flutter/material.dart';

class HikeyLogo extends StatelessWidget {
  const HikeyLogo({
    super.key,
    this.size = 64,
    this.showWordmark = true,
    this.tagline,
  });

  final double size;
  final bool showWordmark;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Column(
      children: <Widget>[
        Material(
          color: scheme.primary,
          elevation: 4,
          shadowColor: scheme.primary.withValues(alpha: 0.4),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(size * 0.34),
          ),
          child: SizedBox.square(
            dimension: size,
            child: Icon(
              Icons.terrain_rounded,
              size: size * 0.55,
              color: scheme.onPrimary,
            ),
          ),
        ),
        if (showWordmark) ...<Widget>[
          const SizedBox(height: 16),
          Text(
            'Hikey',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
        ],
        if (tagline != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
