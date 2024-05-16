// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart'
    hide
        ScrollIncrementType,
        Scrollable,
        TwoDimensionalViewportBuilder,
        ViewportBuilder;

import 'scroll_controller_2.dart';

export 'package:flutter/physics.dart' show Tolerance;

// Examples can assume:
// late BuildContext context;

typedef ViewportBuilder = Widget Function(
    BuildContext context, ViewportOffset position);

typedef TwoDimensionalViewportBuilder = Widget Function(BuildContext context,
    ViewportOffset verticalPosition, ViewportOffset horizontalPosition);

// The return type of _performEnsureVisible.
//
// The list of futures represents each pending ScrollPosition call to
// ensureVisible. The returned ScrollableState's context is used to find the
// next potential ancestor Scrollable.
typedef _EnsureVisibleResults = (List<Future<void>>, ScrollableState);

class Scrollable extends StatefulWidget {
  const Scrollable({
    super.key,
    this.axisDirection = AxisDirection.down,
    this.controller,
    this.physics,
    required this.viewportBuilder,
    this.incrementCalculator,
    this.excludeFromSemantics = false,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.restorationId,
    this.scrollBehavior,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
  }) : assert(semanticChildCount == null || semanticChildCount >= 0);

  final AxisDirection axisDirection;

  final ScrollController? controller;

  final ScrollPhysics? physics;

  final ViewportBuilder viewportBuilder;

  final ScrollIncrementCalculator? incrementCalculator;

  final bool excludeFromSemantics;

  final HitTestBehavior hitTestBehavior;

  final int? semanticChildCount;

  // TODO(jslavitz): Set the DragStartBehavior default to be start across all widgets.

  final DragStartBehavior dragStartBehavior;

  final String? restorationId;

  final ScrollBehavior? scrollBehavior;

  final Clip clipBehavior;

  Axis get axis => axisDirectionToAxis(axisDirection);

  @override
  ScrollableState createState() => ScrollableState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<AxisDirection>('axisDirection', axisDirection));
    properties.add(DiagnosticsProperty<ScrollPhysics>('physics', physics));
    properties.add(StringProperty('restorationId', restorationId));
  }

  static ScrollableState? maybeOf(BuildContext context, {Axis? axis}) {
    // This is the context that will need to establish the dependency.
    final BuildContext originalContext = context;
    InheritedElement? element =
        context.getElementForInheritedWidgetOfExactType<_ScrollableScope>();
    while (element != null) {
      final ScrollableState scrollable =
          (element.widget as _ScrollableScope).scrollable;
      if (axis == null ||
          axisDirectionToAxis(scrollable.axisDirection) == axis) {
        // Establish the dependency on the correct context.
        originalContext.dependOnInheritedElement(element);
        return scrollable;
      }
      context = scrollable.context;
      element =
          context.getElementForInheritedWidgetOfExactType<_ScrollableScope>();
    }
    return null;
  }

  static ScrollableState of(BuildContext context, {Axis? axis}) {
    final ScrollableState? scrollableState = maybeOf(context, axis: axis);
    assert(() {
      if (scrollableState == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'Scrollable.of() was called with a context that does not contain a '
            'Scrollable widget.',
          ),
          ErrorDescription(
            'No Scrollable widget ancestor could be found '
            '${axis == null ? '' : 'for the provided Axis: $axis '}'
            'starting from the context that was passed to Scrollable.of(). This '
            'can happen because you are using a widget that looks for a Scrollable '
            'ancestor, but no such ancestor exists.\n'
            'The context used was:\n'
            '  $context',
          ),
          if (axis != null)
            ErrorHint(
              'When specifying an axis, this method will only look for a Scrollable '
              'that matches the given Axis.',
            ),
        ]);
      }
      return true;
    }());
    return scrollableState!;
  }

  static bool recommendDeferredLoadingForContext(BuildContext context,
      {Axis? axis}) {
    _ScrollableScope? widget =
        context.getInheritedWidgetOfExactType<_ScrollableScope>();
    while (widget != null) {
      if (axis == null ||
          axisDirectionToAxis(widget.scrollable.axisDirection) == axis) {
        return widget.position.recommendDeferredLoading(context);
      }
      context = widget.scrollable.context;
      widget = context.getInheritedWidgetOfExactType<_ScrollableScope>();
    }
    return false;
  }

  static Future<void> ensureVisible(
    BuildContext context, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
  }) {
    final List<Future<void>> futures = <Future<void>>[];

    // The targetRenderObject is used to record the first target renderObject.
    // If there are multiple scrollable widgets nested, the targetRenderObject
    // is made to be as visible as possible to improve the user experience. If
    // the targetRenderObject is already visible, then let the outer
    // renderObject be as visible as possible.
    //
    // Also see https://github.com/flutter/flutter/issues/65100
    RenderObject? targetRenderObject;
    ScrollableState? scrollable = Scrollable.maybeOf(context);
    while (scrollable != null) {
      final List<Future<void>> newFutures;
      (newFutures, scrollable) = scrollable._performEnsureVisible(
        context.findRenderObject()!,
        alignment: alignment,
        duration: duration,
        curve: curve,
        alignmentPolicy: alignmentPolicy,
        targetRenderObject: targetRenderObject,
      );
      futures.addAll(newFutures);

      targetRenderObject ??= context.findRenderObject();
      context = scrollable.context;
      scrollable = Scrollable.maybeOf(context);
    }

    if (futures.isEmpty || duration == Duration.zero) {
      return Future<void>.value();
    }
    if (futures.length == 1) {
      return futures.single;
    }
    return Future.wait<void>(futures).then<void>((List<void> _) => null);
  }
}

// Enable Scrollable.of() to work as if ScrollableState was an inherited widget.
// ScrollableState.build() always rebuilds its _ScrollableScope.
class _ScrollableScope extends InheritedWidget {
  const _ScrollableScope({
    required this.scrollable,
    required this.position,
    required super.child,
  });

  final ScrollableState scrollable;
  final ScrollPosition position;

  @override
  bool updateShouldNotify(_ScrollableScope old) {
    return position != old.position;
  }
}

