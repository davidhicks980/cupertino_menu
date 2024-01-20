// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart' show CupertinoButton, CupertinoDynamicColor, CupertinoIcons, CupertinoScrollbar, CupertinoTheme;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show Colors, MenuStyle;
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




const Duration _kMenuPanReboundDuration = Duration(milliseconds: 600);
const  bool _kDebugMenus = false;

const Map<ShortcutActivator, Intent> _kMenuTraversalShortcuts = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
  SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
  SingleActivator(LogicalKeyboardKey.tab, shift: true): PreviousFocusIntent(),
  SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
  SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
  SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
  SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
};

/// Mix [CupertinoMenuEntryMixin] in to access information about the
/// [CupertinoMenu] layer that contains this menu item.
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
    return CupertinoMenuAnchor._maybeOf(context)?._hasLeadingWidget ?? true;
  }

  /// The [AnimationStatus] of the animation that reveals this menu layer.
  AnimationStatus? getMenuLayerAnimationStatus(BuildContext context) {
    return CupertinoMenuAnchor._maybeOf(context)?._menuAnimationStatus;
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
  AnimationStatus get animationStatus => _anchor!._menuAnimationStatus;

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

class _AnchorScope extends InheritedWidget {
  const _AnchorScope({required this.state, required super.child});
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
    Clip clipBehavior = Clip.hardEdge,
    this.consumeOutsideTap = false,
    this.onOpen,
    this.onClose,
    this.builder,
    this.child,
    this.scrollPhysics,
    this.constraints,
    required this.menuChildren,
    this.forwardSpring = forwardSpringDescription,
    this.reverseSpring = reverseSpringDescription,
    this.alignment,
    this.alignmentOffset,
    this.menuAlignment,
  }) :
  assert(clipBehavior == Clip.antiAlias ||
         clipBehavior == Clip.hardEdge,
         'clipBehavior must be antiAlias or hardEdge.'),
  _clipBehavior = clipBehavior;

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
  final Offset? alignmentOffset;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Must not be [Clip.antiAliasWithSaveLayer]. Defaults to [Clip.hardEdge].
  final Clip _clipBehavior;

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
  /// If the menu's contents are not larger than its constraints, scrolling
  /// will be disabled regardless of the applied physics.
  /// If null, the physics will be determined by the nearest [ScrollConfiguration].
  /// Defaults to null.
  final ScrollPhysics? scrollPhysics;

  /// The spring description used for the opening animation of the menu.
  final SpringDescription forwardSpring;

  /// The spring description used for the closing animation of the menu.
  final SpringDescription reverseSpring;

  /// The constraints to apply to the root menu layer.
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

  /// The default transparent [_MenuPanelLayout] background color.
  //
  // Background colors are based on the following:
  //
  // Dark mode on white background => rgb(83, 83, 83)
  // Dark mode on black => rgb(31, 31, 31)
  // Light mode on black background => rgb(197,197,197)
  // Light mode on white => rgb(246, 246, 246)
  static const CupertinoDynamicColor background =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(243, 243, 243, 0.775),
    darkColor: Color.fromRGBO(55, 55, 55, 0.735),
  );

  /// The default opaque [_MenuPanelLayout] background color.
  static const CupertinoDynamicColor opaqueBackground =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(246, 246, 246, 1),
    darkColor: Color.fromRGBO(31, 31, 31, 1),
  );

  @override
  State<CupertinoMenuAnchor> createState() => _CupertinoMenuAnchorState();

   @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return menuChildren.map<DiagnosticsNode>((Widget child) => child.toDiagnosticsNode()).toList();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('consumeOutsideTap', value: consumeOutsideTap, ifTrue: 'AUTO-CLOSE'));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', childFocusNode));
    properties.add(EnumProperty<Clip>('clipBehavior', _clipBehavior));
    if (alignmentOffset != null) {
      properties.add(DiagnosticsProperty<Offset?>('alignmentOffset', alignmentOffset));
    }

    if (constraints != null) {
      properties.add(DiagnosticsProperty<BoxConstraints?>('constraints',  constraints));
    }

    if (child != null) {
      properties.add(DiagnosticsProperty<String?>('child', child.toString()));
    }
  }
}


