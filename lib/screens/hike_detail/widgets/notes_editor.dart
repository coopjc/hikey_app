import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/hike_controller.dart';
import '../../../models/hike.dart';
import '../../../widgets/hikey_text_field.dart';

/// The hike's notes, editable in place. A save button appears once they've
/// been changed.
class NotesEditor extends StatefulWidget {
  const NotesEditor({super.key, required this.hike});

  final Hike hike;

  @override
  State<NotesEditor> createState() => _NotesEditorState();
}

class _NotesEditorState extends State<NotesEditor> {
  late final TextEditingController _notes = TextEditingController(
    text: widget.hike.notes,
  );
  late String _saved = (widget.hike.notes ?? '').trim();
  bool _isSaving = false;

  bool get _hasChanges => _notes.text.trim() != _saved;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final HikeController hikes = context.read<HikeController>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String notes = _notes.text.trim();

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final String? error = await hikes.updateNotes(widget.hike, notes);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (error == null) _saved = notes;
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error == null ? 'Notes saved.' : "Couldn't save your notes: $error",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        HikeyTextField(
          controller: _notes,
          label: 'Notes',
          hint: 'Trail conditions, views, anything worth keeping',
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 3,
          maxLines: 8,
          enabled: !_isSaving,
          onChanged: (_) => setState(() {}),
        ),
        if (_hasChanges || _isSaving) ...<Widget>[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Saving…' : 'Save notes'),
          ),
        ],
      ],
    );
  }
}
