import 'package:flutter/material.dart';

import '../../foundation/foundation.dart';
import '../../rendering/jelly_surface.dart';
import '../../theme/jelly_theme.dart';

final class JellyPopoverController extends ChangeNotifier {
  JellyPopoverController({bool open = false}) : _open = open;

  bool _open;

  bool get open => _open;

  void show() => _setOpen(true);

  void hide() => _setOpen(false);

  void toggle() => _setOpen(!_open);

  void _setOpen(bool value) {
    if (_open == value) {
      return;
    }
    _open = value;
    notifyListeners();
  }
}

typedef JellyPopoverAnchorBuilder = Widget Function(
  BuildContext context,
  JellyPopoverController controller,
);

/// Anchored overlay with an explicit, reusable controller.
class JellyPopover extends StatefulWidget {
  const JellyPopover({
    required this.anchorBuilder,
    required this.popover,
    this.controller,
    this.offset = const Offset(0, 8),
    this.width,
    this.semanticLabel,
    super.key,
  });

  final JellyPopoverAnchorBuilder anchorBuilder;
  final Widget popover;
  final JellyPopoverController? controller;
  final Offset offset;
  final double? width;
  final String? semanticLabel;

  @override
  State<JellyPopover> createState() => _JellyPopoverState();
}

class _JellyPopoverState extends State<JellyPopover> {
  final LayerLink _link = LayerLink();
  final Object _tapGroup = Object();
  final OverlayPortalController _portal = OverlayPortalController();
  JellyPopoverController? _ownedController;

  JellyPopoverController get _controller {
    return widget.controller ?? (_ownedController ??= JellyPopoverController());
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) => _sync());
  }

  @override
  void didUpdateWidget(covariant JellyPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownedController)?.removeListener(_sync);
      if (widget.controller != null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      _controller.addListener(_sync);
      WidgetsBinding.instance.addPostFrameCallback((Duration _) => _sync());
    }
  }

  void _sync() {
    if (!mounted) {
      return;
    }
    if (_controller.open) {
      _portal.show();
    } else {
      _portal.hide();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = JellyTheme.of(context).resolveFor(context);
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (BuildContext context) {
        return CompositedTransformFollower(
          link: _link,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: widget.offset,
          showWhenUnlinked: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: TapRegion(
              groupId: _tapGroup,
              onTapOutside: (PointerDownEvent _) => _controller.hide(),
              child: Semantics(
                container: true,
                label: widget.semanticLabel,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: widget.width ?? 320,
                  ),
                  child: JellySurface(
                    role: JellySurfaceRole.overlay,
                    padding: EdgeInsets.all(theme.geometry.spacing.md),
                    child: widget.popover,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(
          groupId: _tapGroup,
          child: Semantics(
            expanded: _controller.open,
            child: widget.anchorBuilder(context, _controller),
          ),
        ),
      ),
    );
  }
}
