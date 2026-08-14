import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

@immutable
final class JellyMenuItem<T> {
  const JellyMenuItem({
    required this.value,
    required this.child,
    this.enabled = true,
  });

  final T value;
  final Widget child;
  final bool enabled;
}

/// Anchored menu that delegates route, keyboard, and dismissal behavior.
class JellyMenu<T> extends StatelessWidget {
  const JellyMenu({
    required this.items,
    required this.onSelected,
    required this.child,
    this.onCanceled,
    this.tooltip,
    this.enabled = true,
    this.offset = Offset.zero,
    super.key,
  });

  final List<JellyMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final VoidCallback? onCanceled;
  final Widget child;
  final String? tooltip;
  final bool enabled;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return PopupMenuButton<T>(
      enabled: enabled,
      tooltip: tooltip,
      offset: offset,
      color: theme.palette.surfaceRaised,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: theme.palette.border,
          width: theme.geometry.borderStandard,
        ),
        borderRadius: BorderRadius.circular(theme.geometry.radiusMedium),
      ),
      onSelected: onSelected,
      onCanceled: onCanceled,
      itemBuilder: (BuildContext context) => items
          .map(
            (JellyMenuItem<T> item) => PopupMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              child: DefaultTextStyle.merge(
                style: theme.typography.body,
                child: item.child,
              ),
            ),
          )
          .toList(growable: false),
      child: child,
    );
  }
}
