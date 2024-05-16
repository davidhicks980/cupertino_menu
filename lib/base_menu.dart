// Examples can assume:
// bool _throwShotAway = false;
// late BuildContext context;
// enum SingingCharacter { lafayette }
// late SingingCharacter? _character;
// late StateSetter setState;

// Enable if you want verbose logging about menu changes.
const bool _kDebugMenus = false;

// The default size of the arrow in _MenuItemLabel that indicates that a menu
// has a submenu.
const double _kDefaultSubmenuIconSize = 24;

// The default spacing between the leading icon, label, trailing icon, and
// shortcut label in a _MenuItemLabel.
const double _kLabelItemDefaultSpacing = 12;

// The minimum spacing between the leading icon, label, trailing icon, and
// shortcut label in a _MenuItemLabel.
const double _kLabelItemMinSpacing = 4;

// Navigation shortcuts that we need to make sure are active when menus are
// open.
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

// The minimum vertical spacing on the outside of menus.
const double _kMenuVerticalMinPadding = 8;

// How close to the edge of the safe area the menu will be placed.
const double _kMenuViewPadding = 8;

// The minimum horizontal spacing on the outside of the top level menu.
const double _kTopLevelMenuHorizontalMinPadding = 4;

/// The type of builder function used by [MenuAnchor.builder] to build the
/// widget that the [MenuAnchor] surrounds.
///
/// The `context` is the context that the widget is being built in.
///
/// The `controller` is the [MenuController] that can be used to open and close
/// the menu with.
///
/// The `child` is an optional child supplied as the [MenuAnchor.child]
/// attribute. The child is intended to be incorporated in the result of the
/// function.
typedef MenuAnchorChildBuilder = Widget Function(
  BuildContext context,
  MenuController controller,
  Widget? child,
);

/// The type of builder function used by [MenuAnchor.withOverlayBuilder] to build
/// the overlay attached to a [MenuAnchor].
///
/// The `context` is the context that the overlay is being built in.
///
/// The `menuChildren` is the list of children containing the menu items that
/// was passed to the [MenuAnchor].
///
/// The `menuFocusScopeNode` is the [FocusScopeNode] that should be provided to
/// the [FocusScope.focusNode] for the menu.
///
/// The `menuPosition` should be used to position the menu at a specific
/// location.
///
/// The `tapRegionGroupId` is the [TapRegion.groupId] that should be used to
/// consume taps outside of the menu.
typedef MenuOverlayBuilder = Widget Function(
  BuildContext context,
  List<Widget> menuChildren,
  FocusScopeNode menuFocusScopeNode,
  Offset? menuPosition,
  Object? tapRegionGroupId,
);

/// A widget used to mark the "anchor" for a set of submenus, defining the
/// rectangle used to position the menu, which can be done either with an
/// explicit location, or with an alignment.
///
/// When creating a menu with [MenuBar] or a [SubmenuButton], a [MenuAnchor] is
/// not needed, since they provide their own internally.
///
/// The [MenuAnchor] is meant to be a slightly lower level interface than
/// [MenuBar], used in situations where a [MenuBar] isn't appropriate, or to
/// construct widgets or screen regions that have submenus.
///
/// {@tool dartpad}
/// This example shows how to use a [MenuAnchor] to wrap a button and open a
/// cascading menu from the button.
///
/// ** See code in examples/api/lib/material/menu_anchor/menu_anchor.0.dart **
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to use a [MenuAnchor] to create a cascading context
/// menu in a region of the view, positioned where the user clicks the mouse
/// with Ctrl pressed. The [anchorTapClosesMenu] attribute is set to true so
/// that clicks on the [MenuAnchor] area will cause the menus to be closed.
///
/// ** See code in examples/api/lib/material/menu_anchor/menu_anchor.1.dart **
/// {@end-tool}
class MenuAnchor extends StatefulWidget {
  /// Creates a const [MenuAnchor].
  ///
  /// The [menuChildren] argument is required.
  const MenuAnchor({
    super.key,
    this.controller,
    this.childFocusNode,
    this.style,
    this.alignmentOffset = Offset.zero,
    this.clipBehavior = Clip.hardEdge,
    @Deprecated(
      'Use consumeOutsideTap instead. '
      'This feature was deprecated after v3.16.0-8.0.pre.',
    )
    this.anchorTapClosesMenu = false,
    this.consumeOutsideTap = false,
    this.onOpen,
    this.onClose,
    this.crossAxisUnconstrained = true,
    required this.menuChildren,
    this.builder,
    this.child,
  }) : _overlayBuilder = null;


