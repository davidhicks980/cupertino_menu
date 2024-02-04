// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart'
    show
        CupertinoButton,
        CupertinoColors,
        CupertinoDynamicColor,
        CupertinoIcons,
        CupertinoScrollbar,
        CupertinoTheme,
        kMinInteractiveDimensionCupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    show ButtonStyle, Colors, FilledButton, MaterialLocalizations, MaterialStateProperty, MenuStyle;
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'menu_item.dart';
import 'test_anchor.dart';

// TODO(davidhicks980): A menu button inside of a context menu prevents closure
// of the inner menu

// TODO(davidhicks980): Tab-based focus traversal is broken when encountering a
// submenu: it just loops

// TODO(davidhicks980): Arrow key focus traversal breaks when encountering a
// submenu

// TODO(davidhicks980): Should shortcuts be offered at all?


// TODO(davidhicks980): Press space on a menu anchor should highlight without opening.


const Duration _kMenuPanReboundDuration = Duration(milliseconds: 600);
const bool _kDebugMenus = false;


/// Whether [defaultTargetPlatform] is an Apple platform (Mac or iOS).
bool get _isApple {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return true;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return false;
  }
}
/// Whether [defaultTargetPlatform] is one that uses symbolic shortcuts.
///
/// Mac and iOS use special symbols for modifier keys instead of their names,
/// render them in a particular order defined by Apple's human interface
/// guidelines, and format them so that the modifier keys always align.
bool get _usesSymbolicModifiers {
  return _isApple;
}


bool get _platformSupportsAccelerators {
  // On iOS and macOS, pressing the Option key (a.k.a. the Alt key) causes a
  // different set of characters to be generated, and the native menus don't
  // support accelerators anyhow, so we just disable accelerators on these
  // platforms.
  return !_isApple;
}

const Map<ShortcutActivator, Intent> _kMenuTraversalShortcuts =
    <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
  SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
  SingleActivator(LogicalKeyboardKey.tab, shift: true): PreviousFocusIntent(),
  SingleActivator(LogicalKeyboardKey.arrowUp):
      DirectionalFocusIntent(TraversalDirection.up),
  SingleActivator(LogicalKeyboardKey.arrowDown):
      DirectionalFocusIntent(TraversalDirection.down),
  SingleActivator(LogicalKeyboardKey.arrowLeft):
      DirectionalFocusIntent(TraversalDirection.left),
  SingleActivator(LogicalKeyboardKey.arrowRight):
      DirectionalFocusIntent(TraversalDirection.right),
};

/// Mix [CupertinoMenuEntryMixin] in to communicate with the nearest
/// [CupertinoMenuAnchor]
///
/// The [allowLeadingSeparator] and [allowTrailingSeparator] properties control
/// whether a separator can be drawn between menu items. In an adjacent pair of
/// menu items, a separator will only be drawn if the first item has
/// [allowTrailingSeparator] set to `true` and the second item has
/// [allowLeadingSeparator] set to `true`.
///
/// The [hasLeading] property should describe whether this menu item has a
/// leading widget. If true, the siblings of this menu item that are missing a
/// leading widget will have leading space added to align the leading edges of
/// all menu items. Defaults to false.
mixin CupertinoMenuEntryMixin {
  /// Whether a separator can be drawn before this menu item.
  ///
  /// A separator will only be drawn if the menu item immediately above this
  /// item has mixed in [CupertinoMenuEntryMixin] and has set
  /// [allowTrailingSeparator] to true.
  bool get allowLeadingSeparator => true;

  /// Whether a separator can be drawn after this menu item.
  ///
  /// A separator will only be drawn if the menu item immediately below this
  /// item has mixed in [CupertinoMenuEntryMixin] and has set
  /// [allowLeadingSeparator] to true.
  bool get allowTrailingSeparator => true;

  /// Whether this menu item has a leading widget.
  ///
  /// If true, the siblings of this menu item that are missing a leading
  /// widget will have leading space added to align the leading edges of all
  /// menu items.
  bool get hasLeading => false;
}

enum MenuStatus {
  /// The menu is closed, and the menu animation has completed.
  closed,

  /// The menu is opening, and the menu animation is running forward.
  opening,

  /// The menu is open, and the menu animation has completed.
  open,

  /// The menu is closing, and the menu animation is running in reverse.
  closing,
}

class CupertinoMenuController extends MenuController with ChangeNotifier {
  /// The anchor that this controller controls.
  ///
  /// This is set automatically when a [MenuController] is given to the anchor
  /// it controls.
  _CupertinoMenuAnchorState? _anchor;

  /// The [AnimationStatus] of the animation that reveals this controller's menu.
  MenuStatus get menuStatus => _anchor!._menuStatus;

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
  const _AnchorScope({required this.state, required super.child});
  final _CupertinoMenuAnchorState state;

  @override
  bool updateShouldNotify(_AnchorScope oldWidget) {
    return state != oldWidget.state;
  }
}

/// A builder for the widget that this [CupertinoMenuAnchor] surrounds.
///
/// Typically this is a button used to open the menu by calling
/// [CupertinoMenuAnchor.open] on the `controller` passed to the builder.
///
/// If not supplied, then the [MenuAnchor] will be the size that its parent
/// allocates for it.
typedef CupertinoMenuAnchorChildBuilder = Widget Function(
  BuildContext context,
  CupertinoMenuController controller,
  Widget? child,
);

/// A builder responsible for creating and animating the menu surface.
typedef CupertinoMenuSurfaceBuilder = Widget Function({
  required Widget child,
  required Animation<double> animation,
  required Color backgroundColor,
  required Clip clipBehavior,
});


class CupertinoMenuAnchor extends StatefulWidget {
  const CupertinoMenuAnchor({
    super.key,
    required this.menuChildren,
    this.controller,
    this.childFocusNode,
    this.clipBehavior = Clip.hardEdge,
    this.consumeOutsideTap = false,
    this.enablePan = true,
    this.onOpen,
    this.onClose,
    this.builder,
    this.child,
    this.scrollPhysics,
    this.constraints,
    this.alignment,
    this.alignmentOffset = Offset.zero,
    this.menuAlignment,
    this.forwardSpring = forwardSpringDescription,
    this.reverseSpring = reverseSpringDescription,
    this.backgroundColor = defaultBackground,
    this.surfaceBuilder = defaultSurfaceBuilder,
    this.shrinkWrap = true,
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
  final Offset alignmentOffset;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Must not be [Clip.antiAliasWithSaveLayer]. Defaults to [Clip.hardEdge].
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

  /// The [ScrollPhysics] applied to the menu's scrollable.
  ///
  /// If the menu's contents are smaller than its constraints, scrolling
  /// will be disabled regardless of the applied physics.
  /// If null, the physics will be determined by the nearest [ScrollConfiguration].
  /// Defaults to null.
  final ScrollPhysics? scrollPhysics;

  /// The [SpringDescription] used for the opening animation of the menu.
  final SpringDescription forwardSpring;

  /// The [SpringDescription] used for the closing animation of the menu.
  final SpringDescription reverseSpring;

  /// The constraints to apply to the menu.
  final BoxConstraints? constraints;

  /// The alignment of the menu relative to the anchor.
  ///
  /// If null, defaults to [Alignment.topCenter] when the anchor is above
  /// the center of the screen, and [Alignment.bottomCenter] when the anchor is
  /// below the center of the screen.
  final AlignmentGeometry? alignment;

  /// The alignment of the point from which the menu should grow.
  ///
  /// Defaults to [Alignment.topCenter] when the anchor is above the center of
  /// the screen, and [Alignment.bottomCenter] when the anchor is below the
  /// center of the screen.
  final AlignmentGeometry? menuAlignment;

  /// Whether or not panning is enabled on the menu.
  ///
  /// When panning is enabled, a [PanGestureRecognizer] is added around the menu
  /// anchor and menu items. The [PanGestureRecognizer] allows for users to
  /// press, move, and activate adjacent menu items in a single gesture. Panning
  /// is also responsible for the scale animation of the menu panel when users
  /// drag their pointer away from the menu.
  ///
  /// Disabling panning can be useful if the menu pan effects interfere with
  /// another pan gesture, such as in the case of dragging a menu anchor around
  /// the screen.
  ///
  /// Defaults to true.
  final bool enablePan;

  /// The background color of the menu.
  ///
  /// If null, the menu will use [defaultBackground]. If the provided color is
  /// not opaque, the menu will apply a [ui.ColorFilter.matrix] and
  /// [ui.ImageFilter.blur] to the contents behind the menu using a
  /// [BackdropFilter] widget.
  final Color backgroundColor;

  /// Whether or not the menu scrollable should shrink-wrap its contents.
  ///
  /// If `true`, the menu will be sized to fit its contents. Otherwise, the menu
  /// surface will grow to fill either the total available vertical space, or
  /// the value of [constraints.maxHeight], whichever is smaller.
  ///
  /// If you are unsure of the total size of your menu items, keeping
  /// [shrinkWrap] set to `true` will prevent a menu surface that is larger than
  /// it's contents. However, if you are confident that the total size of your
  /// menu items will always **exceed** the [constraints.maxHeight] you provide,
  /// or the total height of the screen, setting [shrinkWrap] to `false` can
  /// improve performance by allowing the menu to be laid out in advance.
  ///
  /// Defaults to `true`.
  final bool shrinkWrap;

  /// The builder responsible for creating and animating the surface
  ///
  /// The default builder animates the size, color, clip behavior, and shadow of
  /// the menu surface.
  ///
  /// Defaults to [defaultSurfaceBuilder].
  final CupertinoMenuSurfaceBuilder surfaceBuilder;

  /// The [SpringDescription] used for the opening animation of a menu layer.
  static const SpringDescription forwardSpringDescription = SpringDescription(
    mass: 1,
    stiffness: (2 * (math.pi / 0.35)) * (2 * (math.pi / 0.35)),
    damping: (4 * math.pi * 0.81) / 0.35,
  );

  /// The [SpringDescription] used for the closing animation of a menu layer.
  static const SpringDescription reverseSpringDescription = SpringDescription(
    mass: 1,
    stiffness: (2 * (math.pi / 0.25)) * (2 * (math.pi / 0.25)),
    damping: (4 * math.pi * 1.8) / 0.25,
  );

  static _CupertinoMenuAnchorState? _maybeOf(BuildContext context) {
    return context.findAncestorWidgetOfExactType<_AnchorScope>()?.state;
  }

  static Widget defaultSurfaceBuilder({
    required Widget child,
    required Animation<double> animation,
    required Color backgroundColor,
    required Clip clipBehavior,
  }) {
    return _MenuSurface(
      animation: animation,
      clipBehavior: clipBehavior,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// The default transparent [_MenuPanelLayout] background color.
  //
  // Background colors are based on the following:
  //
  // Dark mode on white background => rgb(83, 83, 83)
  // Dark mode on black => rgb(31, 31, 31)
  // Light mode on black background => rgb(197,197,197)
  // Light mode on white => rgb(246, 246, 246)
  static const CupertinoDynamicColor defaultBackground =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(243, 243, 243, 0.775),
    darkColor: Color.fromRGBO(55, 55, 55, 0.735),
  );

  @override
  State<CupertinoMenuAnchor> createState() => _CupertinoMenuAnchorState();

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return menuChildren
        .map<DiagnosticsNode>((Widget child) => child.toDiagnosticsNode())
        .toList();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('consumeOutsideTap',value: consumeOutsideTap, ifTrue: 'AUTO-CLOSE'));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', childFocusNode));
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior));
    properties.add(DiagnosticsProperty<Offset?>('alignmentOffset', alignmentOffset));
    if (constraints != null) {
      properties.add(DiagnosticsProperty<BoxConstraints?>('constraints', constraints));
    }

