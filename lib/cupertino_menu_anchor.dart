// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoDynamicColor, CupertinoScrollbar, CupertinoTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MenuStyle;
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'menu_item.dart';
import 'test_anchor.dart';

final GlobalKey<State<StatefulWidget>> key = GlobalKey<State<StatefulWidget>>();

const  bool _kDebugMenus = false;

const Map<ShortcutActivator, Intent> _kMenuTraversalShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
  // SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
  // SingleActivator(LogicalKeyboardKey.tab, shift: true): PreviousFocusIntent(),
  SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
  SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
  SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
  SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
};


/// A mixin that specifies that a widget can be used in a [_CupertinoMenuPanel] or a
/// [CupertinoNestedMenu].
mixin CupertinoMenuEntryMixin {
  /// Whether this menu item should have a separator separating
  bool get hasSeparatorBefore => true;

  /// Whether this menu item should have a separator drawn before it.
  bool get hasSeparatorAfter => true;
  bool get hasLeading => false;

  /// Whether this menu item has a leading widget. If it does, the menu
  /// items without a leading widget space will have leading space added to align
  /// the leading edges of all menu items.
  bool getMenuLayerHasLeading(BuildContext context) {
    return CupertinoMenuAnchor._maybeOf(context)?._hasLeadingWidget ?? false;
  }

  void closeMenu(BuildContext context) {
    CupertinoMenuAnchor._maybeOf(context)?._beginClose();
  }
}

class CupertinoMenuController extends MenuController {
  /// The anchor that this controller controls.
  ///
  /// This is set automatically when a [MenuController] is given to the anchor
  /// it controls.
  _CupertinoMenuAnchorState? _anchor;

  /// The [AnimationStatus] of the animation that reveals this controller's menu.
  AnimationStatus get animationStatus => _anchor!._animationStatus;

  /// Close the menu that this menu controller is associated with.
  ///
  /// Associating with a menu is done by passing a [MenuController] to a
  /// [MenuAnchor]. A [MenuController] is also be received by the
  /// [MenuAnchor.builder] when invoked.
  ///
  /// If the menu's anchor point (either a [MenuBar] or a [MenuAnchor]) is
  /// scrolled by an ancestor, or the view changes size, then any open menu will
  /// automatically close.
  @override
  void close() {
    _anchor!._beginClose();
  }

  @override
  void open({ui.Offset? position}) {
    _anchor!._open();
    super.open(position: position);
  }

  void _openOverlay() => super.open();
  void _closeOverlay() => super.close();

  // ignore: use_setters_to_change_properties
  void _attach(_CupertinoMenuAnchorState anchor) {
    _anchor = anchor;
  }

  void _detach(_CupertinoMenuAnchorState anchor) {
    if (_anchor == anchor) {
      _anchor = null;
    }
  }
}

class _AnchorScope extends InheritedWidget {
  const _AnchorScope({super.key,  required this.state, required super.child});
  final _CupertinoMenuAnchorState state;

  @override
  bool updateShouldNotify(_AnchorScope oldWidget) {
    return state != oldWidget.state;
  }
}

typedef CupertinoMenuAnchorChildBuilder = Widget Function(
  BuildContext context,
  CupertinoMenuController controller,
  Widget? child,
);

class CupertinoMenuAnchor extends StatefulWidget {
  const CupertinoMenuAnchor({
    super.key,
    this.controller,
    this.childFocusNode,
    this.style,
    this.alignmentOffset,
    this.clipBehavior = Clip.hardEdge,
    this.consumeOutsideTap = true,
    this.onOpen,
    this.onClose,
    this.builder,
    this.child,
    this.scrollPhysics,
    required this.menuChildren,
  });

  /// An optional controller that allows opening and closing of the menu from
  /// other widgets.
  final CupertinoMenuController? controller;