  /// Builds a [MenuAnchor] that lays out it's [menuChildren] in a custom
  /// overlay built by `overlayBuilder`.
  ///
  /// Because providing an `overlayBuilder` entails managing the positioning,
  /// appearance, semantics, and interaction of the menu overlay, in most cases
  /// the default overlay provided by [MenuAnchor] is sufficient. However, in
  /// cases where a custom overlay is needed (e.g. an animated menu), this
  /// constructor can be used to provide one.
  ///
  /// When defining an `overlayBuilder`, proper focus management can be achieved
  /// by wrapping a [FocusScope] around your overlay and providing a
  /// `menuFocusScopeNode` to the [FocusScope.focusNode] property. The
  /// `menuPosition` property should be used to position the menu at the
  /// user-specified location. If a [TapRegion] is used to consume taps outside
  /// of the menu, the `tapRegionGroupId` should be used as the
  /// [TapRegion.groupId].
  const MenuAnchor.withOverlayBuilder({
    super.key,
    this.controller,
    this.childFocusNode,
    this.style,
    this.alignmentOffset = Offset.zero,
    this.clipBehavior = Clip.hardEdge,
    @Deprecated(
      'Use consumeOutsideTap instead. '
      'This feature was deprecated after v3.16.0-8.0.pre.',
    )
    this.anchorTapClosesMenu = false,
    this.consumeOutsideTap = false,
    this.onOpen,
    this.onClose,
    this.crossAxisUnconstrained = true,
    required this.menuChildren,
    required MenuOverlayBuilder overlayBuilder,
    this.builder,
    this.child,
  }) : _overlayBuilder = overlayBuilder;

  /// An optional controller that allows opening and closing of the menu from
  /// other widgets.
  final MenuController? controller;

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

  /// Whether the menus will be closed if the anchor area is tapped.
  ///
  /// For menus opened by buttons that toggle the menu, if the button is tapped
  /// when the menu is open, the button should close the menu. But if
  /// [anchorTapClosesMenu] is true, then the menu will close, and
  /// (surprisingly) immediately re-open. This is because tapping on the button
  /// closes the menu before the `onPressed` or `onTap` handler is called
  /// because of it being considered to be "outside" the menu system, and then
  /// the button (seeing that the menu is closed) immediately reopens the menu.
  /// The result is that the user thinks that tapping on the button does
  /// nothing. So, for button-initiated menus, this value is typically false so
  /// that the menu anchor area is considered "inside" of the menu system and
  /// doesn't cause it to close unless [MenuController.close] is called.
  ///
  /// For menus that are positioned using [MenuController.open]'s `position`
  /// parameter, it is often desirable that clicking on the anchor always closes
  /// the menu since the anchor area isn't usually considered part of the menu
  /// system by the user. In this case [anchorTapClosesMenu] should be true.
  ///
  /// Defaults to false.
  @Deprecated(
    'Use consumeOutsideTap instead. '
    'This feature was deprecated after v3.16.0-8.0.pre.',
  )
  final bool anchorTapClosesMenu;

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

  /// Determine if the menu panel can be wrapped by a [UnconstrainedBox] which allows
  /// the panel to render at its "natural" size.
  ///
  /// Defaults to true as it allows developers to render the menu panel at the
  /// size it should be. When it is set to false, it can be useful when the menu should
  /// be constrained in both main axis and cross axis, such as a [DropdownMenu].
  final bool crossAxisUnconstrained;

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

  /// A method that builds the overlay attached to this [MenuAnchor].
  ///
  /// If supplied, this function is responsible for building a widget that handles
  /// the positioning, appearance, and interaction of the menu overlay.
  ///
  /// When providing a custom overlay builder, a [FocusScope] should wrap the
  /// menu, and the [menuFocusScopeNode] should be provided to the
  /// [FocusScope.focusNode]. The [menuPosition] should be used to position the
  /// menu at the user-specified location. If a [TapRegion] is used to consume
  /// taps outside of the menu, the [tapRegionGroupId] should be used as the
  /// [TapRegion.groupId].
  final MenuOverlayBuilder? _overlayBuilder;

