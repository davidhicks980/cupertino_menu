// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    show ElevationOverlay, Feedback, Theme, ThemeData, WidgetState, WidgetStateProperty, WidgetStatesController;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const Duration _kDefaultHighlightFadeDuration = Duration(milliseconds: 200);

class CustomInkHighlight extends InteractiveCustomInkFeature {
  CustomInkHighlight({
    required super.controller,
    required super.referenceBox,
    required super.color,
    required TextDirection textDirection,
    BoxShape shape = BoxShape.rectangle,
    double? radius,
    BorderRadius? borderRadius,
    super.customBorder,
    RectCallback? rectCallback,
    super.onRemoved,
    Duration fadeDuration = _kDefaultHighlightFadeDuration,
  })  : _shape = shape,
        _radius = radius,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _textDirection = textDirection,
        _rectCallback = rectCallback {
    _alphaController =
        AnimationController(duration: fadeDuration, vsync: controller.vsync)
          ..addListener(controller.markNeedsPaint)
          ..addStatusListener(_handleAlphaStatusChanged)
          ..forward();
    _alpha = _alphaController.drive(IntTween(
      begin: 0,
      end: color.alpha,
    ));

    controller.addInkFeature(this);
  }

  final BoxShape _shape;
  final double? _radius;
  final BorderRadius _borderRadius;
  final RectCallback? _rectCallback;
  final TextDirection _textDirection;

  late Animation<int> _alpha;
  late AnimationController _alphaController;

  bool get active => _active;
  bool _active = true;

  void activate() {
    _active = true;
    _alphaController.forward();
  }

  void deactivate() {
    _active = false;
    _alphaController.reverse();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !_active) {
      dispose();
    }
  }

  @override
  void dispose() {
    _alphaController.dispose();
    super.dispose();
  }

  void _paintHighlight(Canvas canvas, Rect rect, Paint paint) {
    canvas.save();
    if (customBorder != null) {
      canvas.clipPath(
          customBorder!.getOuterPath(rect, textDirection: _textDirection));
    }
    switch (_shape) {
      case BoxShape.circle:
        canvas.drawCircle(
            rect.center, _radius ?? CustomMaterial.defaultSplashRadius, paint);
      case BoxShape.rectangle:
        if (_borderRadius != BorderRadius.zero) {
          final RRect clipRRect = RRect.fromRectAndCorners(
            rect,
            topLeft: _borderRadius.topLeft,
            topRight: _borderRadius.topRight,
            bottomLeft: _borderRadius.bottomLeft,
            bottomRight: _borderRadius.bottomRight,
          );
          canvas.drawRRect(clipRRect, paint);
        } else {
          canvas.drawRect(rect, paint);
        }
    }
    canvas.restore();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()..color = color.withAlpha(_alpha.value);
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    final Rect rect = _rectCallback != null
        ? _rectCallback()
        : Offset.zero & referenceBox.size;
    if (originOffset == null) {
      canvas.save();
      canvas.transform(transform.storage);
      _paintHighlight(canvas, rect, paint);
      canvas.restore();
    } else {
      _paintHighlight(canvas, rect.shift(originOffset), paint);
    }
  }
}

// Examples can assume:
// late BuildContext context;

typedef RectCallback = Rect Function();

enum MaterialType {
  canvas,

  card,

  circle,

  button,

  transparency
}

const Map<MaterialType, BorderRadius?> kMaterialEdges =
    <MaterialType, BorderRadius?>{
  MaterialType.canvas: null,
  MaterialType.card: BorderRadius.all(Radius.circular(2.0)),
  MaterialType.circle: null,
  MaterialType.button: BorderRadius.all(Radius.circular(2.0)),
  MaterialType.transparency: null,
};

abstract class MaterialCustomInkController {
  Color? get color;

  TickerProvider get vsync;

  void addInkFeature(InkFeature feature);

  void markNeedsPaint();
}

class CustomMaterial extends StatefulWidget {
  const CustomMaterial({
    super.key,
    this.type = MaterialType.canvas,
    this.elevation = 0.0,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.textStyle,
    this.borderRadius,
    this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    this.animationDuration = const Duration(milliseconds: 500),
    this.child,
  }) ;

  final Widget? child;

  final MaterialType type;

  final double elevation;

  final Color? color;

  final Color? shadowColor;

  final Color? surfaceTintColor;

  final TextStyle? textStyle;

  final ShapeBorder? shape;

  final bool borderOnForeground;

  final Clip clipBehavior;

  final Duration animationDuration;

  final BorderRadiusGeometry? borderRadius;

  static const double defaultSplashRadius = 35.0;

  static MaterialCustomInkController? maybeOf(BuildContext context) {
    return LookupBoundary.findAncestorRenderObjectOfType<_RenderInkFeatures>(
        context);
  }

  static MaterialCustomInkController of(BuildContext context) {
    final MaterialCustomInkController? controller = maybeOf(context);
    return controller!;
  }

  @override
  State<CustomMaterial> createState() => _CustomMaterialState();
}

class _CustomMaterialState extends State<CustomMaterial> with TickerProviderStateMixin {
  final GlobalKey _inkFeatureRenderer = GlobalKey(debugLabel: 'ink renderer');

  Color? _getBackgroundColor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    Color? color = widget.color;
    if (color == null) {
      switch (widget.type) {
        case MaterialType.canvas:
          color = theme.canvasColor;
        case MaterialType.card:
          color = theme.cardColor;
        case MaterialType.button:
        case MaterialType.circle:
        case MaterialType.transparency:
          break;
      }
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color? backgroundColor = _getBackgroundColor(context);
    final Color modelShadowColor = widget.shadowColor ??
        (theme.useMaterial3 ? theme.colorScheme.shadow : theme.shadowColor);
    final double modelElevation = widget.elevation;
    Widget? contents = widget.child;
    if (contents != null) {
      contents = AnimatedDefaultTextStyle(
        style: widget.textStyle ?? Theme.of(context).textTheme.bodyMedium!,
        duration: widget.animationDuration,
        child: contents,
      );
    }
    contents = NotificationListener<LayoutChangedNotification>(
      onNotification: (LayoutChangedNotification notification) {
        final _RenderInkFeatures renderer = _inkFeatureRenderer.currentContext!
            .findRenderObject()! as _RenderInkFeatures;
        renderer._didChangeLayout();
        return false;
      },
      child: _InkFeatures(
        key: _inkFeatureRenderer,
        absorbHitTest: widget.type != MaterialType.transparency,
        color: backgroundColor,
        vsync: this,
        child: contents,
      ),
    );

    // PhysicalModel has a temporary workaround for a performance issue that
    // speeds up rectangular non transparent material (the workaround is to
    // skip the call to ui.Canvas.saveLayer if the border radius is 0).
    // Until the saveLayer performance issue is resolved, we're keeping this
    // special case here for canvas material type that is using the default
    // shape (rectangle). We could go down this fast path for explicitly
    // specified rectangles (e.g shape RoundedRectangleBorder with radius 0, but
    // we choose not to as we want the change from the fast-path to the
    // slow-path to be noticeable in the construction site of Material.
    if (widget.type == MaterialType.canvas &&
        widget.shape == null &&
        widget.borderRadius == null) {
      final Color color = Theme.of(context).useMaterial3
          ? ElevationOverlay.applySurfaceTint(
              backgroundColor!, widget.surfaceTintColor, widget.elevation)
          : ElevationOverlay.applyOverlay(
              context, backgroundColor!, widget.elevation);

      return AnimatedPhysicalModel(
        curve: Curves.fastOutSlowIn,
        duration: widget.animationDuration,
        shape: BoxShape.rectangle,
        clipBehavior: widget.clipBehavior,
        elevation: modelElevation,
        color: color,
        shadowColor: modelShadowColor,
        animateColor: false,
        child: contents,
      );
    }

    final ShapeBorder shape = _getShape();

    if (widget.type == MaterialType.transparency) {
      return _transparentInterior(
        context: context,
        shape: shape,
        clipBehavior: widget.clipBehavior,
        contents: contents,
      );
    }

    return _MaterialInterior(
      curve: Curves.fastOutSlowIn,
      duration: widget.animationDuration,
      shape: shape,
      borderOnForeground: widget.borderOnForeground,
      clipBehavior: widget.clipBehavior,
      elevation: widget.elevation,
      color: backgroundColor!,
      shadowColor: modelShadowColor,
      surfaceTintColor: widget.surfaceTintColor,
      child: contents,
    );
  }

