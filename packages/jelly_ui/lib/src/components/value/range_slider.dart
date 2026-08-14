import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

/// Controlled two-thumb range using Flutter's native range semantics.
class JellyRangeSlider extends StatelessWidget {
  const JellyRangeSlider({
    required this.values,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.labels,
    this.semanticFormatterCallback,
    this.onChangeStart,
    this.onChangeEnd,
    super.key,
  }) : assert(min <= max);

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final RangeLabels? labels;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final ValueChanged<RangeValues>? onChangeStart;
  final ValueChanged<RangeValues>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: theme.palette.primary,
        inactiveTrackColor: theme.palette.surfaceInset,
        disabledActiveTrackColor: theme.palette.disabledForeground,
        disabledInactiveTrackColor: theme.palette.disabledSurface,
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 12,
          disabledThumbRadius: 11,
        ),
        thumbColor: theme.palette.primary,
        disabledThumbColor: theme.palette.disabledForeground,
        overlayColor: theme.palette.primary.withValues(alpha: 0.16),
        valueIndicatorColor: theme.palette.surfaceRaised,
        valueIndicatorTextStyle: theme.typography.label,
        trackHeight: 6,
      ),
      child: RangeSlider(
        values: values,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        labels: labels,
        semanticFormatterCallback: semanticFormatterCallback,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}