  /// The [childFocusNode] attribute is the optional [FocusNode] also associated
  /// the [child] or [builder] widget that opens the menu.
  ///
  /// The focus node should be attached to the widget that should receive focus
  /// if keyboard focus traversal moves the focus off of the submenu with the
  /// arrow keys.
  ///
  /// If not supplied, then keyboard traversal from the menu back to the
  /// controlling button when the menu is open is disabled.
  final FocusNode? childFocusNode;

  /// The [MenuStyle] that defines the visual attributes of the menu bar.
  ///
  /// Colors and sizing of the menus is controllable via the [MenuStyle].
  ///
  /// Defaults to the ambient [MenuThemeData.style].
  final MenuStyle? style;

  /// The offset of the menu relative to the alignment origin determined by
  /// [MenuStyle.alignment] on the [style] attribute and the ambient
  /// [Directionality].
  ///
  /// Use this for adjustments of the menu placement.
  ///
  /// Increasing [Offset.dy] values of [alignmentOffset] move the menu position
  /// down.
  ///
  /// If the [MenuStyle.alignment] from [style] is not an [AlignmentDirectional]
  /// (e.g. [Alignment]), then increasing [Offset.dx] values of
  /// [alignmentOffset] move the menu position to the right.
  ///
  /// If the [MenuStyle.alignment] from [style] is an [AlignmentDirectional],
  /// then in a [TextDirection.ltr] [Directionality], increasing [Offset.dx]
  /// values of [alignmentOffset] move the menu position to the right. In a
  /// [TextDirection.rtl] directionality, increasing [Offset.dx] values of
  /// [alignmentOffset] move the menu position to the left.
  ///
  /// Defaults to [Offset.zero].
  final Offset? alignmentOffset;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// Whether or not a tap event that closes the menu will be permitted to
  /// continue on to the gesture arena.
  ///
  /// If false, then tapping outside of a menu when the menu is open will both
  /// close the menu, and allow the tap to participate in the gesture arena. If
  /// true, then it will only close the menu, and the tap event will be
  /// consumed.
  ///
  /// Defaults to false.
  final bool consumeOutsideTap;

  /// A callback that is invoked when the menu is opened.
  final VoidCallback? onOpen;

  /// A callback that is invoked when the menu is closed.
  final VoidCallback? onClose;

  /// A list of children containing the menu items that are the contents of the
  /// menu surrounded by this [MenuAnchor].
  ///
  /// {@macro flutter.material.MenuBar.shortcuts_note}
  final List<Widget> menuChildren;

  /// The widget that this [MenuAnchor] surrounds.
  ///
  /// Typically this is a button used to open the menu by calling
  /// [MenuController.open] on the `controller` passed to the builder.
  ///
  /// If not supplied, then the [MenuAnchor] will be the size that its parent
  /// allocates for it.
  final CupertinoMenuAnchorChildBuilder? builder;

  /// The optional child to be passed to the [builder].
  ///
  /// Supply this child if there is a portion of the widget tree built in
  /// [builder] that doesn't depend on the `controller` or `context` supplied to
  /// the [builder]. It will be more efficient, since Flutter doesn't then need
  /// to rebuild this child when those change.
  final Widget? child;

  final ScrollPhysics? scrollPhysics;

  static _CupertinoMenuAnchorState? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AnchorScope>()?.state;
  }

  @override
  State<CupertinoMenuAnchor> createState() => _CupertinoMenuAnchorState();
}


