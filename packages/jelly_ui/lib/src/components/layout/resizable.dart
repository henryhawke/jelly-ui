import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

/// Controlled split layout with a keyboard-accessible draggable separator.
class JellyResizable extends StatelessWidget {
  const JellyResizable({
    required this.first,
    required this.second,
    required this.ratio,
    required this.onChanged,
    this.axis = Axis.horizontal,
    this.minimumFirst = 80,
    this.minimumSecond = 80,
    this.handleExtent = 16,
    this.semanticLabel = 'Resize panels',
    super.key,
  })  : assert(ratio >= 0 && ratio <= 1),
        assert(minimumFirst >= 0),
        assert(minimumSecond >= 0),
        assert(handleExtent > 0);

  final Widget first;
  final Widget second;
  final double ratio;
  final ValueChanged<double>? onChanged;
  final Axis axis;
  final double minimumFirst;
  final double minimumSecond;
  final double handleExtent;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool horizontal = axis == Axis.horizontal;
        final double total =
            horizontal ? constraints.maxWidth : constraints.maxHeight;
        final double available =
            (total - handleExtent).clamp(0, double.infinity);
        final double lower = available == 0 ? 0 : minimumFirst / available;
        final double upper =
            available == 0 ? 1 : 1 - (minimumSecond / available);
        final double effectiveRatio =
            lower <= upper ? ratio.clamp(lower, upper) : 0.5;
        final double firstExtent = available * effectiveRatio;
        void update(double delta) {
          if (onChanged == null || available <= 0) {
            return;
          }
          final double direction =
              horizontal && Directionality.of(context) == TextDirection.rtl
                  ? -1
                  : 1;
          final double next = (effectiveRatio + (delta * direction / available))
              .clamp(lower <= upper ? lower : 0, lower <= upper ? upper : 1);
          onChanged?.call(next);
        }

        final Widget handle = Semantics(
          label: semanticLabel,
          slider: true,
          value: '${(effectiveRatio * 100).round()}%',
          increasedValue:
              '${((effectiveRatio + 0.05).clamp(0, 1) * 100).round()}%',
          decreasedValue:
              '${((effectiveRatio - 0.05).clamp(0, 1) * 100).round()}%',
          onIncrease: onChanged == null ? null : () => update(available * 0.05),
          onDecrease:
              onChanged == null ? null : () => update(-available * 0.05),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: onChanged == null
                ? null
                : (DragUpdateDetails details) => update(
                      horizontal ? details.delta.dx : details.delta.dy,
                    ),
            child: MouseRegion(
              cursor: horizontal
                  ? SystemMouseCursors.resizeColumn
                  : SystemMouseCursors.resizeRow,
              child: Center(
                child: Container(
                  width: horizontal ? 4 : theme.geometry.controlHeight,
                  height: horizontal ? theme.geometry.controlHeight : 4,
                  decoration: BoxDecoration(
                    color: theme.palette.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        );
        final Widget sizedFirst = SizedBox(
          width: horizontal ? firstExtent : null,
          height: horizontal ? null : firstExtent,
          child: first,
        );
        if (horizontal) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              sizedFirst,
              SizedBox(width: handleExtent, child: handle),
              Expanded(child: second),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            sizedFirst,
            SizedBox(height: handleExtent, child: handle),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}
