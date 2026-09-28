import 'package:flutter/material.dart';

import '../../../models/user.dart';

class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final User? currentUser = user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            currentUser == null
                ? 'Hey there!'
                : 'Hey, ${currentUser.displayName}!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Let's find your next trail.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