class ScrollableState extends State<Scrollable>
    with TickerProviderStateMixin, RestorationMixin
    implements ScrollContext {
  // GETTERS

  ScrollPosition get position => _position!;
  ScrollPosition? _position;

  ScrollPhysics? get resolvedPhysics => _physics;
  ScrollPhysics? _physics;

  Offset get deltaToScrollOrigin {
    return switch (axisDirection) {
      AxisDirection.up => Offset(0, -position.pixels),
      AxisDirection.down => Offset(0, position.pixels),
      AxisDirection.left => Offset(-position.pixels, 0),
      AxisDirection.right => Offset(position.pixels, 0),
    };
  }

  ScrollController get _effectiveScrollController =>
      widget.controller ?? _fallbackScrollController!;

  @override
  AxisDirection get axisDirection => widget.axisDirection;

  @override
  TickerProvider get vsync => this;

  @override
  double get devicePixelRatio => _devicePixelRatio;
  late double _devicePixelRatio;

  @override
  BuildContext? get notificationContext => _gestureDetectorKey.currentContext;

  @override
  BuildContext get storageContext => context;

  @override
  String? get restorationId => widget.restorationId;
  final _RestorableScrollOffset _persistedScrollOffset =
      _RestorableScrollOffset();

  late ScrollBehavior _configuration;
  ScrollController? _fallbackScrollController;
  DeviceGestureSettings? _mediaQueryGestureSettings;

  // Only call this from places that will definitely trigger a rebuild.
  void _updatePosition() {
    _configuration = widget.scrollBehavior ?? ScrollConfiguration.of(context);
    _physics = _configuration.getScrollPhysics(context);
    if (widget.physics != null) {
      _physics = widget.physics!.applyTo(_physics);
    } else if (widget.scrollBehavior != null) {
      _physics =
          widget.scrollBehavior!.getScrollPhysics(context).applyTo(_physics);
    }
    final ScrollPosition? oldPosition = _position;
    if (oldPosition != null) {
      _effectiveScrollController.detach(oldPosition);
      // It's important that we not dispose the old position until after the
      // viewport has had a chance to unregister its listeners from the old
      // position. So, schedule a microtask to do it.
      scheduleMicrotask(oldPosition.dispose);
    }

    _position = _effectiveScrollController.createScrollPosition(
        _physics!, this, oldPosition);
    assert(_position != null);
    _effectiveScrollController.attach(position);
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_persistedScrollOffset, 'offset');
    assert(_position != null);
    if (_persistedScrollOffset.value != null) {
      position.restoreOffset(_persistedScrollOffset.value!,
          initialRestore: initialRestore);
    }
  }

  @override
  void saveOffset(double offset) {
    assert(debugIsSerializableForRestoration(offset));
    _persistedScrollOffset.value = offset;
    // [saveOffset] is called after a scrolling ends and it is usually not
    // followed by a frame. Therefore, manually flush restoration data.
    ServicesBinding.instance.restorationManager.flushData();
  }

  @override
  void initState() {
    if (widget.controller == null) {
      _fallbackScrollController = ScrollController2();
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _mediaQueryGestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    _devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ??
        View.of(context).devicePixelRatio;
    _updatePosition();
    super.didChangeDependencies();
  }

  bool _shouldUpdatePosition(Scrollable oldWidget) {
    if ((widget.scrollBehavior == null) != (oldWidget.scrollBehavior == null)) {
      return true;
    }
    if (widget.scrollBehavior != null &&
        oldWidget.scrollBehavior != null &&
        widget.scrollBehavior!.shouldNotify(oldWidget.scrollBehavior!)) {
      return true;
    }
    ScrollPhysics? newPhysics =
        widget.physics ?? widget.scrollBehavior?.getScrollPhysics(context);
    ScrollPhysics? oldPhysics = oldWidget.physics ??
        oldWidget.scrollBehavior?.getScrollPhysics(context);
    do {
      if (newPhysics?.runtimeType != oldPhysics?.runtimeType) {
        return true;
      }
      newPhysics = newPhysics?.parent;
      oldPhysics = oldPhysics?.parent;
    } while (newPhysics != null || oldPhysics != null);

    return widget.controller?.runtimeType != oldWidget.controller?.runtimeType;
  }

  @override
  void didUpdateWidget(Scrollable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        // The old controller was null, meaning the fallback cannot be null.
        // Dispose of the fallback.
        assert(_fallbackScrollController != null);
        assert(widget.controller != null);
        _fallbackScrollController!.detach(position);
        _fallbackScrollController!.dispose();
        _fallbackScrollController = null;
      } else {
        // The old controller was not null, detach.
        oldWidget.controller?.detach(position);
        if (widget.controller == null) {
          // If the new controller is null, we need to set up the fallback
          // ScrollController.
          _fallbackScrollController = ScrollController2();
        }
      }
      // Attach the updated effective scroll controller.
      _effectiveScrollController.attach(position);
    }

    if (_shouldUpdatePosition(oldWidget)) {
      _updatePosition();
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.detach(position);
    } else {
      _fallbackScrollController?.detach(position);
      _fallbackScrollController?.dispose();
    }

    position.dispose();
    _persistedScrollOffset.dispose();
    super.dispose();
  }

  // SEMANTICS

  final GlobalKey _scrollSemanticsKey = GlobalKey();

  @override
  @protected
  void setSemanticsActions(Set<SemanticsAction> actions) {
    if (_gestureDetectorKey.currentState != null) {
      _gestureDetectorKey.currentState!.replaceSemanticsActions(actions);
    }
  }

  // GESTURE RECOGNITION AND POINTER IGNORING

  final GlobalKey<RawGestureDetectorState> _gestureDetectorKey =
      GlobalKey<RawGestureDetectorState>();
  final GlobalKey _ignorePointerKey = GlobalKey();

  // This field is set during layout, and then reused until the next time it is set.
  Map<Type, GestureRecognizerFactory> _gestureRecognizers =
      const <Type, GestureRecognizerFactory>{};
  bool _shouldIgnorePointer = false;

  bool? _lastCanDrag;
  Axis? _lastAxisDirection;

  @override
  @protected
  void setCanDrag(bool value) {
    if (value == _lastCanDrag &&
        (!value || widget.axis == _lastAxisDirection)) {
      return;
    }
    if (!value) {
      _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
      // Cancel the active hold/drag (if any) because the gesture recognizers
      // will soon be disposed by our RawGestureDetector, and we won't be
      // receiving pointer up events to cancel the hold/drag.
      _handleDragCancel();
    } else {
      switch (widget.axis) {
        case Axis.vertical:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer(
                  supportedDevices: _configuration.dragDevices),
              (VerticalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics?.minFlingDistance
                  ..minFlingVelocity = _physics?.minFlingVelocity
                  ..maxFlingVelocity = _physics?.maxFlingVelocity
                  ..velocityTrackerBuilder =
                      _configuration.velocityTrackerBuilder(context)
                  ..dragStartBehavior = widget.dragStartBehavior
                  ..multitouchDragStrategy =
                      _configuration.getMultitouchDragStrategy(context)
                  ..gestureSettings = _mediaQueryGestureSettings
                  ..supportedDevices = _configuration.dragDevices;
              },
            ),
          };
        case Axis.horizontal:
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            HorizontalDragGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                    HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(
                  supportedDevices: _configuration.dragDevices),
              (HorizontalDragGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics?.minFlingDistance
                  ..minFlingVelocity = _physics?.minFlingVelocity
                  ..maxFlingVelocity = _physics?.maxFlingVelocity
                  ..velocityTrackerBuilder =
                      _configuration.velocityTrackerBuilder(context)
                  ..dragStartBehavior = widget.dragStartBehavior
                  ..multitouchDragStrategy =
                      _configuration.getMultitouchDragStrategy(context)
                  ..gestureSettings = _mediaQueryGestureSettings
                  ..supportedDevices = _configuration.dragDevices;
              },
            ),
          };
      }
    }
    _lastCanDrag = value;
    _lastAxisDirection = widget.axis;
    if (_gestureDetectorKey.currentState != null) {
      _gestureDetectorKey.currentState!
          .replaceGestureRecognizers(_gestureRecognizers);
    }
  }

  @override
  @protected
  void setIgnorePointer(bool value) {
    if (_shouldIgnorePointer == value) {
      return;
    }
    _shouldIgnorePointer = value;
    if (_ignorePointerKey.currentContext != null) {
      final RenderIgnorePointer renderBox = _ignorePointerKey.currentContext!
          .findRenderObject()! as RenderIgnorePointer;
      renderBox.ignoring = _shouldIgnorePointer;
    }
  }

  // TOUCH HANDLERS

  Drag? _drag;
  ScrollHoldController? _hold;

  void _handleDragDown(DragDownDetails details) {
    assert(_drag == null);
    assert(_hold == null);
    _hold = position.hold(_disposeHold);
  }

  void _handleDragStart(DragStartDetails details) {
    // It's possible for _hold to become null between _handleDragDown and
    // _handleDragStart, for example if some user code calls jumpTo or otherwise
    // triggers a new activity to begin.
    assert(_drag == null);
    _drag = position.drag(details, _disposeDrag);
    assert(_drag != null);
    assert(_hold == null);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _drag?.end(details);
    assert(_drag == null);
  }

  void _handleDragCancel() {
    if (_gestureDetectorKey.currentContext == null) {
      // The cancel was caused by the GestureDetector getting disposed, which
      // means we will get disposed momentarily as well and shouldn't do
      // any work.
      return;
    }
    // _hold might be null if the drag started.
    // _drag might be null if the drag activity ended and called _disposeDrag.
    assert(_hold == null || _drag == null);
    _hold?.cancel();
    _drag?.cancel();
    assert(_hold == null);
    assert(_drag == null);
  }

  void _disposeHold() {
    _hold = null;
  }

  void _disposeDrag() {
    _drag = null;
  }

  // SCROLL WHEEL

  // Returns the offset that should result from applying [event] to the current
  // position, taking min/max scroll extent into account.
  double _targetScrollOffsetForPointerScroll(double delta) {
    return math.min(
      math.max(position.pixels + delta, position.minScrollExtent),
      position.maxScrollExtent,
    );
  }

  // Returns the delta that should result from applying [event] with axis,
  // direction, and any modifiers specified by the ScrollBehavior taken into
  // account.
  double _pointerSignalEventDelta(PointerScrollEvent event) {
    final Set<LogicalKeyboardKey> pressed =
        HardwareKeyboard.instance.logicalKeysPressed;
    final bool flipAxes = pressed
            .any(_configuration.pointerAxisModifiers.contains) &&
        // Axes are only flipped for physical mouse wheel input.
        // On some platforms, like web, trackpad input is handled through pointer
        // signals, but should not be included in this axis modifying behavior.
        // This is because on a trackpad, all directional axes are available to
        // the user, while mouse scroll wheels typically are restricted to one
        // axis.
        event.kind == PointerDeviceKind.mouse;

    final Axis axis = flipAxes ? flipAxis(widget.axis) : widget.axis;
    final double delta = switch (axis) {
      Axis.horizontal => event.scrollDelta.dx,
      Axis.vertical => event.scrollDelta.dy,
    };


    return axisDirectionIsReversed(widget.axisDirection) ? -delta : delta;
  }

  void _receivedPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _position != null) {
      if (_physics != null && !_physics!.shouldAcceptUserOffset(position)) {
        return;
      }
      final double delta = _pointerSignalEventDelta(event);
      // Only express interest in the event if it would actually result in a scroll.
      if (delta != 0.0) {
        GestureBinding.instance.pointerSignalResolver
            .register(event, _handlePointerScroll);
      }
    } else if (event is PointerScrollInertiaCancelEvent) {
      position.pointerScroll(0);
      // Don't use the pointer signal resolver, all hit-tested scrollables should stop.
    }
  }

  void _handlePointerScroll(PointerEvent event) {
    assert(event is PointerScrollEvent);
    final double delta = _pointerSignalEventDelta(event as PointerScrollEvent);
    if (delta != 0.0 ) {
      position.pointerScroll(delta);
    }
  }

  bool _handleScrollMetricsNotification(
      ScrollMetricsNotification notification) {
    if (notification.depth == 0) {
      final RenderObject? scrollSemanticsRenderObject =
          _scrollSemanticsKey.currentContext?.findRenderObject();
      if (scrollSemanticsRenderObject != null) {
        scrollSemanticsRenderObject.markNeedsSemanticsUpdate();
      }
    }
    return false;
  }

  Widget _buildChrome(BuildContext context, Widget child) {
    final ScrollableDetails details = ScrollableDetails(
      direction: widget.axisDirection,
      controller: _effectiveScrollController,
      decorationClipBehavior: widget.clipBehavior,
    );

    return _configuration.buildScrollbar(
      context,
      _configuration.buildOverscrollIndicator(context, child, details),
      details,
    );
  }

  // DESCRIPTION

  @override
  Widget build(BuildContext context) {
    assert(_position != null);
    // _ScrollableScope must be placed above the BuildContext returned by notificationContext
    // so that we can get this ScrollableState by doing the following:
    //
    // ScrollNotification notification;
    // Scrollable.of(notification.context)
    //
    // Since notificationContext is pointing to _gestureDetectorKey.context, _ScrollableScope
    // must be placed above the widget using it: RawGestureDetector
    Widget result = _ScrollableScope(
      scrollable: this,
      position: position,
      child: Listener(
        onPointerSignal: _receivedPointerSignal,
        child: RawGestureDetector(
          key: _gestureDetectorKey,
          gestures: _gestureRecognizers,
          behavior: widget.hitTestBehavior,
          excludeFromSemantics: widget.excludeFromSemantics,
          child: Semantics(
            explicitChildNodes: !widget.excludeFromSemantics,
            child: IgnorePointer(
              key: _ignorePointerKey,
              ignoring: _shouldIgnorePointer,
              child: widget.viewportBuilder(context, position),
            ),
          ),
        ),
      ),
    );

    if (!widget.excludeFromSemantics) {
      result = NotificationListener<ScrollMetricsNotification>(
          onNotification: _handleScrollMetricsNotification,
          child: _ScrollSemantics(
            key: _scrollSemanticsKey,
            position: position,
            allowImplicitScrolling: _physics!.allowImplicitScrolling,
            semanticChildCount: widget.semanticChildCount,
            child: result,
          ));
    }

    result = _buildChrome(context, result);

    // Selection is only enabled when there is a parent registrar.
    final SelectionRegistrar? registrar = SelectionContainer.maybeOf(context);
    if (registrar != null) {
      result = _ScrollableSelectionHandler(
        state: this,
        position: position,
        registrar: registrar,
        child: result,
      );
    }

    return result;
  }

  // Returns the Future from calling ensureVisible for the ScrollPosition, as
  // as well as this ScrollableState instance so its context can be used to
  // check for other ancestor Scrollables in executing ensureVisible.
  _EnsureVisibleResults _performEnsureVisible(
    RenderObject object, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
    RenderObject? targetRenderObject,
  }) {
    final Future<void> ensureVisibleFuture = position.ensureVisible(
      object,
      alignment: alignment,
      duration: duration,
      curve: curve,
      alignmentPolicy: alignmentPolicy,
      targetRenderObject: targetRenderObject,
    );
    return (<Future<void>>[ensureVisibleFuture], this);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ScrollPosition>('position', _position));
    properties
        .add(DiagnosticsProperty<ScrollPhysics>('effective physics', _physics));
  }
}

