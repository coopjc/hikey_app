import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_exception.dart';
import '../../controllers/hike_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/hike.dart';
import '../../models/hike_stats.dart';
import '../../models/paged.dart';
import '../../utils/route_observer.dart';
import '../../widgets/error_notice.dart';
import '../../widgets/hike_card.dart';
import '../../widgets/no_hikes_notice.dart';
import 'widgets/page_selector.dart';

class HikesScreen extends StatefulWidget {
  const HikesScreen({super.key});

  @override
  State<HikesScreen> createState() => _HikesScreenState();
}

class _HikesScreenState extends State<HikesScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();

  int? _totalHikes;

  List<Hike> _hikes = <Hike>[];
  int _page = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int _requestId = 0;

  int get _pageCount =>
      ((_totalHikes ?? 0) / HikeController.hikesPageSize).ceil();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPage(0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final ModalRoute<void>? route = ModalRoute.of(context);
    if (route is PageRoute<void>) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() => _loadPage(_page, refreshStats: true);

  void _goToPage(int page) {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);

    setState(() => _hikes = <Hike>[]);
    _loadPage(page);
  }

  Future<void> _loadPage(int page, {bool refreshStats = false}) async {
    final HikeController hikeController = context.read<HikeController>();
    final UserController userController = context.read<UserController>();

    final int requestId = ++_requestId;

    setState(() {
      _page = page;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (refreshStats || _totalHikes == null) {
        final HikeStats stats = await userController.getStats();

        if (!mounted || requestId != _requestId) return;

        _totalHikes = stats.totalHikes;

        page = page.clamp(0, max(_pageCount - 1, 0));
      }

      final Paged<Hike> result = await hikeController.getHikesPage(page);

      if (!mounted || requestId != _requestId) return;

      setState(() {
        _hikes = result.content;
        _page = page;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      _setError(requestId, e.message);
    } catch (e) {
      _setError(requestId, 'Something went wrong. Please try again.');
    }
  }

  void _setError(int requestId, String message) {
    if (!mounted || requestId != _requestId) return;

    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hikes')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () => _loadPage(_page, refreshStats: true),
          child: _buildList(),
        ),
      ),
      bottomNavigationBar: _pageCount > 1
          ? BottomAppBar(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: PageSelector(
                  page: _page,
                  pageCount: _pageCount,
                  enabled: !_isLoading,
                  onSelected: _goToPage,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildList() {
    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: <Widget>[
        if (_isLoading && _hikes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          ErrorNotice(icon: Icons.cloud_off_rounded, message: _errorMessage!)
        else if (_hikes.isEmpty)
          const NoHikesNotice()
        else
          for (final Hike hike in _hikes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: HikeCard(hike: hike),
            ),
      ],
    );
  }
}
