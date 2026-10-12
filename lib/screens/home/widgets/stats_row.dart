import 'package:flutter/material.dart';

class StatItem {
  const StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.stats});

  final List<StatItem> stats;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card.filled(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < stats.length; i++) ...<Widget>[
                if (i != 0)
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: scheme.onSecondaryContainer.withValues(alpha: 0.2),
                  ),
                Expanded(child: _Stat(item: stats[i])),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.item});

  final StatItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(item.icon, color: scheme.primary, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: item.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  TextSpan(
                    text: ' ${item.label}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
