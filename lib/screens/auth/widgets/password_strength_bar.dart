import 'package:flutter/material.dart';

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.password});

  final String password;

  int get _score {
    if (password.isEmpty) return 0;

    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(password) ||
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }
    return score.clamp(0, 4);
  }

  static const List<String> _labels = <String>[
    '',
    'Weak',
    'Fair',
    'Good',
    'Strong',
  ];

  static Color _colorFor(int score, ColorScheme scheme) => switch (score) {
    1 => scheme.error,
    2 => const Color(0xFFF9A825),
    3 => scheme.primary.withValues(alpha: 0.7),
    _ => scheme.primary,
  };

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox(height: 12);

    final ThemeData theme = Theme.of(context);
    final int score = _score;
    final Color color = _colorFor(score, theme.colorScheme);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: score / 4),
              duration: const Duration(milliseconds: 250),
              builder: (BuildContext context, double value, _) {
                return LinearProgressIndicator(
                  value: value,
                  color: color,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: Text(
              _labels[score],
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