class _CupertinoMenuAnchorState extends State<CupertinoMenuAnchor>
      with SingleTickerProviderStateMixin {
  final ElasticOutCurve curve = const ElasticOutCurve(1.65);
  final Cubic reverseCurve = Curves.easeIn;
  final Duration transitionDuration = const Duration(milliseconds: 444);
  final Duration reverseTransitionDuration = const Duration(milliseconds: 300);
  final Map<ShortcutActivator, Intent> shortcuts = <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.escape): const DismissIntent(),
    const SingleActivator(LogicalKeyboardKey.tab): const PrioritizedIntents(
      orderedIntents: <Intent>[DismissIntent(), NextFocusIntent()],
    ),
    const SingleActivator(LogicalKeyboardKey.tab, shift: true): const PrioritizedIntents(
      orderedIntents: <Intent>[DismissIntent(), PreviousFocusIntent()],
    ),
    const SingleActivator(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
    const SingleActivator(LogicalKeyboardKey.arrowDown):
    const DirectionalFocusIntent(TraversalDirection.down),
      const SingleActivator(LogicalKeyboardKey.arrowLeft): const DirectionalFocusIntent(TraversalDirection.left),
  const SingleActivator(LogicalKeyboardKey.arrowRight): const DirectionalFocusIntent(TraversalDirection.right),

  };
   /// The SpringDescription used for the opening animation of a nested menu
   /// layer.
  static const SpringDescription forwardSpring = SpringDescription(
    mass: 1,
    stiffness: (2 * (math.pi / 0.35)) * (2 * (math.pi / 0.35)),
    damping: (4 * math.pi * 0.81) / 0.35,
  );

  /// The SpringDescription used for the closing animation of a nested menu layer.
  static const SpringDescription reverseSpring = SpringDescription(
    mass: 1,
    stiffness: (2 * (math.pi / 0.25)) * (2 * (math.pi / 0.25)),
    damping: (4 * math.pi * 1.8) / 0.25,
  );
  CupertinoMenuController? _internalMenuController;
  bool _hasLeadingWidget = false;
  late final AnimationController _controller;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  CupertinoMenuController get _menuController => widget.controller
                                                 ?? _internalMenuController!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
    );

    if (widget.controller == null) {
      _internalMenuController = CupertinoMenuController().._attach(this);
    }
  }

  @override
  void didUpdateWidget(CupertinoMenuAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      if (widget.controller != null) {
        _internalMenuController?._detach(this);
        _internalMenuController = null;
      } else {
        assert(_internalMenuController == null);
        _internalMenuController = CupertinoMenuController();
      }
      _menuController._attach(this);
    }

    _hasLeadingWidget = widget.menuChildren.any((Widget element) =>
        element is CupertinoMenuEntryMixin &&
       (element as CupertinoMenuEntryMixin).hasLeading,
    );
    assert(_menuController._anchor == this);
  }

  @override
  void dispose() {
    _menuController._detach(this);
    _internalMenuController = null;
    _controller.dispose();
    super.dispose();
  }

  void _beginClose() {
    if(_animationStatus case AnimationStatus.dismissed || AnimationStatus.reverse) {
      return;
    }


   widget.childFocusNode?.requestFocus();

    _controller.stop();
    _controller
      ..stop()
      ..animateWith(SpringSimulation(reverseSpring, _controller.value, 0, 5, tolerance: const Tolerance(velocity: 1, distance: 1)))
        .whenComplete(() {
        _animationStatus = AnimationStatus.dismissed;
        _menuController._closeOverlay();
      });

    _animationStatus = AnimationStatus.reverse;

  }

  void _close() {
    _controller.stop();
    _controller.value = 0;
    _animationStatus = AnimationStatus.dismissed;
    widget.onClose?.call();
  }

  void _open() {
    switch (_animationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.forward:
        return;
      case AnimationStatus.dismissed:
        widget.onOpen?.call();
      case AnimationStatus.reverse:
        break;
    }

    _controller
      ..stop()
      ..animateWith(SpringSimulation(forwardSpring, _controller.value, 1, 5))
        .whenComplete(() {
        _animationStatus = AnimationStatus.completed;
        _controller.value = 1;
    });

    _animationStatus = AnimationStatus.forward;
  }

  @override
  Widget build(BuildContext context) {
    return _AnchorScope(
      state: this,
      child:  _CupertinoMenuAnchorBase(
          menuChildren: widget.menuChildren,
          builder: (
            BuildContext context,
            MenuController controller,
            Widget? child
          ) {
            return FocusableActionDetector(
              shortcuts: shortcuts,
              child: TapRegion(
                groupId: controller,
                child: widget.builder?.call(
                  context,
                  _menuController,
                  widget.child,
                ) ?? widget.child!,
              ),
            );
          },
          controller: _menuController,
          childFocusNode: widget.childFocusNode,
          style: widget.style,
          scrollPhysics: widget.scrollPhysics,
          alignmentOffset: widget.alignmentOffset,
          clipBehavior: widget.clipBehavior,
          consumeOutsideTap: widget.consumeOutsideTap,
          onClose: _close,
          onOpen: _open,
          animation: _controller,
          child: widget.child,
        ),
    );
  }
}

