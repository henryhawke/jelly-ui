import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../theme/jelly_theme.dart';
import '../actions/button.dart';
import '../actions/icon_button.dart';

/// Controlled, one-based pagination with a bounded visible window.
class JellyPagination extends StatelessWidget {
  const JellyPagination({
    required this.page,
    required this.pageCount,
    required this.onChanged,
    this.windowSize = 5,
    this.semanticLabel = 'Pagination',
    super.key,
  })  : assert(pageCount > 0),
        assert(page >= 1 && page <= pageCount),
        assert(windowSize >= 3);

  final int page;
  final int pageCount;
  final ValueChanged<int>? onChanged;
  final int windowSize;
  final String semanticLabel;

  List<int?> _visiblePages() {
    if (pageCount <= windowSize) {
      return List<int>.generate(pageCount, (int index) => index + 1);
    }
    final int interior = math.max(1, windowSize - 2);
    int start = (page - interior ~/ 2).clamp(2, pageCount - interior);
    final int end = math.min(pageCount - 1, start + interior - 1);
    start = math.max(2, end - interior + 1);
    return <int?>[
      1,
      if (start > 2) null,
      for (int value = start; value <= end; value++) value,
      if (end < pageCount - 1) null,
      pageCount,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: theme.geometry.spacing.xs,
        runSpacing: theme.geometry.spacing.xs,
        children: <Widget>[
          JellyIconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: page == 1 || onChanged == null
                ? null
                : () => onChanged?.call(page - 1),
            tooltip: 'Previous page',
          ),
          for (final int? candidate in _visiblePages())
            if (candidate == null)
              Semantics(
                label: 'More pages',
                child: SizedBox(
                  width: theme.geometry.minimumTouchTarget,
                  height: theme.geometry.minimumTouchTarget,
                  child: const Center(child: Text('…')),
                ),
              )
            else
              JellyButton(
                onPressed: onChanged == null || candidate == page
                    ? null
                    : () => onChanged?.call(candidate),
                variant: candidate == page
                    ? JellyButtonVariant.solid
                    : JellyButtonVariant.quiet,
                semanticLabel: candidate == page
                    ? 'Page $candidate, current page'
                    : 'Go to page $candidate',
                size: JellyControlSize.compact,
                child: Text('$candidate'),
              ),
          JellyIconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: page == pageCount || onChanged == null
                ? null
                : () => onChanged?.call(page + 1),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}
