// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/cupertino/colors.dart';
import 'package:flutter/src/cupertino/scrollbar.dart';
import 'package:flutter/src/cupertino/theme.dart';
import 'package:flutter/widgets.dart';

import 'cupertino_menu_anchor.dart';
import 'menu_item.dart';
// import 'button.dart';
// import 'colors.dart';
// import 'icons.dart';
// import 'localizations.dart';
// import 'menu_item.dart';
// import 'scrollbar.dart';
// import 'theme.dart';

// TODO(davidhicks980): Shuffle the classes to make the file more readable.

/// Signature used by [CupertinoMenuButton] to lazily construct menu items shown
/// when a [CupertinoMenu] is constructed
///
/// Used by [CupertinoMenuButton.itemBuilder].
typedef CupertinoMenuItemBuilder =
          List<Widget> Function(BuildContext context);

final Animatable<double> _clampedAnimatable =
          Animatable<double>.fromCallback(
            (double value) => ui.clampDouble(value, 0.0, 1.0),
          );




/// An inherited widget that communicates the size and position of this menu
/// layer to its children.
///
/// The [constraintsTween] parameter animates between the size of the menu
/// anchor, and the intrinsic size of this layer (or the constraints provided by
/// the user, if the constraints are smaller than the intrinsic size of the
/// layer).
///
/// The [isInteractive] parameter determines whether items on this layer should
/// respond to user input.
///
/// {@macro flutter.cupertino.MenuModel.interactiveLayers}
///
/// The [hasLeadingWidget] parameter is used to determine whether menu items
/// without a leading widget should be given leading padding to align with their
/// siblings.
///
/// The [childCount] parameter describes the number of children on this menu
/// layer, which is used to determine the initial border radius of this layer
/// prior to animating open.
///
/// The [coordinates] parameter describes [CupertinoMenuCoordinates] of this
/// layer.
///
/// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
class CupertinoMenuLayerModel extends InheritedWidget {
  /// Creates a [CupertinoMenuLayerModel] that communicates the size
  /// and position of this menu layer to its children.
  const CupertinoMenuLayerModel({
    super.key,
    required super.child,
    required this.constraintsTween,
    required this.hasLeadingWidget,
  });

  /// The constraints that describe the expansion of this menu layer.
  ///
  /// The [constraintsTween] animates between the size of the menu item
  /// anchoring this layer, and the intrinsic size of this layer (or the
  /// constraints provided by the user, if the constraints are smaller than the
  /// intrinsic size of the layer).
  final BoxConstraintsTween constraintsTween;

  /// Whether any menu items in this layer have a leading widget.
  ///
  /// If true, all menu items without a leading widget will be given
  /// leading padding to align with their siblings.
  final bool hasLeadingWidget;

  @override
  bool updateShouldNotify(CupertinoMenuLayerModel oldWidget) {
    return constraintsTween.begin != oldWidget.constraintsTween.begin
        || constraintsTween.end   != oldWidget.constraintsTween.end
        ||
        hasLeadingWidget != oldWidget.hasLeadingWidget;
  }
}

/// A root menu layer that displays a list of [Widget] widgets
/// provided by the [children] parameter.
///
/// The [CupertinoMenu] is a [StatefulWidget] that manages the opening and
/// closing of nested [CupertinoMenu] layers.
///
/// The [CupertinoMenu] is typically created by a [CupertinoMenuButton], or by
/// calling [showCupertinoMenu].
///
/// An [animation] must be provided to drive the opening and closing of the
/// menu.
///
/// The [anchorPosition] parameter describes the position of the menu's anchor
/// relative to the screen. An [offset] can be provided to displace the menu
/// relative to its anchor. The [alignment] parameter can be used to specify
/// where the menu should grow from relative to its anchor. The [anchorSize]
/// parameter describes the size of the anchor widget.
///
/// The [hasLeadingWidget] parameter is used to determine whether menu items
/// without a leading widget should be given leading padding to align with their
/// siblings.
///
/// The optional [physics] can be provided to apply scroll physics the root menu
/// layer. Physics will only be applied if the menu contents overflow the menu.
///
/// To constrain the final size of the menu, [BoxConstraints] can be passed to
/// the [constraints] parameter.
class CupertinoMenu extends StatefulWidget {
  /// Creates a [CupertinoMenu] that displays a list of [Widget]s
  const CupertinoMenu({
    super.key,
    required this.children,
    required this.animation,
    required this.anchorPosition,
    required this.hasLeadingWidget,
    required this.alignment,
    required this.anchorSize,
    required this.brightness,
    required this.controller,
    this.clip = Clip.antiAlias,
    this.offset = Offset.zero,
    this.physics,
    this.constraints,
    EdgeInsets? edgeInsets,
  }) : _edgeInsets = edgeInsets ?? const EdgeInsets.all(defaultEdgeInsets);

  /// The menu items to display.
  final List<Widget> children;

  /// The insets of the menu anchor relative to the screen.
  final RelativeRect anchorPosition;

  /// The amount of displacement to apply to the menu relative to the anchor.
  final Offset offset;

  /// The alignment of the menu relative to the screen.
  final Alignment alignment;

  /// The size of the anchor widget.
  final Size anchorSize;

  /// Whether any menu items on this menu layer have a leading widget.
  final bool hasLeadingWidget;

  /// The animation that drives the opening and closing of the menu.
  final Animation<double> animation;

  /// The constraints to apply to the root menu layer.
  final BoxConstraints? constraints;

