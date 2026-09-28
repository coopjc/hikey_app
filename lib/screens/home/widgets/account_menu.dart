import 'package:flutter/material.dart';

import '../../../models/user.dart';

class AccountMenu extends StatelessWidget {
  const AccountMenu({super.key, required this.user, required this.onSignOut});

  final User? user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final User? currentUser = user;
    final String name = currentUser?.displayName.trim() ?? '';

    return MenuAnchor(
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            return IconButton(
              tooltip: 'Account',
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: name.isEmpty
                    ? const Icon(Icons.person_rounded, size: 20)
                    : Text(
                        name.characters.first.toUpperCase(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
              ),
            );
          },
      menuChildren: <Widget>[
        if (currentUser != null) ...<Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 220),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    currentUser.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    currentUser.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
        ],
        MenuItemButton(
          leadingIcon: const Icon(Icons.logout_rounded),
          onPressed: onSignOut,
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
