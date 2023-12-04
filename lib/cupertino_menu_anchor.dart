// ignore_for_file: unused_element

import 'package:flutter/material.dart' show MenuStyle;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'menu.dart';
import 'test_anchor.dart';


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

class CupertinoMenuController extends MenuController {
  /// The anchor that this controller controls.
  ///
  /// This is set automatically when a [MenuController] is given to the anchor
  /// it controls.
  _CupertinoMenuAnchorState? _anchor;

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
    assert(_anchor != null);
    _anchor!._beginClose(onClose: super.close);
  }

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
    required this.menuChildren,
    this.builder,
    this.child,
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
  final MenuAnchorChildBuilder? builder;

  /// The optional child to be passed to the [builder].
  ///
  /// Supply this child if there is a portion of the widget tree built in
  /// [builder] that doesn't depend on the `controller` or `context` supplied to
  /// the [builder]. It will be more efficient, since Flutter doesn't then need
  /// to rebuild this child when those change.
  final Widget? child;

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
  CupertinoMenuController get _menuController =>
      widget.controller ?? _internalMenuController!;
  bool _isClosing = false;

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
    assert(_menuController._anchor == this);
  }

  @override
  void dispose() {
    _menuController._detach(this);
    _internalMenuController = null;
    _controller.dispose();
    super.dispose();
  }

  void _beginClose({VoidCallback? onClose}) {
    if (_isClosing) {
      return;
    }
    void handleStatusChange(AnimationStatus status) {
      if (status != AnimationStatus.reverse) {
        _controller.removeStatusListener(handleStatusChange);
        _isClosing = false;
        if (status == AnimationStatus.dismissed) {
          onClose?.call();
        }
      }

      assert(status == AnimationStatus.reverse || !_isClosing);
    }

    _isClosing = true;
    _controller
      ..addStatusListener(handleStatusChange)
      ..reverse();
  }

  void _handleClose() {
    widget.onClose?.call();
    _controller.reset();
    _isClosing = false;
  }

  void _handleOpen() {
    widget.onOpen?.call();
    _controller.forward();
    _isClosing = false;
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoMenuAnchorProxy(
      menuChildren: widget.menuChildren,
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
        return widget.builder?.call(
              context,
              _menuController,
              widget.child,
            ) ??
            widget.child!;
      },
      controller: _menuController,
      childFocusNode: widget.childFocusNode,
      style: widget.style,
      alignmentOffset: widget.alignmentOffset,
      clipBehavior: widget.clipBehavior,
      consumeOutsideTap: widget.consumeOutsideTap,
      onOpen: _handleOpen,
      onClose: _handleClose,
      animation: _animation,
      child: widget.child,
    );
  }
}

class _CupertinoMenuAnchorProxy extends MenuAnchor {
  const _CupertinoMenuAnchorProxy({
    super.key,
    required super.menuChildren,
    required super.controller,
    super.clipBehavior,
    super.style,
    super.builder,
    this.enableFeedback = true,
    super.alignmentOffset,
    super.childFocusNode,
    super.consumeOutsideTap = false,
    super.onOpen,
    super.onClose,
    super.crossAxisUnconstrained = true,
    super.child,
    this.scrollPhysics = const AlwaysScrollableScrollPhysics(),
    required this.animation,
  });

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// If true, Feedback.forTap will be called when the menu is opened.
  ///
  /// Defaults to true.
  final bool enableFeedback;

  /// The physics to use for the menu's scrollable.
  ///
  /// If the menu's contents are not larger than its constraints, scrolling
  /// will be disabled regardless of the physics.
  ///
  /// Defaults to true.
  final ScrollPhysics scrollPhysics;

  final Animation<double> animation;

  @override
  State<_CupertinoMenuAnchorProxy> createState() => _CupertinoMenuAnchorProxyState();
}

class _CupertinoMenuAnchorProxyState extends MenuAnchorState<_CupertinoMenuAnchorProxy> {
  @override
  void handleScroll() {
    widget.controller!.close();
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
      controller: widget.controller! as CupertinoMenuController,
      alignmentOffset: widget.alignmentOffset,
      anchorRect: anchorRect,
      overlaySize: overlay.size,
    );
  }
}

class _CupertinoSubmenu extends StatelessWidget {
  const _CupertinoSubmenu({
    super.key,
    required this.context,
    required this.menuScopeNode,
    required this.animation,
    required this.consumeOutsideTap,
    required this.menuChildren,
    required this.controller,
    this.alignmentOffset,
    required this.anchorRect,
    required this.overlaySize,
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

    return Actions(
      actions: <Type, Action<Intent>>{
        DirectionalFocusIntent: MenuDirectionalFocusAction(),
        DismissIntent: DismissMenuAction(controller: controller),
      },
      child: Shortcuts(
        shortcuts: _kMenuTraversalShortcuts,
        child: CupertinoMenu(
            controller: controller,
            animation: animation,
            anchorPosition: anchorPosition,
            hasLeadingWidget: true,
            alignment: alignment,
            anchorSize: anchorRect.size,
            brightness: Brightness.dark,
            children: menuChildren,
        ),
      ),
    );
  }
}




class DismissMenuAction extends DismissAction {
  /// Creates a [DismissMenuAction].
  DismissMenuAction({required this.controller});

  /// The [MenuController] associated with the menus that should be closed.
  final CupertinoMenuController controller;

  @override
  void invoke(DismissIntent intent) {
    assert(_debugCupertinoMenu('$runtimeType: Dismissing all open menus.'));
    controller.close();
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
bool _debugCupertinoMenu(String message, [Iterable<String>? details]) {
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