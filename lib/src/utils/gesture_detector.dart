import 'dart:async';

import 'package:cupertino_menu/src/utils/controllers.dart';
import 'package:cupertino_menu/src/utils/swipe_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Default menu gesture detector for applying on pressed color and / or on hover
/// color, and providing builder method that exposes `isHovered` state to
/// descendant widgets.
@immutable
class CupertinoMenuItemGestureDetector extends StatefulWidget {
  /// Creates default menu gesture detector.
  const CupertinoMenuItemGestureDetector({
    super.key,
    required this.onTap,
    required this.pressedColor,
    required this.child,
    this.swipePressActivationDelay = Duration.zero,
  });

  /// Called when the menu item is tapped.
  final FutureOr<void> Function()? onTap;

  final Widget child;

  final Duration swipePressActivationDelay;

  /// Color of container during press event.
  final Color pressedColor;

  @override
  State<CupertinoMenuItemGestureDetector> createState() =>
      _CupertinoMenuItemGestureDetectorState();
}

class _CupertinoMenuItemGestureDetectorState
    extends State<CupertinoMenuItemGestureDetector> {
  bool get enabled => widget.onTap != null && _isLayerActive && mounted;
  Timer? _pressOnSwipeTimerCallback;
  bool _isSwiped = false;
  bool _isPressed = false;
  bool _isLayerActive = true;
  ValueNotifier<CupertinoSwipeDetails?>? _swipeState;

  void onTap() {
    if (enabled) {
      widget.onTap?.call();
      setState(() {
        _isPressed = false;
        _isSwiped = false;
      });
    }
  }

  void onTapDown(TapDownDetails details) {
    if (enabled) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
      _isSwiped = false;
    });
  }

  void onTapCancel() {
    setState(() {
      _isPressed = false;
      _isSwiped = false;
    });
  }

  void _handleSwipePositionUpdates() {
    if (!enabled) {
      return;
    }

    final swipeState = _swipeState?.value;
    if (swipeState == null) {
      return;
    }

    final RenderBox renderBox = context.findRenderObject()! as RenderBox;

    // Check if the user's pointer position is contained within this widget's bounds
    final Rect bounds = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final bool isSwiped = bounds.contains(swipeState.globalPosition);

    // If the item is set to trigger on swipe:

    // * When the user's pointer enters the menu item, start a timer to dispatch a
    // SwipeCompletedNotification, which will bubble to CupertinoSwipeListener. CupertinoSwipeListener will
    // respond by emitting a completed CupertinoSwipeDetails. A new CupertinoSwipeDetails notification
    // will retrigger _handleSwipePositionUpdates, which will then call onTap.
    //
    // * If the item is not swiped, cancel the timer.
    //
    // FIXME - I recently switched from using an overlay for nested menus to using a route. This switch
    // led to unexpected activation, so I've removed the ability to navigate to nested menus for now. Will fix shortly.
    if (widget.swipePressActivationDelay > Duration.zero) {
      if (isSwiped) {
        _pressOnSwipeTimerCallback ??=
            Timer(widget.swipePressActivationDelay, () {
          if (mounted) {
            SwipeCompletedNotification().dispatch(context);
          }
        });
      } else {
        _pressOnSwipeTimerCallback?.cancel();
        _pressOnSwipeTimerCallback = null;
      }
    }

    // If the pointer's previous position was within the bounds of this menu item and the pointer has lost
    // contact with the screen, tap the menu item.
    if (swipeState.complete && isSwiped) {
      onTap();
    } else if (isSwiped != _isSwiped) {
      setState(() {
        _isSwiped = isSwiped;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isLayerActive = CupertinoMenuController.of(context).topLayer ==
        CupertinoMenuLayerController.of(context).depth;

    final newSwipeState = CupertinoSwipeListener.notifierOf(context);
    if (newSwipeState != _swipeState) {
      _swipeState?.removeListener(_handleSwipePositionUpdates);
      _swipeState = newSwipeState;
      _swipeState?.addListener(_handleSwipePositionUpdates);
    }
  }

  @override
  void dispose() {
    _pressOnSwipeTimerCallback?.cancel();
    _swipeState?.removeListener(_handleSwipePositionUpdates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: enabled && kIsWeb ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        onTapDown: onTapDown,
        onTapCancel: onTapCancel,
        onTapUp: onTapUp,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: (_isPressed || _isSwiped) && enabled
                ? widget.pressedColor
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
