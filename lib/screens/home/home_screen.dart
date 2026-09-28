import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/hike_controller.dart';
import '../../models/hike.dart';
import '../../models/user.dart';
import '../../utils/hike_format.dart';
import '../../widgets/hikey_logo.dart';
import 'widgets/account_menu.dart';
import 'widgets/activity_notice.dart';
import 'widgets/greeting.dart';
import 'widgets/hike_card.dart';
import 'widgets/quick_actions_bar.dart';
import 'widgets/stats_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HikeController>().loadHikes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = context.watch<AuthController>();
    final HikeController hikeController = context.watch<HikeController>();

    final User? user = authController.user;
    final ThemeData theme = Theme.of(context);

    final String? message = authController.message;

    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      });
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const HikeyLogo(size: 32, showWordmark: false),
            const SizedBox(width: 12),
            Text(
              'Hikey',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          AccountMenu(user: user, onSignOut: () => _confirmSignOut(context)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => context.read<HikeController>().loadHikes(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              Greeting(user: user),
              const SizedBox(height: 24),
              StatsRow(stats: _statsFor(hikeController)),
              const SizedBox(height: 16),
              const QuickActionsBar(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Recent activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._buildRecentActivity(theme, hikeController),
            ],
          ),
        ),
      ),
    );
  }

  List<StatItem> _statsFor(HikeController hikeController) {
    return <StatItem>[
      StatItem(
        icon: Icons.hiking_rounded,
        value: '${hikeController.hikes.length}',
        label: 'Hikes',
      ),
      StatItem(
        icon: Icons.route_rounded,
        value: formatMiles(hikeController.totalDistanceMiles),
        label: 'Miles',
      ),
    ];
  }

  List<Widget> _buildRecentActivity(
    ThemeData theme,
    HikeController hikeController,
  ) {
    if (hikeController.isLoading && hikeController.hikes.isEmpty) {
      return <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (hikeController.errorMessage != null && hikeController.hikes.isEmpty) {
      return <Widget>[
        ActivityNotice(
          icon: Icons.cloud_off_rounded,
          message: hikeController.errorMessage!,
          isError: true,
        ),
      ];
    }

    if (hikeController.hikes.isEmpty) {
      return <Widget>[
        const ActivityNotice(
          icon: Icons.explore_outlined,
          message: 'No hikes yet — go explore!',
        ),
      ];
    }

    final List<Hike> recentHikes = hikeController.hikes.toList()
      ..sort((Hike a, Hike b) => b.updatedAt.compareTo(a.updatedAt));

    return <Widget>[
      for (final Hike hike in recentHikes.take(3)) ...<Widget>[
        HikeCard(hike: hike),
        const SizedBox(height: 8),
      ],
    ];
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final AuthController auth = context.read<AuthController>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded),
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to see your hikes.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await auth.logout();
  }
}
