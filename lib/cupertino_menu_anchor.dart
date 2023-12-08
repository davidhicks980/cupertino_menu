// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoDynamicColor, CupertinoScrollbar, CupertinoTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show MenuStyle;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'menu_item.dart';
import 'test_anchor.dart';

final GlobalKey<State<StatefulWidget>> key = GlobalKey<State<StatefulWidget>>();

const  bool _kDebugMenus = true;

const Map<ShortcutActivator, Intent> _kMenuTraversalShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
  SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
  SingleActivator(LogicalKeyboardKey.tab, shift: true): PreviousFocusIntent(),
  SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
  SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
  SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
  SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
};

/// A mixin that specifies that a widget can be used in a [_CupertinoMenuPanel] or a
/// [CupertinoNestedMenu].
mixin CupertinoMenuEntryMixin {
  /// Whether this menu item should have a separator drawn after it.
  bool get hasSeparator => false;

  bool get hasLeading => false;

  /// Whether this menu item has a leading widget. If it does, the menu
  /// items without a leading widget space will have leading space added to align
  /// the leading edges of all menu items.
  bool getMenuLayerHasLeading(BuildContext context) {
    return CupertinoMenuAnchor._maybeOf(context)?._hasLeadingWidget ?? false;
  }
}

class CupertinoMenuController extends MenuController {
  /// The anchor that this controller controls.
  ///
  /// This is set automatically when a [MenuController] is given to the anchor
  /// it controls.
  _CupertinoMenuAnchorState? _anchor;
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

class _InheritedAnchorState extends InheritedWidget {
  const _InheritedAnchorState({super.key,  required this.state, required super.child});
  final _CupertinoMenuAnchorState state;

  static _CupertinoMenuAnchorState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedAnchorState>()!.state;
  }

  @override
  bool updateShouldNotify(_InheritedAnchorState oldWidget) {
    return true;
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
    this.containerKey,
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

  final GlobalKey? containerKey;

  final ScrollPhysics? scrollPhysics;

  static _CupertinoMenuAnchorState? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedAnchorState>()?.state;
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
  late final AnimationController _controller;
  late final Animation<double> _animation;
  CupertinoMenuController? _internalMenuController;
  bool _hasLeadingWidget = false;
  CupertinoMenuController get _menuController => widget.controller
                                                  ?? _internalMenuController!;
  AnimationStatus get _animationStatus => _controller.status;
GlobalKey? get containerKey =>  widget.containerKey;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      vsync: this,
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: curve,
      reverseCurve: reverseCurve,
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

    void handleStatusChange(AnimationStatus status) {
      if (status != AnimationStatus.reverse) {
        _controller.removeStatusListener(handleStatusChange);
        if (status == AnimationStatus.dismissed) {
          _menuController._closeOverlay();
        }
      }
    }

    _controller
      ..addStatusListener(handleStatusChange)
      ..reverse();
  }

  void _close() {
    widget.onClose?.call();
    _controller.reset();
  }

