import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

Future<T?> showJellyDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
}) {
  return showDialog<T>(
    context: context,
    builder: builder,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
  );
}

/// Dialog body intended for [showJellyDialog].
class JellyDialog extends StatelessWidget {
  const JellyDialog({
    required this.child,
    this.title,
    this.actions = const <Widget>[],
    this.width = 420,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final Widget? title;
  final List<Widget> actions;
  final double width;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(theme.geometry.spacing.lg),
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        label: semanticLabel,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: JellySurface(
            role: JellySurfaceRole.overlay,
            padding: EdgeInsets.all(theme.geometry.spacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  DefaultTextStyle.merge(
                    style: theme.typography.title,
                    child: title!,
                  ),
                  SizedBox(height: theme.geometry.spacing.md),
                ],
                child,
                if (actions.isNotEmpty) ...<Widget>[
                  SizedBox(height: theme.geometry.spacing.lg),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: theme.geometry.spacing.sm,
                    runSpacing: theme.geometry.spacing.sm,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
