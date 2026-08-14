import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

/// Token-resolved separator for horizontal or vertical layouts.
class JellyDivider extends StatelessWidget {
  const JellyDivider({
    this.axis = Axis.horizontal,
    this.thickness,
    this.indent = 0,
    super.key,
  });

  final Axis axis;
  final double? thickness;
  final double indent;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    final double width = thickness ?? theme.geometry.borderThin;
    if (axis == Axis.vertical) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: indent),
        child: SizedBox(
            width: width, child: ColoredBox(color: theme.palette.border)),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: indent),
      child: SizedBox(
          height: width, child: ColoredBox(color: theme.palette.border)),
    );
  }
}
