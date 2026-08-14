import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';
import '../choice/segmented.dart';

@immutable
final class JellyTab<T> {
  const JellyTab({
    required this.value,
    required this.label,
    required this.child,
    this.semanticLabel,
    this.enabled = true,
  });

  final T value;
  final Widget label;
  final Widget child;
  final String? semanticLabel;
  final bool enabled;
}

/// Controlled typed tabs with a motion-aware content transition.
class JellyTabs<T> extends StatelessWidget {
  const JellyTabs({
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.expanded = true,
    super.key,
  }) : assert(tabs.length > 1);

  final List<JellyTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final JellyThemeData data = JellyTheme.of(context);
    final theme = data.resolveFor(context);
    final JellyTab<T> selected = tabs.firstWhere(
      (JellyTab<T> tab) => tab.value == value,
      orElse: () => tabs.first,
    );
    final Duration duration =
        data.reduceMotionFor(context) ? Duration.zero : theme.transitions.fast;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        JellySegmented<T>(
          value: selected.value,
          onChanged: onChanged,
          expanded: expanded,
          segments: tabs
              .map(
                (JellyTab<T> tab) => JellySegment<T>(
                  value: tab.value,
                  label: tab.label,
                  semanticLabel: tab.semanticLabel,
                  enabled: tab.enabled,
                ),
              )
              .toList(growable: false),
        ),
        SizedBox(height: theme.geometry.spacing.md),
        AnimatedSwitcher(
          duration: duration,
          switchInCurve: theme.transitions.settleCurve,
          switchOutCurve: theme.transitions.pressCurve,
          child: KeyedSubtree(
            key: ValueKey<T>(selected.value),
            child: selected.child,
          ),
        ),
      ],
    );
  }
}