class _ScrollableSelectionHandler extends StatefulWidget {
  const _ScrollableSelectionHandler({
    required this.state,
    required this.position,
    required this.registrar,
    required this.child,
  });

  final ScrollableState state;
  final ScrollPosition position;
  final Widget child;
  final SelectionRegistrar registrar;

  @override
  _ScrollableSelectionHandlerState createState() =>
      _ScrollableSelectionHandlerState();
}

class _ScrollableSelectionHandlerState
    extends State<_ScrollableSelectionHandler> {
  late _ScrollableSelectionContainerDelegate _selectionDelegate;

  @override
  void initState() {
    super.initState();
    _selectionDelegate = _ScrollableSelectionContainerDelegate(
      state: widget.state,
      position: widget.position,
    );
  }

  @override
  void didUpdateWidget(_ScrollableSelectionHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position) {
      _selectionDelegate.position = widget.position;
    }
  }

  @override
  void dispose() {
    _selectionDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionContainer(
      registrar: widget.registrar,
      delegate: _selectionDelegate,
      child: widget.child,
    );
  }
}

class _ScrollableSelectionContainerDelegate
    extends MultiSelectableSelectionContainerDelegate {
  _ScrollableSelectionContainerDelegate(
      {required this.state, required ScrollPosition position})
      : _position = position,
        _autoScroller = EdgeDraggingAutoScroller(state,
            velocityScalar: _kDefaultSelectToScrollVelocityScalar) {
    _position.addListener(_scheduleLayoutChange);
  }

  // Pointer drag is a single point, it should not have a size.
  static const double _kDefaultDragTargetSize = 0;

  // An eye-balled value for a smooth scrolling speed.
  static const double _kDefaultSelectToScrollVelocityScalar = 30;

  final ScrollableState state;
  final EdgeDraggingAutoScroller _autoScroller;
  bool _scheduledLayoutChange = false;
  Offset? _currentDragStartRelatedToOrigin;
  Offset? _currentDragEndRelatedToOrigin;

  // The scrollable only auto scrolls if the selection starts in the scrollable.
  bool _selectionStartsInScrollable = false;

  ScrollPosition get position => _position;
  ScrollPosition _position;
  set position(ScrollPosition other) {
    if (other == _position) {
      return;
    }
    _position.removeListener(_scheduleLayoutChange);
    _position = other;
    _position.addListener(_scheduleLayoutChange);
  }

  // The layout will only be updated a frame later than position changes.
  // Schedule PostFrameCallback to capture the accurate layout.
  void _scheduleLayoutChange() {
    if (_scheduledLayoutChange) {
      return;
    }
    _scheduledLayoutChange = true;
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (!_scheduledLayoutChange) {
        return;
      }
      _scheduledLayoutChange = false;
      layoutDidChange();
    }, debugLabel: 'ScrollableSelectionContainer.layoutDidChange');
  }

  final Map<Selectable, double> _selectableStartEdgeUpdateRecords =
      <Selectable, double>{};
  final Map<Selectable, double> _selectableEndEdgeUpdateRecords =
      <Selectable, double>{};

  @override
  void didChangeSelectables() {
    final Set<Selectable> selectableSet = selectables.toSet();
    _selectableStartEdgeUpdateRecords.removeWhere(
        (Selectable key, double value) => !selectableSet.contains(key));
    _selectableEndEdgeUpdateRecords.removeWhere(
        (Selectable key, double value) => !selectableSet.contains(key));
    super.didChangeSelectables();
  }

  @override
  SelectionResult handleClearSelection(ClearSelectionEvent event) {
    _selectableStartEdgeUpdateRecords.clear();
    _selectableEndEdgeUpdateRecords.clear();
    _currentDragStartRelatedToOrigin = null;
    _currentDragEndRelatedToOrigin = null;
    _selectionStartsInScrollable = false;
    return super.handleClearSelection(event);
  }

  @override
  SelectionResult handleSelectionEdgeUpdate(SelectionEdgeUpdateEvent event) {
    if (_currentDragEndRelatedToOrigin == null &&
        _currentDragStartRelatedToOrigin == null) {
      assert(!_selectionStartsInScrollable);
      _selectionStartsInScrollable =
          _globalPositionInScrollable(event.globalPosition);
    }
    final Offset deltaToOrigin = _getDeltaToScrollOrigin(state);
    if (event.type == SelectionEventType.endEdgeUpdate) {
      _currentDragEndRelatedToOrigin =
          _inferPositionRelatedToOrigin(event.globalPosition);
      final Offset endOffset = _currentDragEndRelatedToOrigin!
          .translate(-deltaToOrigin.dx, -deltaToOrigin.dy);
      event = SelectionEdgeUpdateEvent.forEnd(
          globalPosition: endOffset, granularity: event.granularity);
    } else {
      _currentDragStartRelatedToOrigin =
          _inferPositionRelatedToOrigin(event.globalPosition);
      final Offset startOffset = _currentDragStartRelatedToOrigin!
          .translate(-deltaToOrigin.dx, -deltaToOrigin.dy);
      event = SelectionEdgeUpdateEvent.forStart(
          globalPosition: startOffset, granularity: event.granularity);
    }
    final SelectionResult result = super.handleSelectionEdgeUpdate(event);

    // Result may be pending if one of the selectable child is also a scrollable.
    // In that case, the parent scrollable needs to wait for the child to finish
    // scrolling.
    if (result == SelectionResult.pending) {
      _autoScroller.stopAutoScroll();
      return result;
    }
    if (_selectionStartsInScrollable) {
      _autoScroller.startAutoScrollIfNecessary(_dragTargetFromEvent(event));
      if (_autoScroller.scrolling) {
        return SelectionResult.pending;
      }
    }
    return result;
  }

  Offset _inferPositionRelatedToOrigin(Offset globalPosition) {
    final RenderBox box = state.context.findRenderObject()! as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    if (!_selectionStartsInScrollable) {
      // If the selection starts outside of the scrollable, selecting across the
      // scrollable boundary will act as selecting the entire content in the
      // scrollable. This logic move the offset to the 0.0 or infinity to cover
      // the entire content if the input position is outside of the scrollable.
      if (localPosition.dy < 0 || localPosition.dx < 0) {
        return box.localToGlobal(Offset.zero);
      }
      if (localPosition.dy > box.size.height ||
          localPosition.dx > box.size.width) {
        return Offset.infinite;
      }
    }
    final Offset deltaToOrigin = _getDeltaToScrollOrigin(state);
    return box.localToGlobal(
        localPosition.translate(deltaToOrigin.dx, deltaToOrigin.dy));
  }

  void _updateDragLocationsFromGeometries(
      {bool forceUpdateStart = true, bool forceUpdateEnd = true}) {
    final Offset deltaToOrigin = _getDeltaToScrollOrigin(state);
    final RenderBox box = state.context.findRenderObject()! as RenderBox;
    final Matrix4 transform = box.getTransformTo(null);
    if (currentSelectionStartIndex != -1 &&
        (_currentDragStartRelatedToOrigin == null || forceUpdateStart)) {
      final SelectionGeometry geometry =
          selectables[currentSelectionStartIndex].value;
      assert(geometry.hasSelection);
      final SelectionPoint start = geometry.startSelectionPoint!;
      final Matrix4 childTransform =
          selectables[currentSelectionStartIndex].getTransformTo(box);
      final Offset localDragStart = MatrixUtils.transformPoint(
        childTransform,
        start.localPosition + Offset(0, -start.lineHeight / 2),
      );
      _currentDragStartRelatedToOrigin =
          MatrixUtils.transformPoint(transform, localDragStart + deltaToOrigin);
    }
    if (currentSelectionEndIndex != -1 &&
        (_currentDragEndRelatedToOrigin == null || forceUpdateEnd)) {
      final SelectionGeometry geometry =
          selectables[currentSelectionEndIndex].value;
      assert(geometry.hasSelection);
      final SelectionPoint end = geometry.endSelectionPoint!;
      final Matrix4 childTransform =
          selectables[currentSelectionEndIndex].getTransformTo(box);
      final Offset localDragEnd = MatrixUtils.transformPoint(
        childTransform,
        end.localPosition + Offset(0, -end.lineHeight / 2),
      );
      _currentDragEndRelatedToOrigin =
          MatrixUtils.transformPoint(transform, localDragEnd + deltaToOrigin);
    }
  }

  @override
  SelectionResult handleSelectAll(SelectAllSelectionEvent event) {
    assert(!_selectionStartsInScrollable);
    final SelectionResult result = super.handleSelectAll(event);
    assert(
        (currentSelectionStartIndex == -1) == (currentSelectionEndIndex == -1));
    if (currentSelectionStartIndex != -1) {
      _updateDragLocationsFromGeometries();
    }
    return result;
  }

  @override
  SelectionResult handleSelectWord(SelectWordSelectionEvent event) {
    _selectionStartsInScrollable =
        _globalPositionInScrollable(event.globalPosition);
    final SelectionResult result = super.handleSelectWord(event);
    _updateDragLocationsFromGeometries();
    return result;
  }

  @override
  SelectionResult handleGranularlyExtendSelection(
      GranularlyExtendSelectionEvent event) {
    final SelectionResult result = super.handleGranularlyExtendSelection(event);
    // The selection geometry may not have the accurate offset for the edges
    // that are outside of the viewport whose transform may not be valid. Only
    // the edge this event is updating is sure to be accurate.
    _updateDragLocationsFromGeometries(
      forceUpdateStart: !event.isEnd,
      forceUpdateEnd: event.isEnd,
    );
    if (_selectionStartsInScrollable) {
      _jumpToEdge(event.isEnd);
    }
    return result;
  }

  @override
  SelectionResult handleDirectionallyExtendSelection(
      DirectionallyExtendSelectionEvent event) {
    final SelectionResult result =
        super.handleDirectionallyExtendSelection(event);
    // The selection geometry may not have the accurate offset for the edges
    // that are outside of the viewport whose transform may not be valid. Only
    // the edge this event is updating is sure to be accurate.
    _updateDragLocationsFromGeometries(
      forceUpdateStart: !event.isEnd,
      forceUpdateEnd: event.isEnd,
    );
    if (_selectionStartsInScrollable) {
      _jumpToEdge(event.isEnd);
    }
    return result;
  }

  void _jumpToEdge(bool isExtent) {
    final Selectable selectable;
    final double? lineHeight;
    final SelectionPoint? edge;
    if (isExtent) {
      selectable = selectables[currentSelectionEndIndex];
      edge = selectable.value.endSelectionPoint;
      lineHeight = selectable.value.endSelectionPoint!.lineHeight;
    } else {
      selectable = selectables[currentSelectionStartIndex];
      edge = selectable.value.startSelectionPoint;
      lineHeight = selectable.value.startSelectionPoint?.lineHeight;
    }
    if (lineHeight == null || edge == null) {
      return;
    }
    final RenderBox scrollableBox =
        state.context.findRenderObject()! as RenderBox;
    final Matrix4 transform = selectable.getTransformTo(scrollableBox);
    final Offset edgeOffsetInScrollableCoordinates =
        MatrixUtils.transformPoint(transform, edge.localPosition);
    final Rect scrollableRect = Rect.fromLTRB(
        0, 0, scrollableBox.size.width, scrollableBox.size.height);
    switch (state.axisDirection) {
      case AxisDirection.up:
        final double edgeBottom = edgeOffsetInScrollableCoordinates.dy;
        final double edgeTop =
            edgeOffsetInScrollableCoordinates.dy - lineHeight;
        if (edgeBottom >= scrollableRect.bottom &&
            edgeTop <= scrollableRect.top) {
          return;
        }
        if (edgeBottom > scrollableRect.bottom) {
          position.jumpTo(position.pixels + scrollableRect.bottom - edgeBottom);
          return;
        }
        if (edgeTop < scrollableRect.top) {
          position.jumpTo(position.pixels + scrollableRect.top - edgeTop);
        }
        return;
      case AxisDirection.right:
        final double edge = edgeOffsetInScrollableCoordinates.dx;
        if (edge >= scrollableRect.right && edge <= scrollableRect.left) {
          return;
        }
        if (edge > scrollableRect.right) {
          position.jumpTo(position.pixels + edge - scrollableRect.right);
          return;
        }
        if (edge < scrollableRect.left) {
          position.jumpTo(position.pixels + edge - scrollableRect.left);
        }
        return;
      case AxisDirection.down:
        final double edgeBottom = edgeOffsetInScrollableCoordinates.dy;
        final double edgeTop =
            edgeOffsetInScrollableCoordinates.dy - lineHeight;
        if (edgeBottom >= scrollableRect.bottom &&
            edgeTop <= scrollableRect.top) {
          return;
        }
        if (edgeBottom > scrollableRect.bottom) {
          position.jumpTo(position.pixels + edgeBottom - scrollableRect.bottom);
          return;
        }
        if (edgeTop < scrollableRect.top) {
          position.jumpTo(position.pixels + edgeTop - scrollableRect.top);
        }
        return;
      case AxisDirection.left:
        final double edge = edgeOffsetInScrollableCoordinates.dx;
        if (edge >= scrollableRect.right && edge <= scrollableRect.left) {
          return;
        }
        if (edge > scrollableRect.right) {
          position.jumpTo(position.pixels + scrollableRect.right - edge);
          return;
        }
        if (edge < scrollableRect.left) {
          position.jumpTo(position.pixels + scrollableRect.left - edge);
        }
        return;
    }
  }

  bool _globalPositionInScrollable(Offset globalPosition) {
    final RenderBox box = state.context.findRenderObject()! as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    final Rect rect = Rect.fromLTWH(0, 0, box.size.width, box.size.height);
    return rect.contains(localPosition);
  }

  Rect _dragTargetFromEvent(SelectionEdgeUpdateEvent event) {
    return Rect.fromCenter(
        center: event.globalPosition,
        width: _kDefaultDragTargetSize,
        height: _kDefaultDragTargetSize);
  }

  @override
  SelectionResult dispatchSelectionEventToChild(
      Selectable selectable, SelectionEvent event) {
    switch (event.type) {
      case SelectionEventType.startEdgeUpdate:
        _selectableStartEdgeUpdateRecords[selectable] = state.position.pixels;
        ensureChildUpdated(selectable);
      case SelectionEventType.endEdgeUpdate:
        _selectableEndEdgeUpdateRecords[selectable] = state.position.pixels;
        ensureChildUpdated(selectable);
      case SelectionEventType.granularlyExtendSelection:
      case SelectionEventType.directionallyExtendSelection:
        ensureChildUpdated(selectable);
        _selectableStartEdgeUpdateRecords[selectable] = state.position.pixels;
        _selectableEndEdgeUpdateRecords[selectable] = state.position.pixels;
      case SelectionEventType.clear:
        _selectableEndEdgeUpdateRecords.remove(selectable);
        _selectableStartEdgeUpdateRecords.remove(selectable);
      case SelectionEventType.selectAll:
      case SelectionEventType.selectWord:
      case SelectionEventType.selectParagraph:
        _selectableEndEdgeUpdateRecords[selectable] = state.position.pixels;
        _selectableStartEdgeUpdateRecords[selectable] = state.position.pixels;
    }
    return super.dispatchSelectionEventToChild(selectable, event);
  }

  @override
  void ensureChildUpdated(Selectable selectable) {
    final double newRecord = state.position.pixels;
    final double? previousStartRecord =
        _selectableStartEdgeUpdateRecords[selectable];
    if (_currentDragStartRelatedToOrigin != null &&
        (previousStartRecord == null ||
            (newRecord - previousStartRecord).abs() >
                precisionErrorTolerance)) {
      // Make sure the selectable has up to date events.
      final Offset deltaToOrigin = _getDeltaToScrollOrigin(state);
      final Offset startOffset = _currentDragStartRelatedToOrigin!
          .translate(-deltaToOrigin.dx, -deltaToOrigin.dy);
      selectable.dispatchSelectionEvent(
          SelectionEdgeUpdateEvent.forStart(globalPosition: startOffset));
      // Make sure we track that we have synthesized a start event for this selectable,
      // so we don't synthesize events unnecessarily.
      _selectableStartEdgeUpdateRecords[selectable] = state.position.pixels;
    }
    final double? previousEndRecord =
        _selectableEndEdgeUpdateRecords[selectable];
    if (_currentDragEndRelatedToOrigin != null &&
        (previousEndRecord == null ||
            (newRecord - previousEndRecord).abs() > precisionErrorTolerance)) {
      // Make sure the selectable has up to date events.
      final Offset deltaToOrigin = _getDeltaToScrollOrigin(state);
      final Offset endOffset = _currentDragEndRelatedToOrigin!
          .translate(-deltaToOrigin.dx, -deltaToOrigin.dy);
      selectable.dispatchSelectionEvent(
          SelectionEdgeUpdateEvent.forEnd(globalPosition: endOffset));
      // Make sure we track that we have synthesized an end event for this selectable,
      // so we don't synthesize events unnecessarily.
      _selectableEndEdgeUpdateRecords[selectable] = state.position.pixels;
    }
  }

  @override
  void dispose() {
    _selectableStartEdgeUpdateRecords.clear();
    _selectableEndEdgeUpdateRecords.clear();
    _scheduledLayoutChange = false;
    _autoScroller.stopAutoScroll();
    super.dispose();
  }
}

