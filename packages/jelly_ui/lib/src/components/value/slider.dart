import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

/// Controlled scalar value input using Flutter's native slider semantics.
class JellySlider extends StatelessWidget {
  const JellySlider({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.semanticFormatterCallback,
    this.onChangeStart,
    this.onChangeEnd,
    this.focusNode,
    this.autofocus = false,
    super.key,
  })  : assert(min <= max),
        assert(value >= min && value <= max);

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: theme.palette.primary,
        inactiveTrackColor: theme.palette.surfaceInset,
        disabledActiveTrackColor: theme.palette.disabledForeground,
        disabledInactiveTrackColor: theme.palette.disabledSurface,
        thumbColor: theme.palette.primary,
        disabledThumbColor: theme.palette.disabledForeground,
        overlayColor: theme.palette.primary.withValues(alpha: 0.16),
        valueIndicatorColor: theme.palette.surfaceRaised,
        valueIndicatorTextStyle: theme.typography.label,
        trackHeight: 6,
      ),
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        semanticFormatterCallback: semanticFormatterCallback,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        focusNode: focusNode,
        autofocus: autofocus,
      ),
    );
  }
}
