import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

/// One typed option consumed by [JellySegmented].
@immutable
final class JellySegment<T> {
  const JellySegment({
    required this.value,
    required this.label,
    this.enabled = true,
    this.semanticLabel,
  });

  final T value;
  final Widget label;
  final bool enabled;
  final String? semanticLabel;
}

/// Controlled single-selection segmented control.
class JellySegmented<T> extends StatelessWidget {
  const JellySegmented({
    required this.segments,
    required this.value,
    required this.onChanged,
    this.expanded = true,
    super.key,
  }) : assert(segments.length > 1);

  final List<JellySegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final Widget row = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: segments.map((JellySegment<T> segment) {
        final bool selected = segment.value == value;
        final Widget item = JellyPressableSurface(
          onPressed: onChanged == null || !segment.enabled
              ? null
              : () => onChanged?.call(segment.value),
          role: JellySurfaceRole.quietAction,
          tone: selected ? JellySemanticTone.info : JellySemanticTone.neutral,
          selected: selected,
          semanticsSelected: selected,
          minimumSize: Size(0, theme.geometry.minimumTouchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: theme.geometry.spacing.md,
          ),
          semanticLabel: segment.semanticLabel,
          semanticsButton: false,
          semanticsChecked: selected,
          semanticsMutuallyExclusive: true,
          child: Center(
            child: DefaultTextStyle.merge(
              style: theme.typography.label.copyWith(
                color: selected
                    ? theme.palette.foregroundFor(JellySemanticTone.info)
                    : theme.surfaces.quietAction.normal.foreground,
              ),
              child: segment.label,
            ),
          ),
        );
        return expanded ? Expanded(child: item) : item;
      }).toList(growable: false),
    );
    return JellySurface(
      role: JellySurfaceRole.selectionTrack,
      padding: const EdgeInsets.all(3),
      radius: 999,
      child: row,
    );
  }
}