  /// The physics to apply to the root menu layer if the menu contents overflow
  /// the menu.
  ///
  /// If null, the physics will be determined by the nearest [ScrollConfiguration].
  final ScrollPhysics? physics;

  /// The [Clip] to apply to the menu's surface.
  final Clip clip;

  final CupertinoMenuController controller;

  /// The insets to avoid when positioning the menu.
  final EdgeInsets _edgeInsets;

  /// The [ui.Brightness] of the menu.
  final ui.Brightness? brightness;

  /// The [Radius] of the menu surface [ClipPath].
  static const Radius radius = Radius.circular(14);

  /// The amount of padding between the menu and the screen edge.
  static const double defaultEdgeInsets = 8;

  /// The SpringDescription used for the opening animation of a nested menu layer.
  static const SpringDescription forwardNestedSpring = SpringDescription(
    mass: 1,
    stiffness: (2 * (math.pi / 0.35)) * (2 * (math.pi / 0.35)),
    damping: (4 * math.pi * 0.81) / 0.35,
  );

  /// The SpringDescription used for the closing animation of a nested menu layer.
  static const SpringDescription reverseNestedSpring = SpringDescription(
    mass: 1,
    stiffness: (2 * (math.pi / 0.25)) * (2 * (math.pi / 0.25)),
    damping: (4 * math.pi * 1.8) / 0.25,
  );

  /// The SpringDescription used for when a pointer is dragged outside of the
  /// menu area.
  static const SpringDescription panReboundSpring = SpringDescription(
    mass: 1,
    stiffness: (2 * (math.pi / 0.35)) * (2 * math.pi / 0.35),
    damping: (4 * math.pi * 0.81) / 0.35,
  );

  static EdgeInsets edgeInsetsOf(BuildContext context) {
    return context.findAncestorStateOfType<_CupertinoMenuState>()!.edgeInsets;
  }

  /// The default transparent [CupertinoMenu] background color.
  //
  // Background colors are based on the following:
  //
  // Dark mode on white background => rgb(83, 83, 83)
  // Dark mode on black => rgb(31, 31, 31)
  // Light mode on black background => rgb(197,197,197)
  // Light mode on white => rgb(246, 246, 246)
  static const CupertinoDynamicColor background =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(250, 251, 250, 0.78),
    darkColor: Color.fromRGBO(34, 34, 34, 0.75),
  );

  /// The default opaque [CupertinoMenu] background color.
  static const CupertinoDynamicColor opaqueBackground =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(246, 246, 246, 1),
    darkColor: Color.fromRGBO(31, 31, 31, 1),
  );


  @override
  State<CupertinoMenu> createState() => _CupertinoMenuState();
}