  static Widget _transparentInterior({
    required BuildContext context,
    required ShapeBorder shape,
    required Clip clipBehavior,
    required Widget contents,
  }) {
    final _ShapeBorderPaint child = _ShapeBorderPaint(
      shape: shape,
      child: contents,
    );
    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: shape,
        textDirection: Directionality.maybeOf(context),
      ),
      clipBehavior: clipBehavior,
      child: child,
    );
  }

  // Determines the shape for this Material.
  //
  // If a shape was specified, it will determine the shape.
  // If a borderRadius was specified, the shape is a rounded
  // rectangle.
  // Otherwise, the shape is determined by the widget type as described in the
  // Material class documentation.
  ShapeBorder _getShape() {
    if (widget.shape != null) {
      return widget.shape!;
    }
    if (widget.borderRadius != null) {
      return RoundedRectangleBorder(borderRadius: widget.borderRadius!);
    }
    switch (widget.type) {
      case MaterialType.canvas:
      case MaterialType.transparency:
        return const RoundedRectangleBorder();

      case MaterialType.card:
      case MaterialType.button:
        return RoundedRectangleBorder(
          borderRadius: widget.borderRadius ?? kMaterialEdges[widget.type]!,
        );

      case MaterialType.circle:
        return const CircleBorder();
    }
  }
}

class _RenderInkFeatures extends RenderProxyBox
    implements MaterialCustomInkController {
  _RenderInkFeatures({
    RenderBox? child,
    required this.vsync,
    required this.absorbHitTest,
    this.color,
  }) : super(child);

  // This class should exist in a 1:1 relationship with a MaterialState object,
  // since there's no current support for dynamically changing the ticker
  // provider.
  @override
  final TickerProvider vsync;

  // This is here to satisfy the MaterialCustomInkController contract.
  // The actual painting of this color is done by a Container in the
  // MaterialState build method.
  @override
  Color? color;

  bool absorbHitTest;

  @visibleForTesting
  List<InkFeature>? get debugInkFeatures {
    if (kDebugMode) {
      return _inkFeatures;
    }
    return null;
  }

  List<InkFeature>? _inkFeatures;

  @override
  void addInkFeature(InkFeature feature) {
    assert(!feature._debugDisposed);
    assert(feature._controller == this);
    _inkFeatures ??= <InkFeature>[];
    assert(!_inkFeatures!.contains(feature));
    _inkFeatures!.add(feature);
    markNeedsPaint();
  }

  void _removeFeature(InkFeature feature) {
    assert(_inkFeatures != null);
    _inkFeatures!.remove(feature);
    markNeedsPaint();
  }

  void _didChangeLayout() {
    if (_inkFeatures?.isNotEmpty ?? false) {
      markNeedsPaint();
    }
  }

  @override
  bool hitTestSelf(Offset position) => absorbHitTest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final List<InkFeature>? inkFeatures = _inkFeatures;
    if (inkFeatures != null && inkFeatures.isNotEmpty) {
      final Canvas canvas = context.canvas;
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.clipRect(Offset.zero & size);
      for (final InkFeature inkFeature in inkFeatures) {
        inkFeature._paint(canvas);
      }
      canvas.restore();
    }
    assert(inkFeatures == _inkFeatures);
    super.paint(context, offset);
  }
}

class _InkFeatures extends SingleChildRenderObjectWidget {
  const _InkFeatures({
    super.key,
    this.color,
    required this.vsync,
    required this.absorbHitTest,
    super.child,
  });

  // This widget must be owned by a MaterialState, which must be provided as the vsync.
  // This relationship must be 1:1 and cannot change for the lifetime of the MaterialState.

  final Color? color;

  final TickerProvider vsync;

  final bool absorbHitTest;