class _CupertinoMenuAnchorState extends State<CupertinoMenuAnchor>
      with TickerProviderStateMixin {
  static const Tolerance _springTolerance = Tolerance(velocity: 1, distance: 1);
  final Map<Type, Action<Intent>> _panelActions = <Type, Action<Intent>>{
    DirectionalFocusIntent: MenuDirectionalFocusAction(),
    DismissIntent: _DismissMenuAction(),
  };

  late final Animation<double> _panAnimation;
  late final AnimationController _panAnimationController;
  late final AnimationController _animationController;
       final GlobalKey _panelKey = GlobalKey(debugLabel: 'CupertinoMenuPanel');
       final GlobalKey<_CupertinoMenuAnchorProxyState> _internalAnchorKey =
            GlobalKey<_CupertinoMenuAnchorProxyState>(debugLabel: 'CupertinoMenuAnchor');
  CupertinoMenuController? _internalMenuController;
  AnimationStatus _menuAnimationStatus = AnimationStatus.dismissed;

  /// Whether the menu is open or opening.
  ///
  /// Used to determine whether the menu should be included focus. If the menu
  /// is not open or opening, then the menu should not be included in focus.
  bool get _isOpenOrOpening => _menuAnimationStatus == AnimationStatus.completed ||
                               _menuAnimationStatus == AnimationStatus.forward;
  ui.Rect _anchorRect = ui.Rect.zero;
  bool _hasLeadingWidget = false;
  CupertinoMenuController get _menuController => widget.controller
                                                ?? _internalMenuController!;
  @override
  void initState() {
    super.initState();
     if (widget.controller == null) {
      _internalMenuController = CupertinoMenuController();
    }
    _menuController._attach(this);
    _animationController = AnimationController.unbounded(vsync: this);
    _panAnimationController = AnimationController.unbounded(value: 1.0, vsync: this);
    _panAnimation = _AnimationProduct(
      first: _animationController,
      next: _panAnimationController
    );
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
    _animationController.dispose();
    _panAnimationController.dispose();
    super.dispose();
  }

  void _beginClose() {
    if(_menuAnimationStatus case AnimationStatus.dismissed ||
                                 AnimationStatus.reverse) {
      return;
    }

  _animationController
    ..stop()
    ..animateWith(
      SpringSimulation(
        widget.forwardSpring,
        _animationController.value,
        0.0,
        5.0,
        tolerance: _springTolerance
      )
    ).whenComplete(() {
      _menuController._closeOverlay();
    });

    _menuAnimationStatus = AnimationStatus.reverse;
  }

  void _close() {
    widget.onClose?.call();

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if (mounted) {
        assert(!_menuController.isOpen);
        _animationController.stop();
        _menuAnimationStatus = AnimationStatus.dismissed;
        if (SchedulerBinding.instance.schedulerPhase !=
            SchedulerPhase.persistentCallbacks) {
          _animationController.value = 0.0;
        } else {
          SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
            if (mounted) {
              _animationController.value = 0.0;
            }
          });
        }
      }
    });
  }

  void _open() {
    switch (_menuAnimationStatus) {
      case AnimationStatus.completed:
      case AnimationStatus.forward:
        return;
      case AnimationStatus.dismissed:
        widget.onOpen?.call();
      case AnimationStatus.reverse:
        break;
    }

    _animationController
      ..stop()
      ..animateWith(
        SpringSimulation(
          widget.forwardSpring,
          _animationController.value,
          1.0,
          5.0,
        )
      ).whenComplete(() {
        _animationController.value = 1;
        setState(() {
          _menuAnimationStatus = AnimationStatus.completed;
        });
      });


    _menuAnimationStatus = AnimationStatus.forward;
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      if(mounted && (_panelKey.currentContext?.mounted ?? false)) {
        FocusScope.of(context).setFirstFocus(
          FocusScope.of(_panelKey.currentContext!)
        );
      }
    });

  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final Offset panPosition = details.globalPosition;
    if (!mounted || _panelKey.currentContext?.mounted != true){
      return;
    }

    if (_panAnimationController.isAnimating) {
      _panAnimationController.stop();
    }

    final RenderBox renderObj = _panelKey.currentContext!.findRenderObject()! as RenderBox;
    final Rect rect = (renderObj.localToGlobal(Offset.zero) & renderObj.size).expandToInclude(_anchorRect);
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

    // 60000 is a drag distance of a ~245. At this distance, the menu scale
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
    Object? focusScopeGroupId,
    Offset? menuPosition
  }) {
    final RenderBox anchor = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Overlay.of(overlayContext).context.findRenderObject()! as RenderBox;
    _anchorRect = anchor.localToGlobal(Offset.zero, ancestor: overlay) & anchor.size;
    if (menuPosition != null) {
      _anchorRect = (menuPosition + _anchorRect.topLeft) & Size.zero ;
    }

    return ExcludeFocus(
      excluding: !_isOpenOrOpening,
      child: _MenuPanel(
        onPanEnd: _handlePanEnd,
        onPanUpdate: _handlePanUpdate,
        overlaySize: overlay.paintBounds.size,
        context: overlayContext,
        panelKey: _panelKey,
        animation: _animationController,
        controller: _menuController,
        anchorRect: _anchorRect,
        constraints: widget.constraints,
        consumeOutsideTaps: widget.consumeOutsideTap,
        panelActions: _panelActions,
        clipBehavior: widget._clipBehavior,
        scrollPhysics: widget.scrollPhysics,
        menuScopeNode: menuFocusScopeNode,
        anchorAlignment: widget.alignment,
        menuAlignment: widget.menuAlignment,
        alignmentOffset: widget.alignmentOffset ?? Offset.zero,
        panAnimation: _panAnimation,
        tapRegionId: focusScopeGroupId,
        children: widget.menuChildren,
      ),
    );
  }

  Widget _buildAnchorChild(
    BuildContext context,
    MenuController controller,
    Widget? child,
  ) {
    return widget.builder?.call(context, _menuController, widget.child)
            ?? widget.child
            ?? CupertinoButton(
                onPressed: () {
                  if (!_isOpenOrOpening) {
                    _menuController.open();
                  } else {
                    _menuController.close();
                  }
                },
                child: const Icon(CupertinoIcons.ellipsis_circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlockSemantics(
      blocking: _isOpenOrOpening,
      child: _AnchorScope(
        state: this,
        child: _CupertinoMenuAnchorBase(
          key: _internalAnchorKey,
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
    required super.key,
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
    Object? focusScopeGroupId,
    Offset? menuPosition
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
    Object? focusScopeGroupId,
    Offset? menuPosition
  }) {
    return widget.overlayChildBuilder(
      overlayContext: overlayContext,
      menuFocusScopeNode: menuFocusScopeNode,
      focusScopeGroupId: focusScopeGroupId,
      menuPosition: menuPosition,
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.context,
    required this.controller,
    required Rect anchorRect,
    required this.animation,
    required this.panelActions,
    required this.menuScopeNode,
    required this.children,
    required this.panelKey,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.panAnimation,
    required this.overlaySize,
    required this.consumeOutsideTaps,
    this.clipBehavior,
    this.scrollPhysics,
    required Offset alignmentOffset,
    AlignmentGeometry? menuAlignment,
    AlignmentGeometry? anchorAlignment,
    this.constraints,
    this.tapRegionId,
  })  : _alignmentOffset = alignmentOffset,
        _anchorAlignment = anchorAlignment,
        _anchorRect = anchorRect,
        _menuAlignment = menuAlignment;

  final BuildContext context;
  final bool consumeOutsideTaps;
  final CupertinoMenuController controller;
  final ui.Rect _anchorRect;
  final ui.Size overlaySize;
  final Map<Type, Action<Intent>> panelActions;
  final FocusScopeNode menuScopeNode;
  final Animation<double> animation;
  final List<Widget> children;
  final GlobalKey panelKey;
  final GestureDragUpdateCallback onPanUpdate;
  final void Function([DragEndDetails? details]) onPanEnd;
  final ScrollPhysics? scrollPhysics;
  final BoxConstraints? constraints;
  final ui.Offset _alignmentOffset;
  final Clip? clipBehavior;
  final AlignmentGeometry? _anchorAlignment;
  final Animation<double> panAnimation;
  final Object? tapRegionId;
  final AlignmentGeometry? _menuAlignment;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(overlaySize),
      child: _MenuPanelLayout(
        constraints: constraints,
        anchorRect: _anchorRect,
        overlaySize: overlaySize,
        menuAlignment: _menuAlignment,
        alignment: _anchorAlignment,
        anchorOffset: _alignmentOffset,
        panAnimation: panAnimation,
        child: _PanRegion<PanTarget<StatefulWidget>>(
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            onPanCancel: onPanEnd,
            child: _MenuPanelSurface(
              depth: 0,
              animation: animation,
              clipBehavior: clipBehavior,
              child: TapRegion(
                groupId: tapRegionId,
                consumeOutsideTaps: consumeOutsideTaps,
                onTapOutside: (PointerDownEvent event) {
                  controller._anchor!._beginClose();
                },
                child: MouseRegion(
              hitTestBehavior: HitTestBehavior.deferToChild,
              child: FocusScope(
                node: menuScopeNode,
                skipTraversal: true,
                child: Actions(
                  actions: <Type, Action<Intent>>{
                    DirectionalFocusIntent: MenuDirectionalFocusAction(),
                    DismissIntent: DismissMenuAction(controller: controller),
                  },
                  child: Shortcuts(
                    shortcuts: _kMenuTraversalShortcuts,
                    child: _MenuPanelScrollable(
                      key: panelKey,
                      physics: scrollPhysics,
                      children: children,
                    ),
                  ),
                ),
              )
            ),
          ),
        ),
      ))
    );
  }
}

/// A [MenuAction] that closes this menu when invoked.
class _DismissMenuAction extends ContextAction<DismissIntent> {
  /// Creates a [_DismissMenuAction].
  _DismissMenuAction();
 CupertinoMenuController? _getController(BuildContext? context) {
    if(context?.mounted != true) {
      return null;
    }
    return context?.mounted ?? false ? CupertinoMenuAnchor._maybeOf(context!)?._menuController : null;
  }

  @override
  void invoke(DismissIntent intent, [BuildContext? context]) {
    assert(_debugMenuInfo('$runtimeType: Dismissing all open menus.'));
    _getController(context)?._anchor?._beginClose();
  }

  @override
  bool isEnabled(DismissIntent intent, [BuildContext? context]) {
    return _getController(context)!.isOpen;
  }
}

// TODO(davidhicks980): Shuffle the classes to make the file more readable.

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
    this.alignment,
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
  final AlignmentGeometry? alignment;

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
    if (direction == TextDirection.rtl &&
        alignment is AlignmentDirectional) {
      return Offset(-anchorOffset!.dx, anchorOffset!.dy);
    }

    return anchorOffset!;
  }
  @override
  Widget build(BuildContext context) {
    final ui.TextDirection direction = Directionality.of(context);
    final Offset anchorOffset = _resolveOffset(direction);
    final Rect anchRect = anchorRect.shift(anchorOffset);
    final Alignment? resolveAlignment = alignment?.resolve(direction);
    final Alignment? resolvedMenuAlignment = menuAlignment?.resolve(direction);
    final ui.Offset growthPoint = anchRect.topLeft
                                    + (resolveAlignment ?? Alignment.center).alongSize(anchRect.size);

    // The alignment of the menu growth point relative to the screen.
    final Alignment menuToScreenAlignment = Alignment(
      (growthPoint.dx / overlaySize.width) * 2 - 1,
      (growthPoint.dy / overlaySize.height) * 2 - 1,
    );

    final VerticalDirection growthDirection = menuToScreenAlignment.y > 0
                                              ? VerticalDirection.up
                                              : VerticalDirection.down;
    return ScaleTransition(
      scale: panAnimation,
      alignment: menuToScreenAlignment,
      child: Builder(
        builder: (BuildContext context) {
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
              anchorAlignment: resolveAlignment ??
                  (growthDirection == VerticalDirection.up
                      ? Alignment.topCenter
                      : Alignment.bottomCenter),
              menuAlignment: resolvedMenuAlignment ??
                  (growthDirection == VerticalDirection.up
                      ? const Alignment(0, 1.025)
                      : const Alignment(0, -1.025)),
              anchorPosition: RelativeRect.fromSize(anchRect, overlaySize),
              growthDirection: growthDirection,
              textDirection: Directionality.of(context),
              edgeInsets: _edgeInsets,
              avoidBounds: DisplayFeatureSubScreen.avoidBounds(mediaQuery).toSet(),
            ),
            child: ConstrainedBox(
              constraints: resolvedConstraints,
              child: child,
            ),
          );
        }
      ),
    );
  }
}