  @override
  State<MenuAnchor> createState() => _MenuAnchorState();

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return menuChildren.map<DiagnosticsNode>((Widget child) => child.toDiagnosticsNode()).toList();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('anchorTapClosesMenu', value: anchorTapClosesMenu, ifTrue: 'AUTO-CLOSE'));
    properties.add(DiagnosticsProperty<FocusNode?>('focusNode', childFocusNode));
    properties.add(DiagnosticsProperty<MenuStyle?>('style', style));
    properties.add(EnumProperty<Clip>('clipBehavior', clipBehavior));
    properties.add(DiagnosticsProperty<Offset?>('alignmentOffset', alignmentOffset));
  }
}

class _MenuAnchorState extends State<MenuAnchor> {
  // This is the global key that is used later to determine the bounding rect
  // for the anchor's region that the CustomSingleChildLayout's delegate
  // uses to determine where to place the menu on the screen and to avoid the
  // view's edges.
  final GlobalKey<_MenuAnchorState> _anchorKey = GlobalKey<_MenuAnchorState>(debugLabel: kReleaseMode ? null : 'MenuAnchor');
  _MenuAnchorState? _parent;
  late final FocusScopeNode _menuScopeNode;
  MenuController? _internalMenuController;
  final List<_MenuAnchorState> _anchorChildren = <_MenuAnchorState>[];
  ScrollPosition? _scrollPosition;
  Size? _viewSize;
  final OverlayPortalController _overlayController = OverlayPortalController(debugLabel: kReleaseMode ? null : 'MenuAnchor controller');
  Offset? _menuPosition;
  Axis get _orientation => Axis.vertical;
  bool get _isOpen => _overlayController.isShowing;
  bool get _isRoot => _parent == null;
  bool get _isTopLevel => _parent?._isRoot ?? false;
  MenuController get _menuController => widget.controller ?? _internalMenuController!;

  @override
  void initState() {
    super.initState();
    _menuScopeNode = FocusScopeNode(debugLabel: kReleaseMode ? null : '${describeIdentity(this)} Sub Menu');
    if (widget.controller == null) {
      _internalMenuController = MenuController();
    }
    _menuController._attach(this);
  }

  @override
  void dispose() {
    assert(_debugMenuInfo('Disposing of $this'));
    if (_isOpen) {
      _close(inDispose: true);
      _parent?._removeChild(this);
    }
    _anchorChildren.clear();
    _menuController._detach(this);
    _internalMenuController = null;
    _menuScopeNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _MenuAnchorState? newParent = _MenuAnchorState._maybeOf(context);
    if (newParent != _parent) {
      _parent?._removeChild(this);
      _parent = newParent;
      _parent?._addChild(this);
    }
    _scrollPosition?.isScrollingNotifier.removeListener(_handleScroll);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.isScrollingNotifier.addListener(_handleScroll);
    final Size newSize = MediaQuery.sizeOf(context);
    if (_viewSize != null && newSize != _viewSize) {
      // Close the menus if the view changes size.
      _root._close();
    }
    _viewSize = newSize;
  }

