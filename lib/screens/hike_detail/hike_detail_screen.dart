import 'package:flutter/material.dart';

import '../../models/hike.dart';
import '../../utils/hike_format.dart';
import '../../utils/relative_time.dart';
import 'widgets/delete_hike_button.dart';
import 'widgets/detail_row.dart';
import 'widgets/detail_stat.dart';
import 'widgets/notes_editor.dart';

class HikeDetailScreen extends StatelessWidget {
  const HikeDetailScreen({super.key, required this.hike});

  final Hike hike;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(hike.name)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 28,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: const Icon(Icons.terrain_rounded, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        hike.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Chip(
                            label: Text(hike.status.label),
                            labelStyle: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                            backgroundColor: scheme.secondaryContainer,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            'Updated ${relativeLabel(hike.updatedAt)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
              child: DetailRow(
                label: 'Date',
                value: _dateLabel(hike.createdAt),
              ),
            ),
            const SizedBox(height: 16),
            NotesEditor(hike: hike),
            const SizedBox(height: 32),
            DeleteHikeButton(hike: hike),
          ],
        ),
      ),
    );
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