Offset _getDeltaToScrollOrigin(ScrollableState scrollableState) {
  return switch (scrollableState.axisDirection) {
    AxisDirection.up => Offset(0, -scrollableState.position.pixels),
    AxisDirection.down => Offset(0, scrollableState.position.pixels),
    AxisDirection.left => Offset(-scrollableState.position.pixels, 0),
    AxisDirection.right => Offset(scrollableState.position.pixels, 0),
  };
}

class _ScrollSemantics extends SingleChildRenderObjectWidget {
  const _ScrollSemantics({
    super.key,
    required this.position,
    required this.allowImplicitScrolling,
    required this.semanticChildCount,
    super.child,
  }) : assert(semanticChildCount == null || semanticChildCount >= 0);

  final ScrollPosition position;
  final bool allowImplicitScrolling;
  final int? semanticChildCount;

  @override
  _RenderScrollSemantics createRenderObject(BuildContext context) {
    return _RenderScrollSemantics(
      position: position,
      allowImplicitScrolling: allowImplicitScrolling,
      semanticChildCount: semanticChildCount,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderScrollSemantics renderObject) {
    renderObject
      ..allowImplicitScrolling = allowImplicitScrolling
      ..position = position
      ..semanticChildCount = semanticChildCount;
  }
}

class _RenderScrollSemantics extends RenderProxyBox {
  _RenderScrollSemantics({
    required ScrollPosition position,
    required bool allowImplicitScrolling,
    required int? semanticChildCount,
    RenderBox? child,
  })  : _position = position,
        _allowImplicitScrolling = allowImplicitScrolling,
        _semanticChildCount = semanticChildCount,
        super(child) {
    position.addListener(markNeedsSemanticsUpdate);
  }

  ScrollPosition get position => _position;
  ScrollPosition _position;
  set position(ScrollPosition value) {
    if (value == _position) {
      return;
    }
    _position.removeListener(markNeedsSemanticsUpdate);
    _position = value;
    _position.addListener(markNeedsSemanticsUpdate);
    markNeedsSemanticsUpdate();
  }