  @override
  _RenderInkFeatures createRenderObject(BuildContext context) {
    return _RenderInkFeatures(
      color: color,
      absorbHitTest: absorbHitTest,
      vsync: vsync,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInkFeatures renderObject) {
    renderObject
      ..color = color
      ..absorbHitTest = absorbHitTest;
    assert(vsync == renderObject.vsync);
  }
}

abstract class InkFeature {
  InkFeature({
    required MaterialCustomInkController controller,
    required this.referenceBox,
    this.onRemoved,
  }) : _controller = controller as _RenderInkFeatures {
    // TODO(polina-c): stop duplicating code across disposables
    // https://github.com/flutter/flutter/issues/137435
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:flutter/material.dart',
        className: '$InkFeature',
        object: this,
      );
    }
  }

  MaterialCustomInkController get controller => _controller;
  final _RenderInkFeatures _controller;

  final RenderBox referenceBox;

  final VoidCallback? onRemoved;

  bool _debugDisposed = false;

  @mustCallSuper
  void dispose() {
    assert(!_debugDisposed);
    assert(() {
      _debugDisposed = true;
      return true;
    }());
    // TODO(polina-c): stop duplicating code across disposables
    // https://github.com/flutter/flutter/issues/137435
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _controller._removeFeature(this);
    onRemoved?.call();
  }

  // Returns the paint transform that allows `fromRenderObject` to perform paint
  // in `toRenderObject`'s coordinate space.
  //
  // Returns null if either `fromRenderObject` or `toRenderObject` is not in the
  // same render tree, or either of them is in an offscreen subtree (see
  // RenderObject.paintsChild).
  static Matrix4? _getPaintTransform(
    RenderObject fromRenderObject,
    RenderObject toRenderObject,
  ) {
    // The paths to fromRenderObject and toRenderObject's common ancestor.
    final List<RenderObject> fromPath = <RenderObject>[fromRenderObject];
    final List<RenderObject> toPath = <RenderObject>[toRenderObject];

    RenderObject from = fromRenderObject;
    RenderObject to = toRenderObject;

    while (!identical(from, to)) {
      final int fromDepth = from.depth;
      final int toDepth = to.depth;

      if (fromDepth >= toDepth) {
        final RenderObject? fromParent = from.parent;
        // Return early if the 2 render objects are not in the same render tree,
        // or either of them is offscreen and thus won't get painted.
        if (fromParent is! RenderObject || !fromParent.paintsChild(from)) {
          return null;
        }
        fromPath.add(fromParent);
        from = fromParent;
      }

      if (fromDepth <= toDepth) {
        final RenderObject? toParent = to.parent;
        if (toParent is! RenderObject || !toParent.paintsChild(to)) {
          return null;
        }
        toPath.add(toParent);
        to = toParent;
      }
    }
    assert(identical(from, to));

    final Matrix4 transform = Matrix4.identity();
    final Matrix4 inverseTransform = Matrix4.identity();

    for (int index = toPath.length - 1; index > 0; index -= 1) {
      toPath[index].applyPaintTransform(toPath[index - 1], transform);
    }
    for (int index = fromPath.length - 1; index > 0; index -= 1) {
      fromPath[index]
          .applyPaintTransform(fromPath[index - 1], inverseTransform);
    }

    final double det = inverseTransform.invert();
    return det != 0 ? (inverseTransform..multiply(transform)) : null;
  }

  void _paint(Canvas canvas) {
    assert(referenceBox.attached);
    assert(!_debugDisposed);
    // determine the transform that gets our coordinate system to be like theirs
    final Matrix4? transform = _getPaintTransform(_controller, referenceBox);
    if (transform != null) {
      paintFeature(canvas, transform);
    }
  }

  @protected
  void paintFeature(Canvas canvas, Matrix4 transform);

  @override
  String toString() => describeIdentity(this);
}

class ShapeBorderTween extends Tween<ShapeBorder?> {
  ShapeBorderTween({super.begin, super.end});

  @override
  ShapeBorder? lerp(double t) {
    return ShapeBorder.lerp(begin, end, t);
  }
}

class _MaterialInterior extends ImplicitlyAnimatedWidget {
  const _MaterialInterior({
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
    this.clipBehavior = Clip.none,
    required this.elevation,
    required this.color,
    required this.shadowColor,
    required this.surfaceTintColor,
    super.curve,
    required super.duration,
  }) : assert(elevation >= 0.0);

  final Widget child;

  final ShapeBorder shape;

  final bool borderOnForeground;

  final Clip clipBehavior;

  final double elevation;

  final Color color;

  final Color? shadowColor;

  final Color? surfaceTintColor;

  @override
  _MaterialInteriorState createState() => _MaterialInteriorState();


}

class _MaterialInteriorState
    extends AnimatedWidgetBaseState<_MaterialInterior> {
  Tween<double>? _elevation;
  ColorTween? _surfaceTintColor;
  ColorTween? _shadowColor;
  ShapeBorderTween? _border;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _elevation = visitor(
      _elevation,
      widget.elevation,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
    _shadowColor = widget.shadowColor != null
        ? visitor(
            _shadowColor,
            widget.shadowColor,
            (dynamic value) => ColorTween(begin: value as Color),
          ) as ColorTween?
        : null;
    _surfaceTintColor = widget.surfaceTintColor != null
        ? visitor(
            _surfaceTintColor,
            widget.surfaceTintColor,
            (dynamic value) => ColorTween(begin: value as Color),
          ) as ColorTween?
        : null;
    _border = visitor(
      _border,
      widget.shape,
      (dynamic value) => ShapeBorderTween(begin: value as ShapeBorder),
    ) as ShapeBorderTween?;
  }

  @override
  Widget build(BuildContext context) {
    final ShapeBorder shape = _border!.evaluate(animation)!;
    final double elevation = _elevation!.evaluate(animation);
    final Color color = Theme.of(context).useMaterial3
        ? ElevationOverlay.applySurfaceTint(
            widget.color, _surfaceTintColor?.evaluate(animation), elevation)
        : ElevationOverlay.applyOverlay(context, widget.color, elevation);
    // If no shadow color is specified, use 0 for elevation in the model so a drop shadow won't be painted.
    final double modelElevation = widget.shadowColor != null ? elevation : 0;
    final Color shadowColor =
        _shadowColor?.evaluate(animation) ?? const Color(0x00000000);
    return PhysicalShape(
      clipper: ShapeBorderClipper(
        shape: shape,
        textDirection: Directionality.maybeOf(context),
      ),
      clipBehavior: widget.clipBehavior,
      elevation: modelElevation,
      color: color,
      shadowColor: shadowColor,
      child: _ShapeBorderPaint(
        shape: shape,
        borderOnForeground: widget.borderOnForeground,
        child: widget.child,
      ),
    );
  }
}

class _ShapeBorderPaint extends StatelessWidget {
  const _ShapeBorderPaint({
    required this.child,
    required this.shape,
    this.borderOnForeground = true,
  });

  final Widget child;
  final ShapeBorder shape;
  final bool borderOnForeground;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: borderOnForeground
          ? null
          : _ShapeBorderPainter(shape, Directionality.maybeOf(context)),
      foregroundPainter: borderOnForeground
          ? _ShapeBorderPainter(shape, Directionality.maybeOf(context))
          : null,
      child: child,
    );
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}

// Examples can assume:
// late BuildContext context;

abstract class InteractiveCustomInkFeature extends InkFeature {
  InteractiveCustomInkFeature({
    required super.controller,
    required super.referenceBox,
    required Color color,
    ShapeBorder? customBorder,
    super.onRemoved,
  })  : _color = color,
        _customBorder = customBorder;

  void confirm() {}

  void cancel() {}

  Color get color => _color;
  Color _color;
  set color(Color value) {
    if (value == _color) {
      return;
    }
    _color = value;
    controller.markNeedsPaint();
  }

  ShapeBorder? get customBorder => _customBorder;
  ShapeBorder? _customBorder;
  set customBorder(ShapeBorder? value) {
    if (value == _customBorder) {
      return;
    }
    _customBorder = value;
    controller.markNeedsPaint();
  }