    if (child != null) {
      properties.add(DiagnosticsProperty<String?>('child', child.toString()));
    }
  }
}
class _CupertinoMenuAnchorState extends State<CupertinoMenuAnchor>
    with TickerProviderStateMixin {
  static const Tolerance _springTolerance = Tolerance(velocity: 0.1, distance: 0.1);
  final GlobalKey _panelScrollableKey = GlobalKey(debugLabel: '$CupertinoMenuAnchor Scrollable Key');
  late final Animation<double> _panAnimation;
  late final AnimationController _panAnimationController;
  late final AnimationController _animationController;

  /// Whether any siblings of this menu item have a leading widget. If a sibling
  /// does, this menu item will have leading space added to align the leading edges of
  /// all menu items.
  MenuStatus _menuStatus = MenuStatus.closed;
  ui.Rect _anchorRect = ui.Rect.zero;
  bool _hasLeadingWidget = false;
  CupertinoMenuController? _internalMenuController;
  CupertinoMenuController get _menuController => widget.controller
                                                  ?? _internalMenuController!;

  /// Whether the menu is open or opening.
  ///
  /// Used to determine whether the menu should be included focus. If the menu
  /// is not open or opening, then the menu should not be included in focus.
  bool get _isOpenOrOpening => _menuStatus == MenuStatus.open
                            || _menuStatus == MenuStatus.opening;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalMenuController = CupertinoMenuController();
    }
    _menuController._attach(this);
    _animationController = AnimationController.unbounded(vsync: this);
    _panAnimationController = AnimationController.unbounded(value: 1, vsync: this);
    _panAnimation = _AnimationProduct(
      first: _animationController,
      next: _panAnimationController,
    );
    _hasLeadingWidget = widget.menuChildren.any((Widget element) {
      if (element case CupertinoMenuEntryMixin(:final bool hasLeading)) {
        return hasLeading;
      } else {
        return false;
      }
    });
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

    if (oldWidget.menuChildren != widget.menuChildren) {
      _hasLeadingWidget = widget.menuChildren.any((Widget element) {
        if (element case CupertinoMenuEntryMixin(:final bool hasLeading)) {
          return hasLeading;
        } else {
          return false;
        }
      });
    }

    assert(_menuController._anchor == this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _panAnimationController.dispose();
    _menuController._detach(this);
    _internalMenuController = null;
    super.dispose();
  }

  void _beginClose() {
    if (_menuStatus case MenuStatus.closed || MenuStatus.closing) {
      return;
    }

    _animationController
      ..stop()
      ..animateWith(
        ClampedSimulation(
          SpringSimulation(
            widget.forwardSpring,
            _animationController.value,
            0.0,
            5.0,
            tolerance: _springTolerance,
          ),
          xMin: 0.0,
          xMax: 1.0,
        ),
      ).whenComplete(_menuController._closeOverlay);

    setState(() {
      _menuStatus = MenuStatus.closing;
    });
  }

  void _close() {
    widget.onClose?.call();
    if (mounted) {
      // Reset the menu status to closed regardless of whether the animation
      // ran.
      _animationController.stop();
      _animationController.value = 0.0;
      _menuStatus = MenuStatus.closed;
      if (SchedulerBinding.instance.schedulerPhase !=
          SchedulerPhase.persistentCallbacks) {
        setState(() { /* Mark dirty if mounted and not in a build. */ });
      }
    }
  }

  void _open() {
    switch (_menuStatus) {
      case MenuStatus.open:
      case MenuStatus.opening:
        return;
      case MenuStatus.closed:
        widget.onOpen?.call();
      case MenuStatus.closing:
        break;
    }

    _animationController
      ..stop()
      ..animateWith(SpringSimulation(
        widget.forwardSpring,
        _animationController.value,
        1.0,
        5.0,
      )).whenComplete(() {
        _animationController.value = 1;
        setState(() {
          _menuStatus = MenuStatus.open;
        });
      });

    setState(() {
      _menuStatus = MenuStatus.opening;
    });

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (mounted && (_panelScrollableKey.currentContext?.mounted ?? false)) {
        FocusScope.of(context).setFirstFocus(FocusScope.of(_panelScrollableKey.currentContext!));
      }
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final Offset panPosition = details.globalPosition;
    if (!mounted || _panelScrollableKey.currentContext?.mounted != true) {
      return;
    }

    if (_panAnimationController.isAnimating) {
      _panAnimationController.stop();
    }

    final RenderBox renderObj =
        _panelScrollableKey.currentContext!.findRenderObject()! as RenderBox;
    final Rect rect = (renderObj.localToGlobal(Offset.zero) & renderObj.size)
        .expandToInclude(_anchorRect);
    if (rect.contains(panPosition)) {
      _panAnimationController.value = 1.0;
      return;
    }

    final double x = math.max(
      (panPosition.dx - rect.center.dx).abs() - rect.width / 2,
      0.0,
    );

    final double y = math.max(
      (panPosition.dy - rect.center.dy).abs() - rect.height / 2,
      0.0,
    );

    final double squaredDistance = x * x + y * y;
    if (squaredDistance < 5) {
      _panAnimationController.value = 1.0;
      return;
    }

    // 60000 is a drag distance of ~245. At this distance, the menu scale
    // will be clamped to 0.7.
    final double value = math.min(squaredDistance / 60000, 1);
    _panAnimationController.value = 1.0 - Curves.easeOutExpo.transform(value) * 0.3;
  }

  void _handlePanEnd([DragEndDetails? details]) {
    _panAnimationController
      ..stop()
      ..animateTo(
        1.0,
        duration: _kMenuPanReboundDuration,
        curve: Curves.easeOutQuint,
      );
  }

  Widget _buildOverlay({
    required BuildContext overlayContext,
    required FocusScopeNode menuFocusScopeNode,
    Object? tapRegionGroupId,
    Offset? menuPosition,
  }) {
    final RenderBox anchor = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Overlay.of(overlayContext).context.findRenderObject()! as RenderBox;
    _anchorRect =
        anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size;
    if (menuPosition != null) {
      _anchorRect = (menuPosition + _anchorRect.topLeft) & Size.zero;
    }

    if (_menuStatus == MenuStatus.closed) {
      return const SizedBox.shrink();
    }

    return ExcludeFocus(
      excluding: !_isOpenOrOpening,
      child: _MenuPanel(
        enablePan: widget.enablePan,
        onPanEnd: _handlePanEnd,
        onPanUpdate: _handlePanUpdate,
        overlaySize: overlay.paintBounds.size,
        context: overlayContext,
        panelScrollableKey: _panelScrollableKey,
        animation: _animationController,
        controller: _menuController,
        anchorRect: _anchorRect,
        constraints: widget.constraints,
        consumeOutsideTaps: widget.consumeOutsideTap,
        clipBehavior: widget.clipBehavior,
        scrollPhysics: widget.scrollPhysics,
        menuScopeNode: menuFocusScopeNode,
        anchorAlignment: widget.alignment,
        menuAlignment: widget.menuAlignment,
        alignmentOffset: widget.alignmentOffset,
        panAnimation: _panAnimation,
        tapRegionGroupId: tapRegionGroupId,
        backgroundColor: widget.backgroundColor,
        surfaceBuilder: widget.surfaceBuilder,
        children: widget.menuChildren,
      ),
    );
  }

  Widget _buildAnchorChild(
    BuildContext context,
    MenuController controller,
    Widget? child,
  ) {
    final Widget anchorChild =
                  widget.builder?.call(context, _menuController, widget.child)
                    ?? widget.child
                    ?? const SizedBox.shrink();
    return widget.enablePan
        ? _PanRegion<_PanTarget<StatefulWidget>>(child: anchorChild)
        : anchorChild;
  }

  @override
  Widget build(BuildContext context) {
    return BlockSemantics(
      blocking: _isOpenOrOpening,
      child: _AnchorScope(
        state: this,
        child: _CupertinoMenuAnchorBase(
          menuChildren: widget.menuChildren,
          overlayChildBuilder: _buildOverlay,
          builder: _buildAnchorChild,
          controller: _menuController,
          childFocusNode: widget.childFocusNode,
          alignmentOffset: widget.alignmentOffset,
          consumeOutsideTap: widget.consumeOutsideTap,
          onClose: _close,
          onOpen: _open,
          child: widget.child,
        ),
      ),
    );
  }
}