  @override
  void didUpdateWidget(MenuAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      if (widget.controller != null) {
        _internalMenuController?._detach(this);
        _internalMenuController = null;
        widget.controller?._attach(this);
      } else {
        assert(_internalMenuController == null);
        _internalMenuController = MenuController().._attach(this);
      }
    }
    assert(_menuController._anchor == this);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: _buildOverlay,
      child: _buildContents(context),
    );

    if (!widget.anchorTapClosesMenu) {
      child = TapRegion(
        groupId: _root,
        consumeOutsideTaps: _root._isOpen && widget.consumeOutsideTap,
        onTapOutside: (PointerDownEvent event) {
          assert(_debugMenuInfo('Tapped Outside ${widget.controller}'));
          _closeChildren();
        },
        child: child,
      );
    }

    return _MenuAnchorScope(
      anchorKey: _anchorKey,
      anchor: this,
      isOpen: _isOpen,
      child: child,
    );
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    if (widget._overlayBuilder == null) {
      return _Submenu(
        anchor: this,
        menuStyle: widget.style,
        alignmentOffset: widget.alignmentOffset ?? Offset.zero,
        menuPosition: _menuPosition,
        clipBehavior: widget.clipBehavior,
        menuChildren: widget.menuChildren,
        crossAxisUnconstrained: widget.crossAxisUnconstrained,
      );
    }

    return widget._overlayBuilder!(
      overlayContext,
      widget.menuChildren,
      _menuScopeNode,
      _menuPosition,
      _root,
    );
  }

  Widget _buildContents(BuildContext context) {
    return Actions(
      actions: <Type, Action<Intent>>{
        DirectionalFocusIntent: MenuDirectionalFocusAction(),
        PreviousFocusIntent: _MenuPreviousFocusAction(),
        NextFocusIntent: _MenuNextFocusAction(),
        DismissIntent: DismissMenuAction(controller: _menuController),
      },
      child:  Builder(
        key: _anchorKey,
        builder: (BuildContext context) {
          return widget.builder?.call(context, _menuController, widget.child)
              ?? widget.child ?? const SizedBox();
        },
      ),
    );
  }

  // Returns the first focusable item in the submenu, where "first" is
  // determined by the focus traversal policy.
  FocusNode? get _firstItemFocusNode {
    if (_menuScopeNode.context == null) {
      return null;
    }
    final FocusTraversalPolicy policy =
     FocusTraversalGroup.maybeOf(_menuScopeNode.context!) ?? ReadingOrderTraversalPolicy();
    return policy.findFirstFocus(_menuScopeNode, ignoreCurrentFocus: true);
  }

  void _addChild(_MenuAnchorState child) {
    assert(_isRoot || _debugMenuInfo('Added root child: $child'));
    assert(!_anchorChildren.contains(child));
    _anchorChildren.add(child);
    assert(_debugMenuInfo('Added:\n${child.widget.toStringDeep()}'));
    assert(_debugMenuInfo('Tree:\n${widget.toStringDeep()}'));
  }

  void _removeChild(_MenuAnchorState child) {
    assert(_isRoot || _debugMenuInfo('Removed root child: $child'));
    assert(_anchorChildren.contains(child));
    assert(_debugMenuInfo('Removing:\n${child.widget.toStringDeep()}'));
    _anchorChildren.remove(child);
    assert(_debugMenuInfo('Tree:\n${widget.toStringDeep()}'));
  }

  List<_MenuAnchorState> _getFocusableChildren() {
    if (_parent == null) {
      return <_MenuAnchorState>[];
    }
    return _parent!._anchorChildren.where((_MenuAnchorState menu) {
      return menu.widget.childFocusNode?.canRequestFocus ?? false;
    },).toList();
  }

  _MenuAnchorState? get _nextFocusableSibling {
    final List<_MenuAnchorState> focusable = _getFocusableChildren();
      if (focusable.isEmpty) {
        return null;
      }
      return focusable[(focusable.indexOf(this) + 1) % focusable.length];
  }