  @protected
  void paintInkCircle({
    required Canvas canvas,
    required Matrix4 transform,
    required Paint paint,
    required Offset center,
    required double radius,
    TextDirection? textDirection,
    ShapeBorder? customBorder,
    BorderRadius borderRadius = BorderRadius.zero,
    RectCallback? clipCallback,
  }) {
    final Offset? originOffset = MatrixUtils.getAsTranslation(transform);
    canvas.save();
    if (originOffset == null) {
      canvas.transform(transform.storage);
    } else {
      canvas.translate(originOffset.dx, originOffset.dy);
    }
    if (clipCallback != null) {
      final Rect rect = clipCallback();
      if (customBorder != null) {
        canvas.clipPath(
            customBorder.getOuterPath(rect, textDirection: textDirection));
      } else if (borderRadius != BorderRadius.zero) {
        canvas.clipRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: borderRadius.topLeft,
          topRight: borderRadius.topRight,
          bottomLeft: borderRadius.bottomLeft,
          bottomRight: borderRadius.bottomRight,
        ));
      } else {
        canvas.clipRect(rect);
      }
    }
    canvas.drawCircle(center, radius, paint);
    canvas.restore();
  }
}

abstract class InteractiveCustomInkFeatureFactory {
  const InteractiveCustomInkFeatureFactory();

  @factory
  InteractiveCustomInkFeature create({
    required MaterialCustomInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  });
}

abstract class _ParentInkResponseState {
  void markChildInkResponsePressed(
      _ParentInkResponseState childState, bool value);
}

class _ParentInkResponseProvider extends InheritedWidget {
  const _ParentInkResponseProvider({
    required this.state,
    required super.child,
  });

  final _ParentInkResponseState state;

  @override
  bool updateShouldNotify(_ParentInkResponseProvider oldWidget) =>
      state != oldWidget.state;

  static _ParentInkResponseState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ParentInkResponseProvider>()
        ?.state;
  }
}

typedef _GetRectCallback = RectCallback? Function(RenderBox referenceBox);

class CustomInkResponse extends StatelessWidget {
  const CustomInkResponse({
    super.key,
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.containedInkWell = false,
    this.highlightShape = BoxShape.circle,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.statesController,
    this.hoverDuration,
  });

  final Widget? child;

  final GestureTapCallback? onTap;

  final GestureTapDownCallback? onTapDown;

  final GestureTapUpCallback? onTapUp;

  final GestureTapCallback? onTapCancel;

  final GestureTapCallback? onDoubleTap;

  final GestureLongPressCallback? onLongPress;

  final GestureTapCallback? onSecondaryTap;

  final GestureTapDownCallback? onSecondaryTapDown;

  final GestureTapUpCallback? onSecondaryTapUp;

  final GestureTapCallback? onSecondaryTapCancel;

  final ValueChanged<bool>? onHighlightChanged;

  final ValueChanged<bool>? onHover;

  final MouseCursor? mouseCursor;

  final bool containedInkWell;

  final BoxShape highlightShape;

  final double? radius;

  final BorderRadius? borderRadius;

  final ShapeBorder? customBorder;

  final Color? focusColor;

  final Color? hoverColor;

  final Color? highlightColor;

  final WidgetStateProperty<Color?>? overlayColor;

  final Color? splashColor;

  final InteractiveCustomInkFeatureFactory? splashFactory;

  final bool enableFeedback;

  final bool excludeFromSemantics;

  final ValueChanged<bool>? onFocusChange;

  final bool autofocus;

  final FocusNode? focusNode;

  final bool canRequestFocus;

  RectCallback? getRectCallback(RenderBox referenceBox) => null;

  final WidgetStatesController? statesController;

  final Duration? hoverDuration;

  @override
  Widget build(BuildContext context) {
    final _ParentInkResponseState? parentState =
        _ParentInkResponseProvider.maybeOf(context);
    return _InkResponseStateWidget(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      onSecondaryTap: onSecondaryTap,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onHighlightChanged: onHighlightChanged,
      onHover: onHover,
      mouseCursor: mouseCursor,
      containedInkWell: containedInkWell,
      highlightShape: highlightShape,
      radius: radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
      overlayColor: overlayColor,
      splashColor: splashColor,
      splashFactory: splashFactory,
      enableFeedback: enableFeedback,
      excludeFromSemantics: excludeFromSemantics,
      focusNode: focusNode,
      canRequestFocus: canRequestFocus,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      parentState: parentState,
      getRectCallback: getRectCallback,
      statesController: statesController,
      hoverDuration: hoverDuration,
      child: child,
    );
  }
}

class _InkResponseStateWidget extends StatefulWidget {
  const _InkResponseStateWidget({
    this.child,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onSecondaryTapUp,
    this.onSecondaryTapDown,
    this.onSecondaryTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.containedInkWell = false,
    this.highlightShape = BoxShape.circle,
    this.radius,
    this.borderRadius,
    this.customBorder,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.enableFeedback = true,
    this.excludeFromSemantics = false,
    this.focusNode,
    this.canRequestFocus = true,
    this.onFocusChange,
    this.autofocus = false,
    this.parentState,
    this.getRectCallback,
    this.statesController,
    this.hoverDuration,
  });

  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapCallback? onSecondaryTapCancel;
  final ValueChanged<bool>? onHighlightChanged;
  final ValueChanged<bool>? onHover;
  final MouseCursor? mouseCursor;
  final bool containedInkWell;
  final BoxShape highlightShape;
  final double? radius;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final Color? splashColor;
  final InteractiveCustomInkFeatureFactory? splashFactory;
  final bool enableFeedback;
  final bool excludeFromSemantics;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool canRequestFocus;
  final _ParentInkResponseState? parentState;
  final _GetRectCallback? getRectCallback;
  final WidgetStatesController? statesController;
  final Duration? hoverDuration;

  @override
  _InkResponseState createState() => _InkResponseState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final List<String> gestures = <String>[
      if (onTap != null) 'tap',
      if (onDoubleTap != null) 'double tap',
      if (onLongPress != null) 'long press',
      if (onTapDown != null) 'tap down',
      if (onTapUp != null) 'tap up',
      if (onTapCancel != null) 'tap cancel',
      if (onSecondaryTap != null) 'secondary tap',
      if (onSecondaryTapUp != null) 'secondary tap up',
      if (onSecondaryTapDown != null) 'secondary tap down',
      if (onSecondaryTapCancel != null) 'secondary tap cancel'
    ];
    properties
        .add(IterableProperty<String>('gestures', gestures, ifEmpty: '<none>'));
    properties
        .add(DiagnosticsProperty<MouseCursor>('mouseCursor', mouseCursor));
    properties.add(DiagnosticsProperty<bool>(
        'containedInkWell', containedInkWell,
        level: DiagnosticLevel.fine));
    properties.add(DiagnosticsProperty<BoxShape>(
      'highlightShape',
      highlightShape,
      description: '${containedInkWell ? "clipped to " : ""}$highlightShape',
      showName: false,
    ));
  }
}

enum _HighlightType {
  pressed,
  hover,
  focus,
}

