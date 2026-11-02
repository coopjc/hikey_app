import 'package:flutter/material.dart';
import 'package:hikey_app/models/hike_stats.dart';
import 'package:provider/provider.dart';

import '../../api/api_exception.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/hike_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/hike.dart';
import '../../models/paged.dart';
import '../../models/user.dart';
import '../../utils/hike_format.dart';
import '../../widgets/error_notice.dart';
import '../../widgets/hikey_logo.dart';
import 'widgets/account_menu.dart';
import 'widgets/greeting.dart';
import 'widgets/hike_card.dart';
import 'widgets/navigate_button.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/stats_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Hike> _recentHikes = <Hike>[];
  HikeStats? _stats;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _load();
    });
  }

  Future<void> _load() async {
    await Future.wait(<Future<void>>[_loadStats(), _loadRecentHikes()]);
  }

  Future<void> _loadStats() async {
    final UserController userController = context.read<UserController>();

    try {
      final HikeStats stats = await userController.getStats();

      if (!mounted) return;

      setState(() => _stats = stats);
    } catch (_) {}
  }

  Future<void> _loadRecentHikes() async {
    final HikeController hikeController = context.read<HikeController>();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Paged<Hike> page = await hikeController.getRecentHikes();

      if (!mounted) return;

      _recentHikes = page.content;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    }

    if (!mounted) return;

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = context.watch<AuthController>();

    final User? user = authController.user;
    final ThemeData theme = Theme.of(context);

    final String? message = authController.message;

    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));

        authController.clearMessage();
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
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              Greeting(user: user),
              const SizedBox(height: 24),
              StatsRow(stats: _buildStatItems()),
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
              ..._buildRecentActivity(theme),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        minimum: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              QuickActionsRow(),
              SizedBox(height: 12),
              NavigateButton(),
            ],
          ),
        ),
      ),
    );
  }

  List<StatItem> _buildStatItems() {
    final HikeStats? stats = _stats;

    return <StatItem>[
      StatItem(
        icon: Icons.hiking_rounded,
        value: stats == null ? '–' : '${stats.totalHikes}',
        label: 'Hikes',
      ),
      StatItem(
        icon: Icons.route_rounded,
        value: stats == null ? '–' : formatMiles(stats.totalDistanceMiles),
        label: 'Miles',
      ),
    ];
  }

  List<Widget> _buildRecentActivity(ThemeData theme) {
    if (_isLoading && _recentHikes.isEmpty) {
      return <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_errorMessage != null && _recentHikes.isEmpty) {
      return <Widget>[
        ErrorNotice(icon: Icons.cloud_off_rounded, message: _errorMessage!),
      ];
    }

    if (_recentHikes.isEmpty) {
      return <Widget>[
        Card.filled(
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.explore_outlined,
                  size: 36,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No hikes yet — go explore!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return <Widget>[
      for (final Hike hike in _recentHikes) ...<Widget>[
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
