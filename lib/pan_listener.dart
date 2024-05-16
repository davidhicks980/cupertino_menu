import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Called when a [PanTarget] is entered or exited.
///
/// The [position] describes the global position of the pointer.
///
/// The [onTarget] parameter is true when the pointer is on a [PanTarget].
typedef CupertinoPanUpdateCallback = void Function(DragUpdateDetails position, {bool onTarget});

/// Called when the user starts panning.
///
/// The `position` describes the global position of the pointer.
typedef CupertinoPanStartCallback = void Function(ui.Offset position);

class _PanScope extends InheritedWidget {
  const _PanScope({required super.child, required this.data});
  final PanRouter data;

  @override
  bool updateShouldNotify(_PanScope oldWidget) {
    return oldWidget.data != data;
  }
}

@optionalTypeArgs
mixin PanRouter<T extends StatefulWidget> on State<T> {
  void routePointer(PointerDownEvent event);
}

/// This widget is used by [CupertinoInteractiveMenuItem]s to determine whether
/// the menu item should be highlighted. On items with a defined
/// [CupertinoInteractiveMenuItem.panPressActivationDelay], menu items will be
/// selected after the user's finger has made contact with the menu item for the
/// specified duration
@optionalTypeArgs
class PanRegion extends StatefulWidget {
  /// Creates [PanRegion] that wraps a Cupertino menu and notifies the layer's children during user swiping.
  const PanRegion({
    super.key,
    required this.child,
     this.onPanUpdate,
     this.onPanEnd,
     this.onPanStart,
     this.onPanCanceled,
  });

  /// Called when a [PanTarget] is entered or exited.
  ///
  /// The [position] describes the global position of the pointer.
  ///
  /// The [onTarget] parameter is true when the pointer is on a [PanTarget].
  final CupertinoPanUpdateCallback? onPanUpdate;

  /// Called when the user stops panning.
  ///
  /// The [position] describes the global position of the pointer.
  final GestureDragEndCallback? onPanEnd;

  /// Called when the user starts panning.
  ///
  /// The `position` describes the global position of the pointer.
  final CupertinoPanStartCallback? onPanStart;

  /// Called when a pan did not complete. This can occur when the user drags the
  /// pointer outside of the [PanRegion] area.
  ///
  /// Used by [DragGestureRecognizer.onCancel].
  final GestureDragCancelCallback? onPanCanceled;

  /// The widget below this widget in the tree.
  final Widget child;

  static PanRouter? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_PanScope>()?.data;
  }

  static PanRouter _of(BuildContext context) {
    final PanRouter? result = _maybeOf(context);
    assert(result != null, 'No PanRegion found in context');
    return result!;
  }


  /// Creates a [ImmediateMultiDragGestureRecognizer] to recognize the start of
  /// a pan gesture.
  ImmediateMultiDragGestureRecognizer createRecognizer(
    GestureMultiDragStartCallback onStart,
  ) => ImmediateMultiDragGestureRecognizer()..onStart = onStart;

  @override
  State<PanRegion> createState() => _PanRegionState();

}

class _PanRegionState extends State<PanRegion> with PanRouter {
  ImmediateMultiDragGestureRecognizer? _recognizer;
  bool _isPanning = false;

  @override
  void routePointer(PointerDownEvent event) {
    assert(_recognizer != null);
    assert(!_isPanning);
    _recognizer?.addPointer(event);
  }

  @override
  void initState() {
    super.initState();
    _recognizer = widget.createRecognizer(_beginPan);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recognizer!.gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
  }

  @override
  void dispose() {
    _disposeInactiveRecognizer();
    super.dispose();
  }

  void _disposeInactiveRecognizer() {
    if (!_isPanning && _recognizer != null) {
      _recognizer!.dispose();
      _recognizer = null;
    }
  }

  void _completePan() {
    if (mounted) {
      setState(() {
        _isPanning = false;
      });
    } else {
      _isPanning = false;
      _disposeInactiveRecognizer();
    }
  }

  void _handlePanEnd(DragEndDetails position) {
    _completePan();
    widget.onPanEnd?.call(position);
  }