  bool get allowImplicitScrolling => _allowImplicitScrolling;
  bool _allowImplicitScrolling;
  set allowImplicitScrolling(bool value) {
    if (value == _allowImplicitScrolling) {
      return;
    }
    _allowImplicitScrolling = value;
    markNeedsSemanticsUpdate();
  }

  int? get semanticChildCount => _semanticChildCount;
  int? _semanticChildCount;
  set semanticChildCount(int? value) {
    if (value == semanticChildCount) {
      return;
    }
    _semanticChildCount = value;
    markNeedsSemanticsUpdate();
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
    if (position.haveDimensions) {
      config
        ..hasImplicitScrolling = allowImplicitScrolling
        ..scrollPosition = _position.pixels
        ..scrollExtentMax = _position.maxScrollExtent
        ..scrollExtentMin = _position.minScrollExtent
        ..scrollChildCount = semanticChildCount;
    }
  }

  SemanticsNode? _innerNode;

  @override
  void assembleSemanticsNode(SemanticsNode node, SemanticsConfiguration config,
      Iterable<SemanticsNode> children) {
    if (children.isEmpty ||
        !children.first.isTagged(RenderViewport.useTwoPaneSemantics)) {
      _innerNode = null;
      super.assembleSemanticsNode(node, config, children);
      return;
    }

    (_innerNode ??= SemanticsNode(showOnScreen: showOnScreen)).rect = node.rect;

    int? firstVisibleIndex;
    final List<SemanticsNode> excluded = <SemanticsNode>[_innerNode!];
    final List<SemanticsNode> included = <SemanticsNode>[];
    for (final SemanticsNode child in children) {
      assert(child.isTagged(RenderViewport.useTwoPaneSemantics));
      if (child.isTagged(RenderViewport.excludeFromScrolling)) {
        excluded.add(child);
      } else {
        if (!child.hasFlag(SemanticsFlag.isHidden)) {
          firstVisibleIndex ??= child.indexInParent;
        }
        included.add(child);
      }
    }
    config.scrollIndex = firstVisibleIndex;
    node.updateWith(config: null, childrenInInversePaintOrder: excluded);
    _innerNode!
        .updateWith(config: config, childrenInInversePaintOrder: included);
  }

  @override
  void clearSemantics() {
    super.clearSemantics();
    _innerNode = null;
  }
}

// Not using a RestorableDouble because we want to allow null values and override
// [enabled].
class _RestorableScrollOffset extends RestorableValue<double?> {
  @override
  double? createDefaultValue() => null;

  @override
  void didUpdateValue(double? oldValue) {
    notifyListeners();
  }

  @override
  double fromPrimitives(Object? data) {
    return data! as double;
  }

  @override
  Object? toPrimitives() {
    return value;
  }

  @override
  bool get enabled => value != null;
}

// 2D SCROLLING

// TODO(Piinks): Add sample code, https://github.com/flutter/flutter/issues/126298
enum DiagonalDragBehavior {
  none,

  weightedEvent,

  weightedContinuous,

  free,
}

class TwoDimensionalScrollable extends StatefulWidget {
  const TwoDimensionalScrollable({
    super.key,
    required this.horizontalDetails,
    required this.verticalDetails,
    required this.viewportBuilder,
    this.incrementCalculator,
    this.restorationId,
    this.excludeFromSemantics = false,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
    this.dragStartBehavior = DragStartBehavior.start,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  final DiagonalDragBehavior diagonalDragBehavior;

  final ScrollableDetails horizontalDetails;

  final ScrollableDetails verticalDetails;

  final TwoDimensionalViewportBuilder viewportBuilder;

  final ScrollIncrementCalculator? incrementCalculator;

  final String? restorationId;

  final bool excludeFromSemantics;

  final HitTestBehavior hitTestBehavior;

  final DragStartBehavior dragStartBehavior;

  @override
  State<TwoDimensionalScrollable> createState() =>
      TwoDimensionalScrollableState();

  static TwoDimensionalScrollableState? maybeOf(BuildContext context) {
    final _TwoDimensionalScrollableScope? widget = context
        .dependOnInheritedWidgetOfExactType<_TwoDimensionalScrollableScope>();
    return widget?.twoDimensionalScrollable;
  }

  static TwoDimensionalScrollableState of(BuildContext context) {
    final TwoDimensionalScrollableState? scrollableState = maybeOf(context);
    assert(() {
      if (scrollableState == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'TwoDimensionalScrollable.of() was called with a context that does '
              'not contain a TwoDimensionalScrollable widget.\n'),
          ErrorDescription(
            'No TwoDimensionalScrollable widget ancestor could be found starting '
            'from the context that was passed to TwoDimensionalScrollable.of(). '
            'This can happen because you are using a widget that looks for a '
            'TwoDimensionalScrollable ancestor, but no such ancestor exists.\n'
            'The context used was:\n'
            '  $context',
          ),
        ]);
      }
      return true;
    }());
    return scrollableState!;
  }
}

class TwoDimensionalScrollableState extends State<TwoDimensionalScrollable> {
  ScrollController? _verticalFallbackController;
  ScrollController? _horizontalFallbackController;
  final GlobalKey<ScrollableState> _verticalOuterScrollableKey =
      GlobalKey<ScrollableState>();
  final GlobalKey<ScrollableState> _horizontalInnerScrollableKey =
      GlobalKey<ScrollableState>();

  ScrollableState get verticalScrollable {
    assert(_verticalOuterScrollableKey.currentState != null);
    return _verticalOuterScrollableKey.currentState!;
  }

  ScrollableState get horizontalScrollable {
    assert(_horizontalInnerScrollableKey.currentState != null);
    return _horizontalInnerScrollableKey.currentState!;
  }