class _CupertinoMenuAnchorBase extends MenuAnchor {
  const _CupertinoMenuAnchorBase({
    required super.menuChildren,
    super.clipBehavior,
    super.style,
    super.builder,
    super.alignmentOffset,
    super.childFocusNode,
    super.consumeOutsideTap = false,
    super.onClose,
    super.onOpen,
    super.child,
    this.scrollPhysics,
    required super.controller,
    required this.animation,
  });

  /// The physics to use for the menu's scrollable.
  ///
  /// If the menu's contents are not larger than its constraints, scrolling
  /// will be disabled regardless of the physics.
  ///
  /// Defaults to true.
  final ScrollPhysics? scrollPhysics;
  final Animation<double> animation;

  @override
  State<_CupertinoMenuAnchorBase> createState() => _CupertinoMenuAnchorProxyState();
}

class _CupertinoMenuAnchorProxyState extends MenuAnchorState<_CupertinoMenuAnchorBase>
      with TickerProviderStateMixin {

  final GlobalKey _panelKey = GlobalKey();
  late final AnimationController _panAnimationController;
  late final ProxyAnimation _menuAnimation;
  late final Animation<double> _scaleAnimation;
  CupertinoMenuController get _controller => widget.controller! as CupertinoMenuController;
  ui.Rect _anchorRect = ui.Rect.zero;

  @override
  void initState() {
    super.initState();
    _menuAnimation = ProxyAnimation(widget.animation);
    _panAnimationController = AnimationController.unbounded(
      value: 1.0,
      vsync: this,
    );
    _scaleAnimation = _AnimationProduct(
      first: _menuAnimation,
      next: _panAnimationController
    );
  }

  @override
  void didUpdateWidget(_CupertinoMenuAnchorBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _menuAnimation.parent = widget.animation;
    }
  }

  void _handlePanUpdate(Offset position) {
    if (!mounted || _panelKey.currentContext?.mounted != true){
      return;
    }

    if (_panAnimationController.isAnimating) {
      _panAnimationController.stop();
    }

    final RenderBox renderObj = _panelKey.currentContext!.findRenderObject()! as RenderBox;
    final Rect rect = (renderObj.localToGlobal(Offset.zero) & renderObj.size).expandToInclude(_anchorRect);
    if (rect.contains(position)) {
      _panAnimationController.value = 1.0;
      return;
    }

    final double x = math.max(
      (position.dx - rect.center.dx).abs() - rect.width / 2,
      0.0,
    );

    final double y = math.max(
      (position.dy - rect.center.dy).abs() - rect.height / 2,
      0.0,
    );

    final double squaredDistance = x * x + y * y;
    if (squaredDistance < 5) {
      _panAnimationController.value = 1.0;
      return;
    }

    final double value = math.min(squaredDistance / 60000, 1);
    _panAnimationController.value = 1.0 - Curves.easeOutExpo.transform(value) * 0.3;
  }

  void _handlePanEnd(Offset position) {
    _panAnimationController
      ..stop()
      ..animateTo(
        1.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuint,
      );
  }

  @override
  void handleScroll() {
    if (_controller.isOpen) {
      _controller._anchor!._beginClose();
    }
  }

  @override
  void handleScreenSizeChanged() {
    if (_controller.isOpen) {
      _controller._anchor!._beginClose();
    }
  }

  @override
  Widget buildOverlayChild(BuildContext portalContext, FocusScopeNode menuScopeNode) {
    final RenderBox anchor = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Overlay.of(portalContext).context.findRenderObject()! as RenderBox;
    final Offset offset = widget.alignmentOffset ?? Offset.zero;
    _anchorRect = Rect.fromPoints(
      anchor.localToGlobal(offset, ancestor: overlay),
      anchor.localToGlobal(
        anchor.size.bottomRight(offset) + offset,
        ancestor: overlay,
      ),
    );

    final Size overlaySize = overlay.size;
    final RelativeRect anchorPosition = RelativeRect.fromSize(
      _anchorRect,
      overlaySize,
    );

    final Alignment alignment = Alignment(
      (_anchorRect.center.dx / overlaySize.width) * 2 - 1,
      (_anchorRect.center.dy / overlaySize.height) * 2 - 1,
    );

    return ConstrainedBox(
      constraints: BoxConstraints.loose(overlaySize),
      child:Actions(
          actions: <Type, Action<Intent>>{
            DirectionalFocusIntent: MenuDirectionalFocusAction(),
            DismissIntent: _DismissMenuAction(controller: _controller),
          },
          child: FocusScope(
              debugLabel: 'child focus',
              node: menuScopeNode,
              child: Shortcuts(
              shortcuts: _kMenuTraversalShortcuts,
              child: CupertinoPanListener<PanTarget<StatefulWidget>>(
                onPanEnd: _handlePanEnd,
                onPanUpdate: _handlePanUpdate,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: alignment,
                  child:  _CupertinoSubmenu(
                    context: context,
                    animation: widget.animation,
                    consumeOutsideTap: widget.consumeOutsideTap,
                    controller: _controller,
                    alignmentOffset: widget.alignmentOffset,
                    anchorRect: _anchorRect,
                    alignment: alignment,
                    anchorPosition: anchorPosition,
                    physics: widget.scrollPhysics,
                    child:  _MenuBody(
                          key: _panelKey,
                          children: widget.menuChildren,
                    ),
                  )
                ),
              ),
                        ),
            )
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPanListener<PanTarget<StatefulWidget>>(
            onPanEnd: _handlePanEnd,
            onPanUpdate: _handlePanUpdate,
            child: super.build(context),
    );
  }
}