  void _open() {
    _controller.forward();
    if (_controller.isDismissed) {
      widget.onOpen?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoMenuAnchorProxy(
      menuChildren: widget.menuChildren,
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return TapRegion(
          groupId: controller,
          child: widget.builder?.call(context, _menuController, widget.child)
                  ?? widget.child!,
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
      animation: _animation,
      child: widget.child,
    );
  }
}

class _CupertinoMenuAnchorProxy extends MenuAnchor {
  const _CupertinoMenuAnchorProxy({
    required super.menuChildren,
    required super.controller,
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
  CupertinoMenuController get controller => super.controller! as CupertinoMenuController;

  @override
  State<_CupertinoMenuAnchorProxy> createState() => _CupertinoMenuAnchorProxyState();
}

class _CupertinoMenuAnchorProxyState extends MenuAnchorState<_CupertinoMenuAnchorProxy> {

  @override
  void handleScroll() {
    if (widget.controller.isOpen) {
      widget.controller._anchor!._beginClose();
    }
  }

  @override
  void handleScreenSizeChanged() {
    if (widget.controller.isOpen) {
      widget.controller._anchor!._beginClose();
    }
  }

  @override
  Widget overlayChildBuilder(BuildContext portalContext) {
    final RenderBox anchor = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Overlay.of(portalContext).context.findRenderObject()! as RenderBox;
    final Offset offset = widget.alignmentOffset ?? Offset.zero;
    final Rect anchorRect = Rect.fromPoints(
      anchor.localToGlobal(offset, ancestor: overlay),
      anchor.localToGlobal(
        anchor.size.bottomRight(offset) + offset,
        ancestor: overlay,
      ),
    );

    return _CupertinoSubmenu(
      context: context,
      menuScopeNode: menuScopeNode,
      animation: widget.animation,
      consumeOutsideTap: widget.consumeOutsideTap,
      menuChildren: widget.menuChildren,
      controller: widget.controller,
      alignmentOffset: widget.alignmentOffset,
      anchorRect: anchorRect,
      overlaySize: overlay.size,
    );
  }
}


class _CupertinoSubmenu extends StatelessWidget {
  const _CupertinoSubmenu({
    required this.context,
    required this.menuScopeNode,
    required this.animation,
    required this.consumeOutsideTap,
    required this.menuChildren,
    required this.controller,
    required this.anchorRect,
    required this.overlaySize,
    this.alignmentOffset,
  });

  final BuildContext context;
  final FocusScopeNode menuScopeNode;
  final Animation<double> animation;
  final bool consumeOutsideTap;
  final List<Widget> menuChildren;
  final CupertinoMenuController controller;
  final Offset? alignmentOffset;
  final Rect anchorRect;
  final Size overlaySize;

  @override
  Widget build(BuildContext context) {
    final RelativeRect anchorPosition = RelativeRect.fromSize(
      anchorRect,
      overlaySize,
    );

    final Alignment alignment = Alignment(
      (anchorRect.center.dx / overlaySize.width) * 2 - 1,
      (anchorRect.center.dy / overlaySize.height) * 2 - 1,
    );

    return ConstrainedBox(
      constraints: BoxConstraints.loose(overlaySize),
      child: FocusScope(
        node: menuScopeNode,
        skipTraversal: true,
        child: Actions(
          actions: <Type, Action<Intent>>{
            DirectionalFocusIntent: MenuDirectionalFocusAction(),
            DismissIntent: _DismissMenuAction(controller: controller),
          },
          child: Shortcuts(
            shortcuts: _kMenuTraversalShortcuts,
            child: _CupertinoMenuPanel(
              controller: controller,
              animation: animation,
              anchorPosition: anchorPosition,
              hasLeadingWidget: true,
              alignment: alignment,
              anchorSize: anchorRect.size,
              children: menuChildren,
            ),
          ),
        ),
      ),
    );
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


// import 'button.dart';
// import 'colors.dart';
// import 'icons.dart';
// import 'localizations.dart';
// import 'menu_item.dart';
// import 'scrollbar.dart';
// import 'theme.dart';

// TODO(davidhicks980): Shuffle the classes to make the file more readable.

/// Signature used by [CupertinoMenuButton] to lazily construct menu items shown
/// when a [_CupertinoMenuPanel] is constructed
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
    required this.children,
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

  final CupertinoMenuController? controller;

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
    stiffness: (2 * (math.pi / 0.4)) * (2 * math.pi / 0.4),
    damping: (4 * math.pi * 0.99) / 0.4,
  );

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
    darkColor: Color.fromRGBO(40, 40, 40, 0.75),
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
  late final AnimationController _panAnimation;
  final FocusNode _focusNode = FocusNode(debugLabel: 'CupertinoMenu-FocusNode');
  final ValueNotifier<double?> _panPosition = ValueNotifier<double?>(0);
  // Used for pan animation to determine whether user has dragged
  // outside of the menu area
  final ValueNotifier<Rect?> _rootMenuRectNotifier = ValueNotifier<Rect?>(null);

  late final _AnimationProduct _scaledAnimation;
  late final ProxyAnimation _menuAnimation;
  EdgeInsets get edgeInsets => widget._edgeInsets;

  @override
  void initState() {
    super.initState();
    _menuAnimation = ProxyAnimation(widget.animation);
    _panAnimation = AnimationController.unbounded(
      value: 1.0,
      vsync: this,
    );
    _scaledAnimation = _AnimationProduct(first: _menuAnimation, next: _panAnimation);
    _panAnimation.addListener(() {
      print(_panAnimation.value);
    });
  }

  @override
  void didUpdateWidget(covariant _CupertinoMenuPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.animation != widget.animation) {
      _menuAnimation.parent = widget.animation;
    }
  }


  @override
  void dispose() {
    _focusNode.dispose();
    _panAnimation.dispose();
    _panPosition.dispose();
    _rootMenuRectNotifier.dispose();
    super.dispose();
  }

  Future<void> _handlePanEnd(Offset offset) async {
    _panAnimation.stop();
    _panAnimation.animateTo(1, duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuint);
  }

  void _handlePanUpdate(Offset position, Rect? pannedArea) {
    if (_panAnimation.isAnimating) {
      _panAnimation.stop();
    }

    if (!(pannedArea?.contains(position) ?? true)) {
      final double squaredDistance = _calculateSquaredDistanceToMenuEdge(
        rect: pannedArea!,
        position: position,
      );
      final double value = math.min(squaredDistance / 20000, 1);


      _panAnimation.value = 1 - Curves.fastEaseInToSlowEaseOut.transform(
       value
      ) * 0.2;

    }
  }

  double _calculateSquaredDistanceToMenuEdge({
    required Rect rect,
    required Offset position,
  }) {
    // Compute squared distance
    final double dx = math.max(
      (position.dx - rect.center.dx).abs() - rect.width / 2,
      0.0,
    );

    final double dy = math.max(
      (position.dy - rect.center.dy).abs() - rect.height / 2,
      0.0,
    );
    return dx * dx + dy * dy;

  }

  @override
  Widget build(BuildContext context) {
    Widget menu = CupertinoPanListener<PanTarget<StatefulWidget>>(
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: MetaData(
          metaData: CupertinoTheme.brightnessOf(context),
          child: RepaintBoundary(
            child: _MenuContainer(
              depth: 0,
              animation: widget.animation,
              child: _MenuBody(
                physics: widget.physics,
                children: widget.children,
              ),
            ),
          ),
        ),
      );

    if (widget.controller != null) {
      menu = TapRegion(
        groupId: widget.controller,
        onTapOutside: (PointerDownEvent event) {
          // if (widget.controller!._anchor!._animationStatus
          //     case AnimationStatus.completed || AnimationStatus.forward) {
          //   widget.controller!._anchor!._beginClose();
          // }
        },
        child: menu,
      );
    }

    return ScaleTransition(
        alignment: widget.alignment,
        scale: _scaledAnimation,
        child: Builder(
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
                growthDirection: VerticalDirection.down,
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
        ),
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
      heightFactor: _clampedAnimation.value,
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

 /// A Color matrix that saturates and brightens
  ///
  /// Adapted from https://docs.rainmeter.net/tips/colormatrix-guide/, but
  /// changed to be more similar to iOS
    List<double> buildBrightnessAndSaturateMatrix({
    required double strength,
  }) {
    final double saturation = strength * 0.8 + 1;
    const double lumR = 0.3086;
    const double lumG = 0.6094;
    const double lumB = 0.0820;
    final double sr = (1 - saturation) * lumR * strength;
    final double sg = (1 - saturation) * lumG * strength;
    final double sb = (1 - saturation) * lumB * strength;
    return <double>[
      sr + saturation, sg,              sb,              0.0, 0.0,
      sr,              sg + saturation, sb,              0.0, 0.0,
      sr,              sg,              sb + saturation, 0.0, 0.0,
      0.0,             0.0,             0.0,             1.0, 0.0,
    ];
  }
class _BlurredSurface extends AnimatedWidget {
  const _BlurredSurface({
    required Animation<double> listenable,
    required this.child,
  }) : super(listenable: listenable);

  final Widget child;

  double get value => (super.listenable as Animation<double>).value;

  static const Interval delayedInterval =  Interval(0.55, 1.0);




  @override
  Widget build(BuildContext context) {
    Color color = _CupertinoMenuPanel.background.resolveFrom(context);
    final double delayedValue = delayedInterval.transform(value);
    final bool transparent = color.alpha != 0xFF && !kIsWeb;
    if (transparent) {
      color = color.withOpacity(color.opacity * value);
    }

    final ui.ImageFilter filter =
        ui.ImageFilter.compose(
          outer: ui.ImageFilter.blur(
            tileMode: TileMode.mirror,
            sigmaX: 30 * delayedValue,
            sigmaY: 30 * delayedValue,
          ),
          inner: ui.ColorFilter.matrix(
            buildBrightnessAndSaturateMatrix(strength: delayedValue)
          )
        );



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
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: false,
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


// Multiplies the values of two animations. Used to multiply the route animation
// and the nesting animation to apply effects when the menu closes.
class _AnimationProduct extends CompoundAnimation<double> {
  _AnimationProduct({
    required super.first,
    required super.next,
  });

  @override
  double get value => super.first.value * super.next.value;
}
