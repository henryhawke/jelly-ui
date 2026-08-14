import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../rendering/jelly_surface_controller.dart';

class JellyPressableSurface extends StatefulWidget {
  const JellyPressableSurface({
    required this.child,
    required this.onPressed,
    required this.minimumSize,
    this.role = JellySurfaceRole.action,
    this.tone = JellySemanticTone.primary,
    this.padding = EdgeInsets.zero,
    this.semanticLabel,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.selected = false,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Size minimumSize;
  final JellySurfaceRole role;
  final JellySemanticTone tone;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool selected;

  @override
  State<JellyPressableSurface> createState() => _JellyPressableSurfaceState();
}

class _JellyPressableSurfaceState extends State<JellyPressableSurface> {
  final JellySurfaceController _controller = JellySurfaceController();
  final Set<WidgetState> _states = <WidgetState>{};

  bool get _enabled => widget.onPressed != null;

  void _setState(WidgetState state, {required bool enabled}) {
    final bool changed = enabled ? _states.add(state) : _states.remove(state);
    if (changed && mounted) {
      setState(() {});
    }
  }

  Offset _centered(Offset localPosition) {
    return localPosition -
        Offset(_controller.body.width / 2, _controller.body.height / 2);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_enabled) {
      return;
    }
    _setState(WidgetState.pressed, enabled: true);
    _controller.pressAt(_centered(details.localPosition));
  }

  void _releaseVisual() {
    _setState(WidgetState.pressed, enabled: false);
    _controller.release();
  }

  void _activate() {
    if (!_enabled) {
      return;
    }
    _controller.centerPop();
    widget.onPressed?.call();
  }

  @override
  void didUpdateWidget(covariant JellyPressableSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && oldWidget.onPressed != null) {
      _releaseVisual();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Set<WidgetState> states = <WidgetState>{..._states};
    if (!_enabled) {
      states.add(WidgetState.disabled);
    }
    if (widget.selected) {
      states.add(WidgetState.selected);
    }

    Widget result = Semantics(
      container: true,
      button: true,
      enabled: _enabled,
      selected: widget.selected ? true : null,
      label: widget.semanticLabel,
      onTap: _enabled ? _activate : null,
      child: ExcludeSemantics(
        excluding: widget.semanticLabel != null,
        child: FocusableActionDetector(
          enabled: _enabled,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          mouseCursor:
              _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onShowFocusHighlight: (bool value) {
            _setState(WidgetState.focused, enabled: value);
          },
          onShowHoverHighlight: (bool value) {
            _setState(WidgetState.hovered, enabled: value);
          },
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (ActivateIntent intent) {
                _activate();
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _enabled ? _handleTapDown : null,
            onTapUp:
                _enabled ? (TapUpDetails details) => _releaseVisual() : null,
            onTapCancel: _enabled ? _releaseVisual : null,
            onTap: _enabled ? widget.onPressed : null,
            child: JellySurface(
              controller: _controller,
              states: Set<WidgetState>.unmodifiable(states),
              role: widget.role,
              tone: widget.tone,
              padding: widget.padding,
              minimumSize: widget.minimumSize,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
    if (widget.tooltip case final String tooltip) {
      result = Tooltip(message: tooltip, child: result);
    }
    return result;
  }
}
