import 'package:flutter/material.dart';
import 'package:hikey_app/screens/hike_detail/hike_detail_screen.dart';

import '../../../models/hike.dart';
import '../../../utils/relative_time.dart';

class HikeCard extends StatelessWidget {
  const HikeCard({super.key, required this.hike});

  final Hike hike;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Card.outlined(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => HikeDetailScreen(hike: hike)),
        ),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: const Icon(Icons.terrain_rounded),
        ),
        title: Text(
          hike.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${hike.status.label} · ${relativeLabel(hike.updatedAt)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
