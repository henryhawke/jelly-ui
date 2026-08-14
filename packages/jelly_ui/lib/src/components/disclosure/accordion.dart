import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';
import 'collapsible.dart';

@immutable
final class JellyAccordionItem<T> {
  const JellyAccordionItem({
    required this.value,
    required this.header,
    required this.child,
    this.semanticLabel,
    this.enabled = true,
  });

  final T value;
  final Widget header;
  final Widget child;
  final String? semanticLabel;
  final bool enabled;
}

/// Controlled collection of disclosure rows.
class JellyAccordion<T> extends StatelessWidget {
  const JellyAccordion({
    required this.items,
    required this.expandedValues,
    required this.onChanged,
    this.allowMultiple = false,
    this.maintainState = true,
    super.key,
  });

  final List<JellyAccordionItem<T>> items;
  final Set<T> expandedValues;
  final ValueChanged<Set<T>>? onChanged;
  final bool allowMultiple;
  final bool maintainState;

  void _toggle(T value, bool expanded) {
    if (onChanged == null) {
      return;
    }
    final Set<T> next = allowMultiple ? <T>{...expandedValues} : <T>{};
    if (expanded) {
      next.add(value);
    } else {
      next.remove(value);
    }
    onChanged?.call(Set<T>.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < items.length; index++) ...<Widget>[
          JellyCollapsible(
            expanded: expandedValues.contains(items[index].value),
            onChanged: onChanged == null
                ? null
                : (bool value) => _toggle(items[index].value, value),
            header: items[index].header,
            semanticLabel: items[index].semanticLabel,
            enabled: items[index].enabled,
            maintainState: maintainState,
            child: items[index].child,
          ),
          if (index != items.length - 1)
            SizedBox(height: theme.geometry.spacing.sm),
        ],
      ],
    );
  }
}