  void _handlePanCancel() {
    _completePan();
    widget.onPanCanceled?.call();
  }

  Drag? _beginPan(ui.Offset position) {
    assert(!_isPanning);
    _isPanning = true;
    widget.onPanStart?.call(position);
    return _PanHandler(
      router: this,
      viewId: View.of(context).viewId,
      initialPosition: position,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: _handlePanEnd,
      onPanCancel: _handlePanCancel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PanScope(data: this, child: widget.child);
  }
}

/// An area that can initiate panning.
///
/// This widget will report [PointerDownEvent]s it receives to the nearest
/// ancestor [PanRegion].
class PanSurface extends StatelessWidget {
  const PanSurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        PanRegion._of(context).routePointer(event);
      },
      child: child,
    );
  }
}

/// Mix into [State] to receive callbacks when a pointer enters or leaves. This
/// widget's [StatefulWidget] must be a descendant of a [PanRegion].
@optionalTypeArgs
mixin PanTarget<T extends StatefulWidget> on State<T> {
  /// Called when a pointer enters the [PanTarget]. Return true if the pointer
  /// should be considered "on" the [PanTarget], and false otherwise (for
  /// example, when the [PanTarget] is disabled).
  @mustCallSuper
  bool didPanEnter();

  /// Called when the pan is ended or canceled. If `pointerUp` is true,
  /// then the pointer was removed from the screen while over this [PanTarget].
  void didPanLeave({bool pointerUp = false});
}

/// Handles panning events for a [PanRegion]
// This class was adapted from _DragAvatar.
class _PanHandler extends Drag {
  /// Creates a [_PanHandler] that handles panning events for a [PanRegion].
  _PanHandler({
    required Offset initialPosition,
    required this.viewId,
    required this.router,
    this.onPanEnd,
    this.onPanUpdate,
    this.onPanCancel,
  }) : _position = initialPosition {
    _updatePan();
  }

  final int viewId;
  final List<PanTarget> _enteredTargets = <PanTarget>[];
  final CupertinoPanUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragCancelCallback? onPanCancel;
  final PanRouter router;
  Offset _position;

  @override
  void update(DragUpdateDetails details) {
    final Offset oldPosition = _position;
    _position += details.delta;
    if (_position != oldPosition) {
      _updatePan();
      onPanUpdate?.call(details, onTarget: _enteredTargets.isNotEmpty);
    }
  }

  @override
  void end(DragEndDetails details) {
    _leaveAllEntered(pointerUp: true);
    onPanEnd?.call(details);
  }

  @override
  void cancel() {
    _leaveAllEntered();
    onPanCancel?.call();
  }

  void _updatePan() {
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, _position, viewId);
    // Look for the RenderBoxes that corresponds to the hit target
    final List<PanTarget> targets = <PanTarget>[];
    for (final HitTestEntry entry in result.path) {
      if (entry.target case RenderMetaData(:final PanTarget metaData)) {
        if (PanRegion._maybeOf(metaData.context) == router) {
          targets.add(metaData);
        }
      }
    }

    bool listsMatch = false;
    if (
      targets.length >= _enteredTargets.length &&
      _enteredTargets.isNotEmpty
    ) {
      listsMatch = true;
      for (int i = 0; i < _enteredTargets.length; i++) {
        if (targets[i] != _enteredTargets[i]) {
          listsMatch = false;
          break;
        }
      }
    }

    // If everything is the same, bail early.
    if (listsMatch) {
      return;
    }

    // Leave old targets.
    _leaveAllEntered();

    // Enter new targets.
    for (final PanTarget? target in targets) {
      if (target != null) {
        _enteredTargets.add(target);
        if (target.didPanEnter()) {
          HapticFeedback.selectionClick();
          return;
        }
      }
    }
  }

  void _leaveAllEntered({bool pointerUp = false}) {
    for (int i = 0; i < _enteredTargets.length; i += 1) {
      _enteredTargets[i].didPanLeave(pointerUp: pointerUp);
    }
    _enteredTargets.clear();
  }
}
