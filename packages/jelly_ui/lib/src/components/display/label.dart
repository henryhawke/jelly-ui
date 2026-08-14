import 'package:flutter/material.dart';

import '../../theme/jelly_theme.dart';

/// Consistent field/control label with an explicit required cue.
class JellyLabel extends StatelessWidget {
  const JellyLabel({
    required this.text,
    this.required = false,
    super.key,
  });

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return Text.rich(
      TextSpan(
        text: text,
        children: <InlineSpan>[
          if (required)
            TextSpan(
              text: ' (required)',
              style: TextStyle(color: theme.palette.danger),
            ),
        ],
      ),
      style: theme.typography.label,
    );
  }
}