  @override
  void initState() {
    if (widget.verticalDetails.controller == null) {
      _verticalFallbackController = ScrollController();
    }
    if (widget.horizontalDetails.controller == null) {
      _horizontalFallbackController = ScrollController();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(TwoDimensionalScrollable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle changes in the provided/fallback scroll controllers

    // Vertical
    if (oldWidget.verticalDetails.controller !=
        widget.verticalDetails.controller) {
      if (oldWidget.verticalDetails.controller == null) {
        // The old controller was null, meaning the fallback cannot be null.
        // Dispose of the fallback.
        assert(_verticalFallbackController != null);
        assert(widget.verticalDetails.controller != null);
        _verticalFallbackController!.dispose();
        _verticalFallbackController = null;
      } else if (widget.verticalDetails.controller == null) {
        // If the new controller is null, we need to set up the fallback
        // ScrollController.
        assert(_verticalFallbackController == null);
        _verticalFallbackController = ScrollController();
      }
    }

    // Horizontal
    if (oldWidget.horizontalDetails.controller !=
        widget.horizontalDetails.controller) {
      if (oldWidget.horizontalDetails.controller == null) {
        // The old controller was null, meaning the fallback cannot be null.
        // Dispose of the fallback.
        assert(_horizontalFallbackController != null);
        assert(widget.horizontalDetails.controller != null);
        _horizontalFallbackController!.dispose();
        _horizontalFallbackController = null;
      } else if (widget.horizontalDetails.controller == null) {
        // If the new controller is null, we need to set up the fallback
        // ScrollController.
        assert(_horizontalFallbackController == null);
        _horizontalFallbackController = ScrollController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(
        axisDirectionToAxis(widget.verticalDetails.direction) == Axis.vertical,
        'TwoDimensionalScrollable.verticalDetails are not Axis.vertical.');
    assert(
        axisDirectionToAxis(widget.horizontalDetails.direction) ==
            Axis.horizontal,
        'TwoDimensionalScrollable.horizontalDetails are not Axis.horizontal.');

    final Widget result = RestorationScope(
        restorationId: widget.restorationId,
        child: _VerticalOuterDimension(
            key: _verticalOuterScrollableKey,
            // For gesture forwarding
            horizontalKey: _horizontalInnerScrollableKey,
            axisDirection: widget.verticalDetails.direction,
            controller: widget.verticalDetails.controller ??
                _verticalFallbackController!,
            physics: widget.verticalDetails.physics,
            clipBehavior: widget.verticalDetails.decorationClipBehavior ??
                widget.verticalDetails.decorationClipBehavior ??
                Clip.hardEdge,
            incrementCalculator: widget.incrementCalculator,
            excludeFromSemantics: widget.excludeFromSemantics,
            restorationId: 'OuterVerticalTwoDimensionalScrollable',
            dragStartBehavior: widget.dragStartBehavior,
            diagonalDragBehavior: widget.diagonalDragBehavior,
            hitTestBehavior: widget.hitTestBehavior,
            viewportBuilder:
                (BuildContext context, ViewportOffset verticalOffset) {
              return _HorizontalInnerDimension(
                key: _horizontalInnerScrollableKey,
                verticalOuterKey: _verticalOuterScrollableKey,
                axisDirection: widget.horizontalDetails.direction,
                controller: widget.horizontalDetails.controller ??
                    _horizontalFallbackController!,
                physics: widget.horizontalDetails.physics,
                clipBehavior: widget.horizontalDetails.decorationClipBehavior ??
                    widget.horizontalDetails.decorationClipBehavior ??
                    Clip.hardEdge,
                incrementCalculator: widget.incrementCalculator,
                excludeFromSemantics: widget.excludeFromSemantics,
                restorationId: 'InnerHorizontalTwoDimensionalScrollable',
                dragStartBehavior: widget.dragStartBehavior,
                diagonalDragBehavior: widget.diagonalDragBehavior,
                hitTestBehavior: widget.hitTestBehavior,
                viewportBuilder:
                    (BuildContext context, ViewportOffset horizontalOffset) {
                  return widget.viewportBuilder(
                      context, verticalOffset, horizontalOffset);
                },
              );
            }));

    // TODO(Piinks): Build scrollbars for 2 dimensions instead of 1,
    //  https://github.com/flutter/flutter/issues/122348

    return _TwoDimensionalScrollableScope(
      twoDimensionalScrollable: this,
      child: result,
    );
  }

  @override
  void dispose() {
    _verticalFallbackController?.dispose();
    _horizontalFallbackController?.dispose();
    super.dispose();
  }
}

// Enable TwoDimensionalScrollable.of() to work as if
// TwoDimensionalScrollableState was an inherited widget.
// TwoDimensionalScrollableState.build() always rebuilds its
// _TwoDimensionalScrollableScope.
class _TwoDimensionalScrollableScope extends InheritedWidget {
  const _TwoDimensionalScrollableScope({
    required this.twoDimensionalScrollable,
    required super.child,
  });

  final TwoDimensionalScrollableState twoDimensionalScrollable;

  @override
  bool updateShouldNotify(_TwoDimensionalScrollableScope old) => false;
}

// Vertical outer scrollable of 2D scrolling
class _VerticalOuterDimension extends Scrollable {
  const _VerticalOuterDimension({
    super.key,
    required this.horizontalKey,
    required super.viewportBuilder,
    required super.axisDirection,
    super.controller,
    super.physics,
    super.clipBehavior,
    super.incrementCalculator,
    super.excludeFromSemantics,
    super.dragStartBehavior,
    super.restorationId,
    super.hitTestBehavior,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
  }) : assert(axisDirection == AxisDirection.up ||
            axisDirection == AxisDirection.down);

  final DiagonalDragBehavior diagonalDragBehavior;
  final GlobalKey<ScrollableState> horizontalKey;

  @override
  _VerticalOuterDimensionState createState() => _VerticalOuterDimensionState();
}

class _VerticalOuterDimensionState extends ScrollableState {
  DiagonalDragBehavior get diagonalDragBehavior =>
      (widget as _VerticalOuterDimension).diagonalDragBehavior;
  ScrollableState get horizontalScrollable =>
      (widget as _VerticalOuterDimension).horizontalKey.currentState!;

  Axis? lockedAxis;
  Offset? lastDragOffset;

  // Implemented in the _HorizontalInnerDimension instead.
  @override
  _EnsureVisibleResults _performEnsureVisible(
    RenderObject object, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
    RenderObject? targetRenderObject,
  }) {
    assert(
        false,
        'The _performEnsureVisible method was called for the vertical scrollable '
        'of a TwoDimensionalScrollable. This should not happen as the horizontal '
        'scrollable handles both axes.');
    return (<Future<void>>[], this);
  }

  void _evaluateLockedAxis(Offset offset) {
    assert(lastDragOffset != null);
    final Offset offsetDelta = lastDragOffset! - offset;
    final double axisDifferential = offsetDelta.dx.abs() - offsetDelta.dy.abs();
    if (axisDifferential.abs() >= kTouchSlop) {
      // We have single axis winner.
      lockedAxis = axisDifferential > 0.0 ? Axis.horizontal : Axis.vertical;
    } else {
      lockedAxis = null;
    }
  }

  @override
  void _handleDragDown(DragDownDetails details) {
    switch (diagonalDragBehavior) {
      case DiagonalDragBehavior.none:
        break;
      case DiagonalDragBehavior.weightedEvent:
      case DiagonalDragBehavior.weightedContinuous:
      case DiagonalDragBehavior.free:
        // Initiate hold. If one or the other wins the gesture, cancel the
        // opposite axis.
        horizontalScrollable._handleDragDown(details);
    }
    super._handleDragDown(details);
  }

  @override
  void _handleDragStart(DragStartDetails details) {
    lastDragOffset = details.globalPosition;
    switch (diagonalDragBehavior) {
      case DiagonalDragBehavior.none:
        break;
      case DiagonalDragBehavior.free:
        // Prepare to scroll both.
        // vertical - will call super below after switch.
        horizontalScrollable._handleDragStart(details);
      case DiagonalDragBehavior.weightedEvent:
      case DiagonalDragBehavior.weightedContinuous:
        // See if one axis wins the drag.
        _evaluateLockedAxis(details.globalPosition);
        switch (lockedAxis) {
          case null:
            // Prepare to scroll both, null means no winner yet.
            // vertical - will call super below after switch.
            horizontalScrollable._handleDragStart(details);
          case Axis.horizontal:
            // Prepare to scroll horizontally.
            horizontalScrollable._handleDragStart(details);
            return;
          case Axis.vertical:
          // Prepare to scroll vertically - will call super below after switch.
        }
    }
    super._handleDragStart(details);
  }

  @override
  void _handleDragUpdate(DragUpdateDetails details) {
    final DragUpdateDetails verticalDragDetails = DragUpdateDetails(
      sourceTimeStamp: details.sourceTimeStamp,
      delta: Offset(0.0, details.delta.dy),
      primaryDelta: details.delta.dy,
      globalPosition: details.globalPosition,
      localPosition: details.localPosition,
    );
    final DragUpdateDetails horizontalDragDetails = DragUpdateDetails(
      sourceTimeStamp: details.sourceTimeStamp,
      delta: Offset(details.delta.dx, 0.0),
      primaryDelta: details.delta.dx,
      globalPosition: details.globalPosition,
      localPosition: details.localPosition,
    );

    switch (diagonalDragBehavior) {
      case DiagonalDragBehavior.none:
        // Default gesture handling from super class.
        super._handleDragUpdate(verticalDragDetails);
        return;
      case DiagonalDragBehavior.free:
        // Scroll both axes
        horizontalScrollable._handleDragUpdate(horizontalDragDetails);
        super._handleDragUpdate(verticalDragDetails);
        return;
      case DiagonalDragBehavior.weightedContinuous:
        // Re-evaluate locked axis for every update.
        _evaluateLockedAxis(details.globalPosition);
        lastDragOffset = details.globalPosition;
      case DiagonalDragBehavior.weightedEvent:
        // Lock axis only once per gesture.
        if (lockedAxis == null && lastDragOffset != null) {
          // A winner has not been declared yet.
          // See if one axis has won the drag.
          _evaluateLockedAxis(details.globalPosition);
        }
    }
    switch (lockedAxis) {
      case null:
        // Scroll both - vertical after switch
        horizontalScrollable._handleDragUpdate(horizontalDragDetails);
      case Axis.horizontal:
        // Scroll horizontally
        horizontalScrollable._handleDragUpdate(horizontalDragDetails);
        return;
      case Axis.vertical:
      // Scroll vertically - after switch
    }
    super._handleDragUpdate(verticalDragDetails);
  }

  @override
  void _handleDragEnd(DragEndDetails details) {
    lastDragOffset = null;
    lockedAxis = null;
    final double dx = details.velocity.pixelsPerSecond.dx;
    final double dy = details.velocity.pixelsPerSecond.dy;
    final DragEndDetails verticalDragDetails = DragEndDetails(
      velocity: Velocity(pixelsPerSecond: Offset(0.0, dy)),
      primaryVelocity: dy,
    );
    final DragEndDetails horizontalDragDetails = DragEndDetails(
      velocity: Velocity(pixelsPerSecond: Offset(dx, 0.0)),
      primaryVelocity: dx,
    );

    switch (diagonalDragBehavior) {
      case DiagonalDragBehavior.none:
        break;
      case DiagonalDragBehavior.weightedEvent:
      case DiagonalDragBehavior.weightedContinuous:
      case DiagonalDragBehavior.free:
        horizontalScrollable._handleDragEnd(horizontalDragDetails);
    }
    super._handleDragEnd(verticalDragDetails);
  }

  @override
  void _handleDragCancel() {
    lastDragOffset = null;
    lockedAxis = null;
    switch (diagonalDragBehavior) {
      case DiagonalDragBehavior.none:
        break;
      case DiagonalDragBehavior.weightedEvent:
      case DiagonalDragBehavior.weightedContinuous:
      case DiagonalDragBehavior.free:
        horizontalScrollable._handleDragCancel();
    }
    super._handleDragCancel();
  }

  @override
  void setCanDrag(bool value) {
    switch (diagonalDragBehavior) {
      case DiagonalDragBehavior.none:
        // If we aren't scrolling diagonally, the default drag gesture recognizer
        // is used.
        super.setCanDrag(value);
        return;
      case DiagonalDragBehavior.weightedEvent:
      case DiagonalDragBehavior.weightedContinuous:
      case DiagonalDragBehavior.free:
        if (value) {
          // Replaces the typical vertical/horizontal drag gesture recognizers
          // with a pan gesture recognizer to allow bidirectional scrolling.
          // Based on the diagonalDragBehavior, valid vertical deltas are
          // applied to this scrollable, while horizontal deltas are routed to
          // the horizontal scrollable.
          _gestureRecognizers = <Type, GestureRecognizerFactory>{
            PanGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
              () => PanGestureRecognizer(
                  supportedDevices: _configuration.dragDevices),
              (PanGestureRecognizer instance) {
                instance
                  ..onDown = _handleDragDown
                  ..onStart = _handleDragStart
                  ..onUpdate = _handleDragUpdate
                  ..onEnd = _handleDragEnd
                  ..onCancel = _handleDragCancel
                  ..minFlingDistance = _physics?.minFlingDistance
                  ..minFlingVelocity = _physics?.minFlingVelocity
                  ..maxFlingVelocity = _physics?.maxFlingVelocity
                  ..velocityTrackerBuilder =
                      _configuration.velocityTrackerBuilder(context)
                  ..dragStartBehavior = widget.dragStartBehavior
                  ..gestureSettings = _mediaQueryGestureSettings;
              },
            ),
          };
          // Cancel the active hold/drag (if any) because the gesture recognizers
          // will soon be disposed by our RawGestureDetector, and we won't be
          // receiving pointer up events to cancel the hold/drag.
          _handleDragCancel();
          _lastCanDrag = value;
          _lastAxisDirection = widget.axis;
          if (_gestureDetectorKey.currentState != null) {
            _gestureDetectorKey.currentState!
                .replaceGestureRecognizers(_gestureRecognizers);
          }
        }
        return;
    }
  }

  @override
  Widget _buildChrome(BuildContext context, Widget child) {
    final ScrollableDetails details = ScrollableDetails(
      direction: widget.axisDirection,
      controller: _effectiveScrollController,
      decorationClipBehavior: widget.clipBehavior,
    );
    // Skip building a scrollbar here, the dual scrollbar is added in
    // TwoDimensionalScrollableState.
    return _configuration.buildOverscrollIndicator(context, child, details);
  }
}

// Horizontal inner scrollable of 2D scrolling
class _HorizontalInnerDimension extends Scrollable {
  const _HorizontalInnerDimension({
    super.key,
    required this.verticalOuterKey,
    required super.viewportBuilder,
    required super.axisDirection,
    super.controller,
    super.physics,
    super.clipBehavior,
    super.incrementCalculator,
    super.excludeFromSemantics,
    super.dragStartBehavior,
    super.restorationId,
    super.hitTestBehavior,
    this.diagonalDragBehavior = DiagonalDragBehavior.none,
  }) : assert(axisDirection == AxisDirection.left ||
            axisDirection == AxisDirection.right);

  final GlobalKey<ScrollableState> verticalOuterKey;
  final DiagonalDragBehavior diagonalDragBehavior;

  @override
  _HorizontalInnerDimensionState createState() =>
      _HorizontalInnerDimensionState();
}

class _HorizontalInnerDimensionState extends ScrollableState {
  late ScrollableState verticalScrollable;

  GlobalKey<ScrollableState> get verticalOuterKey =>
      (widget as _HorizontalInnerDimension).verticalOuterKey;
  DiagonalDragBehavior get diagonalDragBehavior =>
      (widget as _HorizontalInnerDimension).diagonalDragBehavior;

  @override
  void didChangeDependencies() {
    verticalScrollable = Scrollable.of(context);
    assert(
        axisDirectionToAxis(verticalScrollable.axisDirection) == Axis.vertical);
    super.didChangeDependencies();
  }

  // Returns the Future from calling ensureVisible for the ScrollPosition, as
  // as well as the vertical ScrollableState instance so its context can be
  // used to check for other ancestor Scrollables in executing ensureVisible.
  @override
  _EnsureVisibleResults _performEnsureVisible(
    RenderObject object, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy =
        ScrollPositionAlignmentPolicy.explicit,
    RenderObject? targetRenderObject,
  }) {
    final List<Future<void>> newFutures = <Future<void>>[
      position.ensureVisible(
        object,
        alignment: alignment,
        duration: duration,
        curve: curve,
        alignmentPolicy: alignmentPolicy,
      ),
      verticalScrollable.position.ensureVisible(
        object,
        alignment: alignment,
        duration: duration,
        curve: curve,
        alignmentPolicy: alignmentPolicy,
      ),
    ];

    return (newFutures, verticalScrollable);
  }

  @override
  void setCanDrag(bool value) {
    switch (diagonalDragBehavior) {
      case DiagonalDragBehavior.none:
        // If we aren't scrolling diagonally, the default drag gesture
        // recognizer is used.
        super.setCanDrag(value);
        return;
      case DiagonalDragBehavior.weightedEvent:
      case DiagonalDragBehavior.weightedContinuous:
      case DiagonalDragBehavior.free:
        if (value) {
          // If a type of diagonal scrolling is enabled, a panning gesture
          // recognizer will be created for the _VerticalOuterDimension. So in
          // this case, the _HorizontalInnerDimension does not require a gesture
          // recognizer, meanwhile we should ensure the outer dimension has
          // updated in case it did not have enough content to enable dragging.
          _gestureRecognizers = const <Type, GestureRecognizerFactory>{};
          verticalOuterKey.currentState!.setCanDrag(value);
          // Cancel the active hold/drag (if any) because the gesture recognizers
          // will soon be disposed by our RawGestureDetector, and we won't be
          // receiving pointer up events to cancel the hold/drag.
          _handleDragCancel();
          _lastCanDrag = value;
          _lastAxisDirection = widget.axis;
          if (_gestureDetectorKey.currentState != null) {
            _gestureDetectorKey.currentState!
                .replaceGestureRecognizers(_gestureRecognizers);
          }
        }
        return;
    }
  }

  @override
  Widget _buildChrome(BuildContext context, Widget child) {
    final ScrollableDetails details = ScrollableDetails(
      direction: widget.axisDirection,
      controller: _effectiveScrollController,
      decorationClipBehavior: widget.clipBehavior,
    );
    // Skip building a scrollbar here, the dual scrollbar is added in
    // TwoDimensionalScrollableState.
    return _configuration.buildOverscrollIndicator(context, child, details);
  }
}

class EdgeDraggingAutoScroller {
  EdgeDraggingAutoScroller(
    this.scrollable, {
    this.onScrollViewScrolled,
    required this.velocityScalar,
  });

