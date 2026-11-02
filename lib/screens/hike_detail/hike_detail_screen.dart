import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/api_exception.dart';
import '../../controllers/hike_controller.dart';
import '../../models/hike.dart';
import '../../utils/hike_format.dart';
import '../../utils/relative_time.dart';
import '../../widgets/error_notice.dart';
import 'widgets/delete_hike_button.dart';
import 'widgets/detail_row.dart';
import 'widgets/detail_stat.dart';
import 'widgets/notes_editor.dart';

class HikeDetailScreen extends StatefulWidget {
  const HikeDetailScreen({super.key, required this.hikeId});

  final int hikeId;

  @override
  State<HikeDetailScreen> createState() => _HikeDetailScreenState();
}

class _HikeDetailScreenState extends State<HikeDetailScreen> {
  Hike? _hike;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadHike();
    });
  }

  Future<void> _loadHike() async {
    final HikeController hikeController = context.read<HikeController>();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Hike hike = await hikeController.getHike(widget.hikeId);

      if (!mounted) return;

      _hike = hike;
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
    final Hike? hike = _hike;
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: hike == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Last updated ${relativeLabel(hike.updatedAt)}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadHike,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: <Widget>[
              if (_isLoading && hike == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                ErrorNotice(
                  icon: Icons.cloud_off_rounded,
                  message: _errorMessage!,
                )
              else if (hike != null)
                ..._buildDetails(hike),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails(Hike hike) {
    final ThemeData theme = Theme.of(context);

    return <Widget>[
      Text(
        hike.name,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 24),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: DetailStat(
                icon: Icons.route_rounded,
                value: formatMiles(hike.distanceMiles),
                label: 'Miles',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DetailStat(
                icon: Icons.timer_rounded,
                value: formatDuration(hike.duration),
                label: 'Duration',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const SizedBox(height: 32),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: 12),
      Card.outlined(
        child: DetailRow(label: 'Date', value: _dateLabel(hike.createdAt)),
      ),
      const SizedBox(height: 16),
      // Keyed so a refresh that brings back changed notes resets the editor.
      NotesEditor(key: ValueKey<DateTime>(hike.updatedAt), hike: hike),
      const SizedBox(height: 32),
      DeleteHikeButton(hike: hike),
    ];
  }

  String _dateLabel(DateTime dateTime) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }
}
