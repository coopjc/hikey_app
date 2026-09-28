import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/hike_controller.dart';
import '../../../models/hike.dart';

/// Deletes the hike after confirmation, then leaves the detail screen.
class DeleteHikeButton extends StatefulWidget {
  const DeleteHikeButton({super.key, required this.hike});

  final Hike hike;

  @override
  State<DeleteHikeButton> createState() => _DeleteHikeButtonState();
}

class _DeleteHikeButtonState extends State<DeleteHikeButton> {
  bool _isDeleting = false;

  Future<void> _confirmAndDelete() async {
    final HikeController hikes = context.read<HikeController>();
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        icon: Icon(Icons.delete_forever_rounded, color: colors.error),
        title: const Text('Delete hike?'),
        content: Text(
          '"${widget.hike.name}" will be permanently deleted. '
          "This can't be undone.",
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final String? error = await hikes.deleteHike(widget.hike);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text("Couldn't delete this hike: $error")),
      );
      return;
    }

    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Hike deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      // Disabled while the request is out, so it can't be sent twice.
      onPressed: _isDeleting ? null : _confirmAndDelete,
      icon: const Icon(Icons.delete_outline_rounded),
      label: Text(_isDeleting ? 'Deleting…' : 'Delete hike'),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error),
      ),
    );
  }
}