class _CupertinoSubmenu extends StatelessWidget {
  const _CupertinoSubmenu({
     super.key,
    required this.context,
    required this.animation,
    required this.consumeOutsideTap,
    required this.child,
    required this.controller,
    required this.anchorRect,
    required this.anchorPosition,
    required this.alignment,
    this.alignmentOffset,
    this.physics,
  });

  final BuildContext context;
  final Animation<double> animation;
  final bool consumeOutsideTap;
  final Widget child;
  final CupertinoMenuController controller;
  final Offset? alignmentOffset;
  final Alignment alignment;
  final RelativeRect anchorPosition;
  final Rect anchorRect;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return _CupertinoMenuPanel(
      controller: controller,
      animation: animation,
      anchorPosition: anchorPosition,
      hasLeadingWidget: true,
      alignment: alignment,
      anchorSize: anchorRect.size,
      child: TapRegion(
        consumeOutsideTaps: true,
        groupId: controller,
        onTapOutside: _handleOutsideTap,
        child: child,
      ),
    );
  }

  void _handleOutsideTap(PointerDownEvent event) {
    if (controller._anchor!._animationStatus
        case AnimationStatus.completed || AnimationStatus.forward) {
      controller._anchor!._beginClose();
    }
  }
}


class _DismissMenuAction extends DismissAction {
  /// Creates a [_DismissMenuAction].
  _DismissMenuAction({required this.controller});