class _MenuPanelSurface extends StatelessWidget {
  const _MenuPanelSurface({
    required this.child,
    required this.depth,
    required this.animation,
    this.clipBehavior,
  });

  final Widget child;
  final int depth;
  final Animation<double> animation;
  final Clip? clipBehavior;

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
      heightFactor: animation.value,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBoxTransition(
      decoration: _decorationTween.animate(animation),
      child: ClipRRect(
        clipBehavior: clipBehavior ?? Clip.antiAlias,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        child: AnimatedBuilder(
          animation: animation,
          builder: _alignTransitionBuilder,
          child: _BlurredSurface(
            color: CupertinoMenuAnchor.background.resolveFrom(context),
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
    required this.color,
    required this.child,
  }) : super(listenable: listenable);

  static const Interval _surfaceDelay =  Interval(0.55, 1.0);
  final Widget child;
  final Color color;
  double get value => ui.clampDouble((super.listenable as Animation<double>).value, 0.0, 1.0);
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
     double  additive, saturation, lumR, lumG, lumB;
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
      sr + saturation, sg              ,sb              , 0.0, additive,
      sr             , sg + saturation ,sb              , 0.0, additive,
      sr             , sg              ,sb + saturation , 0.0, additive,
      0.0            , 0.0             ,0.0             , 1.0, 0.0     ,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isLight = CupertinoTheme.brightnessOf(context) == Brightness.light;
    final ui.Color resolvedColor = color.withOpacity(color.opacity * value);
    final double intervalValue = _surfaceDelay.transform(value);
    final bool transparent = resolvedColor.alpha != 0xFF;
    Widget surface = CustomPaint(
      willChange: value != 0 && value != 1,
      painter: _UnclippedColorPainter(color: resolvedColor),
      child: child,
    );

    if (transparent) {
      ui.ImageFilter filter = ui.ImageFilter.blur(
        sigmaX: 30 * intervalValue,
        sigmaY: 30 * intervalValue,
      );

      if (!kIsWeb) {
        filter = ui.ImageFilter.compose(
          outer: filter,
          inner: ui.ColorFilter.matrix(
            buildColorFilterMatrix(
              strength: intervalValue,
              brightness: isLight ? Brightness.light : Brightness.dark,
            )
          )
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

    if (child case CupertinoMenuEntryMixin(hasSeparatorAfter: false)) {
      return child;
    }

    if (widget.children[index + 1] case CupertinoMenuEntryMixin(hasSeparatorBefore: false)) {
      return child;
    }

    return CupertinoMenuDivider.wrap(child: child);
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                _buildChild,
                childCount: widget.children.length,
              ),
            )
          ],
        ),
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

class _PanRegion<T extends PanTarget<StatefulWidget>> extends SingleChildRenderObjectWidget {
  const _PanRegion({
    super.key,
    super.child,
    this.group,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
  });

  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragCancelCallback? onPanCancel;
  final Object? group;
  @override
  RenderPanningScale<T> createRenderObject(BuildContext context) {
    return RenderPanningScale<T>(
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      onPanCancel: onPanCancel,
      group: group,
      viewId: View.of(context).viewId,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderPanningScale<T> renderObject) {
    renderObject
      ..onPanUpdate = onPanUpdate
      ..onPanEnd = onPanEnd
      ..onPanCancel = onPanCancel
      ..group = group
      ..viewId = View.of(context).viewId;
  }
}



class RenderPanningScale<T extends PanTarget<StatefulWidget>> extends RenderProxyBoxWithHitTestBehavior {
  RenderPanningScale({
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    required int viewId,
    Object? group,
  }): _group = group,
      _viewId = viewId {
      _tap = PanGestureRecognizer()
            ..onUpdate = _handlePanUpdate
            ..onCancel = _handlePanCancel
            ..onEnd    = _handlePanEnd;
  }

  final List<T> _enteredTargets = <T>[];
  Offset? _position;
  late PanGestureRecognizer _tap;
  GestureDragUpdateCallback? onPanUpdate;
  GestureDragEndCallback? onPanEnd;
  GestureDragCancelCallback? onPanCancel;

  /// The blend mode to use to apply the filtered background content onto the background
  /// surface.
  ///
  /// {@macro flutter.widgets.BackdropFilter.blendMode}
  Object? get group => _group;
  Object? _group;
  set group(Object? value) {
    if (_group == value) {
      return;
    }

    _group = value;
    markNeedsDragUpdate();
  }

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
    _leaveAllEntered(complete: true);
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

  // TODO: Remove this method if idiom is unnecessary.
  // This method is defined to match "mark" idiom (markNeedsLayout, markNeedsPaint, etc.)
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

      // If [MetaData] is hit that contains a [PanTarget] in the same group,
      // then add it to the list of targets.
      if (target case RenderMetaData(:final T metaData)) {
        if (metaData.group == _group) {
          targets ??= <T>[]; // lazy init
          targets.add(metaData);
        }
      }
    }

    bool listsMatch = false;
    if (
      targets != null &&
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

  void _leaveAllEntered({bool complete = false}) {
    for (int i = 0; i < _enteredTargets.length; i += 1) {
      _enteredTargets[i].didPanLeave(complete: complete);
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
    required this.growthDirection,
    required this.textDirection,
    required this.anchorAlignment,
    required this.menuAlignment
  });

  // Whether the menu should begin growing above or below the menu anchor.
  final VerticalDirection growthDirection;

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
    final Offset resolvedOffset = anchorAlignment.withinRect(anchorRect)
                                  - menuAlignment.alongSize(childSize);

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
    return edgeInsets      != oldDelegate.edgeInsets
        || anchorPosition  != oldDelegate.anchorPosition
        || textDirection   != oldDelegate.textDirection
        || growthDirection != oldDelegate.growthDirection
        || !setEquals(avoidBounds, oldDelegate.avoidBounds);
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
