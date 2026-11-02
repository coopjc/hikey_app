import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../models/user.dart';
import '../../widgets/error_notice.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<AuthController>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            if (user == null)
              const ErrorNotice(
                icon: Icons.person_off_rounded,
                message: "Couldn't load your profile.",
              )
            else ...<Widget>[
              ProfileHeader(user: user),
              const SizedBox(height: 32),
              SettingsSection(
                title: 'Account',
                children: <Widget>[
                  SettingsTile(
                    icon: Icons.badge_rounded,
                    label: 'Display name',
                    value: user.displayName,
                  ),
                  SettingsTile(
                    icon: Icons.email_rounded,
                    label: 'Email',
                    value: user.email,
                  ),
                  SettingsTile(
                    icon: Icons.cake_rounded,
                    label: 'Age',
                    value: '${user.age}',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
