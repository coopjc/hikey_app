import 'package:flutter/material.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  static const List<_QuickAction> _actions = <_QuickAction>[
    _QuickAction(icon: Icons.map_rounded, label: 'Navigate'),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < _actions.length; i++) ...<Widget>[
            if (i != 0) const SizedBox(width: 8),
            Expanded(
              child: Card.filled(
                color: i == 0 ? scheme.primary : scheme.secondaryContainer,
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          _actions[i].icon,
                          size: 28,
                          color: i == 0
                              ? scheme.onPrimary
                              : scheme.onSecondaryContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _actions[i].label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: i == 0
                                ? scheme.onPrimary
                                : scheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