_MenuAnchorState? get _previousFocusableSibling {
  final List<_MenuAnchorState> focusable = _getFocusableChildren();
  if (focusable.isEmpty) {
    return null;
  }
  return focusable[(focusable.indexOf(this) - 1 + focusable.length) % focusable.length];
}

  _MenuAnchorState get _root {
    _MenuAnchorState anchor = this;
    while (anchor._parent != null) {
      anchor = anchor._parent!;
    }
    return anchor;
  }

  _MenuAnchorState get _topLevel {
    _MenuAnchorState handle = this;
    while (handle._parent != null && !handle._parent!._isTopLevel) {
      handle = handle._parent!;
    }
    return handle;
  }

  void _childChangedOpenState() {
    _parent?._childChangedOpenState();
    assert(mounted);
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      setState(() {
        // Mark dirty now, but only if not in a build.
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        setState(() {
          // Mark dirty after this frame, but only if in a build.
        });
      });
    }

  }

  void _focusButton() {
    if (widget.childFocusNode == null) {
      return;
    }
    assert(_debugMenuInfo('Requesting focus for ${widget.childFocusNode}'));
    widget.childFocusNode!.requestFocus();
  }

  void _handleScroll() {
    // If an ancestor scrolls, and we're a root anchor, then close the menus.
    // Don't just close it on *any* scroll, since we want to be able to scroll
    // menus themselves if they're too big for the view.
    if (_isRoot) {
      _close();
    }
  }

  KeyEventResult _checkForEscape(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Open the menu, optionally at a position relative to the [MenuAnchor].
  ///
  /// Call this when the menu should be shown to the user.
  ///
  /// The optional `position` argument will specify the location of the menu in
  /// the local coordinates of the [MenuAnchor], ignoring any
  /// [MenuStyle.alignment] and/or [MenuAnchor.alignmentOffset] that were
  /// specified.
  void _open({Offset? position}) {
    assert(_menuController._anchor == this);
    if (_isOpen && position == null) {
      assert(_debugMenuInfo("Not opening $this because it's already open"));
      return;
    }
    if (_isOpen && position != null) {
      // The menu is already open, but we need to move to another location, so
      // close it first.
      _close();
    }
    assert(_debugMenuInfo(
        'Opening $this at ${position ?? Offset.zero} with alignment offset ${widget.alignmentOffset ?? Offset.zero}'));
    _parent?._closeChildren(); // Close all siblings.
    assert(!_overlayController.isShowing);

    _parent?._childChangedOpenState();
    _menuPosition = position;
    _overlayController.show();

    widget.onOpen?.call();
  }

  /// Close the menu.
  ///
  /// Call this when the menu should be closed. Has no effect if the menu is
  /// already closed.
  void _close({bool inDispose = false}) {
    assert(_debugMenuInfo('Closing $this'));
    if (!_isOpen) {
      return;
    }
    if (_isRoot) {
      FocusManager.instance.removeEarlyKeyEventHandler(_checkForEscape);
    }
    _closeChildren(inDispose: inDispose);
    // Don't hide if we're in the middle of a build.
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      _overlayController.hide();
    } else if (!inDispose) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _overlayController.hide();
      }, debugLabel: 'MenuAnchor.hide');
    }
    if (!inDispose) {
      // Notify that _childIsOpen changed state, but only if not
      // currently disposing.
      _parent?._childChangedOpenState();
      widget.onClose?.call();
      if (mounted && SchedulerBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
        setState(() {
          // Mark dirty, but only if mounted and not in a build.
        });
      }
    }
  }

  void _closeChildren({bool inDispose = false}) {
    assert(_debugMenuInfo('Closing children of $this${inDispose ? ' (dispose)' : ''}'));
    for (final _MenuAnchorState child in List<_MenuAnchorState>.from(_anchorChildren)) {
      child._close(inDispose: inDispose);
    }
  }

  // Returns the active anchor in the given context, if any, and creates a
  // dependency relationship that will rebuild the context when the node
  // changes.
  static _MenuAnchorState? _maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MenuAnchorScope>()?.anchor;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return describeIdentity(this);
  }
}

/// A controller to manage a menu created by a [MenuBar] or [MenuAnchor].
///
/// A [MenuController] is used to control and interrogate a menu after it has
/// been created, with methods such as [open] and [close], and state accessors
/// like [isOpen].
///
/// See also:
///
/// * [MenuAnchor], a widget that defines a region that has submenu.
/// * [MenuBar], a widget that creates a menu bar, that can take an optional
///   [MenuController].
/// * [SubmenuButton], a widget that has a button that manages a submenu.
class MenuController {
  /// The anchor that this controller controls.
  ///
  /// This is set automatically when a [MenuController] is given to the anchor
  /// it controls.
  _MenuAnchorState? _anchor;

  /// Whether or not the associated menu is currently open.
  bool get isOpen {
    assert(_anchor != null);
    return _anchor!._isOpen;
  }

  /// Close the menu that this menu controller is associated with.
  ///
  /// Associating with a menu is done by passing a [MenuController] to a
  /// [MenuAnchor]. A [MenuController] is also be received by the
  /// [MenuAnchor.builder] when invoked.
  ///
  /// If the menu's anchor point (either a [MenuBar] or a [MenuAnchor]) is
  /// scrolled by an ancestor, or the view changes size, then any open menu will
  /// automatically close.
  void close() {
    assert(_anchor != null);
    _anchor!._close();
  }

  /// Opens the menu that this menu controller is associated with.
  ///
  /// If `position` is given, then the menu will open at the position given, in
  /// the coordinate space of the [MenuAnchor] this controller is attached to.
  ///
  /// If given, the `position` will override the [MenuAnchor.alignmentOffset]
  /// given to the [MenuAnchor].
  ///
  /// If the menu's anchor point (either a [MenuBar] or a [MenuAnchor]) is
  /// scrolled by an ancestor, or the view changes size, then any open menu will
  /// automatically close.
  void open({Offset? position}) {
    assert(_anchor != null);
    _anchor!._open(position: position);
  }

  // ignore: use_setters_to_change_properties
  void _attach(_MenuAnchorState anchor) {
    _anchor = anchor;
  }

  void _detach(_MenuAnchorState anchor) {
    if (_anchor == anchor) {
      _anchor = null;
    }
  }
}