class _InkResponseState extends State<_InkResponseStateWidget>
    with AutomaticKeepAliveClientMixin<_InkResponseStateWidget>
    implements _ParentInkResponseState {
  Set<InteractiveCustomInkFeature>? _splashes;
  InteractiveCustomInkFeature? _currentSplash;
  bool _hovering = false;
  final Map<_HighlightType, CustomInkHighlight?> _highlights =
      <_HighlightType, CustomInkHighlight?>{};
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: activateOnIntent),
    ButtonActivateIntent:
        CallbackAction<ButtonActivateIntent>(onInvoke: activateOnIntent),
  };
  WidgetStatesController? internalStatesController;

  bool get highlightsExist => _highlights.values
      .where((CustomInkHighlight? highlight) => highlight != null)
      .isNotEmpty;

  final ObserverList<_ParentInkResponseState> _activeChildren =
      ObserverList<_ParentInkResponseState>();

  static const Duration _activationDuration = Duration(milliseconds: 100);
  Timer? _activationTimer;

  @override
  void markChildInkResponsePressed(
      _ParentInkResponseState childState, bool value) {
    final bool lastAnyPressed = _anyChildInkResponsePressed;
    if (value) {
      _activeChildren.add(childState);
    } else {
      _activeChildren.remove(childState);
    }
    final bool nowAnyPressed = _anyChildInkResponsePressed;
    if (nowAnyPressed != lastAnyPressed) {
      widget.parentState?.markChildInkResponsePressed(this, nowAnyPressed);
    }
  }

  bool get _anyChildInkResponsePressed => _activeChildren.isNotEmpty;

  void activateOnIntent(Intent? intent) {
    _activationTimer?.cancel();
    _activationTimer = null;
    _startNewSplash(context: context);
    _currentSplash?.confirm();
    _currentSplash = null;
    if (widget.onTap != null) {
      if (widget.enableFeedback) {
        Feedback.forTap(context);
      }
      widget.onTap?.call();
    }
    // Delay the call to `updateHighlight` to simulate a pressed delay
    // and give MaterialStatesController listeners a chance to react.
    _activationTimer = Timer(_activationDuration, () {
      updateHighlight(_HighlightType.pressed, value: false);
    });
  }

  void simulateTap([Intent? intent]) {
    _startNewSplash(context: context);
    handleTap();
  }

  void simulateLongPress() {
    _startNewSplash(context: context);
    handleLongPress();
  }

  void handleStatesControllerChange() {
    // Force a rebuild to resolve widget.overlayColor, widget.mouseCursor
    setState(() {});
  }

  WidgetStatesController get statesController =>
      widget.statesController ?? internalStatesController!;

  void initStatesController() {
    if (widget.statesController == null) {
      internalStatesController = WidgetStatesController();
    }
    statesController.update(WidgetState.disabled, !enabled);
    statesController.addListener(handleStatesControllerChange);
  }

  @override
  void initState() {
    super.initState();
    initStatesController();
    FocusManager.instance
        .addHighlightModeListener(handleFocusHighlightModeChange);
  }

  @override
  void didUpdateWidget(_InkResponseStateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.statesController != oldWidget.statesController) {
      oldWidget.statesController?.removeListener(handleStatesControllerChange);
      if (widget.statesController != null) {
        internalStatesController?.dispose();
        internalStatesController = null;
      }
      initStatesController();
    }
    if (widget.radius != oldWidget.radius ||
        widget.highlightShape != oldWidget.highlightShape ||
        widget.borderRadius != oldWidget.borderRadius) {
      final CustomInkHighlight? hoverHighlight = _highlights[_HighlightType.hover];
      if (hoverHighlight != null) {
        hoverHighlight.dispose();
        updateHighlight(_HighlightType.hover,
            value: _hovering, callOnHover: false);
      }
      final CustomInkHighlight? focusHighlight = _highlights[_HighlightType.focus];
      if (focusHighlight != null) {
        focusHighlight.dispose();
        // Do not call updateFocusHighlights() here because it is called below
      }
    }
    if (widget.customBorder != oldWidget.customBorder) {
      _updateHighlightsAndSplashes();
    }
    if (enabled != isWidgetEnabled(oldWidget)) {
      statesController.update(WidgetState.disabled, !enabled);
      if (!enabled) {
        statesController.update(WidgetState.pressed, false);
        // Remove the existing hover highlight immediately when enabled is false.
        // Do not rely on updateHighlight or InkHighlight.deactivate to not break
        // the expected lifecycle which is updating _hovering when the mouse exit.
        // Manually updating _hovering here or calling InkHighlight.deactivate
        // will lead to onHover not being called or call when it is not allowed.
        final CustomInkHighlight? hoverHighlight = _highlights[_HighlightType.hover];
        hoverHighlight?.dispose();
      }
      // Don't call widget.onHover because many widgets, including the button
      // widgets, apply setState to an ancestor context from onHover.
      updateHighlight(_HighlightType.hover,
          value: _hovering, callOnHover: false);
    }
    updateFocusHighlights();
  }

  @override
  void dispose() {
    FocusManager.instance
        .removeHighlightModeListener(handleFocusHighlightModeChange);
    statesController.removeListener(handleStatesControllerChange);
    internalStatesController?.dispose();
    _activationTimer?.cancel();
    _activationTimer = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive =>
      highlightsExist || (_splashes != null && _splashes!.isNotEmpty);

  Duration getFadeDurationForType(_HighlightType type) {
    switch (type) {
      case _HighlightType.pressed:
        return const Duration(milliseconds: 200);
      case _HighlightType.hover:
      case _HighlightType.focus:
        return widget.hoverDuration ?? const Duration(milliseconds: 50);
    }
  }

  void updateHighlight(_HighlightType type,
      {required bool value, bool callOnHover = true}) {
    final CustomInkHighlight? highlight = _highlights[type];
    void handleInkRemoval() {
      assert(_highlights[type] != null);
      _highlights[type] = null;
      updateKeepAlive();
    }

    switch (type) {
      case _HighlightType.pressed:
        statesController.update(WidgetState.pressed, value);
      case _HighlightType.hover:
        if (callOnHover) {
          statesController.update(WidgetState.hovered, value);
        }
      case _HighlightType.focus:
        // see handleFocusUpdate()
        break;
    }

    if (type == _HighlightType.pressed) {
      widget.parentState?.markChildInkResponsePressed(this, value);
    }
    if (value == (highlight != null && highlight.active)) {
      return;
    }

    if (value) {
      if (highlight == null) {
        Color? resolvedOverlayColor =
            widget.overlayColor?.resolve(statesController.value);
        if (resolvedOverlayColor == null) {
          // Use the backwards compatible defaults
          final ThemeData theme = Theme.of(context);
          switch (type) {
            case _HighlightType.pressed:
              resolvedOverlayColor =
                  widget.highlightColor ?? theme.highlightColor;
            case _HighlightType.focus:
              resolvedOverlayColor = widget.focusColor ?? theme.focusColor;
            case _HighlightType.hover:
              resolvedOverlayColor = widget.hoverColor ?? theme.hoverColor;
          }
        }
        final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
        _highlights[type] = CustomInkHighlight(
          controller: CustomMaterial.of(context),
          referenceBox: referenceBox,
          color: enabled
              ? resolvedOverlayColor
              : resolvedOverlayColor.withAlpha(0),
          shape: widget.highlightShape,
          radius: widget.radius,
          borderRadius: widget.borderRadius,
          customBorder: widget.customBorder,
          rectCallback: widget.getRectCallback!(referenceBox),
          onRemoved: handleInkRemoval,
          textDirection: Directionality.of(context),
          fadeDuration: getFadeDurationForType(type),
        );
        updateKeepAlive();
      } else {
        highlight.activate();
      }
    } else {
      highlight!.deactivate();
    }
    assert(value == (_highlights[type] != null && _highlights[type]!.active));

    switch (type) {
      case _HighlightType.pressed:
        widget.onHighlightChanged?.call(value);
      case _HighlightType.hover:
        if (callOnHover) {
          widget.onHover?.call(value);
        }
      case _HighlightType.focus:
        break;
    }
  }

  void _updateHighlightsAndSplashes() {
    for (final CustomInkHighlight? highlight in _highlights.values) {
      if (highlight != null) {
        highlight.customBorder = widget.customBorder;
      }
    }
    if (_currentSplash != null) {
      _currentSplash!.customBorder = widget.customBorder;
    }
    if (_splashes != null && _splashes!.isNotEmpty) {
      for (final InteractiveCustomInkFeature inkFeature in _splashes!) {
        inkFeature.customBorder = widget.customBorder;
      }
    }
  }

  InteractiveCustomInkFeature _createSplash(Offset globalPosition) {
    final MaterialCustomInkController inkController = CustomMaterial.of(context);
    final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
    final Offset position = referenceBox.globalToLocal(globalPosition);
    final Color color = widget.overlayColor?.resolve(statesController.value) ??
        widget.splashColor ??
        Theme.of(context).splashColor;
    final RectCallback? rectCallback =
        widget.containedInkWell ? widget.getRectCallback!(referenceBox) : null;
    final BorderRadius? borderRadius = widget.borderRadius;
    final ShapeBorder? customBorder = widget.customBorder;

    InteractiveCustomInkFeature? splash;
    void onRemoved() {
      if (_splashes != null) {
        assert(_splashes!.contains(splash));
        _splashes!.remove(splash);
        if (_currentSplash == splash) {
          _currentSplash = null;
        }
        updateKeepAlive();
      } // else we're probably in deactivate()
    }

    splash = ((widget.splashFactory ?? Theme.of(context).splashFactory) as InteractiveCustomInkFeatureFactory).create(
      controller: inkController,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: widget.containedInkWell,
      rectCallback: rectCallback,
      radius: widget.radius,
      borderRadius: borderRadius,
      customBorder: customBorder,
      onRemoved: onRemoved,
      textDirection: Directionality.of(context),
    );

    return splash;
  }

  void handleFocusHighlightModeChange(FocusHighlightMode mode) {
    if (!mounted) {
      return;
    }
    setState(() {
      updateFocusHighlights();
    });
  }

  bool get _shouldShowFocus {
    final NavigationMode mode =
        MediaQuery.maybeNavigationModeOf(context) ?? NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && _hasFocus;
      case NavigationMode.directional:
        return _hasFocus;
    }
  }

  void updateFocusHighlights() {
    final bool showFocus;
    switch (FocusManager.instance.highlightMode) {
      case FocusHighlightMode.touch:
        showFocus = false;
      case FocusHighlightMode.traditional:
        showFocus = _shouldShowFocus;
    }
    updateHighlight(_HighlightType.focus, value: showFocus);
  }

  bool _hasFocus = false;
  void handleFocusUpdate(bool hasFocus) {
    _hasFocus = hasFocus;
    // Set here rather than updateHighlight because this widget's
    // (MaterialState) states include MaterialState.focused if
    // the InkWell _has_ the focus, rather than if it's showing
    // the focus per FocusManager.instance.highlightMode.
    statesController.update(WidgetState.focused, hasFocus);
    updateFocusHighlights();
    widget.onFocusChange?.call(hasFocus);
  }

  void handleAnyTapDown(TapDownDetails details) {
    if (_anyChildInkResponsePressed) {
      return;
    }
    _startNewSplash(details: details);
  }

  void handleTapDown(TapDownDetails details) {
    handleAnyTapDown(details);
    widget.onTapDown?.call(details);
  }

  void handleTapUp(TapUpDetails details) {
    widget.onTapUp?.call(details);
  }

  void handleSecondaryTapDown(TapDownDetails details) {
    handleAnyTapDown(details);
    widget.onSecondaryTapDown?.call(details);
  }

  void handleSecondaryTapUp(TapUpDetails details) {
    widget.onSecondaryTapUp?.call(details);
  }

  void _startNewSplash({TapDownDetails? details, BuildContext? context}) {
    assert(details != null || context != null);

    final Offset globalPosition;
    if (context != null) {
      final RenderBox referenceBox = context.findRenderObject()! as RenderBox;
      assert(referenceBox.hasSize,
          'InkResponse must be done with layout before starting a splash.');
      globalPosition =
          referenceBox.localToGlobal(referenceBox.paintBounds.center);
    } else {
      globalPosition = details!.globalPosition;
    }
    statesController.update(
        WidgetState.pressed, true); // ... before creating the splash
    final InteractiveCustomInkFeature splash = _createSplash(globalPosition);
    _splashes ??= HashSet<InteractiveCustomInkFeature>();
    _splashes!.add(splash);
    _currentSplash?.cancel();
    _currentSplash = splash;
    updateKeepAlive();
    updateHighlight(_HighlightType.pressed, value: true);
  }

  void handleTap() {
    _currentSplash?.confirm();
    _currentSplash = null;
    updateHighlight(_HighlightType.pressed, value: false);
    if (widget.onTap != null) {
      if (widget.enableFeedback) {
        Feedback.forTap(context);
      }
      widget.onTap?.call();
    }
  }

  void handleTapCancel() {
    _currentSplash?.cancel();
    _currentSplash = null;
    widget.onTapCancel?.call();
    updateHighlight(_HighlightType.pressed, value: false);
  }

  void handleDoubleTap() {
    _currentSplash?.confirm();
    _currentSplash = null;
    updateHighlight(_HighlightType.pressed, value: false);
    widget.onDoubleTap?.call();
  }

  void handleLongPress() {
    _currentSplash?.confirm();
    _currentSplash = null;
    if (widget.onLongPress != null) {
      if (widget.enableFeedback) {
        Feedback.forLongPress(context);
      }
      widget.onLongPress!();
    }
  }

  void handleSecondaryTap() {
    _currentSplash?.confirm();
    _currentSplash = null;
    updateHighlight(_HighlightType.pressed, value: false);
    widget.onSecondaryTap?.call();
  }

  void handleSecondaryTapCancel() {
    _currentSplash?.cancel();
    _currentSplash = null;
    widget.onSecondaryTapCancel?.call();
    updateHighlight(_HighlightType.pressed, value: false);
  }

  @override
  void deactivate() {
    if (_splashes != null) {
      final Set<InteractiveCustomInkFeature> splashes = _splashes!;
      _splashes = null;
      for (final InteractiveCustomInkFeature splash in splashes) {
        splash.dispose();
      }
      _currentSplash = null;
    }
    assert(_currentSplash == null);
    for (final _HighlightType highlight in _highlights.keys) {
      _highlights[highlight]?.dispose();
      _highlights[highlight] = null;
    }
    widget.parentState?.markChildInkResponsePressed(this, false);
    super.deactivate();
  }

  bool isWidgetEnabled(_InkResponseStateWidget widget) {
    return _primaryButtonEnabled(widget) || _secondaryButtonEnabled(widget);
  }

  bool _primaryButtonEnabled(_InkResponseStateWidget widget) {
    return widget.onTap != null ||
        widget.onDoubleTap != null ||
        widget.onLongPress != null ||
        widget.onTapUp != null ||
        widget.onTapDown != null;
  }

  bool _secondaryButtonEnabled(_InkResponseStateWidget widget) {
    return widget.onSecondaryTap != null ||
        widget.onSecondaryTapUp != null ||
        widget.onSecondaryTapDown != null;
  }

  bool get enabled => isWidgetEnabled(widget);
  bool get _primaryEnabled => _primaryButtonEnabled(widget);
  bool get _secondaryEnabled => _secondaryButtonEnabled(widget);

  void handleMouseEnter(PointerEnterEvent event) {
    _hovering = true;
    if (enabled) {
      handleHoverChange();
    }
  }

  void handleMouseExit(PointerExitEvent event) {
    _hovering = false;
    // If the exit occurs after we've been disabled, we still
    // want to take down the highlights and run widget.onHover.
    handleHoverChange();
  }

  void handleHoverChange() {
    updateHighlight(_HighlightType.hover, value: _hovering);
  }

  bool get _canRequestFocus {
    final NavigationMode mode =
        MediaQuery.maybeNavigationModeOf(context) ?? NavigationMode.traditional;
    switch (mode) {
      case NavigationMode.traditional:
        return enabled && widget.canRequestFocus;
      case NavigationMode.directional:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.
    Color getHighlightColorForType(_HighlightType type) {
      const Set<WidgetState> pressed = <WidgetState>{WidgetState.pressed};
      const Set<WidgetState> focused = <WidgetState>{WidgetState.focused};
      const Set<WidgetState> hovered = <WidgetState>{WidgetState.hovered};

      final ThemeData theme = Theme.of(context);
      switch (type) {
        // The pressed state triggers a ripple (ink splash), per the current
        // Material Design spec. A separate highlight is no longer used.
        // See https://material.io/design/interaction/states.html#pressed
        case _HighlightType.pressed:
          return widget.overlayColor?.resolve(pressed) ??
              widget.highlightColor ??
              theme.highlightColor;
        case _HighlightType.focus:
          return widget.overlayColor?.resolve(focused) ??
              widget.focusColor ??
              theme.focusColor;
        case _HighlightType.hover:
          return widget.overlayColor?.resolve(hovered) ??
              widget.hoverColor ??
              theme.hoverColor;
      }
    }

    for (final _HighlightType type in _highlights.keys) {
      _highlights[type]?.color = getHighlightColorForType(type);
    }

    _currentSplash?.color =
        widget.overlayColor?.resolve(statesController.value) ??
            widget.splashColor ??
            Theme.of(context).splashColor;

    final MouseCursor effectiveMouseCursor =
        WidgetStateProperty.resolveAs<MouseCursor>(
      widget.mouseCursor ?? WidgetStateMouseCursor.clickable,
      statesController.value,
    );

    return _ParentInkResponseProvider(
      state: this,
      child: Actions(
        actions: _actionMap,
        child: Focus(
          focusNode: widget.focusNode,
          canRequestFocus: _canRequestFocus,
          onFocusChange: handleFocusUpdate,
          autofocus: widget.autofocus,
          child: MouseRegion(
            cursor: effectiveMouseCursor,
            onEnter: handleMouseEnter,
            onExit: handleMouseExit,
            child: DefaultSelectionStyle.merge(
              mouseCursor: effectiveMouseCursor,
              child: Semantics(
                onTap: widget.excludeFromSemantics || widget.onTap == null
                    ? null
                    : simulateTap,
                onLongPress:
                    widget.excludeFromSemantics || widget.onLongPress == null
                        ? null
                        : simulateLongPress,
                child: GestureDetector(
                  onTapDown: _primaryEnabled ? handleTapDown : null,
                  onTapUp: _primaryEnabled ? handleTapUp : null,
                  onTap: _primaryEnabled ? handleTap : null,
                  onTapCancel: _primaryEnabled ? handleTapCancel : null,
                  onDoubleTap:
                      widget.onDoubleTap != null ? handleDoubleTap : null,
                  onLongPress:
                      widget.onLongPress != null ? handleLongPress : null,
                  onSecondaryTapDown:
                      _secondaryEnabled ? handleSecondaryTapDown : null,
                  onSecondaryTapUp:
                      _secondaryEnabled ? handleSecondaryTapUp : null,
                  onSecondaryTap: _secondaryEnabled ? handleSecondaryTap : null,
                  onSecondaryTapCancel:
                      _secondaryEnabled ? handleSecondaryTapCancel : null,
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInkWell extends CustomInkResponse {
  const CustomInkWell({
    super.key,
    super.child,
    super.onTap,
    super.onDoubleTap,
    super.onLongPress,
    super.onTapDown,
    super.onTapUp,
    super.onTapCancel,
    super.onSecondaryTap,
    super.onSecondaryTapUp,
    super.onSecondaryTapDown,
    super.onSecondaryTapCancel,
    super.onHighlightChanged,
    super.onHover,
    super.mouseCursor,
    super.focusColor,
    super.hoverColor,
    super.highlightColor,
    super.overlayColor,
    super.splashColor,
    super.splashFactory,
    super.radius,
    super.borderRadius,
    super.customBorder,
    bool? enableFeedback = true,
    super.excludeFromSemantics,
    super.focusNode,
    super.canRequestFocus,
    super.onFocusChange,
    super.autofocus,
    super.statesController,
    super.hoverDuration,
  }) : super(
          containedInkWell: true,
          highlightShape: BoxShape.rectangle,
          enableFeedback: enableFeedback ?? true,
        );
}


const Duration _kUnconfirmedRippleDuration = Duration(seconds: 1);
const Duration _kFadeInDuration = Duration(milliseconds: 75);
const Duration _kRadiusDuration = Duration(milliseconds: 225);
const Duration _kFadeOutDuration = Duration(milliseconds: 375);
const Duration _kCancelDuration = Duration(milliseconds: 75);

// The fade out begins 225ms after the _fadeOutController starts. See confirm().
const double _kFadeOutIntervalStart = 225.0 / 375.0;

RectCallback? _getClipCallback(RenderBox referenceBox, bool containedInkWell, RectCallback? rectCallback) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell) {
    return () => Offset.zero & referenceBox.size;
  }
  return null;
}

double _getTargetRadius(RenderBox referenceBox, bool containedInkWell, RectCallback? rectCallback, Offset position) {
  final Size size = rectCallback != null ? rectCallback().size : referenceBox.size;
  final double d1 = size.bottomRight(Offset.zero).distance;
  final double d2 = (size.topRight(Offset.zero) - size.bottomLeft(Offset.zero)).distance;
  return math.max(d1, d2) / 2.0;
}

class _CustomInkRippleFactory extends InteractiveCustomInkFeatureFactory {
  const _CustomInkRippleFactory();

  @override
  InteractiveCustomInkFeature create({
    required MaterialCustomInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return CustomInkRipple(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
      textDirection: textDirection,
    );
  }
}

/// A visual reaction on a piece of [Material] to user input.
///
/// A circular ink feature whose origin starts at the input touch point and
/// whose radius expands from 60% of the final radius. The splash origin
/// animates to the center of its [referenceBox].
///
/// This object is rarely created directly. Instead of creating an ink ripple,
/// consider using an [CustomInkResponse] or [CustomInkWell] widget, which uses
/// gestures (such as tap and long-press) to trigger ink splashes. This class
/// is used when the [Theme]'s [ThemeData.splashFactory] is [CustomInkRipple.splashFactory].
///
/// See also:
///
///  * [InkSplash], which is an ink splash feature that expands less
///    aggressively than the ripple.
///  * [CustomInkResponse], which uses gestures to trigger ink highlights and ink
///    splashes in the parent [Material].
///  * [CustomInkWell], which is a rectangular [CustomInkResponse] (the most common type of
///    ink response).
///  * [Material], which is the widget on which the ink splash is painted.
///  * [InkHighlight], which is an ink feature that emphasizes a part of a
///    [Material].
class CustomInkRipple extends InteractiveCustomInkFeature {
  /// Begin a ripple, centered at [position] relative to [referenceBox].
  ///
  /// The [controller] argument is typically obtained via
  /// `Material.of(context)`.
  ///
  /// If [containedInkWell] is true, then the ripple will be sized to fit
  /// the well rectangle, then clipped to it when drawn. The well
  /// rectangle is the box returned by [rectCallback], if provided, or
  /// otherwise is the bounds of the [referenceBox].
  ///
  /// If [containedInkWell] is false, then [rectCallback] should be null.
  /// The ink ripple is clipped only to the edges of the [Material].
  /// This is the default.
  ///
  /// When the ripple is removed, [onRemoved] will be called.
  CustomInkRipple({
    required MaterialCustomInkController controller,
    required super.referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    super.customBorder,
    double? radius,
    super.onRemoved,
  }) : _position = position,
       _borderRadius = borderRadius ?? BorderRadius.zero,
       _textDirection = textDirection,
       _targetRadius = radius ?? _getTargetRadius(referenceBox, containedInkWell, rectCallback, position),
       _clipCallback = _getClipCallback(referenceBox, containedInkWell, rectCallback),
       super(controller: controller, color: color) {

    // Immediately begin fading-in the initial splash.
    _fadeInController = AnimationController(duration: _kFadeInDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _fadeIn = _fadeInController.drive(IntTween(
      begin: 0,
      end: color.alpha,
    ));

    // Controls the splash radius and its center. Starts upon confirm.
    _radiusController = AnimationController(duration: _kUnconfirmedRippleDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
     // Initial splash diameter is 60% of the target diameter, final
     // diameter is 10dps larger than the target diameter.
    _radius = _radiusController.drive(
      Tween<double>(
        begin: _targetRadius * 0.30,
        end: _targetRadius + 5.0,
      ).chain(_easeCurveTween),
    );

    // Controls the splash radius and its center. Starts upon confirm however its
    // Interval delays changes until the radius expansion has completed.
    _fadeOutController = AnimationController(duration: _kFadeOutDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged);
    _fadeOut = _fadeOutController.drive(
      IntTween(
        begin: color.alpha,
        end: 0,
      ).chain(_fadeOutIntervalTween),
    );

    controller.addInkFeature(this);
  }

  final Offset _position;
  final BorderRadius _borderRadius;
  final double _targetRadius;
  final RectCallback? _clipCallback;
  final TextDirection _textDirection;

  late Animation<double> _radius;
  late AnimationController _radiusController;

  late Animation<int> _fadeIn;
  late AnimationController _fadeInController;

  late Animation<int> _fadeOut;
  late AnimationController _fadeOutController;

  /// Used to specify this type of ink splash for an [CustomInkWell], [CustomInkResponse],
  /// material [Theme], or [ButtonStyle].
  static const InteractiveCustomInkFeatureFactory splashFactory = _CustomInkRippleFactory();

  static final Animatable<double> _easeCurveTween = CurveTween(curve: Curves.ease);
  static final Animatable<double> _fadeOutIntervalTween = CurveTween(curve: const Interval(_kFadeOutIntervalStart, 1.0));

  @override
  void confirm() {
    _radiusController
      ..duration = _kRadiusDuration
      ..forward();
    // This confirm may have been preceded by a cancel.
    _fadeInController.forward();
    _fadeOutController.animateTo(1.0, duration: _kFadeOutDuration);
  }

  @override
  void cancel() {
    _fadeInController.stop();
    // Watch out: setting _fadeOutController's value to 1.0 will
    // trigger a call to _handleAlphaStatusChanged() which will
    // dispose _fadeOutController.
    final double fadeOutValue = 1.0 - _fadeInController.value;
    _fadeOutController.value = fadeOutValue;
    if (fadeOutValue < 1.0) {
      _fadeOutController.animateTo(1.0, duration: _kCancelDuration);
    }
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      dispose();
    }
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final int alpha = _fadeInController.isAnimating ? _fadeIn.value : _fadeOut.value;
    final Paint paint = Paint()..color = color.withAlpha(alpha);
    Rect? rect;
    if (_clipCallback != null) {
       rect = _clipCallback();
    }
    // Splash moves to the center of the reference box.
    final Offset center = Offset.lerp(
      _position,
      rect != null ? rect.center : referenceBox.size.center(Offset.zero),
      Curves.ease.transform(_radiusController.value),
    )!;
    paintInkCircle(
      canvas: canvas,
      transform: transform,
      paint: paint,
      center: center,
      textDirection: _textDirection,
      radius: _radius.value,
      customBorder: customBorder,
      borderRadius: _borderRadius,
      clipCallback: _clipCallback,
    );
  }
}
