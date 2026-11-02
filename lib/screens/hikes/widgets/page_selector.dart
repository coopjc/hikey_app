import 'package:flutter/material.dart';

class PageSelector extends StatelessWidget {
  const PageSelector({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onSelected,
    this.enabled = true,
  });

  final int page;
  final int pageCount;
  final ValueChanged<int> onSelected;
  final bool enabled;

  static const Size _buttonSize = Size(36, 36);

  List<int?> _visiblePages() {
    final List<int> pinned = <int>{
      0,
      for (int i = page - 1; i <= page + 1; i++)
        if (i >= 0 && i < pageCount) i,
      pageCount - 1,
    }.toList()..sort();

    final List<int?> pages = <int?>[];

    for (final int p in pinned) {
      if (pages.isNotEmpty) {
        final int gap = p - pages.last!;

        if (gap == 2) pages.add(p - 1);
        if (gap > 2) pages.add(null);
      }

      pages.add(p);
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ButtonStyle pageStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll<Size>(_buttonSize),
      padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            tooltip: 'Previous page',
            onPressed: enabled && page > 0 ? () => onSelected(page - 1) : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          for (final int? p in _visiblePages())
            if (p == null)
              SizedBox(
                width: 24,
                child: Text(
                  '…',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: p == page
                    ? FilledButton(
                        style: pageStyle,
                        onPressed: enabled ? () {} : null,
                        child: Text('${p + 1}'),
                      )
                    : TextButton(
                        style: pageStyle,
                        onPressed: enabled ? () => onSelected(p) : null,
                        child: Text('${p + 1}'),
                      ),
              ),
          IconButton(
            tooltip: 'Next page',
            onPressed: enabled && page < pageCount - 1
                ? () => onSelected(page + 1)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
