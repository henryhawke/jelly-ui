import 'package:flutter/material.dart';

import '../foundation/foundation.dart';
import '../theme/jelly_theme.dart';
import '../theme/tokens.dart';
import 'jelly_surface_controller.dart';
import 'jelly_surface_painter.dart';

/// Paints a morph-resolved soft-body surface behind a stable child subtree.
class JellySurface extends StatefulWidget {
  const JellySurface({
    required this.child,
    this.role = JellySurfaceRole.container,
    this.tone = JellySemanticTone.neutral,
    this.states = const <WidgetState>{},
    this.controller,
    this.padding = EdgeInsets.zero,
    this.minimumSize,
    this.radius,
    super.key,
  });

  final Widget child;
  final JellySurfaceRole role;
  final JellySemanticTone tone;
  final Set<WidgetState> states;
  final JellySurfaceController? controller;
  final EdgeInsetsGeometry padding;
  final Size? minimumSize;
  final double? radius;

  @override
  State<JellySurface> createState() => _JellySurfaceState();
}

class _JellySurfaceState extends State<JellySurface> {
  JellySurfaceController? _ownedController;

  JellySurfaceController get _controller {
    return widget.controller ?? (_ownedController ??= JellySurfaceController());
  }

  @override
  void didUpdateWidget(covariant JellySurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _ownedController?.dispose();
      _ownedController = null;
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final JellyThemeData data = JellyTheme.of(context);
    final JellyMorphTheme theme = data.resolveFor(context);
    final JellyMotionSettings configuredMotion = data.motion;
    final bool reduced = data.reduceMotionFor(context);
    final JellyMotionMode effectiveMode =
        configuredMotion.mode == JellyMotionMode.none
            ? JellyMotionMode.none
            : reduced
                ? JellyMotionMode.reduced
                : JellyMotionMode.adaptive;
    _controller.updatePolicy(
      mode: effectiveMode,
      intensity: configuredMotion.intensity,
      quality: configuredMotion.quality,
      // TickerMode.valuesOf was added after Jelly's provisional Flutter floor.
      // ignore: deprecated_member_use
      enabled: TickerMode.of(context),
    );

    JellySurfaceStyle style =
        theme.surfaces[widget.role].resolve(widget.states);
    if (widget.tone != JellySemanticTone.neutral &&
        !widget.states.contains(WidgetState.disabled)) {
      style = style.copyWith(
        fill: theme.palette.tone(widget.tone),
        foreground: theme.palette.foregroundFor(widget.tone),
      );
    }
    style = style.copyWith(
      focus: style.fill.computeLuminance() < 0.35
          ? theme.palette.focusOnDark
          : theme.palette.focus,
    );
    final double radius = widget.radius ?? style.radius;
    final Size minimum = widget.minimumSize ?? Size.zero;
    final Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minimum.width,
        minHeight: minimum.height,
      ),
      child: Transform.translate(
        offset: style.contentOffset,
        child: Padding(
          padding: widget.padding,
          child: IconTheme.merge(
            data: IconThemeData(color: style.foreground),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: style.foreground),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    return RepaintBoundary(
      child: CustomPaint(
        painter: JellySurfacePainter(
          controller: _controller,
          style: style.copyWith(radius: radius),
          backgroundColor: theme.palette.canvas,
          focused: widget.states.contains(WidgetState.focused),
          focusWidth: theme.geometry.focusWidth,
          focusGap: theme.geometry.focusGap,
          curveTension: 0.68,
        ),
        child: content,
      ),
    );
  }
}