  /// The [MenuController] associated with the menus that should be closed.
  final CupertinoMenuController controller;

  @override
  void invoke(DismissIntent intent) {
    assert(_debugMenuInfo('$runtimeType: Dismissing all open menus.'));
    controller._anchor?._beginClose();
  }

  @override
  bool isEnabled(DismissIntent intent) {
    return controller.isOpen;
  }
}



/// A debug print function, which should only be called within an assert, like
/// so:
///
///   assert(_debugMenuInfo('Debug Message'));
///
/// so that the call is entirely removed in release builds.
///
/// Enable debug printing by setting [_kDebugMenus] to true at the top of the
/// file.
bool _debugMenuInfo(String message, [Iterable<String>? details]) {
  assert(() {
    if (_kDebugMenus) {
      debugPrint('MENU: $message');
      if (details != null && details.isNotEmpty) {
        for (final String detail in details) {
          debugPrint('    $detail');
        }
      }
    }
    return true;
  }());
  // Return true so that it can be easily used inside of an assert.
  return true;
}


// TODO(davidhicks980): Shuffle the classes to make the file more readable.

/// Signature used by [CupertinoMenuButton] to lazily construct menu items shown
/// when a [_CupertinoMenuPanel] is constructed
///
/// Used by [CupertinoMenuButton.itemBuilder].
typedef CupertinoMenuItemBuilder =
          List<Widget> Function(BuildContext context);

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
        || hasLeadingWidget != oldWidget.hasLeadingWidget;
  }
}

/// A root menu layer that displays a list of [Widget] widgets
/// provided by the [child] parameter.
///
/// The [_CupertinoMenuPanel] is a [StatefulWidget] that manages the opening and
/// closing of nested [_CupertinoMenuPanel] layers.
///
/// The [_CupertinoMenuPanel] is typically created by a [CupertinoMenuButton], or by
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
class _CupertinoMenuPanel extends StatefulWidget {
  /// Creates a [_CupertinoMenuPanel] that displays a list of [Widget]s
  const _CupertinoMenuPanel({
    super.key,
    required this.child,
    required this.animation,
    required this.anchorPosition,
    required this.hasLeadingWidget,
    required this.alignment,
    required this.anchorSize,
    this.brightness,
    this.controller,
    this.clip = Clip.antiAlias,
    this.offset = Offset.zero,
    this.physics,
    this.constraints,
    EdgeInsets? edgeInsets,
  }) : _edgeInsets = edgeInsets ?? const EdgeInsets.all(defaultEdgeInsets);

  /// The menu items to display.
  final Widget child;

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

  final CupertinoMenuController? controller;

  /// The insets to avoid when positioning the menu.
  final EdgeInsets _edgeInsets;

  /// The [ui.Brightness] of the menu.
  final ui.Brightness? brightness;

  /// The amount of padding between the menu and the screen edge.
  static const double defaultEdgeInsets = 8;

  /// The default transparent [_CupertinoMenuPanel] background color.
  //
  // Background colors are based on the following:
  //
  // Dark mode on white background => rgb(83, 83, 83)
  // Dark mode on black => rgb(31, 31, 31)
  // Light mode on black background => rgb(197,197,197)
  // Light mode on white => rgb(246, 246, 246)
  static const CupertinoDynamicColor background =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(250, 251, 250, 0.775),
    darkColor: Color.fromRGBO(0, 0, 0, 0.675),
  );

  /// The default opaque [_CupertinoMenuPanel] background color.
  static const CupertinoDynamicColor opaqueBackground =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(246, 246, 246, 1),
    darkColor: Color.fromRGBO(31, 31, 31, 1),
  );


  @override
  State<_CupertinoMenuPanel> createState() => _CupertinoMenuPanelState();
}