  final ScrollableState scrollable;

  final VoidCallback? onScrollViewScrolled;

  final double velocityScalar;

  late Rect _dragTargetRelatedToScrollOrigin;

  bool get scrolling => _scrolling;
  bool _scrolling = false;

  double _offsetExtent(Offset offset, Axis scrollDirection) {
    return switch (scrollDirection) {
      Axis.horizontal => offset.dx,
      Axis.vertical => offset.dy,
    };
  }

  double _sizeExtent(Size size, Axis scrollDirection) {
    return switch (scrollDirection) {
      Axis.horizontal => size.width,
      Axis.vertical => size.height,
    };
  }

  AxisDirection get _axisDirection => scrollable.axisDirection;
  Axis get _scrollDirection => axisDirectionToAxis(_axisDirection);

  void startAutoScrollIfNecessary(Rect dragTarget) {
    final Offset deltaToOrigin = scrollable.deltaToScrollOrigin;
    _dragTargetRelatedToScrollOrigin =
        dragTarget.translate(deltaToOrigin.dx, deltaToOrigin.dy);
    if (_scrolling) {
      // The change will be picked up in the next scroll.
      return;
    }
    assert(!_scrolling);
    _scroll();
  }

  void stopAutoScroll() {
    _scrolling = false;
  }

  Future<void> _scroll() async {
    final RenderBox scrollRenderBox =
        scrollable.context.findRenderObject()! as RenderBox;
    final Rect globalRect = MatrixUtils.transformRect(
      scrollRenderBox.getTransformTo(null),
      Rect.fromLTWH(
          0, 0, scrollRenderBox.size.width, scrollRenderBox.size.height),
    );
    assert(
      globalRect.size.width >= _dragTargetRelatedToScrollOrigin.size.width &&
          globalRect.size.height >=
              _dragTargetRelatedToScrollOrigin.size.height,
      'Drag target size is larger than scrollable size, which may cause bouncing',
    );
    _scrolling = true;
    double? newOffset;
    const double overDragMax = 20.0;

    final Offset deltaToOrigin = scrollable.deltaToScrollOrigin;
    final Offset viewportOrigin =
        globalRect.topLeft.translate(deltaToOrigin.dx, deltaToOrigin.dy);
    final double viewportStart =
        _offsetExtent(viewportOrigin, _scrollDirection);
    final double viewportEnd =
        viewportStart + _sizeExtent(globalRect.size, _scrollDirection);

    final double proxyStart = _offsetExtent(
        _dragTargetRelatedToScrollOrigin.topLeft, _scrollDirection);
    final double proxyEnd = _offsetExtent(
        _dragTargetRelatedToScrollOrigin.bottomRight, _scrollDirection);
    switch (_axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        if (proxyEnd > viewportEnd &&
            scrollable.position.pixels > scrollable.position.minScrollExtent) {
          final double overDrag = math.min(proxyEnd - viewportEnd, overDragMax);
          newOffset = math.max(scrollable.position.minScrollExtent,
              scrollable.position.pixels - overDrag);
        } else if (proxyStart < viewportStart &&
            scrollable.position.pixels < scrollable.position.maxScrollExtent) {
          final double overDrag =
              math.min(viewportStart - proxyStart, overDragMax);
          newOffset = math.min(scrollable.position.maxScrollExtent,
              scrollable.position.pixels + overDrag);
        }
      case AxisDirection.right:
      case AxisDirection.down:
        if (proxyStart < viewportStart &&
            scrollable.position.pixels > scrollable.position.minScrollExtent) {
          final double overDrag =
              math.min(viewportStart - proxyStart, overDragMax);
          newOffset = math.max(scrollable.position.minScrollExtent,
              scrollable.position.pixels - overDrag);
        } else if (proxyEnd > viewportEnd &&
            scrollable.position.pixels < scrollable.position.maxScrollExtent) {
          final double overDrag = math.min(proxyEnd - viewportEnd, overDragMax);
          newOffset = math.min(scrollable.position.maxScrollExtent,
              scrollable.position.pixels + overDrag);
        }
    }

    if (newOffset == null ||
        (newOffset - scrollable.position.pixels).abs() < 1.0) {
      // Drag should not trigger scroll.
      _scrolling = false;
      return;
    }
    final Duration duration =
        Duration(milliseconds: (1000 / velocityScalar).round());
    await scrollable.position.animateTo(
      newOffset,
      duration: duration,
      curve: Curves.linear,
    );
    if (onScrollViewScrolled != null) {
      onScrollViewScrolled!();
    }
    if (_scrolling) {
      await _scroll();
    }
  }
}

typedef ScrollIncrementCalculator = double Function(
    ScrollIncrementDetails details);

enum ScrollIncrementType {
  line,

  page,
}

class ScrollIncrementDetails {
  const ScrollIncrementDetails({
    required this.type,
    required this.metrics,
  });

  final ScrollIncrementType type;

  final ScrollMetrics metrics;
}

class ScrollIntent extends Intent {
  const ScrollIntent({
    required this.direction,
    this.type = ScrollIncrementType.line,
  });

  final AxisDirection direction;

  final ScrollIncrementType type;
}

class ScrollAction extends ContextAction<ScrollIntent> {
  @override
  bool isEnabled(ScrollIntent intent, [BuildContext? context]) {
    if (context == null) {
      return false;
    }
    if (Scrollable.maybeOf(context) != null) {
      return true;
    }
    final ScrollController? primaryScrollController =
        PrimaryScrollController.maybeOf(context);
    return (primaryScrollController != null) &&
        (primaryScrollController.hasClients);
  }

  static double _calculateScrollIncrement(ScrollableState state,
      {ScrollIncrementType type = ScrollIncrementType.line}) {
    assert(state.position.hasPixels);
    assert(state.resolvedPhysics == null ||
        state.resolvedPhysics!.shouldAcceptUserOffset(state.position));
    if (state.widget.incrementCalculator != null) {
      return state.widget.incrementCalculator!(
        ScrollIncrementDetails(
          type: type,
          metrics: state.position,
        ),
      );
    }
    return switch (type) {
      ScrollIncrementType.line => 50.0,
      ScrollIncrementType.page => 0.8 * state.position.viewportDimension,
    };
  }