class _CupertinoMenuState extends State<CupertinoMenu>
      with SingleTickerProviderStateMixin {
  late final AnimationController _panAnimation;
  final FocusNode _focusNode = FocusNode(debugLabel: 'CupertinoMenu-FocusNode');
  final ValueNotifier<Offset?> _panPosition = ValueNotifier<Offset?>(null);
  // Used for pan animation to determine whether user has dragged
  // outside of the menu area
  final ValueNotifier<Rect?> _rootMenuRectNotifier = ValueNotifier<Rect?>(null);
  EdgeInsets get edgeInsets => widget._edgeInsets;

  @override
  void initState() {
    super.initState();
    _panAnimation = AnimationController(
      vsync: this,
      value: 0.0,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _panAnimation.dispose();
    _panPosition.dispose();
    _rootMenuRectNotifier.dispose();
    super.dispose();
  }

  void _handlePanEnd(Offset offset) {
    void updateAnimation() {
      if (mounted) {
        _panPosition.value = Offset.lerp(
          offset,
          _rootMenuRectNotifier.value!.center,
          _panAnimation.value,
        );
      }
    }

    _panAnimation
      ..addListener(updateAnimation)
      ..animateWith(SpringSimulation(CupertinoMenu.panReboundSpring, 0, 1, 10))
        .whenCompleteOrCancel(() {
          if (mounted) {
            _panAnimation.removeListener(updateAnimation);
            _panPosition.value = null;
          }
        });
  }

  void _handlePanUpdate(Offset position, bool onTarget) {
    if (_panAnimation.isAnimating) {
      _panAnimation.stop();
    }

    if (!onTarget) {
      _panPosition.value = position;
    }
  }

  // Clunky method that stores the last known position of the root menu layer.
  // This is used to determine the boundaries of the root menu so it can be
  // scaled when a user drags outside of the menu area.
  void Function(ui.Offset offset) _handleRootLayerPositioned(BuildContext context) {
    final ui.Size? size =
        CupertinoMenuLayer.of(context).constraintsTween.end?.smallest;
    return (Offset offset) {
      final ui.Rect rect = _rootMenuRectNotifier.value ?? Rect.zero;
      if (
        rect.topLeft != offset ||
        rect.size    != size
      ) {
        _rootMenuRectNotifier.value = offset & size!;
      }
    };
  }


  RelativeRect _insetAnchorPosition(
    BuildContext context,
    RelativeRect position
  ) {
    final ui.Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets padding = widget._edgeInsets;
    final ui.Size rootAnchorSize = widget.anchorSize;
    return RelativeRect.fromLTRB(
      ui.clampDouble(
        position.left,
        padding.left,
        math.max(
          padding.left,
          screenSize.width - (padding.right + rootAnchorSize.width),
        ),
      ),
      ui.clampDouble(
        position.top,
        padding.top,
        math.max(
          padding.top,
          screenSize.height - (padding.bottom + rootAnchorSize.height),
        ),
      ),
      ui.clampDouble(
        position.right,
        padding.right,
        math.max(
          padding.right,
          screenSize.width - (padding.left + rootAnchorSize.width),
        ),
      ),
      ui.clampDouble(
        position.bottom,
        padding.bottom,
        math.max(
          padding.bottom,
          screenSize.height - (padding.top + rootAnchorSize.height),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget menu = TapRegion(
      groupId: widget.controller,
      onTapOutside: (PointerDownEvent event) {
        if (widget.controller.isOpen) {
          widget.controller.close();
        }
      },
      child: _MenuContainer(
        depth: 0,
        animation: widget.animation,
        child: _MenuBody(
          physics: widget.physics,
          children: widget.children,
        ),
      ),
    );

    final Widget layer =  Builder(
        builder: (BuildContext context) {
          final MediaQueryData mediaQuery = MediaQuery.of(context);
          return CustomSingleChildLayout(
              delegate: _RootMenuLayout(
                onPositioned: _handleRootLayerPositioned(context),
                growthDirection: VerticalDirection.down,
                unboundedOffset: widget.offset,
                anchorPosition: _insetAnchorPosition(
                  context,
                  widget.anchorPosition,
                ),
                textDirection: Directionality.of(context),
                edgeInsets: widget._edgeInsets,
                avoidBounds:
                    DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet(),
              ),
              child: ConstrainedBox(
                constraints: widget.constraints ??
                    const BoxConstraints.tightFor(width: 250),
                child: menu,
            ),
          );
        },
    );

    final CupertinoThemeData theme = CupertinoTheme.of(context);
    return CupertinoTheme(
        data: theme.copyWith(
            brightness: widget.brightness ??
                theme.brightness ??
                CupertinoTheme.maybeBrightnessOf(context) ??
                ui.Brightness.light),
        child: CupertinoMenuLayer(
          anchorSize: Size.zero,
          hasLeadingWidget: widget.hasLeadingWidget,
          constraints: widget.constraints,
          child: CupertinoPanListener<PanTarget<StatefulWidget>>(
            // onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: ScaleTransition(
              alignment: widget.alignment,
              scale: widget.animation,
              child: layer
              ),
            ),
        )
    );
  }
}



// Controls the position and scale of menu layers
// class _CupertinoMenuFlowDelegate extends FlowDelegate {
//   const _CupertinoMenuFlowDelegate( {
//     super.repaint,
//     required this.rootAnchorPosition,
//     required this.rootMenuRectNotifier,
//     required this.routeAnimation,
//     required this.nestingAnimation,
//     required this.alignment,
//     required this.pointerPositionNotifier,
//     required this.layers,
//     required this.rootAnchorSize,
//     this.overrideTransforms,
//     this.onPainted,
//     this.growthDirection = VerticalDirection.down,
//     this.padding = EdgeInsets.zero,
//   });

//   final VerticalDirection growthDirection;
//   final RelativeRect rootAnchorPosition;
//   final Size rootAnchorSize;
//   final Animation<double> nestingAnimation;
//   final Animation<double> routeAnimation;
//   final Alignment alignment;
//   final ValueChanged<List<Matrix4>>? onPainted;
//   final List<Matrix4>? overrideTransforms;
//   final List<_CupertinoMenuLayerDescription> layers;
//   final ValueNotifier<Rect?> rootMenuRectNotifier;
//   final ValueNotifier<Offset?> pointerPositionNotifier;
//   final EdgeInsets padding;

//   static const double defaultShift = 16;

//   Offset? get pointerPosition => pointerPositionNotifier.value;
//   Rect get rootMenuRect => rootMenuRectNotifier.value ?? Rect.zero;

//   @override
//   void paintChildren(FlowPaintingContext context) {
//     final List<Matrix4> transforms =
//           overrideTransforms
//             ?? List<Matrix4>.generate(
//                 context.childCount,
//                 (int int) => Matrix4.identity(),
//                 growable: false,
//               );

//     if (overrideTransforms == null) {
//       _applyTransforms(context, transforms);
//     }

//     for (int i = 0; i < context.childCount; ++i) {
//       context.paintChild(i, transform: transforms[i]);
//     }

//     onPainted?.call(transforms);
//   }

//   _CupertinoMenuVerticalOffset _positionChild({
//     required Size size,
//     required Rect anchorRect,
//     required RelativeRect shiftedRootMenuAnchor,
//     required int index,
//   }) {
//     final double finalLayerHeight = layers[index].height;
//     // The fraction of the menu layer that is visible.
//     // The top layer is allowed to be more than 100% visible to allow for
//     // overshoot.
//     double visibleFraction = 1.0;
//     if(layers.length - 1 == index){
//       visibleFraction = ui.clampDouble(nestingAnimation.value - index + 1, 0, 1.1);
//     }

//     // The offset of the menu layer from the top of the screen
//     double layerYOffset = anchorRect.top;

//     // The offset of the entire menu from the top of the screen
//     double menuOffsetY = 0.0;

//     if (growthDirection == VerticalDirection.up) {
//       double rootAnchorTop = shiftedRootMenuAnchor.top;
//       // A vertical shift is applied to each menu layer to create a cascading
//       // effect. This shift is only noticeable when the menu layer would extend
//       // beyond the top of the shifted root anchor position.
//       rootAnchorTop -= defaultShift * (index - 1 + visibleFraction);
//       // The menu layer, when fully extended, will overflow the larger of:
//       //
//       // 1. The area above the root anchor position.
//       // 2. The largest underlying menu.
//       //
//       // The menu layer will be shifted upwards by the amount it overflows.
//       if (rootAnchorTop + padding.top < finalLayerHeight + layerYOffset) {
//         layerYOffset = ui.lerpDouble(
//           layerYOffset,
//           rootAnchorTop + padding.top - finalLayerHeight,
//           visibleFraction,
//         )!;
//       }

//       // Shift the menu down by the amount the menu overflows the top of the
//       // root menu anchor.
//       if (rootAnchorTop < finalLayerHeight) {
//         menuOffsetY = ui.lerpDouble(
//           0,
//           finalLayerHeight - rootAnchorTop,
//           visibleFraction,
//         )!;
//       }
//     } else {
//       final double rootAnchorBottom = shiftedRootMenuAnchor.bottom;
//       // If the height of the menu layer is greater than the area underneath the
//       // root anchor position minus bottom padding, shift the menu upwards by
//       // the amount the menu overflows.
//       if (size.height - padding.bottom < layerYOffset + finalLayerHeight) {
//         if (finalLayerHeight > rootAnchorBottom - padding.bottom) {
//           menuOffsetY = ui.lerpDouble(
//             0,
//             rootAnchorBottom - (finalLayerHeight + padding.bottom),
//             visibleFraction,
//           )!;
//         } else {
//           // If the layer overflows the bottom of the screen minus bottom padding,
//           // shift the layer upwards by the amount it overflows.
//           layerYOffset = ui.lerpDouble(
//             layerYOffset,
//             size.height - padding.bottom - finalLayerHeight,
//             visibleFraction,
//           )!;
//         }
//       }
//     }

//     return (
//       layerOffset: layerYOffset,
//       menuOffset: menuOffsetY,
//     );
//   }

//   void _applyTransforms(
//     FlowPaintingContext context,
//     List<Matrix4> transforms,
//   ) {
//     final List<Offset> offsets = List<Offset>.generate(
//       context.childCount,
//       (int index) => Offset.zero,
//       growable: false,
//     );

//     // The menuYOffset is the amount the menu extends past the top or bottom of
//     // the root menu anchor position, depending on the growth direction.
//     double menuYOffset = growthDirection == VerticalDirection.up
//       ? math.max((rootMenuRect.height + padding.top) - rootAnchorPosition.top, 0)
//       : math.min(rootAnchorPosition.bottom - (rootMenuRect.height + padding.bottom), 0);

//     // The shiftedRootMenuAnchor is the anchor position of the root menu layer
//     // after it has been shifted by the menuYOffset.
//     RelativeRect shiftedRootMenuAnchor = rootAnchorPosition.shift(
//         Offset(0, menuYOffset),
//       );
//     double previousLayerOffsetY = rootMenuRect.top;
//     Rect totalMenuRect = rootMenuRect;
//     // Two passes: First pass aggregates the offsets of each layer. Second pass
//     // applies the offsets and scales the menu.
//     /*  1st pass  */
//     for (int depth = 1; depth < context.childCount; ++depth) {
//         final Size size = context.getChildSize(depth) ?? Size.zero;
//         Rect anchorRect = Rect.zero;
//         if (layers.length > depth) {
//           final double anchorOffset = layers[depth].anchorOffset;
//           anchorRect = Rect.fromLTWH(
//             rootMenuRect.left,
//             anchorOffset + previousLayerOffsetY,
//             size.width,
//             size.height,
//           );
//         }
//         final _CupertinoMenuVerticalOffset position = _positionChild(
//           size: context.size,
//           index: depth,
//           anchorRect: anchorRect,
//           shiftedRootMenuAnchor: shiftedRootMenuAnchor,
//         );
//         offsets[depth] = Offset(rootMenuRect.left, position.layerOffset);
//         menuYOffset = position.menuOffset;
//         for (int i = 0; i <= depth; i++) {
//           final double height = i == 0
//                                 ? rootMenuRect.height
//                                 : context.getChildSize(i)!.height;
//           double min = padding.top;
//           double max = context.size.height - height - padding.bottom;
//           if (i == 0) {
//             min -= rootMenuRect.top;
//             max -= rootMenuRect.top;
//           }

//           max = math.max(max, min);
//           offsets[i] = Offset(
//             offsets[i].dx,
//             ui.clampDouble(
//               offsets[i].dy + menuYOffset,
//               min,
//               max,
//             ),
//           );
//         }

//       previousLayerOffsetY = offsets[depth].dy;
//       shiftedRootMenuAnchor = shiftedRootMenuAnchor.shift(Offset(0, menuYOffset));
//     }

//     // Calculate the total area the menu takes up, so panning can be scaled
//     // based on the distance from the menu edge.
//     //
//     // A (presumably) more efficient way to calculate totalMenuRect that hurts
//     // readability:
//     //
//     // var Rect(:double left, :double right, :double top, :double bottom) = rootMenuRect;
//     // for (int i = 1; i < offsets.length; i++) {
//     //   final ui.Size size = context.getChildSize(i)!;
//     //   left   = math.min(left  , offsets[i].dx);
//     //   top    = math.min(top   , offsets[i].dy);
//     //   right  = math.max(right , offsets[i].dx + size.width);
//     //   bottom = math.max(bottom, offsets[i].dy + size.height);
//     // }
//     for (int i = 1; i < offsets.length; i++) {
//      totalMenuRect = totalMenuRect.expandToInclude(
//        offsets[i] & context.getChildSize(i)!,
//      );
//     }

//     double menuScale = 1.0;
//     if (pointerPosition != null) {
//       // Get squared distance to rect
//       final double minDistanceToEdge = _calculateSquaredDistanceToMenuEdge(
//         rect: totalMenuRect,
//         position: pointerPosition!,
//       );
//       // Scales based on distance from menu edge. The divisor has an
//       // inverse relationship with the amount of scaling that occurs for each
//       // unit of distance.
//       menuScale = math.max(
//         1.0 - minDistanceToEdge / 50000,
//         0.8,
//       );
//     }

//     final Offset menuOrigin = alignment.alongSize(
//       padding.deflateSize(
//         context.getChildSize(0)!,
//       ),
//     );

//     /*****  2nd pass  *****/
//     for (int i = 0; i < context.childCount; ++i) {
//       // Scale the menu based on the pointer position
//       transforms[i]
//         ..translate(menuOrigin.dx, menuOrigin.dy)
//         ..scale(menuScale, menuScale, menuScale)
//         ..translate(-menuOrigin.dx, -menuOrigin.dy);
//       if (context.childCount > 1) {
//         final double atOrAbove = nestingAnimation.value - i + 1;
//         // Scale the layer based on depth. The top layer is 1.0, and each
//         // subsequent layer is scaled down.
//         final double layerScale = math.min(
//           0.825 + 0.175 / math.sqrt(
//                           math.max(atOrAbove, 1),
//                         ),
//           1,
//         );
//         // Apply layer and menu offsets
//         transforms[i]
//           ..translate(menuOrigin.dx, menuOrigin.dy)
//           ..scale(layerScale, layerScale, layerScale)
//           ..translate(offsets[i].dx, offsets[i].dy)
//           ..translate(-menuOrigin.dx, -menuOrigin.dy);

//       }
//     }
//   }

//   double _calculateSquaredDistanceToMenuEdge({
//     required Rect rect,
//     required Offset position,
//   }) {
//     // Compute squared distance
//     final double dx = math.max(
//       (position.dx - rect.center.dx).abs() - rect.width / 2,
//       0.0,
//     );

//     final double dy = math.max(
//       (position.dy - rect.center.dy).abs() - rect.height / 2,
//       0.0,
//     );

//     return dx * dx + dy * dy;
//   }

//   @override
//   bool shouldRelayout(_CupertinoMenuFlowDelegate oldDelegate) {
//     return oldDelegate.padding != padding;
//   }

//   @override
//   bool shouldRepaint(_CupertinoMenuFlowDelegate oldDelegate) {
//     if (identical(this, oldDelegate)) {
//       return false;
//     }

//     return oldDelegate.padding != padding
//         || oldDelegate.alignment != alignment
//         || oldDelegate.onPainted != onPainted
//         || oldDelegate.growthDirection != growthDirection
//         || oldDelegate.nestingAnimation != nestingAnimation
//         || oldDelegate.routeAnimation != routeAnimation
//         || oldDelegate.rootAnchorSize != rootAnchorSize
//         || oldDelegate.rootAnchorPosition != rootAnchorPosition
//         || oldDelegate.rootMenuRectNotifier != rootMenuRectNotifier
//         || oldDelegate.pointerPositionNotifier != pointerPositionNotifier
//         || !listEquals(oldDelegate.layers, layers)
//         || !listEquals(oldDelegate.overrideTransforms, overrideTransforms);
//   }
// }


/// A widget that shares information about a menu layer with its descendants.
///
/// The [constraintsTween] animates between the size of the menu anchor, and the
/// intrinsic size of this layer (or the constraints provided by the user, if
/// the constraints are smaller than the intrinsic size of the layer).
///
/// The [isInteractive] parameter determines whether items on this layer should
/// respond to user input.
///
/// The [hasLeadingWidget] parameter describes whether any menu items on this layer have
/// a leading widget.
///
/// The [childCount] describes the number of children on this layer, which is
/// used to determine the initial border radius of this layer while animating
/// open.
///
/// The [coordinates] identify the position of this layer relative to the root
/// menu.
///
/// The [anchorSize] is used to determine the starting size of the menu layer.
///
/// The [menuController] can be used to control this menu layer.
///
/// See also:
///
/// * [_CupertinoMenuModel], which provides information about all menu layers
class CupertinoMenuLayer extends StatefulWidget {
  /// Creates a widget that shares information about a menu layer with its descendants.
  const CupertinoMenuLayer({
    super.key,
    required this.child,
    required this.hasLeadingWidget,
    required this.constraints,
    required this.anchorSize,
  });

  /// The menu layer.
  final Widget child;

  /// Whether any menu items on this layer has a leading widget.
  final bool hasLeadingWidget;

  /// The constraints for this menu layer.
  final BoxConstraints? constraints;

  /// The size of the anchor that this menu layer is attached to.
  final Size anchorSize;


  /// Returns the nearest anecestor [CupertinoMenuLayerModel] from the provided
  /// [BuildContext], or null if none exists.
  static CupertinoMenuLayerModel? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CupertinoMenuLayerModel>();
  }

  /// Returns the nearest anecestor [CupertinoMenuLayerModel] from the provided
  /// [BuildContext].
  static CupertinoMenuLayerModel of(BuildContext context) {
    final CupertinoMenuLayerModel? result = maybeOf(context);
    assert(result != null, 'No CupertinoMenuLayerModel found in context');
    return result!;
  }

  @override
  State<CupertinoMenuLayer> createState() =>
      _CupertinoMenuLayerState();
}

class _CupertinoMenuLayerState extends State<CupertinoMenuLayer> {
  double? _height;
  double? _width;
  BoxConstraintsTween _constraintsTween = BoxConstraintsTween();
  ui.Size deflatedScreenSize = Size.zero;
  BoxConstraintsTween _buildConstraintsTween() {
    final Size(:double height, :double width) = deflatedScreenSize;
    final double menuWidth = ui.clampDouble(_width ?? 0, 0, width);
    return BoxConstraintsTween(
      begin: BoxConstraints.tightFor(
        width: menuWidth,
        height: math.min<double>(height, widget.anchorSize.height),
      ),
      end: BoxConstraints.tightFor(
        width: menuWidth,
        height: math.min<double>(height, _height ?? widget.anchorSize.height),
      ),
    );
  }

  void _setLayerHeight(double value) {
    final double height = widget.constraints?.constrainHeight(value) ?? value;
    if (_height != height && height != 0) {
      setState(() {
        _height = height;
        _constraintsTween = _buildConstraintsTween();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ui.Size size = MediaQuery.sizeOf(context);
    final EdgeInsets screenPadding = CupertinoMenu.edgeInsetsOf(context);
    deflatedScreenSize = Size(
      math.max<double>(size.width - screenPadding.horizontal, 0),
      math.max<double>(size.height - screenPadding.vertical, 0),
    );
    _width = MediaQuery.textScalerOf(context).scale(1) > 1.25 ? 350.0 : 250.0;
    _constraintsTween = _buildConstraintsTween();

  }

  @override
  void didUpdateWidget(covariant CupertinoMenuLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.anchorSize != widget.anchorSize) {
      _constraintsTween = _buildConstraintsTween();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoMenuLayerModel(
      constraintsTween: _constraintsTween,
      hasLeadingWidget: widget.hasLeadingWidget,
      child: widget.child,
    );
  }
}

// A layout delegate that positions the root menu relative to its anchor.
class _RootMenuLayout extends SingleChildLayoutDelegate {
  const _RootMenuLayout({
    required this.anchorPosition,
    required this.edgeInsets,
    required this.avoidBounds,
    required this.growthDirection,
    required this.textDirection,
    this.unboundedOffset = Offset.zero,
    this.boundedOffset = Offset.zero,
    this.onPositioned,
  });

  // Whether the menu should begin growing above or below the menu anchor.
  final VerticalDirection growthDirection;

  // The text direction of the menu.
  final TextDirection textDirection;

  // The position of underlying anchor that the menu is attached to.
  final RelativeRect anchorPosition;

  // The amount of unbounded displacement to apply to the menu's position.
  //
  // This offset is applied after the menu is fit inside the screen, and will
  // not be limited by the bounds of the screen.
  final Offset unboundedOffset;

  // The amount of bounded displacement to apply to the menu's position.
  //
  // This offset is applied before the menu is fit inside the screen, and will
  // be limited by the bounds of the screen.
  //
  // TODO(davidhicks980): Should we offer both unbounded and bounded offsets?
  // Unbounded offsets are not affected by the bounds of the screen.
  final Offset boundedOffset;

  // Padding obtained from calling [MediaQuery.paddingOf(context)].
  //
  // Used to prevent the menu from being obstructed by system UI.
  final EdgeInsets edgeInsets;

  // List of rectangles that the menu should not overlap. Unusable screen area.
  final Set<Rect> avoidBounds;

  // A callback that is called when the menu is positioned.
  final ValueSetter<Offset>? onPositioned;

 // Finds the closest screen to the anchor position.
  //
  // The closest screen is defined as the screen whose center is closest to the
  // anchor position.
  //
  // This method is only called on the root menu, since all overlapping layers
  // will be positioned on the same screen as the root menu.
  Rect _findClosestScreen(Size size, Offset point, Set<Rect> avoidBounds) {
    final Iterable<ui.Rect> screens =
        DisplayFeatureSubScreen.subScreensInBounds(
          Offset.zero & size,
          avoidBounds,
        );

    Rect closest = screens.first;
    for (final ui.Rect screen in screens) {
      if ((screen.center - point).distance <
          (closest.center - point).distance) {
        closest = screen;
      }
    }

    return closest;
  }

  // Fits the menu inside the screen, and returns the new position of the menu.
  //
  // Because all layers are positioned relative to the root menu, this method
  // is only called on the root menu. Overlapping layers will not leave the
  // horizontal bounds of the root menu, and can position themselves vertically
  // using flow.
  Offset _fitInsideScreen(
    Rect screen,
    Size childSize,
    Offset wantedPosition,
    EdgeInsets screenPadding,
  ) {
    double x = wantedPosition.dx;
    double y = wantedPosition.dy;
    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < screen.left + screenPadding.left) {
      // Desired X would overflow left, so we set X to left screen edge
      x = screen.left + screenPadding.left;
    } else if (x + childSize.width >
        screen.right - screenPadding.right) {
      // Overflows right
      x = screen.right -
          childSize.width -
          screenPadding.right;
    }

    if (y < screen.top + screenPadding.top) {
      // Overflows top
      y = screenPadding.top;
    }

    // Overflows bottom
    if (y + childSize.height >
        screen.bottom - screenPadding.bottom) {
      y = screen.bottom -
          childSize.height -
          screenPadding.bottom;

      // If the menu is too tall to fit on the screen, then move it into frame
      if (y < screen.top) {
        y = screen.top + screenPadding.top;
      }
    }

    return Offset(x, y);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus totalPadding.
    return BoxConstraints.loose(constraints.biggest).deflate(edgeInsets);
  }

  @override
  Offset getPositionForChild(
    Size size,
    Size childSize,
  ) {
    final Rect anchorRect = anchorPosition.toRect(Offset.zero & size);
    // Subtracting half of the menu's width from the anchor's midpoint
    // horizontally centers the menu and the anchor.
    //
    // If centering would cause the menu to overflow the screen, the x-value is
    // set to the edge of the screen to ensure the user-provided offset is
    // respected.
    final double offsetX = anchorRect.center.dx - (childSize.width / 2);

    // If the menu opens upwards, use the menu's top edge as an initial offset
    // for the menu item. As the menu grows, subtracting childSize from the
    // top edge of the anchor will cause the menu to grow upwards.
    final double offsetY = growthDirection == VerticalDirection.up
                            ? anchorRect.top - childSize.height
                            : anchorRect.bottom;

    final Rect screen = _findClosestScreen(
      size,
      anchorRect.center,
      avoidBounds,
    );

    Offset position = _fitInsideScreen(
      screen,
      childSize,
      Offset(offsetX, offsetY) + boundedOffset,
      edgeInsets,
    );

    position += unboundedOffset;
    onPositioned?.call(position);
    return position;
  }

  @override
  bool shouldRelayout(_RootMenuLayout oldDelegate) {
    return edgeInsets      != oldDelegate.edgeInsets
        || anchorPosition  != oldDelegate.anchorPosition
        || unboundedOffset != oldDelegate.unboundedOffset
        || boundedOffset   != oldDelegate.boundedOffset
        || growthDirection != oldDelegate.growthDirection
        || onPositioned    != oldDelegate.onPositioned
        || textDirection   != oldDelegate.textDirection
        || !setEquals(avoidBounds, oldDelegate.avoidBounds);
  }
}

class _MenuContainer extends StatefulWidget {
  const _MenuContainer({
    super.key,
    required this.child,
    required this.depth,
    required this.animation,
    this.clip = Clip.antiAlias,
  });

  final Widget child;
  final int depth;
  final Animation<double> animation;
  final Clip clip;

  @override
  State<_MenuContainer> createState() => _MenuContainerState();
}

class _MenuContainerState extends State<_MenuContainer>
    with SingleTickerProviderStateMixin {
  final ProxyAnimation _truncatedRouteAnimation = ProxyAnimation(kAlwaysDismissedAnimation);

  @override
  void initState() {
    super.initState();
    _truncatedRouteAnimation.parent = widget.animation
        .drive(_clampedAnimatable)
        .drive(CurveTween(curve: const Interval(0.4, 1.0)));
  }

  @override
  void didUpdateWidget(_MenuContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _truncatedRouteAnimation.parent = widget.animation
          .drive(_clampedAnimatable)
          .drive(CurveTween(curve: const Interval(0.4, 1.0)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShadowPainter(
        brightness: CupertinoTheme.brightnessOf(context),
        depth: widget.depth,
        radius: CupertinoMenu.radius,
        repaint: widget.animation,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(CupertinoMenu.radius),
        child: SizeTransition(
          axisAlignment: -1,
          sizeFactor: widget.animation,
          child: _BlurredSurface(
            listenable: _truncatedRouteAnimation,
            child: FadeTransition(
              opacity: widget.animation,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class Squircle extends CustomClipper<Path> {
  const Squircle({
    required this.radius,
  });

  final double radius;


  @override
  bool shouldReclip(Squircle oldClipper) => oldClipper.radius != radius;

  @override
  Path getClip(Size size) {
    const double a = 1.512996779;
    const double b = 1.000822998;
    const double c = 0.857108385;
    const double d = 0.636612366;
    const double e = 0.074140812;
    const double f = 0.375930619;
    const double g = 0.169408557;

    final double limit = math.min(size.width, size.height) / (2 / a);
    final double limitedRadius = math.min(radius, limit);

    double startX(double x) => x * limitedRadius;
    double startY(double y) => y * limitedRadius;
    double endX(double x) => size.width - x * limitedRadius;
    double endY(double y) => size.height - y * limitedRadius;

    //start at top left end of curve
    return Path()
      ..moveTo(startX(a), startY(0))
      ..lineTo(endX(a), startY(0))
      ..cubicTo(endX(b), startY(0), endX(c), startY(0), endX(d), startY(e))
      ..lineTo(endX(d), startY(e))
      ..cubicTo(endX(f), startY(g), endX(g), startY(f), endX(e), startY(d))
      ..cubicTo(endX(0), startY(c), endX(0), startY(b), endX(0), startY(a))
      ..lineTo(endX(0), endY(a))
      ..cubicTo(endX(0), endY(b), endX(0), endY(c), endX(e), endY(d))
      ..lineTo(endX(e), endY(d))
      ..cubicTo(endX(g), endY(f), endX(f), endY(g), endX(d), endY(e))
      ..cubicTo(endX(c), endY(0), endX(b), endY(0), endX(a), endY(0))
      ..lineTo(startX(a), endY(0))
      ..cubicTo(startX(b), endY(0), startX(c), endY(0), startX(d), endY(e))
      ..lineTo(startX(d), endY(e))
      ..cubicTo(startX(f), endY(g), startX(g), endY(f), startX(e), endY(d))
      ..cubicTo(startX(0), endY(c), startX(0), endY(b), startX(0), endY(a))
      ..lineTo(startX(0), startY(a))
      ..cubicTo(startX(0), startY(b), startX(0), startY(c), startX(e), startY(d))
      ..lineTo(startX(e), startY(d))
      ..cubicTo(startX(g), startY(f), startX(f), startY(g), startX(d), startY(e))
      ..cubicTo(startX(c), startY(0), startX(b), startY(0), startX(a), startY(0))
      ..close();
  }
}

class _ShadowPainter extends CustomPainter {
  const _ShadowPainter({
    required this.depth,
    required this.radius,
    required this.brightness,
    required this.repaint,
  }) : super(repaint: repaint);

  double get shadowOpacity => ui.clampDouble(repaint?.value ?? 0.0, 0.0, 1.0);
  final Animation<double>? repaint;
  final Radius radius;
  final int depth;
  final ui.Brightness brightness;

  double get diffuseShadowOpacity => math.sqrt(shadowOpacity) * .12;

  @override
  void paint(Canvas canvas, Size size) {
    assert(
      shadowOpacity >= 0 && shadowOpacity <= 1,
      'Shadow opacity must be between 0 and 1, inclusive.',
    );
    final Offset center = Offset(size.width / 2, size.height / 2);
    final ui.RRect diffuseShadowRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width + 50 * shadowOpacity,
        height: size.height + 50,
      ),
      const Radius.circular(14),
    );

    // A soft shadow that extends beyond the menu layer surface which makes the
    // menu appear lighter
    final Paint diffuseShadow = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowOpacity * 15 + 35)
      ..color = ui.Color.fromRGBO(0, 0, 0, diffuseShadowOpacity);

    canvas.drawRRect(
      diffuseShadowRect,
      diffuseShadow,
    );
  }

  @override
  bool shouldRepaint(_ShadowPainter oldDelegate) {
    return oldDelegate.radius != radius
        || oldDelegate.depth != depth
        || oldDelegate.shadowOpacity != shadowOpacity
        || oldDelegate.brightness != brightness;
  }

  @override
  bool shouldRebuildSemantics(_ShadowPainter oldDelegate) => false;
}



// The blurred and saturated background of the menu
//
// For performance, the backdrop filter is only applied if the menu's
// background is transparent. The backdrop is applied as a separate layer
// because opacity transitions applied to a backdrop filter have some visual
// artifacts. See https://github.com/flutter/flutter/issues/31706.
class _BlurredSurface extends AnimatedWidget {
  const _BlurredSurface({
    required Animation<double> listenable,
    required this.child,
  }) : super(listenable: listenable);

  final Widget child;

  double get value => (super.listenable as Animation<double>).value;

  /// A Color matrix that saturates and brightens
  ///
  /// Adapted from https://docs.rainmeter.net/tips/colormatrix-guide/, but
  /// changed to be more similar to iOS
   static List<double> _buildBrightnessAndSaturateMatrix({
    required double strength,
  }) {
    final double saturation = strength * 1.2 + 1;
    const double lumR = 0.4;
    const double lumG = 0.3;
    const double lumB = 0.0;
    final double sr = (1 - saturation) * lumR * strength;
    final double sg = (1 - saturation) * lumG * strength;
    final double sb = (1 - saturation) * lumB * strength;
    return <double>[
      sr + saturation, sg, sb, 0.0, 0.0,
      sr, sg + saturation, sb, 0.0, 0.0,
      sr, sg, sb + saturation, 0.0, 0.0,
      0.0, 0.0, 0.0, 1, 0.0,
    ];
  }


  @override
  Widget build(BuildContext context) {

    Color color = CupertinoMenu.background.resolveFrom(context);
    final bool transparent = color.alpha != 0xFF && !kIsWeb;
    if (transparent) {
      color = color.withOpacity(color.opacity * value);
    }
    ui.ImageFilter? filter = ColorFilter.matrix(
      _buildBrightnessAndSaturateMatrix(
        strength: value,
      ),
    );
    if (value != 0) {
      filter = ui.ImageFilter.compose(
        outer: filter,
        inner: ui.ImageFilter.blur(
          tileMode: TileMode.mirror,
          sigmaX: 45 * value,
          sigmaY: 45 * value,
        ),
      );
    }

    return BackdropFilter(
      blendMode: BlendMode.src,
      filter: filter,
      child: CustomPaint(
        willChange: value != 0 && value != 1,
        painter: _UnclippedColorPainter(color: color),
        child: child
      ),
    );
  }
}

class _UnclippedColorPainter extends CustomPainter {
  const _UnclippedColorPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(
     color,
     BlendMode.srcOver,
    );
  }

  @override
  bool shouldRepaint(_UnclippedColorPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _MenuBody extends StatefulWidget {
  const _MenuBody({
    required this.children,
    this.physics,
  });

  final List<Widget> children;
  final ScrollPhysics? physics;

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return children.map<DiagnosticsNode>((Widget child) => child.toDiagnosticsNode()).toList();
  }

  @override
  State<_MenuBody> createState() => _MenuBodyState();
}

class _MenuBodyState extends State<_MenuBody> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      focusable: false,
      label: 'Popup menu',
      child: CupertinoScrollbar(
        controller: _controller,
        thumbVisibility: false,
        child: CustomScrollView(
          clipBehavior: Clip.none,
          controller: _controller,
          physics: widget.physics,
          shrinkWrap: true,
          slivers: <Widget>[
            SliverList.separated(
              itemCount: widget.children.length,
              separatorBuilder: _separatorBuilder,
              itemBuilder: (BuildContext context, int index) {
                return widget.children[index];
              },
            )
          ],
        ),
      ),
    );
  }

  Widget? _separatorBuilder(BuildContext context, int index) {
    if (
      index == widget.children.length - 1 ||
      widget.children[index] is CupertinoMenuLargeDivider ||
      widget.children[index + 1] is CupertinoMenuLargeDivider
    ) {
      return const SizedBox.shrink();
    }

    return const CupertinoMenuDivider();
  }
}