class _CupertinoMenuAnchorBase extends MenuAnchor {
  const _CupertinoMenuAnchorBase({
    required this.overlayChildBuilder,
    required super.menuChildren,
    required super.controller,
    super.builder,
    super.alignmentOffset,
    super.childFocusNode,
    super.consumeOutsideTap = false,
    super.onClose,
    super.onOpen,
    super.child,
  });

  final Widget Function({
    required BuildContext overlayContext,
    required FocusScopeNode menuFocusScopeNode,
    Object? tapRegionGroupId,
    Offset? menuPosition,
  }) overlayChildBuilder;

  @override
  State<_CupertinoMenuAnchorBase> createState() => _CupertinoMenuAnchorProxyState();
}

class _CupertinoMenuAnchorProxyState extends MenuAnchorState<_CupertinoMenuAnchorBase>
    with TickerProviderStateMixin {

  @override
  Widget buildOverlayChild({
    required BuildContext overlayContext,
    required FocusScopeNode menuFocusScopeNode,
    Object? tapRegionGroupId,
    Offset? menuPosition,
  }) {
    return widget.overlayChildBuilder(
      overlayContext: overlayContext,
      menuFocusScopeNode: menuFocusScopeNode,
      tapRegionGroupId: tapRegionGroupId,
      menuPosition: menuPosition,
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.anchorRect,
    required this.context,
    required this.controller,
    required this.animation,
    required this.menuScopeNode,
    required this.children,
    required this.panelScrollableKey,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.panAnimation,
    required this.overlaySize,
    required this.consumeOutsideTaps,
    required this.enablePan,
    required this.backgroundColor,
    required this.clipBehavior,
    required this.alignmentOffset,
    required this.surfaceBuilder,
    this.scrollPhysics,
    this.menuAlignment,
    this.anchorAlignment,
    this.constraints,
    this.tapRegionGroupId,
  });


  final Color backgroundColor;
  final bool enablePan;
  final BuildContext context;
  final bool consumeOutsideTaps;
  final CupertinoMenuController controller;
  final ui.Rect anchorRect;
  final ui.Size overlaySize;
  final FocusScopeNode menuScopeNode;
  final Animation<double> animation;
  final List<Widget> children;
  final GlobalKey panelScrollableKey;
  final GestureDragUpdateCallback onPanUpdate;
  final void Function([DragEndDetails? details]) onPanEnd;
  final ScrollPhysics? scrollPhysics;
  final BoxConstraints? constraints;
  final Clip clipBehavior;
  final ui.Offset alignmentOffset;
  final AlignmentGeometry? anchorAlignment;
  final AlignmentGeometry? menuAlignment;
  final Animation<double> panAnimation;
  final Object? tapRegionGroupId;
  final CupertinoMenuSurfaceBuilder surfaceBuilder;

  @override
  Widget build(BuildContext context) {
    Widget child = surfaceBuilder(
      animation: animation,
      clipBehavior: clipBehavior,
      backgroundColor: backgroundColor,
      child: TapRegion(
        debugLabel: '$_MenuPanel Tap Region',
        groupId: tapRegionGroupId,
        consumeOutsideTaps: consumeOutsideTaps,
        onTapOutside: (PointerDownEvent event) {
          controller._anchor!._beginClose();
        },
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.deferToChild,
          child: Actions(
            actions: <Type, Action<Intent>>{
              DirectionalFocusIntent: MenuDirectionalFocusAction(),
              DismissIntent: DismissMenuAction(controller: controller),
            },
            child: Shortcuts(
              shortcuts: _kMenuTraversalShortcuts,
              child: FocusScope(
                debugLabel: '$_MenuPanel Focus Scope',
                node: menuScopeNode,
                skipTraversal: true,
                child: _MenuPanelScrollable(
                  key: panelScrollableKey,
                  physics: scrollPhysics,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (enablePan) {
      child = _PanRegion<_PanTarget<StatefulWidget>>(
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onPanCancel: onPanEnd,
        child: child,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints.loose(overlaySize),
      child: _MenuPanelLayout(
        constraints: constraints,
        anchorRect: anchorRect,
        overlaySize: overlaySize,
        menuAlignment: menuAlignment,
        anchorAlignment: anchorAlignment,
        anchorOffset: alignmentOffset,
        panAnimation: panAnimation,
        child: child,
      ),
    );
  }
}


/// Signature used by [CupertinoMenuButton] to lazily construct menu items shown
/// when a [_MenuPanelLayout] is constructed
///
/// Used by [CupertinoMenuButton.itemBuilder].
typedef CupertinoMenuItemBuilder = List<Widget> Function(BuildContext context);

/// A root menu layer that displays a list of [Widget] widgets
/// provided by the [child] parameter.
///
/// The [_MenuPanelLayout] is a [StatefulWidget] that manages the opening and
/// closing of nested [_MenuPanelLayout] layers.
///
/// The [_MenuPanelLayout] is typically created by a [CupertinoMenuButton], or by
/// calling [showCupertinoMenu].
///
/// An [animation] must be provided to drive the opening and closing of the
/// menu.
///
/// The [anchorPosition] parameter describes the position of the menu's anchor
/// relative to the screen. An [anchorOffset] can be provided to displace the menu
/// relative to its anchor. The [growthDirection] parameter can be used to specify
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
class _MenuPanelLayout extends StatelessWidget {
  /// Creates a [_MenuPanelLayout] that displays a list of [Widget]s
  const _MenuPanelLayout({
    required this.child,
    required this.constraints,
    required this.menuAlignment,
    required this.overlaySize,
    required this.anchorRect,
    required this.panAnimation,
    this.anchorAlignment,
    this.anchorOffset,
    EdgeInsets? edgeInsets,
  }) : _edgeInsets = edgeInsets ?? const EdgeInsets.all(defaultEdgeInsets);

  /// The menu items to display.
  final Widget child;

  /// The anchor rect relative to the menu overlay.
  final Rect anchorRect;

  /// The animation that drives the pan scale animation.
  final Animation<double> panAnimation;

  /// The alignment of the menu attachment point relative to the anchor button.
  final Offset? anchorOffset;

  /// The point on the anchor surface that should attach to
  /// the [menuAnchor]
  final AlignmentGeometry? anchorAlignment;

  /// The constraints to apply to the root menu layer.
  final BoxConstraints? constraints;

  /// The insets to avoid when positioning the menu.
  final EdgeInsets _edgeInsets;

  /// The insets to avoid when positioning the menu.
  final Size overlaySize;

  /// The point on the menu surface that should attach to
  /// the anchor point.
  final AlignmentGeometry? menuAlignment;

  /// The amount of padding between the menu and the screen edge.
  static const double defaultEdgeInsets = 8;

  Offset _resolveOffset(TextDirection direction) {
    if (direction == TextDirection.rtl && anchorAlignment is AlignmentDirectional) {
      return Offset(-anchorOffset!.dx, anchorOffset!.dy);
    }

    return anchorOffset!;
  }

  @override
  Widget build(BuildContext context) {
    final ui.TextDirection direction = Directionality.of(context);
    final Offset resolvedAnchorOffset = _resolveOffset(direction);
    final Rect resolvedAnchorRect = anchorRect.shift(resolvedAnchorOffset);
    Alignment? resolvedAnchorAlignment = anchorAlignment?.resolve(direction);
    Alignment? resolvedMenuAlignment = menuAlignment?.resolve(direction);

    // The point on the menu surface that should appear to grow from. The growth
    // point will ignore any offset applied (in other words, anchorRect is used
    // instead of resolvedAnchorRect), so offset will not determine the
    // growth direction.
    final ui.Offset growthPoint = anchorRect.topLeft +
        (resolvedAnchorAlignment ?? Alignment.center).alongSize(anchorRect.size);

    // The alignment of the menu growth point relative to the screen. The
    // alignment has already been resolved for the text direction. This value is
    // used to determine the growth direction. If the menu anchor point is above
    // the center of the screen, the menu will grow downwards. Otherwise, it
    // will grow upwards.
    final Alignment menuToScreenAlignment = Alignment(
      (growthPoint.dx / overlaySize.width) * 2 - 1,
      (growthPoint.dy / overlaySize.height) * 2 - 1,
    );

    // The default alignment of the menu relative to the anchor point is 2.5%
    // above or below the anchor.
    resolvedMenuAlignment ??= menuToScreenAlignment.y > 0
                                ? const Alignment(0, 1.025)   // Grows up
                                : const Alignment(0, -1.025); // Grows down

    // The default alignment of the anchor attachment point relative to the menu.
    resolvedAnchorAlignment ??= menuToScreenAlignment.y > 0
                                  ? Alignment.topCenter       // Grows up
                                  : Alignment.bottomCenter;   // Grows down

    return ScaleTransition(
      scale: panAnimation,
      alignment: menuToScreenAlignment,
      child: Builder(builder: (BuildContext context) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        final double textScale = mediaQuery.textScaler.scale(1);
        final double width = textScale > 1.25 ? 350.0 : 250.0;
        final BoxConstraints resolvedConstraints = BoxConstraints(
          minWidth: constraints?.minWidth ?? width,
          maxWidth: constraints?.maxWidth ?? width,
          minHeight: constraints?.minHeight ?? 0.0,
          maxHeight: constraints?.maxHeight ?? double.infinity,
        );

        return CustomSingleChildLayout(
          delegate: _MenuLayout(
            anchorAlignment: resolvedAnchorAlignment!,
            menuAlignment: resolvedMenuAlignment!,
            anchorPosition: RelativeRect.fromSize(
              resolvedAnchorRect,
              overlaySize,
            ),
            textDirection: Directionality.of(context),
            edgeInsets: _edgeInsets,
            avoidBounds: DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet(),
          ),
          child: ConstrainedBox(
            constraints: resolvedConstraints,
            child: child,
          ),
        );
      }),
    );
  }
}

class _MenuSurface extends StatelessWidget {
  const _MenuSurface({
    required this.child,
    required this.animation,
    required this.backgroundColor,
    required this.clipBehavior,
  });

  final Widget child;
  final Animation<double> animation;
  final Clip clipBehavior;
  final Color backgroundColor;

  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(14));
  static final DecorationTween _decorationTween = DecorationTween(
    begin: const BoxDecoration(
        borderRadius: defaultBorderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0),
          ),
        ]),
    end: const BoxDecoration(
        borderRadius: defaultBorderRadius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.12),
            spreadRadius: 30,
            blurRadius: 50,
          ),
        ]),
  );

  //  Align is used instead of sizeTransition because sizeTransition uses
  //  ClipRect rather than ClipRRect.
  Align _alignTransitionBuilder(BuildContext context, Widget? child) {
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: animation.value,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      decoration: _decorationTween.animate(animation),
      child: ClipRRect(
        clipBehavior: clipBehavior,
        borderRadius: defaultBorderRadius,
        child: AnimatedBuilder(
          animation: animation,
          builder: _alignTransitionBuilder,
          child: _BlurredSurface(
            surfaceColor: backgroundColor,
            listenable: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
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
    required this.surfaceColor,
    required this.child,
  }) : super(listenable: listenable);

  static const Interval _surfaceDelay = Interval(0.55, 1.0);
  final Widget child;
  final Color surfaceColor;
  double get value =>
      ui.clampDouble((super.listenable as Animation<double>).value, 0.0, 1.0);
  static const double darkLumR = 0.45;
  static const double darkLumG = 0.8;
  static const double darkLumB = 0.16;
  static const double lightLumR = 0.26;
  static const double lightLumG = 0.4;
  static const double lightLumB = 0.17;

  /// A Color filter matrix that saturates and brightens.
  ///
  /// From https://docs.rainmeter.net/tips/colormatrix-guide/, but tuned
  /// to resemble the iOS 17 menu. Luminance values were altered to emphasize
  /// blues and greens.
  List<double> buildColorFilterMatrix({
    required double strength,
    required Brightness brightness,
  }) {
    double additive, saturation, lumR, lumG, lumB;
    if (brightness == Brightness.light) {
      saturation = strength * 1 + 1;
      additive = 0.0;
      lumR = lightLumR;
      lumG = lightLumG;
      lumB = lightLumB;
    } else {
      saturation = strength * 0.7 + 1;
      additive = 0.3;
      lumR = darkLumR;
      lumG = darkLumG;
      lumB = darkLumB;
    }
    final double sr = (1 - saturation) * lumR;
    final double sg = (1 - saturation) * lumG;
    final double sb = (1 - saturation) * lumB;
    return <double>[
      sr + saturation, sg             , sb             , 0.0, additive,
      sr             , sg + saturation, sb             , 0.0, additive,
      sr             , sg             , sb + saturation, 0.0, additive,
      0.0            , 0.0            , 0.0            , 1.0, 0.0     ,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final ui.Color resolved = CupertinoDynamicColor.maybeResolve(surfaceColor, context)
                                ?? surfaceColor;
    final ui.Color color = resolved.withOpacity(resolved.opacity * value);
    final double delayedValue = _surfaceDelay.transform(value);

    Widget surface = CustomPaint(
      willChange: value != 0 && value != 1,
      painter: _UnclippedColorPainter(color: color),
      child: child,
    );

    // If the color is not opaque, apply a blur filter to the surface.
    if (color.alpha != 0xFF) {
      ui.ImageFilter filter = ui.ImageFilter.blur(
        sigmaX: 30 * delayedValue,
        sigmaY: 30 * delayedValue,
      );

      if (!kIsWeb) {
        filter = ui.ImageFilter.compose(
          outer: filter,
          inner: ui.ColorFilter.matrix(
            buildColorFilterMatrix(
              strength: delayedValue,
              brightness: CupertinoTheme.maybeBrightnessOf(context) ?? Brightness.light,
            ),
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
//
// TODO(davidhicks980): Determine if using a custom painter for overflow
// painting is necessary.
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

class _MenuPanelScrollable extends StatefulWidget {
  const _MenuPanelScrollable({
    super.key,
    required this.children,
    this.physics,
  });

  final List<Widget> children;
  final ScrollPhysics? physics;

  @override
  State<_MenuPanelScrollable> createState() => _MenuPanelScrollableState();
}

class _MenuPanelScrollableState extends State<_MenuPanelScrollable> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget? _buildChild(BuildContext context, int index) {
    final Widget child = widget.children[index];
    if (child == widget.children.last) {
      return child;
    }

    if (child case CupertinoMenuEntryMixin(allowTrailingSeparator: false)) {
      return child;
    }

    if (widget.children[index + 1]
        case CupertinoMenuEntryMixin(allowLeadingSeparator: false)) {
      return child;
    }

    return CupertinoMenuDivider.wrapBottom(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      controller: _controller,
      thumbVisibility: false,
      child: CustomScrollView(
        clipBehavior: Clip.none,
        controller: _controller,
        physics: widget.physics,
        shrinkWrap: true,
        slivers: <Widget>[
          // A sliver is used because to accommodate a header widget in a future PR.
          SliverList(
            delegate: SliverChildBuilderDelegate(
              _buildChild,
              childCount: widget.children.length,
            ),
          )
        ],
      ),
    );
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

class _PanRegion<T extends _PanTarget<StatefulWidget>>
    extends SingleChildRenderObjectWidget {
  const _PanRegion({
    super.key,
    super.child,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
  });

  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragCancelCallback? onPanCancel;

  @override
  RenderPanningScale<T> createRenderObject(BuildContext context) {
    return RenderPanningScale<T>(
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      viewId: View.of(context).viewId,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPanningScale<T> renderObject,
  ) {
    renderObject
      ..onPanUpdate = onPanUpdate
      ..onPanEnd = onPanEnd
      ..onPanCancel = onPanCancel
      ..viewId = View.of(context).viewId;
  }
}

class RenderPanningScale<T extends _PanTarget<StatefulWidget>>
    extends RenderProxyBoxWithHitTestBehavior {
  RenderPanningScale({
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    required int viewId,
  })  : _viewId = viewId {
    _tap = PanGestureRecognizer()
      ..onUpdate = _handlePanUpdate
      ..onCancel = _handlePanCancel
      ..onEnd = _handlePanEnd;
  }

  final List<T> _enteredTargets = <T>[];
  Offset? _position;
  late PanGestureRecognizer _tap;
  GestureDragUpdateCallback? onPanUpdate;
  GestureDragEndCallback? onPanEnd;
  GestureDragCancelCallback? onPanCancel;

  /// The id of the view that should be hit tested.
  int get viewId => _viewId;
  int _viewId;
  set viewId(int value) {
    if (_viewId == value) {
      return;
    }

    _viewId = value;
    markNeedsDragUpdate();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    _position = _position! + details.delta;
    onPanUpdate?.call(details);
    markNeedsDragUpdate();
  }

  void _handlePanEnd(DragEndDetails details) {
    _leaveAllEntered(pointerUp: true);
    onPanEnd?.call(details);
    _position = null;
  }

  void _handlePanCancel() {
    _leaveAllEntered();
    onPanCancel?.call();
    _position = null;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _tap.addPointer(event);
      _position = event.position;
    }
  }

  @override
  void detach() {
    _tap.dispose();
    super.detach();
  }

  // This method is defined to match "mark" idiom (markNeedsLayout,
  // markNeedsPaint, etc.)
  void markNeedsDragUpdate() {
    _updateDrag();
  }

  void _updateDrag() {
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, _position!, _viewId);

    // Look for the RenderBoxes that corresponds to the hit target (the hit target
    // widgets build RenderMetaData boxes for us for this purpose).
    // Visit elements that were hit, starting from the frontmost element.
    final Iterator<HitTestEntry<HitTestTarget>> hitPath = result.path.iterator;
    List<T>? targets;
    while (hitPath.moveNext()) {
      final HitTestTarget target = hitPath.current.target;

      // If the [MetaData] that is hit contains a [PanTarget] in the same group,
      // then add it to the list of targets.
      if (target case RenderMetaData(:final T metaData)) {
        targets ??= <T>[]; // lazy init
        targets.add(metaData);
      }
    }

    bool listsMatch = false;
    if (targets != null &&
        targets.length >= _enteredTargets.length &&
        _enteredTargets.isNotEmpty) {
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

    // If no new targets, bail early.
    if (targets == null) {
      return;
    }

    // Enter new targets.
    for (final T? target in targets) {
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

// A layout delegate that positions the root menu relative to its anchor.
class _MenuLayout extends SingleChildLayoutDelegate {
  const _MenuLayout({
    required this.anchorPosition,
    required this.edgeInsets,
    required this.avoidBounds,
    required this.textDirection,
    required this.anchorAlignment,
    required this.menuAlignment,
  });

  // The text direction of the menu.
  final TextDirection textDirection;

  // The position of underlying anchor that the menu is attached to.
  final RelativeRect anchorPosition;

  // Padding obtained from calling [MediaQuery.paddingOf(context)].
  //
  // Used to prevent the menu from being obstructed by system UI.
  final EdgeInsets edgeInsets;

  // List of rectangles that the menu should not overlap. Unusable screen area.
  final Set<Rect> avoidBounds;

  // The alignment of the menu attachment point relative to the anchor button.
  final Alignment anchorAlignment;

  // The alignment of the menu attachment point relative to the menu itself.
  final Alignment menuAlignment;

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
    } else if (x + childSize.width > screen.right - screenPadding.right) {
      // Overflows right
      x = screen.right - childSize.width - screenPadding.right;
    }

    if (y < screen.top + screenPadding.top) {
      // Overflows top
      y = screenPadding.top;
    }

    // Overflows bottom
    if (y + childSize.height > screen.bottom - screenPadding.bottom) {
      y = screen.bottom - childSize.height - screenPadding.bottom;

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
    final Offset resolvedOffset =
      anchorAlignment.withinRect(anchorRect) - menuAlignment.alongSize(childSize);

    final Rect screen = _findClosestScreen(
      size,
      anchorRect.center,
      avoidBounds,
    );

    // If aligning the menu would cause the menu to overflow the screen, the x-value is
    // set to the edge of the screen to ensure the user-provided offset is
    // respected.
    final Offset position = _fitInsideScreen(
      screen,
      childSize,
      resolvedOffset,
      edgeInsets,
    );

    return position;
  }

  @override
  bool shouldRelayout(_MenuLayout oldDelegate) {
    return edgeInsets      != oldDelegate.edgeInsets      ||
           anchorPosition  != oldDelegate.anchorPosition  ||
           textDirection   != oldDelegate.textDirection   ||
           anchorAlignment != oldDelegate.anchorAlignment ||
           menuAlignment   != oldDelegate.menuAlignment   ||
           !setEquals(avoidBounds, oldDelegate.avoidBounds);
  }
}

/// ### Description
/// A button for use in a [CupertinoMenuAnchor] or on its own, that can be
/// activated by click or keyboard navigation.
///
/// ### Layout
/// A [CupertinoMenuItem] is unconstrained by default and will grow to fit the
/// size of its container. To constrain the size of a [CupertinoMenuItem], the
/// [constraints] parameter can be set. Constraints are applied **after**
/// [padding]. This means that padding will only affect the size of the menu
/// item if this item's minimum constraints are less than the sum of its
/// [padding] and the size of its contents.
///
/// The [leading] and [trailing] widgets will display before and after the
/// [child] widget, respectively. The [leadingWidth] and [trailingWidth]
/// parameters control the horizontal space that these widgets occupy. The
/// [leadingAlignment] and [trailingAlignment] parameters control the alignment
/// of the leading and trailing widgets within their respective spaces.
///
/// ### Input
/// In order to respond to user input, an [onPressed] callback must be provided.
/// If absent, the [enabled] property will be false and user input callbacks
/// ([onFocusChange], [onHover], and [onPressed]) will be ignored. The
/// [behavior] parameter can be used to control whether hit tests can be travel
/// behind the menu item, and the [mouseCursor] parameter can be used to change
/// the cursor that appears when the user hovers over the menu.
///
/// The [requestCloseOnActivate] parameter can be set to false to prevent the
/// menu from closing when the item is activated. By default, the menu will
/// close when the item is pressed.
///
/// The [requestFocusOnHover] parameter, when true, focuses the menu item when
/// hovered over.
///
/// The [panActivationDelay] parameter can be provided to synthetically activate
/// the menu item after a delay when the user pans over the menu item. By default,
/// the menu item will not activate when panned over.
///
/// ### Visuals
/// The [hoveredColor], [focusedColor], and [pressedColor] parameters can be
/// used to change the background color of the menu item when hovered, focused,
/// or pressed/panned, respectively. If these parameters are not set, the menu item
/// will use the [defaultPressedColor] at 5%, 7.5%, and default opacity,
/// respectively.
///
/// The [isDefaultAction] should be set to true if the menu item is the
/// suggested menu item for the action (for example, "Confirm"). When set, this
/// will bold the text of the menu item.
///
/// The [isDestructiveAction] parameter should be set to true if the menu item
/// will perform a destructive action, and will color the text of the menu item
/// [CupertinoColors.systemRed].
///
///
/// ### Shortcuts
/// {@macro flutter.material.MenuBar.shortcuts_note}
///
/// ```dart
///
///// Example (Padding ignored)
///
///              Left-to-right Menu Item
///Leading                            Trailing
///Alignment(-0.2, -0.2)              Alignment(0.6, 0.8)
///   ┌────|────────┬───────────────┬────────|────┐
///   │    |        │               │        |    │
///   │    ▼        │    Child      │        |    │
///   │---►Leading  │               │        |    │
///   │             ├───────────────┤        |    │
///   │             │               │        ▼    │
///   │             │   Subtitle    │------►Trail-│
///   │             │               │       ing   │
///   |─────────────|───────────────|─────────────|
///   ▲   Leading   ▲               ▲   Trailing  ▲
///        width                         width
///
///
///
///              Right-to-left Menu Item
///
///    Trailing                      Leading
///    Alignment(0.6, 0.8)           Alignment(-0.4, -0.2)
///   ┌────────|────┬───────────────┬────|────────┐
///   │        |    │               │    |        │
///   │        |    │    Child      │    ▼        │
///   │        |    │               │---►Leading  │
///   │        |    ├───────────────┤             │
///   │        ▼    │               │             │
///   │------►Trail-│   Subtitle    │             │
///   │       ing   │               │             │
///   |─────────────|───────────────|─────────────|
///   ▲   Trailing  ▲               ▲   Leading   ▲
///        width                         width
///```
/// See also:
/// * [CupertinoMenuAnchor], a Cupertino-style widget that shows a menu of
///   actions in a popup
/// * [CupertinoLargeMenuDivider], a Cupertino-style widget that draws a thick
///   horizontal line between menu items.
/// * [CupertinoMenuDivider], a Cupertino-style widget that draws a thin
///   horizontal line between menu items.
/// * [MenuAnchor], a widget that creates a region with a submenu and shows it
///   when requested.
/// * [MenuItemButton], a menu item with a Material Design style.
/// * [PlatformMenuBar], which creates a menu bar that is rendered by the host
///   platform instead of by Flutter (on macOS, for example).
/// * [ShortcutRegistry], a registry of shortcuts that apply for the entire
///   application.
/// * [VoidCallbackIntent], to define intents that will call a [VoidCallback]
///   and work with the [Actions] and [Shortcuts] system.
/// * [CallbackShortcuts] to define shortcuts that call a callback without
///   involving [Actions].
class CupertinoMenuItem extends StatelessWidget with CupertinoMenuEntryMixin {
  /// Creates a [CupertinoMenuItem]
  ///
  /// The [child] parameter is required and must not be null.
  const CupertinoMenuItem({
    super.key,
    required this.child,
    this.subtitle,
    this.leading,
    this.leadingWidth,
    this.leadingAlignment,
    this.trailing,
    this.trailingWidth,
    this.trailingAlignment,
    this.padding,
    this.constraints,
    this.focusNode,
    this.onHover,
    this.onFocusChange,
    this.onPressed,
    this.hoveredColor,
    this.focusedColor,
    this.pressedColor,
    this.mouseCursor,
    this.panActivationDelay,
    this.shortcut,
    this.behavior = HitTestBehavior.opaque,
    this.applyInsetScaling = true,
    this.requestCloseOnActivate = true,
    this.requestFocusOnHover = false,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });

  /// The widget displayed in the center of this button.
  ///
  /// Typically this is the button's label, using a [Text] widget.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The padding for the contents of this menu item.
  final EdgeInsetsGeometry? padding;

  /// The widget shown before the label. Typically a [CupertinoIcon].
  final Widget? leading;

  /// The widget shown after the label. Typically a [CupertinoIcon].
  final Widget? trailing;

  /// A widget displayed underneath the title. Typically a [Text] widget.
  ///
  /// If overriding the default [TextStyle.color] of the [subtitle] widget,
  /// [CupertinoDynamicColor.resolve] should be used to resolve the color
  /// against the ambient [CupertinoTheme]. [TextStyle.inherit] must also be set
  /// to false, otherwise the [TextStyle.color] parameter will be overidden by
  /// [TextStyle.foreground].
  final Widget? subtitle;

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this callback is null, then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onPressed;

  /// Called when a pointer enters or exits the button response area.
  ///
  /// The value passed to the callback is true if a pointer has entered button
  /// area and false if a pointer has exited.
  final ValueChanged<bool>? onHover;

  /// Determine if hovering can request focus.
  ///
  /// Defaults to false.
  final bool requestFocusOnHover;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// Delay between a user's pointer entering a menu item during a pan, and
  /// the menu item being tapped.
  ///
  /// Defaults to null, meaning the menu item will not activate when panned over.
  final Duration? panActivationDelay;

  /// The color of menu item when focused.
  ///
  /// If null, the [defaultPressedColor] will be applied at 0.075 opacity.
  final Color? focusedColor;

  /// The color of menu item while the menu item is panned or pressed.
  ///
  /// If null, the [defaultPressedColor] will be applied.
  final Color? pressedColor;

  /// The color of menu item when hovered by the user's pointer.
  ///
  /// If null, the [defaultPressedColor] will be applied at 0.05 opacity.
  final Color? hoveredColor;

  /// The mouse cursor to display on hover.
  final MouseCursor? mouseCursor;

  /// How the menu item should respond to hit tests.
  final HitTestBehavior behavior;

  /// {@macro flutter.material.menu_anchor.closeOnActivate}
  final bool requestCloseOnActivate;

  /// Whether pressing this item will perform a destructive action
  ///
  /// Defaults to `false`. If `true`, [CupertinoColors.destructiveRed] will be
  /// applied to this item's label and icon.
  final bool isDestructiveAction;

  /// Whether pressing this item performs the suggested or most commonly used action.
  ///
  /// Defaults to `false`. If `true`, [FontWeight.w600] will be
  /// applied to this item's label.
  final bool isDefaultAction;

  /// The width of the leading portion of the menu item.
  final double? leadingWidth;

  /// The width of the trailing portion of the menu item.
  final double? trailingWidth;

  /// The alignment of the leading widget within the leading portion of the menu
  /// item.
  final AlignmentGeometry? leadingAlignment;

  /// The alignment of the trailing widget within the trailing portion of the
  /// menu item.
  final AlignmentGeometry? trailingAlignment;

  /// Whether the insets of the menu item should scale with the
  /// [MediaQuery.textScalerOf].
  ///
  /// Defaults to `true`.
  final bool applyInsetScaling;

  /// The optional shortcut that selects this [CupertinoMenuItem].
  ///
  /// {@macro flutter.material.MenuBar.shortcuts_note}
  final MenuSerializableShortcut? shortcut;

  /// Whether the menu item will respond to user input.
  bool get enabled => onPressed != null;

  @override
  bool get hasLeading => leading != null;

  /// The constraints to apply to the menu item.
  ///
  /// Because padding is applied to the menu item prior to constraints, padding
  /// will only affect the size of the menu item iff the height of the padding
  /// plus the height of the menu item's children exceeds the
  /// [BoxConstraints.minHeight].
  ///
  /// By default, the only constraint applied to the menu item is a
  /// [BoxConstraints.minHeight] of [kMinInteractiveDimensionCupertino].
  final BoxConstraints? constraints;

  static const TextStyle defaultTitleStyle = TextStyle(
    height: 1.25,
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: <String>['.AppleSystemUIFont'],
    fontSize: 17,
    letterSpacing: -0.41,
    textBaseline: TextBaseline.ideographic,
    overflow: TextOverflow.ellipsis,
    color: CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(0, 0, 0, 0.96),
      darkColor: Color.fromRGBO(255, 255, 255, 0.96),
    ),
  );

  static const TextStyle defaultSubtitleStyle = TextStyle(
    height: 1.25,
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: <String>['.AppleSystemUIFont'],
    fontSize: 15,
    letterSpacing: -0.21,
    textBaseline: TextBaseline.ideographic,
    overflow: TextOverflow.ellipsis,
    color: CupertinoDynamicColor.withBrightnessAndContrast(
      color: Color.fromRGBO(0, 0, 0, 0.4),
      darkColor: Color.fromRGBO(255, 255, 255, 0.4),
      highContrastColor: Color.fromRGBO(0, 0, 0, 0.8),
      darkHighContrastColor: Color.fromRGBO(255, 255, 255, 0.8),
    ),
  );

  /// The color of a [_CupertinoInteractiveMenuItem] when pressed.
  // Pressed colors were sampled from the iOS simulator and are based on the
  // following:
  //
  // Dark mode on white background     rgb(111, 111, 111)
  // Dark mode on black                rgb(61, 61, 61)
  // Light mode on black               rgb(177, 177, 177)
  // Light mode on white               rgb(225, 225, 225)
  static const CupertinoDynamicColor defaultPressedColor =
      CupertinoDynamicColor.withBrightnessAndContrast(
          color: Color.fromRGBO(50, 50, 50, 0.1),
          darkColor: Color.fromRGBO(255, 255, 255, 0.1),
          highContrastColor: Color.fromRGBO(50, 50, 50, 0.2),
          darkHighContrastColor: Color.fromRGBO(255, 255, 255, 0.2),
        );

  /// Resolves the title [TextStyle] in response to [CupertinoThemeData.brightness],
  ///  [isDefaultAction], [isDestructiveAction], and [enabled].
  //
  // Eyeballed from the iOS simulator.
  TextStyle _resolveTitleStyle(BuildContext context) {
    final Color color;
    if (!enabled) {
      color = CupertinoColors.systemGrey;
    } else if (isDestructiveAction) {
      color = CupertinoColors.systemRed;
    } else {
      color = defaultTitleStyle.color!;
    }

    return defaultTitleStyle.copyWith(
      color: CupertinoDynamicColor.maybeResolve(color, context) ?? color,
      fontWeight: isDefaultAction ? FontWeight.bold : FontWeight.normal,
    );
  }

  /// Handles user selection of the menu item.
  ///
  /// To prevent redundant presses, selection is blocked if the menu has already
  /// started closing.
  ///
  /// If [requestCloseOnActivate] is true, this method is responsible for notifying the
  /// [CupertinoMenuAnchor] that the menu should begin closing.
  void _handleSelect(BuildContext context) {
    assert(_debugMenuInfo('Selected $child menu'));
    final _CupertinoMenuAnchorState? anchor = CupertinoMenuAnchor._maybeOf(context);

    // If the menu is already closing or closed, then block selection and
    // return early.
    if (anchor?._menuStatus case MenuStatus.closing || MenuStatus.closed) {
      return;
    }

    if (requestCloseOnActivate) {
      anchor?._beginClose();
    }

    // Delay the call to onPressed until post-frame so that the focus is
    // restored to what it was before the menu was opened before the action is
    // executed.
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      FocusManager.instance.applyFocusChangesIfNeeded();
      onPressed?.call();
    }, debugLabel: '$CupertinoMenuItem.onPressed');
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle titleTextStyle = _resolveTitleStyle(context);
    final double textScale =
        (MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling).scale(1);
    Widget? subtitleWidget = subtitle;
    if (subtitleWidget != null) {
      final bool isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
      final Paint subtitlePainter = Paint()
        ..blendMode = isDark ? BlendMode.plus
                             : BlendMode.hardLight
        ..color = CupertinoDynamicColor.maybeResolve(
                  defaultSubtitleStyle.color,
                    context,
                  ) ?? defaultSubtitleStyle.color!;
      subtitleWidget = DefaultTextStyle.merge(
        style: defaultSubtitleStyle.copyWith(foreground: subtitlePainter),
        child: _AnimatedTitleSwitcher(
          child: subtitleWidget,
        ),
      );
    }

    Widget label = _CupertinoMenuItemLabel(
      padding: padding,
      constraints: constraints,
      trailing: textScale <= 1.25 ? trailing : null,
      leading: leading,
      subtitle: subtitleWidget,
      leadingAlignment: leadingAlignment,
      trailingAlignment: trailingAlignment,
      leadingWidth: leadingWidth,
      trailingWidth: trailingWidth,
      applyInsetScaling: applyInsetScaling,
      shortcut: shortcut,
      child: DefaultTextStyle.merge(
        style: titleTextStyle,
        child: _AnimatedTitleSwitcher(
          child: child,
        ),
      ),
    );

    if (leading != null || trailing != null) {
      label = IconTheme.merge(
        data: IconThemeData(
          size: math.sqrt(textScale) * 21,
          color: titleTextStyle.color,
        ),
        child: label,
      );
    }

     if (_platformSupportsAccelerators && enabled) {
      label = MenuAcceleratorCallbackBinding(
        onInvoke: () => _handleSelect(context),
        child: label,
      );
    }


    final Color pressedColor = this.pressedColor ?? defaultPressedColor;
    return MergeSemantics(
      child: Semantics(
        enabled: onPressed != null,
        child: CupertinoMenuItemGestureHandler(
          mouseCursor: mouseCursor,
          panActivationDelay: panActivationDelay,
          requestFocusOnHover: requestFocusOnHover,
          onPressed: onPressed != null ? () => _handleSelect(context) : null,
          onHover: onHover,
          onFocusChange: onFocusChange,
          focusNode: focusNode,
          focusNodeDebugLabel: child.toString(),
          pressedColor: CupertinoDynamicColor.maybeResolve(pressedColor, context)
                          ?? pressedColor,
          focusedColor: CupertinoDynamicColor.maybeResolve(focusedColor, context)
                          ?? focusedColor,
          hoveredColor: CupertinoDynamicColor.maybeResolve(hoveredColor, context)
                          ?? hoveredColor,
          behavior: behavior,
          child: DefaultTextStyle.merge(
            // The maximum number of lines appears to be infinite on the iOS
            // simulator, so just use a large number. This will apply to all
            // descendents with maxLines = null.
            maxLines: textScale > 1.25 ? 100 : 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: titleTextStyle,
            child: label,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HitTestBehavior>('hitTestBehavior', behavior));
    properties.add(DiagnosticsProperty<Duration>(
        'panActivationDelay', panActivationDelay,
        defaultValue: Duration.zero));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode,
        defaultValue: null));
    properties.add(
        FlagProperty('enabled', value: onPressed != null, ifFalse: 'DISABLED'));
    properties.add(DiagnosticsProperty<Widget?>('title', child));
    properties.add(DiagnosticsProperty<Widget?>('subtitle', subtitle));
    properties.add(
        DiagnosticsProperty<Widget?>('leading', leading, defaultValue: null));
    properties.add(
        DiagnosticsProperty<Widget?>('trailing', trailing, defaultValue: null));
  }
}

class _AnimatedTitleSwitcher extends StatelessWidget {
  const _AnimatedTitleSwitcher({required this.child});
  final Widget child;

  static Widget _layoutBuilder(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: AlignmentDirectional.centerStart,
      children: <Widget>[
        for (final Widget child in previousChildren)
          SizedOverflowBox(
            size: Size.zero,
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
        if (currentChild != null)
          AnimatedSize(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.centerStart,
            curve: const Cubic(0.33, 0.2, 0.16, 1.04),
            duration: const Duration(milliseconds: 400),
            child: currentChild,
          )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      reverseDuration: const Duration(milliseconds: 200),
      duration: const Duration(milliseconds: 200),
      layoutBuilder: _layoutBuilder,
      child: child,
    );
  }
}

/// A label widget that is used as the label for a [CupertinoMenuItem].
///
/// It not only shows the [CupertinoMenuItem.child], but if
/// there is a shortcut associated with the [CupertinoMenuItem], it will display a
/// mnemonic for the shortcut.
class _CupertinoMenuItemLabel extends StatelessWidget
    with CupertinoMenuEntryMixin {

  /// Creates a [_CupertinoMenuItemLabel]
  const _CupertinoMenuItemLabel({
    required this.child,
    this.leading,
    this.trailing,
    this.subtitle,
    this.shortcut,
    this.applyInsetScaling = true,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? padding,
    AlignmentGeometry? leadingAlignment,
    AlignmentGeometry? trailingAlignment,
    double? leadingWidth,
    double? trailingWidth,
  })  : _padding = padding,
        _leadingAlignment = leadingAlignment ?? defaultLeadingAlignment,
        _trailingAlignment = trailingAlignment ?? defaultTrailingAlignment,
        _trailingWidth = trailingWidth,
        _leadingWidth = leadingWidth,
        _constraints = constraints;

  static const EdgeInsetsDirectional defaultPadding =
      EdgeInsetsDirectional.symmetric(vertical: 11.5);
  static const double defaultHorizontalWidth = 16;
  static const double leadingWidgetWidth = 32.0;
  static const double trailingWidgetWidth = 44.0;
  static const AlignmentDirectional defaultLeadingAlignment =
      AlignmentDirectional(1 / 6, 0);
  static const AlignmentDirectional defaultTrailingAlignment =
      AlignmentDirectional(-3 / 11, 0);
  static const BoxConstraints defaultConstraints = BoxConstraints(
    minHeight: kMinInteractiveDimensionCupertino,
  );

  // The padding for the contents of the menu item.
  //
  // If null, defaults to [defaultPadding].
  final EdgeInsetsGeometry? _padding;

  // The widget shown before the title. Typically a [CupertinoIcon].
  final Widget? leading;

  // The widget shown after the title. Typically a [CupertinoIcon].
  final Widget? trailing;

  // The width of the leading portion of the menu item.
  //
  // If null, [leadingWidgetWidth] is used when this menu item or a sibling menu
  // item has a leading widget, and [defaultHorizontalWidth] is used otherwise.
  final double? _leadingWidth;

  // The width of the trailing portion of the menu item.
  //
  // Defaults to [trailingWidgetWidth] when this menu item has a trailing
  // widget, and [defaultHorizontalWidth] otherwise.
  final double? _trailingWidth;

  // The alignment of the leading widget within the leading portion of the menu
  // item.
  //
  // Defaults to [defaultLeadingAlignment] when null.
  final AlignmentGeometry _leadingAlignment;

  // The alignment of the trailing widget within the trailing portion of the
  // menu item.
  //
  // Defaults to [defaultTrailingAlignment].
  final AlignmentGeometry _trailingAlignment;

  // The constraints applied to this menu item.
  //
  // If null, [defaultConstraints] is used.
  final BoxConstraints? _constraints;

  // The top center content of the menu item. Typically a [Text] widget.
  final Widget child;

  // The bottom center content of the menu item. Typically a [Text] widget.
  final Widget? subtitle;

  // Whether the insets of the menu item should scale with the
  // [MediaQuery.textScalerOf].
  final bool applyInsetScaling;

  /// The shortcut for this label, so that it can generate a string describing
  /// the shortcut.
  final MenuSerializableShortcut? shortcut;

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.maybeTextScalerOf(context)?.scale(1) ?? 1.0;
    final double pixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
    final double physicalPixel = 1 / pixelRatio;
    final bool showLeadingWidget = leading != null || (CupertinoMenuAnchor
                                                        ._maybeOf(context)
                                                        ?._hasLeadingWidget ?? false);
    double trailingWidth = _trailingWidth
                            ?? (trailing != null
                                  ? trailingWidgetWidth
                                  : defaultHorizontalWidth);
    double leadingWidth = _leadingWidth
                            ?? (showLeadingWidget
                                  ? leadingWidgetWidth
                                  : defaultHorizontalWidth);
    // Subtract a physical pixel from the default padding if no padding is
    // specified by the user. (iOS 17.2 simulator debug view)
    EdgeInsetsGeometry padding = _padding
            ?? defaultPadding.copyWith(
                 top:    math.max(defaultPadding.top - physicalPixel / 2, 0),
                 bottom: math.max(defaultPadding.bottom - physicalPixel / 2, 0),
               );
    BoxConstraints constraints = _constraints
                    ?? defaultConstraints.copyWith(
                        minHeight: defaultConstraints.minHeight - physicalPixel
                      );

    if (applyInsetScaling && textScale != 1.0) {
      // Padding scales with textScale, but at a slower rate than text. Square
      // root is used to estimate the padding scaling factor.
      final double paddingScaler = math.sqrt(textScale);
      padding       *= paddingScaler;
      constraints   *= paddingScaler;
      leadingWidth  *= paddingScaler;
      trailingWidth *= paddingScaler;
    }

    return ConstrainedBox(
      constraints: constraints,
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            // The leading and trailing widgets are wrapped in SizedBoxes and
            // then aligned, rather than just padded, because the alignment
            // behavior of the SizedBoxes appears to be more consistent with
            // AutoLayout (iOS).
            SizedBox(
              width: leadingWidth,
              child: showLeadingWidget
                  ? Align(alignment: _leadingAlignment, child: leading)
                  : null,
            ),
            Expanded(
              child: subtitle == null
                  ? child
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        child,
                        const SizedBox(height: 1),
                        subtitle!,
                      ],
                    ),
            ),
            if (shortcut != null)
              Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Text(
                    LocalizedShortcutLabeler.instance.getShortcutLabel(
                      shortcut!,
                      MaterialLocalizations.of(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: CupertinoColors.secondaryLabel,
                    )
                  )
              ),
            SizedBox(
              width: trailingWidth,
              child: trailing != null
                  ? Align(alignment: _trailingAlignment, child: trailing)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// A [CupertinoMenuEntryMixin] that inserts a large horizontal divider.
///
/// The divider has a height of 8 logical pixels. A [color] parameter can be
/// provided to customize the color of the divider.
///
/// See also:
///
/// * [CupertinoMenuItem], a Cupertino menu item.
/// * [CupertinoMenuDivider], a thin horizontal divider.
/// * [CupertinoMenuAnchor], a widget that creates a Cupertino-style popup menu.
@immutable
class CupertinoLargeMenuDivider extends StatelessWidget
    with CupertinoMenuEntryMixin {
  /// Creates a large horizontal divider for a [_CupertinoMenuPanel].
  const CupertinoLargeMenuDivider({
    super.key,
    this.color = _color,
  });

  /// Color for a transparent [CupertinoLargeMenuDivider].
  // The following colors were measured from debug mode on the iOS simulator,
  static const CupertinoDynamicColor _color =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    darkColor: Color.fromRGBO(0, 0, 0, 0.16),
  );

  /// The color of the divider.
  ///
  /// If this property is null, [CupertinoLargeMenuDivider._color] is
  /// used.
  final Color color;

  @override
  bool get allowTrailingSeparator => false;

  @override
  bool get allowLeadingSeparator => false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: CupertinoDynamicColor.resolve(color, context),
    );
  }
}

/// A horizontal divider used to separate [CupertinoMenuItem]s
///
/// The default width of the divider is 1 physical pixel, Unlike a [Border],
/// the [thickness] of the divider does occupy layout space.
@immutable
class CupertinoMenuDivider extends StatelessWidget {
  /// Creates a [CupertinoMenuDivider] with a default width of 1 physical pixel.
  const CupertinoMenuDivider({
    super.key,
    this.color = baseColor,
    this.tint = tintColor,
    this.thickness,
  })  : _child = null,
        _alignmentStart = AlignmentDirectional.centerStart,
        _alignmentEnd = AlignmentDirectional.centerEnd;

  /// Creates a [CupertinoMenuDivider] with a default width of 1 physical pixel
  /// that is drawn above [child].
  const CupertinoMenuDivider.wrapTop({
    super.key,
    this.color = baseColor,
    this.tint = tintColor,
    this.thickness,
    required Widget child,
  })  : _child = child,
        _alignmentStart = AlignmentDirectional.topStart,
        _alignmentEnd = AlignmentDirectional.topEnd;

  /// Creates a [CupertinoMenuDivider] with a default width of 1 physical pixel
  /// that is drawn below [child].
  const CupertinoMenuDivider.wrapBottom({
    super.key,
    this.color = baseColor,
    this.tint = tintColor,
    this.thickness,
    required Widget child,
  })  : _child = child,
        _alignmentStart = AlignmentDirectional.bottomStart,
        _alignmentEnd = AlignmentDirectional.bottomEnd;

  /// Default transparent color for [CupertinoMenuDivider] and
  /// [CupertinoVerticalMenuDivider].
  ///
  // The following colors were measured from the iOS simulator, and opacity was
  // extrapolated:
  // Dark mode on black       Color.fromRGBO(97, 97, 97)
  // Dark mode on white       Color.fromRGBO(132, 132, 132)
  // Light mode on black      Color.fromRGBO(147, 147, 147)
  // Light mode on white      Color.fromRGBO(187, 187, 187)
  static const CupertinoDynamicColor baseColor =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(140, 140, 140, 0.5),
    darkColor: Color.fromRGBO(255, 255, 255, 0.25),
  );
  static const CupertinoDynamicColor tintColor =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.24),
    darkColor: Color.fromRGBO(255, 255, 255, 0.23),
  );

  /// The color of divider.
  ///
  /// Defaults to [CupertinoMenuDivider.baseColor].
  final CupertinoDynamicColor color;

  /// The color of divider.
  ///
  /// Defaults to [CupertinoMenuDivider.tintColor].
  final CupertinoDynamicColor tint;

  /// The thickness of the divider.
  ///
  /// If null, the default divider thickness is 1 physical pixel.
  final double? thickness;

  /// The widget below this widget in the tree.
  final Widget? _child;

  /// The relative start point of the divider's path.
  final AlignmentDirectional _alignmentStart;

  /// The relative end point of the divider's path.
  final AlignmentDirectional _alignmentEnd;

  @override
  Widget build(BuildContext context) {
    final double pixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    final double displacement = thickness ?? (1 / pixelRatio);
    final TextDirection textDirection = Directionality.of(context);
    final Alignment begin = _alignmentStart.resolve(textDirection);
    final Alignment end = _alignmentEnd.resolve(textDirection);
    assert(
      begin.y == end.y && begin.y.roundToDouble() == begin.y,
      'CupertinoMenuDivider must either inhabit the top, bottom, or center of its parent. ',
    );
    return CustomPaint(
      painter: _AliasedBorderPainter(
        begin: begin,
        end: end,
        tint: CupertinoDynamicColor.maybeResolve(tint, context) ?? tint,
        color: CupertinoDynamicColor.maybeResolve(color, context) ?? color,
        offset: Offset(0, -displacement / 2) * begin.y,
        border: BorderSide(width: thickness ?? 0.0),
        antiAlias: pixelRatio < 1.0,
      ),
      size: _child == null ? Size(double.infinity, displacement) : Size.zero,
      child: _child != null
          ? Padding(
              padding: EdgeInsets.only(
                top: begin.y == -1 ? displacement : 0.0,
                bottom: begin.y == 1 ? displacement : 0.0,
              ),
              child: _child,
            )
          : null,
    );
  }
}

// A custom painter that draws a border without antialiasing.
class _AliasedBorderPainter extends CustomPainter {
  const _AliasedBorderPainter({
    required this.border,
    required this.tint,
    required this.color,
    required this.begin,
    required this.end,
    this.offset = Offset.zero,
    this.antiAlias = false,
  });

  final BorderSide border;
  final Color tint;
  final Color color;
  final Alignment begin;
  final Alignment end;
  final Offset offset;
  final bool antiAlias;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset p1 = begin.alongSize(size) + offset;
    final Offset p2 = end.alongSize(size) + offset;
    if (!kIsWeb) {
      final Paint basePainter = border.toPaint()
        ..color = color
        ..isAntiAlias = antiAlias
        ..blendMode = BlendMode.overlay;
      canvas.drawLine(p1, p2, basePainter);
    }

    final Paint tintPainter = border.toPaint()
      ..color = tint
      ..isAntiAlias = antiAlias;

    canvas.drawLine(p1, p2, tintPainter);
  }

  @override
  bool shouldRepaint(_AliasedBorderPainter oldDelegate) {
    return tint != oldDelegate.tint ||
        color != oldDelegate.color ||
        end != oldDelegate.end ||
        begin != oldDelegate.begin ||
        border != oldDelegate.border ||
        offset != oldDelegate.offset ||
        antiAlias != oldDelegate.antiAlias;
  }
}

/// A gesture handler for [CupertinoMenuItem]s that responds to  taps, pans, and
/// long presses.
///
/// The [onPressed] callback is called when the user taps the menu item, pans over
/// the menu item and lifts their finger, or when the user long-presses a menu
/// item that has a non-null [panActivationDelay]. If provided, the [pressedColor]
/// will highlight the menu item whenever a pointer is in contact with the menu
/// item. If [onPressed] is null, the menu item will be disabled and will not
/// respond to user input.
///
/// A [mouseCursor] can be provided to change the cursor that appears when a
/// mouse hovers over the menu item. If [mouseCursor] is null, the
/// [SystemMouseCursors.click] cursor is used. A [hoveredColor] can be provided
/// to change the color of the menu item when a mouse hovers over the menu item.
///
/// If [focusNode] is provided, the menu item will be focusable. When the menu
/// item is focused, the [focusedColor] will be used to highlight the menu item.
class CupertinoMenuItemGestureHandler extends StatefulWidget {
  /// Creates a [CupertinoMenuItemGestureHandler].
  ///
  /// The [child] and [pressedColor] arguments are required and must not be null.
  const CupertinoMenuItemGestureHandler({
    super.key,
    required this.child,
    required this.pressedColor,
    this.mouseCursor,
    this.focusedColor,
    this.focusNode,
    this.hoveredColor,
    this.panActivationDelay,
    this.onPressed,
    this.onHover,
    this.onFocusChange,
    this.shortcut,
    this.focusNodeDebugLabel,
    this.requestFocusOnHover = false,
    this.behavior = HitTestBehavior.opaque,
  });

  /// The widget displayed in the center of this button.
  ///
  /// Typically this is the button's label, using a [Text] widget.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// Called when the button is tapped or otherwise activated.
  ///
  /// If this callback is null, then the button will be disabled.
  ///
  /// See also:
  ///
  ///  * [enabled], which is true if the button is enabled.
  final VoidCallback? onPressed;

  /// Called when a pointer enters or exits the button response area.
  ///
  /// The value passed to the callback is true if a pointer has entered button
  /// area and false if a pointer has exited.
  final ValueChanged<bool>? onHover;

  /// Determine if hovering can request focus.
  ///
  /// Defaults to `false`.
  final bool requestFocusOnHover;

  /// Handler called when the focus changes.
  ///
  /// Called with true if this widget's node gains focus, and false if it loses
  /// focus.
  final ValueChanged<bool>? onFocusChange;

  /// {@macro flutter.widgets.Focus.focusNode}
  final FocusNode? focusNode;

  /// The optional shortcut that selects this [CupertinoMenuItemGestureHandler].
  ///
  /// {@macro flutter.material.MenuBar.shortcuts_note}
  final MenuSerializableShortcut? shortcut;

  /// Delay between a user's pointer entering a menu item during a pan, and
  /// the menu item being tapped.
  ///
  /// If null, the menu item will not be pressed when panned over.
  final Duration? panActivationDelay;

  /// The color of menu item when focused.
  final Color? focusedColor;

  /// The color of menu item when hovered by the user's pointer.
  final Color? hoveredColor;

  /// The color of menu item while the menu item is swiped or pressed down.
  final Color? pressedColor;

  /// The mouse cursor to display on hover.
  final MouseCursor? mouseCursor;

  /// How the menu item should respond to hit tests.
  ///
  /// Defaults to [HitTestBehavior.opaque].
  final HitTestBehavior behavior;

  /// A debug label that is used to identify the focus node.
  final String? focusNodeDebugLabel;

  /// Whether the menu item will respond to user input.
  bool get enabled => onPressed != null;

  @override
  State<CupertinoMenuItemGestureHandler> createState() =>
      _CupertinoMenuItemGestureHandlerState();
}

class _CupertinoMenuItemGestureHandlerState
    extends State<CupertinoMenuItemGestureHandler>
    with _PanTarget<CupertinoMenuItemGestureHandler> {
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _simulateTap),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: _simulateTap),
  };

  Timer? _longPanPressTimer;
  bool _isFocused = false;
  bool _isSwiped = false;
  bool _isPressed = false;
  bool _isHovered = false;

  // If a focus node isn't given to the widget, then we have to manage our own.
  FocusNode? _internalFocusNode;
  FocusNode? get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _createInternalFocusNode();
    }
    _focusNode?.addListener(_handleFocusChange);
  }

  @override
  bool didPanEnter() {
    if (!widget.enabled) {
      return false;
    }

    if (widget.panActivationDelay != null) {
      _longPanPressTimer = Timer(widget.panActivationDelay!, () {
        if (mounted) {
          _handleTap();
        }

        _longPanPressTimer = null;
      });
    }

    if (!_isSwiped) {
      setState(() {
        _isSwiped = true;
      });
    }
    return true;
  }

  @override
  void didPanLeave({required bool pointerUp}) {
    _longPanPressTimer?.cancel();
    _longPanPressTimer = null;
    if (mounted) {
      if (pointerUp) {
        _simulateTap();
      } else if (_isSwiped || _isPressed) {
        setState(() {
          _isSwiped = false;
          _isPressed = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(CupertinoMenuItemGestureHandler oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _internalFocusNode)
          ?.removeListener(_handleFocusChange);
      if (widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      } else {
        _createInternalFocusNode();
      }
      _focusNode!.addListener(_handleFocusChange);
    }

    if (oldWidget.enabled && !widget.enabled) {
      _isHovered = false;
      _isPressed = false;
      _isSwiped = false;
      _handleFocusChange(false);
    }
  }

  @override
  void dispose() {
    _longPanPressTimer?.cancel();
    _focusNode?.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    _internalFocusNode = null;
    super.dispose();
  }

  void _handleFocusChange([bool? focused]) {
    if (_focusNode?.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode?.hasFocus ?? focused ?? false;
      });

      widget.onFocusChange?.call(_isFocused);
    }
  }

  void _handleHover(PointerEvent event) {
    final bool hovered = event is PointerEnterEvent;
    if (!widget.enabled) {
      if (_isHovered) {
        setState(() {
          _isHovered = false;
        });
      }
      return;
    }

    if (hovered != _isHovered) {
      widget.onHover?.call(hovered);
      if (hovered && widget.requestFocusOnHover) {
        assert(_debugMenuInfo('Requesting focus for $_focusNode from hover'));
        _focusNode?.requestFocus();
      }

      setState(() {
        _isHovered = hovered;
      });
    }
  }

  void _simulateTap([Intent? intent]) {
    if (widget.enabled) {
      _handleTap();
    }
  }

  void _handleTap() {
    if (widget.enabled) {
      widget.onPressed?.call();
      setState(() {
        _isPressed = false;
        _isSwiped = false;
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled && !_isPressed) {
      setState(() {
        _isPressed = true;
        _isSwiped = true;
      });
    }
  }

  void _handleTapCancel() {
    if (_isPressed || _isSwiped) {
      setState(() {
        _isPressed = false;
        _isSwiped = false;
      });
    }
  }

  void _createInternalFocusNode() {
    _internalFocusNode = FocusNode();
    assert(() {
      _internalFocusNode!.debugLabel =
          '$CupertinoMenuItem(${widget.focusNodeDebugLabel})';
      return true;
    }());
  }

  Color? get backgroundColor {
    if (widget.enabled) {
      if (_isPressed || _isSwiped) {
        return widget.pressedColor;
      }

      if (_isFocused) {
        return widget.focusedColor ?? widget.pressedColor?.withOpacity(0.075);
      }

      if (_isHovered) {
        return widget.hoveredColor ?? widget.pressedColor?.withOpacity(0.05);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget? child = widget.child;
    final Color? backgroundColor = this.backgroundColor;
    if (backgroundColor != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          backgroundBlendMode:
              CupertinoTheme.maybeBrightnessOf(context) == Brightness.light
                  ? BlendMode.multiply
                  : BlendMode.plus,
          color: backgroundColor,
        ),
        child: child,
      );
    }

    return MetaData(
      metaData: this,
      child: MouseRegion(
        onEnter: _handleHover,
        onExit: _handleHover,
        hitTestBehavior: HitTestBehavior.deferToChild,
        cursor: widget.enabled
            ? widget.mouseCursor ?? SystemMouseCursors.click
            : MouseCursor.defer,
        child: Actions(
          actions: _actionMap,
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: widget.enabled,
            skipTraversal: !widget.enabled,
            onFocusChange: _handleFocusChange,
            child: GestureDetector(
              behavior: widget.behavior,
              onTap: _handleTap,
              onTapDown: _handleTapDown,
              onTapCancel: _handleTapCancel,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Can be mixed into a [State] to receive callbacks when a pointer enters or
/// leaves a [_PanTarget]. The [_PanTarget] is should be an ancestor of a
/// [CupertinoPanListener].
mixin _PanTarget<T extends StatefulWidget> on State<T> {
  /// Called when a pointer enters the [_PanTarget]. Return true if the pointer
  /// should be considered "on" the [_PanTarget], and false otherwise (for
  /// example, when the [_PanTarget] is disabled).
  bool didPanEnter();

  /// Called when the pointer leaves the [_PanTarget]. If [pointerUp] is true,
  /// then the pointer left the screen while over this menu item.
  void didPanLeave({required bool pointerUp});
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