  static double getDirectionalIncrement(
      ScrollableState state, ScrollIntent intent) {
    if (axisDirectionToAxis(intent.direction) ==
        axisDirectionToAxis(state.axisDirection)) {
      final double increment =
          _calculateScrollIncrement(state, type: intent.type);
      return intent.direction == state.axisDirection ? increment : -increment;
    }
    return 0.0;
  }

  @override
  void invoke(ScrollIntent intent, [BuildContext? context]) {
    assert(context != null, 'Cannot scroll without a context.');
    ScrollableState? state = Scrollable.maybeOf(context!);
    if (state == null) {
      final ScrollController primaryScrollController =
          PrimaryScrollController.of(context);
      assert(() {
        if (primaryScrollController.positions.length != 1) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
              'A ScrollAction was invoked with the PrimaryScrollController, but '
              'more than one ScrollPosition is attached.',
            ),
            ErrorDescription(
              'Only one ScrollPosition can be manipulated by a ScrollAction at '
              'a time.',
            ),
            ErrorHint(
              'The PrimaryScrollController can be inherited automatically by '
              'descendant ScrollViews based on the TargetPlatform and scroll '
              'direction. By default, the PrimaryScrollController is '
              'automatically inherited on mobile platforms for vertical '
              'ScrollViews. ScrollView.primary can also override this behavior.',
            ),
          ]);
        }
        return true;
      }());

      if (primaryScrollController.position.context.notificationContext ==
              null &&
          Scrollable.maybeOf(primaryScrollController
                  .position.context.notificationContext!) ==
              null) {
        return;
      }
      state = Scrollable.maybeOf(
          primaryScrollController.position.context.notificationContext!);
    }
    assert(state != null,
        '$ScrollAction was invoked on a context that has no scrollable parent');
    assert(state!.position.hasPixels,
        'Scrollable must be laid out before it can be scrolled via a ScrollAction');

    // Don't do anything if the user isn't allowed to scroll.
    if (state!.resolvedPhysics != null &&
        !state.resolvedPhysics!.shouldAcceptUserOffset(state.position)) {
      return;
    }
    final double increment = getDirectionalIncrement(state, intent);
    if (increment == 0.0) {
      return;
    }
    state.position.moveTo(
      state.position.pixels + increment,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }
}


/// A scroll position that manages scroll activities for a single
/// [ScrollContext].
///
/// This class is a concrete subclass of [ScrollPosition] logic that handles a
/// single [ScrollContext], such as a [Scrollable]. An instance of this class
/// manages [ScrollActivity] instances, which change what content is visible in
/// the [Scrollable]'s [Viewport].
///
/// {@macro flutter.widgets.scrollPosition.listening}
///
/// See also:
///
///  * [ScrollPosition], which defines the underlying model for a position
///    within a [Scrollable] but is agnostic as to how that position is
///    changed.
///  * [ScrollView] and its subclasses such as [ListView], which use
///    [ScrollPositionWithSingleContext2] to manage their scroll position.
///  * [ScrollController], which can manipulate one or more [ScrollPosition]s,
///    and which uses [ScrollPositionWithSingleContext2] as its default class for
///    scroll positions.
class ScrollPositionWithSingleContext2 extends ScrollPosition implements ScrollActivityDelegate {
  /// Create a [ScrollPosition] object that manages its behavior using
  /// [ScrollActivity] objects.
  ///
  /// The `initialPixels` argument can be null, but in that case it is
  /// imperative that the value be set, using [correctPixels], as soon as
  /// [applyNewDimensions] is invoked, before calling the inherited
  /// implementation of that method.
  ///
  /// If [keepScrollOffset] is true (the default), the current scroll offset is
  /// saved with [PageStorage] and restored it if this scroll position's scrollable
  /// is recreated.
  ScrollPositionWithSingleContext2({
    required super.physics,
    required super.context,
    double? initialPixels = 0.0,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  }) {
    // If oldPosition is not null, the superclass will first call absorb(),
    // which may set _pixels and _activity.
    if (!hasPixels && initialPixels != null) {
      correctPixels(initialPixels);
    }
    if (activity == null) {
      goIdle();
    }
    assert(activity != null);
  }

  /// Velocity from a previous activity temporarily held by [hold] to potentially
  /// transfer to a next activity.
  double _heldPreviousVelocity = 0.0;

  @override
  AxisDirection get axisDirection => context.axisDirection;

  @override
  double setPixels(double newPixels) {
    assert(activity!.isScrolling);
    return super.setPixels(newPixels);
  }

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    if (other is! ScrollPositionWithSingleContext2) {
      goIdle();
      return;
    }
    activity!.updateDelegate(this);
    _userScrollDirection = other._userScrollDirection;
    assert(_currentDrag == null);
    if (other._currentDrag != null) {
      _currentDrag = other._currentDrag;
      _currentDrag!.updateDelegate(this);
      other._currentDrag = null;
    }
  }

  @override
  void applyNewDimensions() {
    super.applyNewDimensions();
    context.setCanDrag(physics.shouldAcceptUserOffset(this));
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    _heldPreviousVelocity = 0.0;
    if (newActivity == null) {
      return;
    }
    assert(newActivity.delegate == this);
    super.beginActivity(newActivity);
    _currentDrag?.dispose();
    _currentDrag = null;
    if (!activity!.isScrolling) {
      updateUserScrollDirection(ScrollDirection.idle);
    }
  }

  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    setPixels(pixels - physics.applyPhysicsToUserOffset(this, delta));
  }

  @override
  void goIdle() {
    beginActivity(IdleScrollActivity2(this));
  }

  /// Start a physics-driven simulation that settles the [pixels] position,
  /// starting at a particular velocity.
  ///
  /// This method defers to [ScrollPhysics.createBallisticSimulation], which
  /// typically provides a bounce simulation when the current position is out of
  /// bounds and a friction simulation when the position is in bounds but has a
  /// non-zero velocity.
  ///
  /// The velocity should be in logical pixels per second.
  @override
  void goBallistic(double velocity) {
    assert(hasPixels);
    final Simulation? simulation = physics.createBallisticSimulation(this, velocity);
    if (simulation != null) {
      beginActivity(BallisticScrollActivity(
        this,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? true,
      ));
    } else {
      goIdle();
    }
  }

  @override
  ScrollDirection get userScrollDirection => _userScrollDirection;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  /// Set [userScrollDirection] to the given value.
  ///
  /// If this changes the value, then a [UserScrollNotification] is dispatched.
  @protected
  @visibleForTesting
  void updateUserScrollDirection(ScrollDirection value) {
    if (userScrollDirection == value) {
      return;
    }
    _userScrollDirection = value;
    didUpdateScrollDirection(value);
  }

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) {
    if (nearEqual(to, pixels, physics.toleranceFor(this).distance)) {
      // Skip the animation, go straight to the position as we are already close.
      jumpTo(to);
      return Future<void>.value();
    }

    final DrivenScrollActivity activity = DrivenScrollActivity(
      this,
      from: pixels,
      to: to,
      duration: duration,
      curve: curve,
      vsync: context.vsync,
    );
    beginActivity(activity);
    return activity.done;
  }

  @override
  void jumpTo(double value) {
    goIdle();
    if (pixels != value) {
      final double oldPixels = pixels;
      forcePixels(value);
      didStartScroll();
      didUpdateScrollPositionBy(pixels - oldPixels);
      didEndScroll();
    }
    goBallistic(0.0);
  }

  @override
  void pointerScroll(double delta) {
    // If an update is made to pointer scrolling here, consider if the same
    // (or similar) change should be made in
    // _NestedScrollCoordinator.pointerScroll.
    if (delta == 0.0) {
      goBallistic(0.0);
      return;
    }

print(delta);
    final double targetPixels =
        pixels + delta;
        print(targetPixels);
    if (targetPixels != pixels) {
      goIdle();
      updateUserScrollDirection(
          -delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse,
      );
      final double oldPixels = pixels;
      // Set the notifier before calling force pixels.
      // This is set to false again after going ballistic below.
      isScrollingNotifier.value = true;
      forcePixels(targetPixels);
      didStartScroll();
      didUpdateScrollPositionBy(pixels - oldPixels);
      didEndScroll();
      goBallistic(0.0);
    }
  }


  @Deprecated('This will lead to bugs.') // flutter_ignore: deprecation_syntax, https://github.com/flutter/flutter/issues/44609
  @override
  void jumpToWithoutSettling(double value) {
    goIdle();
    if (pixels != value) {
      final double oldPixels = pixels;
      forcePixels(value);
      didStartScroll();
      didUpdateScrollPositionBy(pixels - oldPixels);
      didEndScroll();
    }
  }

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    final double previousVelocity = activity!.velocity;
    final HoldScrollActivity holdActivity = HoldScrollActivity(
      delegate: this,
      onHoldCanceled: holdCancelCallback,
    );
    beginActivity(holdActivity);
    _heldPreviousVelocity = previousVelocity;
    return holdActivity;
  }

  ScrollDragController? _currentDrag;

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    final ScrollDragController drag = ScrollDragController(
      delegate: this,
      details: details,
      onDragCanceled: dragCancelCallback,
      carriedVelocity: physics.carriedMomentum(_heldPreviousVelocity),
      motionStartDistanceThreshold: physics.dragStartDistanceMotionThreshold,
    );
    beginActivity(DragScrollActivity(this, drag));
    assert(_currentDrag == null);
    _currentDrag = drag;
    return drag;
  }

  @override
  void dispose() {
    _currentDrag?.dispose();
    _currentDrag = null;
    super.dispose();
  }

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('${context.runtimeType}');
    description.add('$physics');
    description.add('$activity');
    description.add('$userScrollDirection');
  }
}


/// A scroll activity that does nothing.
///
/// When a scroll view is not scrolling, it is performing the idle activity.
///
/// If the [Scrollable] changes dimensions, this activity triggers a ballistic
/// activity to restore the view.
class IdleScrollActivity2 extends ScrollActivity {
  /// Creates a scroll activity that does nothing.
  IdleScrollActivity2(super.delegate);

  @override
  void applyNewDimensions() {
    delegate.goBallistic(0.0);
  }

  @override
  bool get shouldIgnorePointer => false;

  @override
  bool get isScrolling => false;

  @override
  double get velocity => 0.0;
}