class _CupertinoMenuPanelState extends State<_CupertinoMenuPanel>
      with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode(debugLabel: 'CupertinoMenu-FocusNode');
  // Used for pan animation to determine whether user has dragged
  // outside of the menu area

  EdgeInsets get edgeInsets => widget._edgeInsets;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Widget menu = _MenuContainer(
        depth: 0, animation: widget.animation, child: widget.child);

    return Builder(
      builder: (BuildContext context) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        final ui.Size size = mediaQuery.size;
        final double textScale = mediaQuery.textScaler.scale(1);
        final double width = textScale > 1.25 ? 350.0 : 250.0;
        final BoxConstraints constraints = BoxConstraints(
          minWidth: widget.constraints?.minWidth ?? width,
          maxWidth: widget.constraints?.maxWidth ?? width,
          minHeight: widget.constraints?.minHeight ?? 0.0,
          maxHeight: widget.constraints?.maxHeight ?? size.height,
        );
        return CustomSingleChildLayout(
          delegate: _RootMenuLayout(
            growthDirection: widget.alignment.y > 0
                ? VerticalDirection.up
                : VerticalDirection.down,
            anchorPosition: widget.anchorPosition,
            textDirection: Directionality.of(context),
            edgeInsets: widget._edgeInsets,
            avoidBounds:
                DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet(),
          ),
          child: ConstrainedBox(
            constraints: constraints,
            child: menu,
          ),
        );
      },
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
    // ignore: unused_element
    this.boundedOffset = Offset.zero,
  });

  // Whether the menu should begin growing above or below the menu anchor.
  final VerticalDirection growthDirection;

  // The text direction of the menu.
  final TextDirection textDirection;

  // The position of underlying anchor that the menu is attached to.
  final RelativeRect anchorPosition;

  // The amount of bounded displacement to apply to the menu's position.
  //
  // This offset is applied before the menu is fit inside the screen, and will
  // be limited by the bounds of the screen.
  final Offset boundedOffset;

  // Padding obtained from calling [MediaQuery.paddingOf(context)].
  //
  // Used to prevent the menu from being obstructed by system UI.
  final EdgeInsets edgeInsets;

  // List of rectangles that the menu should not overlap. Unusable screen area.
  final Set<Rect> avoidBounds;

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

    final Offset position = _fitInsideScreen(
      screen,
      childSize,
      Offset(offsetX, offsetY) + boundedOffset,
      edgeInsets,
    );

    return position;
  }

  @override
  bool shouldRelayout(_RootMenuLayout oldDelegate) {
    return edgeInsets      != oldDelegate.edgeInsets
        || anchorPosition  != oldDelegate.anchorPosition
        || boundedOffset   != oldDelegate.boundedOffset
        || textDirection   != oldDelegate.textDirection
        || growthDirection != oldDelegate.growthDirection
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
  late final Animation<double> _clampedAnimation;
  late final ProxyAnimation _proxiedAnimation;


  @override
  void initState() {
    super.initState();
    _proxiedAnimation = ProxyAnimation(widget.animation);
    _clampedAnimation = _proxiedAnimation
    .drive(Animatable<double>.fromCallback(
      (double value) => ui.clampDouble(value, 0.0, 1.0)
    ))
    .drive(CurveTween(curve: const Interval(0.4, 1.0)));

  }

  @override
  void didUpdateWidget(_MenuContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _proxiedAnimation.parent = widget.animation;
    }
  }

  static final DecorationTween _decorationTween = DecorationTween(
    begin: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0),
          ),
        ]),
    end: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            spreadRadius: 30,
            blurRadius: 50,
          ),
        ]),
  );

 Align _alignTransitionBuilder(BuildContext context, Widget? child){
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: _proxiedAnimation.value,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      decoration: _decorationTween.animate(_clampedAnimation),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        child: AnimatedBuilder(
          animation: _clampedAnimation,
          builder: _alignTransitionBuilder,
          child: _BlurredSurface(
            color: _CupertinoMenuPanel.background.resolveFrom(context),
            listenable: _clampedAnimation,
            child: FadeTransition(
              opacity: _clampedAnimation,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}




class _BlurredSurface extends AnimatedWidget {
  const _BlurredSurface({
    required Animation<double> listenable,
    required this.color,
    required this.child,
  }) : super(listenable: listenable);

  static const Interval _surfaceDelay =  Interval(0.55, 1.0);
  final Widget child;
  final Color color;
  double get value => (super.listenable as Animation<double>).value;

  /// A Color matrix that saturates and brightens
  ///
  /// Adapted from https://docs.rainmeter.net/tips/colormatrix-guide/, but adapted
  /// to resemble the iOS 17 menu.
  List<double> buildBrightnessAndSaturateMatrix({
    required double strength,
  }) {
    final double saturation = strength * 0.7 + 1;
    final double brightness = strength * 66;
    const double lumR = 0.3086;
    const double lumG = 0.6094;
    const double lumB = 0.0820;
    final double sr = (1 - saturation) * lumR * strength;
    final double sg = (1 - saturation) * lumG * strength;
    final double sb = (1 - saturation) * lumB * strength;
    return <double>[
      sr + saturation, sg             , sb             , 0.0, brightness,
      sr             , sg + saturation, sb             , 0.0, brightness,
      sr             , sg             , sb + saturation, 0.0, brightness,
      0.0            , 0.0            ,0.0             , 1.0, 0.0       ,
    ];
  }

  @override
  Widget build(BuildContext context) {

    final ui.Color resolvedColor = color.withOpacity(color.opacity * value);

    final double delayedValue = _surfaceDelay.transform(value);
    final bool transparent = resolvedColor.alpha != 0xFF;

    Widget surface = CustomPaint(
      willChange: value != 0 && value != 1,
      painter: _UnclippedColorPainter(color: resolvedColor),
      child: child,
    );

    if (transparent) {
      ui.ImageFilter filter = ui.ImageFilter.blur(
        tileMode: ui.TileMode.mirror,
        sigmaX: 30 * delayedValue,
        sigmaY: 30 * delayedValue,
      );

      if (!kIsWeb) {
        filter = ui.ImageFilter.compose(
          outer: filter,
          inner: ui.ColorFilter.matrix(
            buildBrightnessAndSaturateMatrix(
              strength: delayedValue
            )
          ),
        );
      }

      surface = BackdropFilter(
        blendMode: BlendMode.src,
        filter: filter,
        child: surface,
      );
    }

    return surface;
  }
}


// A custom painter that paints a color without clipping.
//
// Used to fill the background color of the menu even when the menu size animation
// surpasses a heightFactor of 1.0.
class _UnclippedColorPainter extends CustomPainter {
  const _UnclippedColorPainter({required this.color});

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
    super.key,
    required this.children,
    this.physics,
  });

  final List<Widget> children;
  final ScrollPhysics? physics;

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
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
              itemCount: widget.children.length,
              separatorBuilder: _separatorBuilder,
              itemBuilder: _itemBuilder,
            )
          ],
        ),
      ),
    );
  }

  Widget? _itemBuilder(BuildContext context, int index) => widget.children[index];
  Widget? _separatorBuilder(BuildContext context, int index) {
    if (index == widget.children.length - 1) {
      return const SizedBox.shrink();
    }

    if (widget.children[index] case CupertinoMenuEntryMixin(hasSeparatorAfter: false)) {
      return const SizedBox.shrink();
    }

    if (widget.children[index + 1] case CupertinoMenuEntryMixin(hasSeparatorBefore: false)) {
      return const SizedBox.shrink();
    }

    return const CupertinoMenuDivider();
  }
}


/// Multiplies the values of two animations.
///
/// This class is used to animate the scale of the menu when the user drags
/// outside of the menu area.
class _AnimationProduct extends CompoundAnimation<double> {
  _AnimationProduct({
    required super.first,
    required super.next,
  });

  @override
  double get value => super.first.value * super.next.value;
}
