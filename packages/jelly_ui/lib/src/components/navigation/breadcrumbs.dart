import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../theme/jelly_theme.dart';
import '../internal/pressable_surface.dart';

@immutable
final class JellyBreadcrumbItem {
  const JellyBreadcrumbItem({
    required this.label,
    this.onPressed,
    this.semanticLabel,
  });

  final Widget label;
  final VoidCallback? onPressed;
  final String? semanticLabel;
}

/// Wrapping breadcrumb trail with one current destination.
class JellyBreadcrumbs extends StatelessWidget {
  const JellyBreadcrumbs({
    required this.items,
    this.separator = const Icon(Icons.chevron_right, size: 18),
    this.semanticLabel = 'Breadcrumbs',
    super.key,
  }) : assert(items.length > 0);

  final List<JellyBreadcrumbItem> items;
  final Widget separator;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final List<Widget> children = <Widget>[];
    for (int index = 0; index < items.length; index++) {
      final JellyBreadcrumbItem item = items[index];
      final bool current = index == items.length - 1;
      if (index > 0) {
        children.add(
          ExcludeSemantics(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.geometry.spacing.xs,
              ),
              child: separator,
            ),
          ),
        );
      }
      if (current || item.onPressed == null) {
        children.add(
          Semantics(
            selected: current,
            label: item.semanticLabel,
            child: DefaultTextStyle.merge(
              style: theme.typography.label.copyWith(
                color: current
                    ? theme.palette.textStrong
                    : theme.palette.textMuted,
              ),
              child: item.label,
            ),
          ),
        );
      } else {
        children.add(
          JellyPressableSurface(
            onPressed: item.onPressed,
            role: JellySurfaceRole.quietAction,
            minimumSize: Size(0, theme.geometry.minimumTouchTarget),
            padding: EdgeInsets.symmetric(
              horizontal: theme.geometry.spacing.sm,
            ),
            semanticLabel: item.semanticLabel,
            child: DefaultTextStyle.merge(
              style: theme.typography.label,
              child: item.label,
            ),
          ),
        );
      }
    }
    return Semantics(
      container: true,
      label: semanticLabel,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }
}
