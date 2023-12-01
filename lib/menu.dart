// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/cupertino/button.dart';
import 'package:flutter/src/cupertino/colors.dart';
import 'package:flutter/src/cupertino/icons.dart';
import 'package:flutter/src/cupertino/localizations.dart';
import 'package:flutter/src/cupertino/scrollbar.dart';
import 'package:flutter/src/cupertino/theme.dart';
import 'package:flutter/widgets.dart';

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

/// Mixin that allows a subclasses to be controlled by a [CupertinoMenuController].
abstract class CupertinoMenuControlMixin {
  /// Opens the menu attached to this menu controller.
  ///
  /// If the menu is already open, this method does nothing.
  void open();

  /// Closes the menu attached to this menu controller.
  ///
  /// If the menu is already closed, this method does nothing.
  void close();

  /// Rebuilds the menu attached to this menu controller.
  ///
  /// It is an error to call this method if the menu is closed.
  void rebuild();

  /// Whether the menu is currently open.
  bool get isOpen;
}

/// {@template CupertinoMenuController}
/// A controller that manages menus created by a [CupertinoMenuButton] or
/// [CupertinoNestedMenu].
///
/// Associating with a menu is done by passing a [MenuController] to a
/// [CupertinoMenuButton.controller] or [CupertinoNestedMenu.controller].
///
/// A [CupertinoMenuController] is used to control and interrogate a menu after
/// it has been created, with methods such as [open] and [close], and state
/// accessors like [isOpen].
/// {@endtemplate}
/// See also:
///
/// * [CupertinoMenuButton], a widget that creates a Cupertino-themed menu that
///   can be controlled by a [CupertinoMenuController].
/// * [CupertinoNestedMenu], a nested Cupertino-themed menu that can be
///   controlled by a [CupertinoMenuController].
class CupertinoMenuController extends CupertinoMenuControlMixin {
  CupertinoMenuControlMixin? _controller;
  // Throws if the menu is not attached to a CupertinoMenuControlMixin
  CupertinoMenuControlMixin get _attachedController {
    assert(_controller != null);
    return _controller!;
  }

  @override
  bool get isOpen => _controller?.isOpen ?? false;

  @override
  void open() {
    _attachedController.open();
  }

  @override
  void rebuild() {
    _attachedController.rebuild();
  }

  @override
  void close() {
    _attachedController.close();
  }

  // ignore: use_setters_to_change_properties
  void _attach(CupertinoMenuControlMixin menu) {
    _controller = menu;
  }

  void _detach(CupertinoMenuControlMixin menu) {
    if (_controller == menu) {
      _controller = null;
    }
  }
}

/// A button that displays a Cupertino-style menu when pressed.
///
/// The menu is composed of a list of [Widget]s that can be
/// traversed using the up- and down-arrow keys. A [controller] can be provided
/// to open and close the menu programmatically, as well as interrogate whether
/// the menu is currently open.
///
/// An [itemBuilder] must be provided to build the menu's items. The menu will
/// be rebuilt whenever the [itemBuilder] is changed, or when
/// [controller.rebuild] is called.
///
/// The menu anchor is a [CupertinoButton] whose body can be customized using
/// the [child] parameter. If [child] is null, [CupertinoIcons.ellipsis] will be
/// used as the button's child. A [focusNode] can be provided to control the
/// focus behavior of the menu button.
///
/// If [enableFeedback] is true, [Feedback.forTap] will be called when the menu
/// is opened.
///
/// The [constraints] parameter describes the [BoxConstraints] to apply to this
/// menu layer. By default, the menu will expand to fit the lesser of the total
/// height of the menu items and the bounds of the screen. The [edgeInsets]
/// parameter can be used to avoid screen edges when positioning the menu. By
/// default, the menu will ignore [MediaQuery] padding.
///
/// The [onOpen] callback will be called when the menu has started opening, and
/// the [onClose] callback will be called when the menu has finished closing,
/// regardless of whether a value has been selected. To respond when the menu
/// closes *without* an item selection, an [onCancel] callback can be provided.
/// Conversely, [onSelect] can be provided to respond only when an item
/// selection closes the menu.
///
/// The [physics] parameter describes the [ScrollPhysics] to use for the menu's
/// scrollable. If the menu's contents are not larger than its constraints, the
/// menu will not scroll regardless of the physics.
///
/// The [useRootNavigator] parameter is used to determine whether to push the
/// menu to the root navigator, thereby pushing the menu above all other
/// navigators. If false, the menu will be pushed to the nearest navigator.
///
/// The [clip] parameter describes the clip behavior to use for the menu's
/// surface. In most cases, the default value of [Clip.antiAlias] should be
/// used. However, [Clip.antiAliasWithSaveLayer] may be used if elements of the
/// screen that are not under the menu surface bleed onto the menu's backdrop.
/// This occurs because [BackdropFilter] is applied to the entire screen, and
/// not just the menu. Afterwards, the blurred screen is clipped to the menu's
/// bounds. Save layers are expensive, so this option should only be used if
/// absolutely necessary.
///
/// {@tool dartpad}
/// ** See code in examples/api/lib/cupertino/menu/cupertino_menu.0.dart **
/// {@end-tool}
///
/// See also:
///
/// * [CupertinoMenuItem], a menu item with a trailing widget slot.
/// * [CupertinoCheckedMenuItem], a menu item that displays a leading checkmark
///   widget when selected
/// * [CupertinoMenuLargeDivider], a large divider that can be placed between
///   groups of menu items.
/// * [CupertinoMenuTitle], a small title that can be used to label groups of
///   menu items.
/// * [CupertinoMenuActionItem], a fractional-width menu item intended for menu
///   actions.
/// * [CupertinoNestedMenu], a menu item that expands to show a nested menu.
/// * [showCupertinoMenu], an alternative way of displaying a [CupertinoMenu].
// TODO(davidhicks980): Document the cupertino_menu.0.dart dartpad example.
class CupertinoMenuButton extends StatefulWidget {
  /// Creates a [CupertinoButton] that shows a [CupertinoMenu] when pressed.
  const CupertinoMenuButton({
    super.key,
    required this.itemBuilder,
    this.enabled = true,
    this.onOpen,
    this.onClose,
    this.constraints,
    this.offset,
    this.child,
    this.enableFeedback = true,
    this.physics,
    this.controller,
    this.useRootNavigator = false,
    this.minSize,
    this.buttonPadding,
    this.edgeInsets = const EdgeInsets.all(CupertinoMenu.defaultEdgeInsets),
    this.clip = Clip.antiAlias,
    this.focusNode,
  });

  /// Called when building the menu items and when a new itemBuilder is provided.
  final CupertinoMenuItemBuilder itemBuilder;

  /// If provided, [child] is the widget used for this button
  ///
  /// The button will utilize a [CupertinoButton] for taps.
  final Widget? child;

  /// The offset is applied relative to the initial position set by the
  /// [alignment].
  ///
  /// When not set, the offset defaults to [Offset.zero].
  final Offset? offset;

  /// Whether this popup menu button is interactive.
  ///
  /// Must be non-null, defaults to `true`
  ///
  /// If `true`, the button will respond to presses by displaying the menu.
  ///
  /// If `false`, the button will be given disabled styling and will not respond
  /// to press or focus.
  final bool enabled;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// If true, Feedback.forTap will be called when the menu is opened.
  ///
  /// Defaults to true.
  final bool enableFeedback;

  /// Called when the user dismisses the menu, regardless of whether an item has
  /// been selected
  final VoidCallback? onClose;

  /// Called when the menu begins opening.
  ///
  /// When called, enabled menu items will have been built and will be selectable.
  final VoidCallback? onOpen;

  /// Constraints to apply to this menu layer.
  ///
  /// By default, the menu will expand to fit the lesser of the total height of
  /// the menu items and the bounds of the screen.
  final BoxConstraints? constraints;

  /// Minimum size of the button. Equivalent to [CupertinoButton.minSize]
  final double? minSize;

  /// Padding to apply to this menu layer.
  final EdgeInsetsGeometry? buttonPadding;

  /// The insets to avoid when positioning the menu.
  final EdgeInsets edgeInsets;

  /// The physics to use for the menu's scrollable.
  ///
  /// If the menu's contents are not larger than its constraints, scrolling
  /// will be disabled regardless of the physics.
  ///
  /// Defaults to true.
  final ScrollPhysics? physics;

  /// {@macro CupertinoMenuController}
  final CupertinoMenuController? controller;

  /// A focus node that can be used to focus this menu button.
  final FocusNode? focusNode;

  /// The clip behavior to use for the menu's surface.
  ///
  /// In most cases, the default value of [Clip.antiAlias] should be used.
  /// However, [Clip.antiAliasWithSaveLayer] may be used if elements of the
  /// screen that are not under the menu surface bleed onto the menu's backdrop.
  /// This occurs because [BackdropFilter] is applied to the entire screen, and
  /// not just the menu. Afterwards, the blurred screen is clipped to the menu's
  /// bounds. Save layers are expensive, so this option should only be used if
  /// absolutely necessary.
  // TODO(davidhicks980): Does this Clip.antiAliasWithSaveLayer description make sense?
  final Clip clip;

  /// Whether to push the menu to the root navigator.
  final bool useRootNavigator;

  @override
  State<CupertinoMenuButton> createState() => CupertinoMenuButtonState();
}

/// The [State] for a [CupertinoMenuButton].
///
/// To imperatively open a [CupertinoMenuButton] without using a
/// [CupertinoMenuController], a [GlobalKey] can be passed to
/// [CupertinoMenuButton] and [CupertinoMenuButtonState.showMenu] can be
/// called from [GlobalKey.currentState].
class CupertinoMenuButtonState extends State<CupertinoMenuButton>
      implements CupertinoMenuControlMixin {
  final ValueNotifier<int> _rebuildSignal = ValueNotifier<int>(0);
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _simulateTap),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: _simulateTap),
  };
  CupertinoMenuController? _controller;

  @override
  bool get isOpen => _isOpen;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CupertinoMenuController();
    _controller?._controller = this;
  }

  @override
  void reassemble() {
    super.reassemble();
    rebuild();
  }

  @override
  void didUpdateWidget(CupertinoMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller?._controller = null;
      _controller = widget.controller ?? CupertinoMenuController();
      _controller?._controller = this;
    }
  }

  @override
  void dispose() {
    _rebuildSignal.dispose();
    _controller?._controller = null;
    super.dispose();
  }

  void _handleOpen() {
    widget.onOpen?.call();
  }

  @override
  void open() {
    if (!_isOpen) {
      showMenu();
    }
  }

  @override
  void rebuild() {
    if (_isOpen && mounted) {
      _rebuildSignal.value += 1;
    }
  }

  @override
  void close() {
    if (_isOpen) {
      Navigator.pop(context);
    }
  }

  void _simulateTap(Intent intent){
    showMenu();
  }

  /// Shows a [CupertinoMenu] in the current navigator
  void showMenu() {
    if (widget.enableFeedback) {
      HapticFeedback.lightImpact();
    }

    final RenderBox anchor = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(context, rootNavigator: widget.useRootNavigator)
        .overlay!
        .context
        .findRenderObject()! as RenderBox;
    final Offset offset = widget.offset ?? Offset.zero;
    final Rect anchorRect = Rect.fromPoints(
        anchor.localToGlobal(offset, ancestor: overlay),
        anchor.localToGlobal(
          anchor.size.bottomRight(offset) + offset,
          ancestor: overlay,
        ),
      );
    final RelativeRect anchorPosition = RelativeRect.fromSize(
      anchorRect,
      overlay.size,
    );

    _isOpen = true;
    final Alignment alignment = Alignment(
        (anchorRect.center.dx / overlay.size.width) * 2 - 1,
        (anchorRect.center.dy / overlay.size.height) * 2 - 1,
      );
    showCupertinoMenu(
      alignment: alignment,
      anchorPosition: anchorPosition,
      context: context,
      clip: widget.clip,
      constraints: widget.constraints,
      itemBuilder: widget.itemBuilder,
      offset: offset,
      onOpened: _handleOpen,
      physics: widget.physics,
      rebuildSignal: _rebuildSignal,
      useRootNavigator: widget.useRootNavigator,
      settings: const RouteSettings(name: '_CupertinoMenu'),
      edgeInsets: widget.edgeInsets,
    );
  }

  bool get _canRequestFocus {
    final NavigationMode mode = MediaQuery.maybeNavigationModeOf(context)
                                ?? NavigationMode.traditional;
    return switch (mode) {
      NavigationMode.traditional => widget.enabled,
      NavigationMode.directional => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: widget.focusNode,
      enabled: _canRequestFocus,
      actions: _actionMap,
      child: CupertinoButton(
        pressedOpacity: widget.child != null ? 1 : 0.4,
        onPressed: widget.enabled ? showMenu : null,
        minSize: widget.minSize,
        padding: widget.buttonPadding ?? EdgeInsets.zero,
        child: IconTheme.merge(
          data: IconTheme.of(context),
          child: widget.child
                  ?? const Icon(
                       CupertinoIcons.ellipsis_circle,
                       size: 24
                     ),
        ),
      )
    );
  }
}

/// Shows a Cupertino-style menu with items built by [itemBuilder] at
/// [anchorPosition].
///
/// The [alignment] parameter determines the position of the menu relative to
/// the screen. If provided, an [offset] will displace the menu from its
/// [anchorPosition].
///
/// The [semanticLabel] is used by accessibility frameworks to announce screen
/// transitions when the menu is opened and closed. If this label is not
/// provided, it will default to "Popup menu".
///
/// A [rebuildSignal] can be provided to rebuild the menu's items. Whenever the
/// listener emits, [itemBuilder] will be called. For example, the
/// [CupertinoCheckedMenuItem] widget updates its leading checkmark when the
/// rebuildSignal emits.
///
/// If the [itemBuilder] returns items (in other words, if the menu is not
/// empty), the [onOpened] callback will be called immediately before the menu
/// starts opening.
///
/// The [constraints] parameter describes the [BoxConstraints] to apply to this
/// menu layer. By default, the menu will expand to fit the lesser of the total
/// height of the menu items and the bounds of the screen. The [edgeInsets] can
/// be used to avoid screen edges when positioning the menu. The menu will
/// ignore [MediaQuery] padding.
///
/// The [physics] parameter describes the [ScrollPhysics] to use for the menu's
/// scrollable. If the menu's contents are not larger than its constraints, the
/// menu will not scroll regardless of the physics.
///
/// The [useRootNavigator] parameter is used to determine whether to push the
/// menu to the root navigator, thereby pushing the menu above all other
/// navigators. If false, the menu will be pushed to the nearest navigator.
///
///
/// See also:
///
/// * [CupertinoMenuItem], a simple menu item with a trailing widget slot.
/// * [CupertinoCheckedMenuItem], a menu item that displays a leading checkmark
///   widget when selected
/// * [CupertinoMenuActionItem], a fractional-width menu item intended for
///   desktop-style quick actions.
/// * [CupertinoMenuLargeDivider], a menu item that displays a large divider.
/// * [CupertinoMenuTitle],  a menu item that displays a title.
/// * [CupertinoNestedMenu], a menu item that can be expanded to show a nested
///   menu.
// TODO(davidhicks980): Determine a default value for semanticLabel.
Future<void> showCupertinoMenu({
  required BuildContext context,
  required RelativeRect anchorPosition,
  required List<Widget> Function(BuildContext) itemBuilder,
  ui.Brightness? brightness,
  Alignment? alignment,
  BoxConstraints? constraints,
  Clip clip = Clip.antiAlias,
  VoidCallback? onOpened,
  Offset offset = Offset.zero,
  ScrollPhysics? physics,
  RouteSettings? settings,
  ValueListenable<int> rebuildSignal = const AlwaysStoppedAnimation<int>(0),
  String? semanticLabel = 'Popup Menu',
  EdgeInsets? edgeInsets,
  bool useRootNavigator = false,
}) async {
  // Build items initially so that we know whether we need to push the menu on
  // the navigation stack. If the menu is empty, we don't need to push it.
  List<Widget>? initialMenuItems = itemBuilder(context);
  if (initialMenuItems.isEmpty) {
    return;
  }

  onOpened?.call();
  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final Size overlaySize = navigator.overlay!.context.size!;
  final Size anchorSize = anchorPosition.toSize(overlaySize);
  Alignment? menuAlignment = alignment;
  final CapturedThemes inheritedTheme = InheritedTheme.capture(
    from: context,
    to: navigator.context,
  );
  return navigator.push<void>(
    _CupertinoMenuRoute(
      curve: const ElasticOutCurve(1.65),
      reverseCurve: Curves.easeIn,
      settings: settings,
      // Approximation
      transitionDuration: const Duration(milliseconds: 444),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      barrierLabel: _getLocalizedBarrierLabel(context),
      pageBuilder: (
        BuildContext childContext,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {

        if(menuAlignment == null){
          final Offset anchorCenter = Offset(
            anchorPosition.left + anchorSize.width / 2,
            anchorPosition.top + anchorSize.height / 2,
          );
          menuAlignment = Alignment(
            (anchorCenter.dx / overlaySize.width) * 2 - 1,
            (anchorCenter.dy / overlaySize.height) * 2 - 1,
          );
        }

        final Widget child = inheritedTheme.wrap(
            ValueListenableBuilder<int>(
              valueListenable: rebuildSignal,
              builder:(BuildContext context, int value, Widget? child) {
                final List<Widget> menuItems;
                if (value == 0) {
                  menuItems = initialMenuItems ?? itemBuilder(context);
                  initialMenuItems = null;
                } else {
                  menuItems = itemBuilder(context);
                }

                return CupertinoMenu(
                  brightness: brightness,
                  alignment: menuAlignment!,
                  offset: offset,
                  animation: animation,
                  anchorPosition: anchorPosition,
                  anchorSize: anchorSize,
                  hasLeadingWidget: menuItems.any(
                    (Widget item) => item is CupertinoMenuEntry && item.hasLeading
                  ),
                  constraints: constraints,
                  physics: physics,
                  clip: clip,
                  edgeInsets: edgeInsets,
                  children: menuItems,
                );
              },
            ),
        );


        return  Directionality(
            textDirection: Directionality.of(context),
            child: Builder(
              builder: (BuildContext localContext) {
                return MediaQuery(
                  data: MediaQuery.of(localContext).copyWith(
                    textScaler: MediaQuery.textScalerOf(context),
                  ),
                  child: child,
                );
              }
          ),
        );
      },
    ),
  );
}


String _getLocalizedBarrierLabel(BuildContext context) {
  // Use this instead of `CupertinoLocalizations.of(context)` because
  // [CupertinoLocalizations] might be null in some cases.
  final CupertinoLocalizations? cupertinoLocalizations =
      Localizations.of<CupertinoLocalizations>(context, CupertinoLocalizations);

  // If both localizations are null, fallback to
  // [DefaultMaterialLocalizations().modalBarrierDismissLabel].
  return cupertinoLocalizations?.modalBarrierDismissLabel
         ?? const DefaultCupertinoLocalizations().modalBarrierDismissLabel;
}

class _CupertinoMenuRoute extends PopupRoute {
  _CupertinoMenuRoute({
    required this.barrierLabel,
    required this.pageBuilder,
    required this.curve,
    required this.reverseCurve,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
    super.settings,
  }) : super(traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop);

  final Curve curve;
  final Curve reverseCurve;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) pageBuilder;

  @override
  final Duration transitionDuration;

  @override
  final Duration reverseTransitionDuration;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return pageBuilder(
             context,
             animation,
             secondaryAnimation,
           );
  }

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
             parent: super.createAnimation(),
             curve: curve,
             reverseCurve: reverseCurve,
           );
  }
}


/// Contains a nested menu layer, along with information regarding the layer's
/// position.
///
/// The [coordinates] property describes the [CupertinoMenuCoordinates] of
/// this menu layer relative to the root menu layer.
///
/// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
///
/// The [height] property describes the height of this menu layer after it has
/// finished opening.
///
/// The [anchorOffset] property describes the offset of this layer's anchor from
///
@immutable
class _CupertinoMenuLayerDescription {
  /// Creates a menu layer description, which will be used to position and display
  /// the menu layer.
  const _CupertinoMenuLayerDescription({
    required this.height,
    required this.anchorOffset,
    required this.coordinates,
    required this.menu,
  });

  /// The height of the menu layer
  final double height;

  /// The offset of this layer's anchor from the top left corner of the anchor's
  /// parent layer.
  final double anchorOffset;

  /// The coordinates of this layer.
  final CupertinoMenuCoordinates coordinates;

  /// The menu layer widget.
  final Widget menu;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _CupertinoMenuLayerDescription &&
           other.height == height &&
           other.menu == menu &&
           other.coordinates == coordinates &&
           other.anchorOffset == anchorOffset;
  }

  @override
  int get hashCode => Object.hash(height, anchorOffset, coordinates, menu);
}

enum _MenuModelAspect {
  edgeInsets,
  layers,
  anchorPosition,
  growthDirection,
  nestingAnimation,
  interactiveLayers,
}

/// An [InheritedModel] that shares information regarding the layers of a
/// [CupertinoMenu].
///
/// See also:
/// * [CupertinoMenuLayer], which provides information about a single menu
///   layer
class _CupertinoMenuModel extends InheritedModel<_MenuModelAspect> {
  /// Creates a [_CupertinoMenuModel] -- an [InheritedModel] that shares
  /// information regarding the layers of a [CupertinoMenu].with it's
  /// descendants.
  const _CupertinoMenuModel({
    // ignore: unused_element
    super.key,
    required super.child,
    required this.edgeInsets,
    required this.layers,
    required this.anchorPosition,
    required this.growthDirection,
    required this.nestingAnimation,
    required this.interactiveLayers,
  });

  /// The insets to avoid when positioning the menu.
  final EdgeInsets edgeInsets;

  /// The menu layers that are currently visible.
  ///
  /// Along with containing the build menu layer, the
  /// [_CupertinoMenuLayerDescription] provides information about the layer's
  /// position and size.
  final List<_CupertinoMenuLayerDescription> layers;

  /// The position of the root menu's anchor relative to the screen.
  final RelativeRect anchorPosition;

  /// The direction that the menu grows from the anchor.
  final VerticalDirection growthDirection;

  /// Tracks the sum of all partially- or fully-visible menu animations.
  final Animation<double> nestingAnimation;

  /// The menu layers that can respond to user input.
  ///
  /// {@template flutter.cupertino.MenuModel.interactiveLayers}
  /// The root menu becomes interactive when the route animation  complete, and
  /// will stay interactive until the menu has started closing or until a child
  /// layer has finished opening.
  ///
  /// A nested menu becomes interactive when it begins opening. The layer will
  /// stay interactive until it has finished closing, a child layer begins
  /// opening, or the root menu begins closing.
  /// {@endtemplate}
  final Set<CupertinoMenuCoordinates> interactiveLayers;

  @override
  bool updateShouldNotify(_CupertinoMenuModel oldWidget) {
    return oldWidget.edgeInsets != edgeInsets
        || oldWidget.anchorPosition != anchorPosition
        || oldWidget.growthDirection != growthDirection
        || oldWidget.nestingAnimation != nestingAnimation
        || !listEquals(oldWidget.layers, layers)
        || !setEquals(oldWidget.interactiveLayers, interactiveLayers);
  }

  @override
  bool updateShouldNotifyDependent(
    _CupertinoMenuModel oldWidget,
    // ignore: library_private_types_in_public_api
    Set<_MenuModelAspect> dependencies,
  ) {
    for (final _MenuModelAspect dependencies in dependencies) {
      switch (dependencies) {
        case _MenuModelAspect.edgeInsets:
          if (edgeInsets != oldWidget.edgeInsets) {
            return true;
          }
        case _MenuModelAspect.anchorPosition:
          if (anchorPosition != oldWidget.anchorPosition) {
            return true;
          }
        case _MenuModelAspect.growthDirection:
          if (growthDirection != oldWidget.growthDirection) {
            return true;
          }
        case _MenuModelAspect.nestingAnimation:
          if (nestingAnimation != oldWidget.nestingAnimation) {
            return true;
          }
        case _MenuModelAspect.layers:
          if (!listEquals(layers, oldWidget.layers)) {
            return true;
          }
        case _MenuModelAspect.interactiveLayers:
          if (!setEquals(interactiveLayers, oldWidget.interactiveLayers)) {
            return true;
          }
      }
    }
    return false;
  }
}

// Information shared between all layers of a [CupertinoMenu].
//
// The [rootMenuLayer] is the first layer of the menu.
//
// The [anchorPosition] describes the position of the root menu's anchor
// relative to the screen. A relative rect is used to allow the menu to
// reposition itself if the screen size changes.
//
// The [alignment] property describes the section of the root anchor that the
// menu should grow from.
class _MenuScope extends StatefulWidget {
  const _MenuScope({
    required this.child,
    required this.rootMenuLayer,
    required this.anchorPosition,
    required this.alignment,
    required this.edgeInsets,
  });

  final Widget child;

  // The first layer of the menu.
  final Widget rootMenuLayer;

  // The position of the root menu's anchor relative to the screen.
  final RelativeRect anchorPosition;

  // The alignment of the root menu relative to the anchor position.
  final Alignment alignment;

  // The screen insets to avoid when positioning the menu.
  final EdgeInsets edgeInsets;


  @override
  State<_MenuScope> createState() => _MenuScopeState();
}

class _MenuScopeState extends State<_MenuScope> with TickerProviderStateMixin {
  static const Duration _forceCloseDuration = Duration(milliseconds: 50);
  // A list of built layers in ascending order
  final List<Widget> _visibleLayers = <Widget>[];

  // Map of layer ID to layer builder
  final Map<String, CupertinoNestedMenuControlMixin> _layerIdToMenuControl =
      <String, CupertinoNestedMenuControlMixin>{};

  // Map of layer ID to anchor offset from the top left corner of the layer.
  final Map<String, double> _layerIdToAnchorOffset = <String, double>{};

  // Map of layer ID to layer size
  final Map<String, double> _layerIdToHeight = <String, double>{};

  // A list of layer coordinates corresponding to visible layers in ascending order
  final List<CupertinoMenuCoordinates> _layerCoordinates = <CupertinoMenuCoordinates>[
    CupertinoMenu.rootMenuCoordinates,
  ];

  // Tracks the progress of all partially- or fully-visible menu simulations,
  // including overshoot.
  AnimationController? _nestingAnimation;

  // These are initialized in initState because their type definitions
  // are long enough to affect readability.
  final Map<String, _AnimationControllerWithStatusOverride> _layerIdToAnimation =
      <String, _AnimationControllerWithStatusOverride>{};

  // Nested layer animations ordered by depth
  final List<_AnimationControllerWithStatusOverride> _animations =
      <_AnimationControllerWithStatusOverride>[];

  /// Duration of the animation that runs when a menu layer is force closed.
  bool _isForceClosing = false;
  // The topmost nested menu controller, if that menu is currently closing.
  // Otherwise, null. Used to force the closing menu to finish before
  // opening or closing a new menu.
  _AnimationControllerWithStatusOverride? _closingController;

  Set<CupertinoMenuCoordinates> _interactiveLayers =
      <CupertinoMenuCoordinates>{CupertinoMenu.rootMenuCoordinates};

  // The direction that the menu grows from the anchor.
  VerticalDirection get _growthDirection {
    return widget.anchorPosition.top >= widget.anchorPosition.bottom * 0.95
          ? VerticalDirection.up
          : VerticalDirection.down;
  }

  // The number of layers above the root layer once all animations have
  // completed.
  int get depth => _depth;
  int _depth = 0;

  @override
  void initState() {
    super.initState();
    _nestingAnimation = AnimationController.unbounded(vsync: this);
  }

  @override
  void dispose() {
    _nestingAnimation?.dispose();
    for (
      final AnimationController animation
      in _layerIdToAnimation.values.toList()
    ) {
      animation
        ..stop()
        ..dispose();
    }
    super.dispose();
  }

  // Removes the topmost layer from the menu, returning whether or not the layer
  // was successfully removed.
  Future<bool> popMenu() async {
    if (_depth == 0) {
      return false;
    }

    return _setTopMenu(_layerCoordinates[_depth - 1]);
  }

  // Builds, attaches, and animates a new layer to the top of the menu,
  // returning whether or not the layer was successfully attached.
  Future<bool> pushMenu({required CupertinoMenuCoordinates coordinates}) async {
    if (coordinates.depth != _depth + 1) {
      return false;
    }

    return _setTopMenu(coordinates);
  }

  // Runs a simulation on the given animation controller, and returns whether or
  // not the simulation has stopped running.
  Future<bool> _runSimulation({
    required _AnimationControllerWithStatusOverride controller,
    required SpringSimulation simulation,
    required bool forward,
  }) {
    final Completer<bool> simulationCompleter = Completer<bool>();
    controller
      ..overrideStatus(
          forward
          ? AnimationStatus.forward
          : AnimationStatus.reverse,
      )
      ..animateWith(simulation)
          .whenCompleteOrCancel(() {
            if (!controller.isAnimating) {
              controller.overrideStatus(
                  forward
                  ? AnimationStatus.completed
                  : AnimationStatus.dismissed,
              );
              simulationCompleter.complete(true);
            } else {
              simulationCompleter.complete(false);
            }
          });
    return simulationCompleter.future;
  }

  // Sums all current layer animations. A function is used instead of a
  // CompoundAnimation to make it easier to add/remove animations.
  void _updateAnimationValue() {
    double value = 0;
    for (
      final _AnimationControllerWithStatusOverride controller
      in _layerIdToAnimation.values
    ) {
      value += controller.value;
    }

    _nestingAnimation?.value = value;
  }

  // If the top layer has closed by at least 30%, the underlying layer is made
  // interactive.
  //
  // TODO(davidhicks980): Determine the behavior of setEquals.
  // As far as I can tell, because setEquals calls identical, it appears a new
  // Set must be created to update the setEquals result.
  void _updateInteractiveLayers() {
    final double value = _nestingAnimation!.value;
    final CupertinoMenuCoordinates layer =
        _layerCoordinates[math.max(_layerCoordinates.length - 2, 0)];
    if (_closingController != null && value.remainder(1) < 0.7) {
      if (!_interactiveLayers.contains(layer)) {
        setState(() {
          _interactiveLayers = <CupertinoMenuCoordinates>{
            ..._interactiveLayers,
            layer,
          };
        });
      }
    } else if (_interactiveLayers.contains(layer)) {
      setState(() {
        _interactiveLayers = <CupertinoMenuCoordinates>{
          ..._interactiveLayers,
        }..remove(layer);
      });
    }
  }

  /// Sets the topmost menu layer to the given coordinates.
  ///
  /// If not already attached, this function builds, attaches, and animates the
  /// layer open. If the layer is attached and fully open, the layer is animated
  /// closed and detached. If the layer is animating open or closed, the layer
  /// animation is reversed.
  ///
  /// The [coordinates] parameter must specify an attached
  /// [CupertinoNestedMenuControlMixin] that is within one layer of the current
  /// depth of the menu. The menu depth describes the number of nested layers
  /// that will be visible once all animations have completed. The root menu is
  /// at depth 0, and each nested menu increases the depth by 1.
  Future<bool> _setTopMenu(CupertinoMenuCoordinates coordinates) async {
    assert(
      coordinates.depth >= 0 &&
      coordinates.depth <= _depth + 1 &&
      coordinates.depth >= _depth - 1,
      'An invalid layer was provided: $coordinates. '
      'Current depth: $_depth. '
      'The layer must be within one layer of the current depth of the menu.',
    );
    assert(
      _layerIdToMenuControl.containsKey(coordinates.layerId)
      || coordinates == CupertinoMenu.rootMenuCoordinates,
      'The provided coordinates do not describe a menu layer: $coordinates',
    );
    final int depth = coordinates.depth;
    final bool isOpening = depth > _depth;

    // If a layer is closing and while a layer attached to a different anchor is
    // pushed or popped, force the closing layer to finish before attempting the
    // requested action.
    if (
      (!isOpening || _layerCoordinates.last != coordinates)
      && _closingController != null
    ) {
      if (_isForceClosing) {
        return false;
      }
      _isForceClosing = true;
      // Because a simulation is not used to force-close the menu,
      // the AnimationController will properly report its status when the
      // animation completes.
      _closingController!.clearStatus();
      await _closingController!.animateBack(0, duration: _forceCloseDuration);
      _isForceClosing = false;
      if (mounted) {
        setState(() {
          _detachMenu();
        });
        _closingController = null;
        return _setTopMenu(coordinates);
      } else {
        return false;
      }
    }

    if (isOpening && _visibleLayers.length < depth) {
      final bool isAttached = _attachMenu(coordinates);
      if (!isAttached) {
        return false;
      }
    }

    setState(() {
      _depth = depth;
    });

    final _AnimationControllerWithStatusOverride controller =
        _animations[isOpening ? _depth - 1 : _depth];
    if (!isOpening) {
      assert(
        _closingController == null,
        'Only one layer can close at a time',
      );
      _closingController = controller;
    } else {
      _closingController = null;
    }

    final bool completed = await _runSimulation(
      controller: controller,
      simulation: SpringSimulation(
        isOpening
            ? CupertinoMenu.forwardNestedSpring
            : CupertinoMenu.reverseNestedSpring,
        controller.value,
        isOpening ? 1 : 0,
        5,
      ),
      forward: isOpening,
    );

    if (completed && mounted) {
      if (isOpening) {
        setState(() {
          _interactiveLayers = <CupertinoMenuCoordinates>{_layerCoordinates.last};
        });
      } else {
        setState(() {
          _detachMenu();
        });
      }
      return true;
    }
    return false;
  }

  // Records the final height of the layer once the animation has completed.
  void _setNestedLayerHeight({
    required CupertinoMenuCoordinates coordinates,
    required double height,
  }) {
    final double value = (height * 10).roundToDouble() / 10;
    if (_layerIdToHeight[coordinates.layerId] != value) {
      setState(() {
        _layerIdToHeight[coordinates.layerId] = value;
      });
    }
  }

  // Records the vertical offset of this menu layer from the top left corner of
  // it's parent ListBody.
  void _setVerticalAnchorOffset({
    required CupertinoMenuCoordinates coordinates,
    required double yOffset,
  }) {
    final double value = (yOffset * 10).roundToDouble() / 10;
    if (_layerIdToAnchorOffset[coordinates.layerId] != value) {
      setState(() {
        _layerIdToAnchorOffset[coordinates.layerId] = value;
      });
    }
  }

  void _attachMenuControl(CupertinoNestedMenuControlMixin control) {
    final String id = control.coordinates!.layerId;
    final _AnimationControllerWithStatusOverride animationController =
          _AnimationControllerWithStatusOverride.unbounded(vsync: this)
            ..addListener(_updateAnimationValue)
            ..addListener(_updateInteractiveLayers);
    animationController.overrideStatus(AnimationStatus.dismissed);
    control._attachAnimation(animationController);
    _layerIdToAnimation[id] = animationController;
    _layerIdToMenuControl[id] = control;
  }

  void _detachMenuControl(CupertinoNestedMenuControlMixin control) {
    final String? id = control.coordinates?.layerId;
    if (id != null) {
      _layerIdToMenuControl.remove(id);
      if (_layerIdToAnimation[id] != null) {
        control._detachAnimation(_layerIdToAnimation[id]!);
        _layerIdToAnimation[id]?.dispose();
        _layerIdToAnimation.remove(id);
      }
    }
  }

  // Builds the layer widget adds the layer to the list of visible layers.
  // Returns whether or not the layer was added. Layers are not added if they do
  // not have any items.
  bool _attachMenu(CupertinoMenuCoordinates coordinates) {
    final CupertinoNestedMenuControlMixin<StatefulWidget>? builder =
        _layerIdToMenuControl[coordinates.layerId];

    assert(
      builder?.mounted ?? false,
      '${builder.runtimeType} is not mounted: $coordinates',
    );

    final Widget? menu = builder!.buildMenu(
      builder.context,
      builder._rebuildSignal,
    );

    if (menu == null) {
      return false;
    }

    _visibleLayers.add(menu);
    _layerCoordinates.add(coordinates);
    _animations.add(_layerIdToAnimation[coordinates.layerId]!);
    _interactiveLayers.add(coordinates);
    return true;
  }

  /// Removes the topmost layer from the menu and sets the [_closingController]
  /// to null. This removes the layer from the list of interactive layers,
  /// and should be called when the layer has fully closed.
  void _detachMenu() {
    assert(_animations.last.isDismissed, 'The topmost layer is not finished closing');
    _visibleLayers.removeLast();
    _animations.removeLast();
    _layerCoordinates.removeLast();
    _interactiveLayers = <CupertinoMenuCoordinates>{_layerCoordinates.last};
    _closingController = null;
  }

  _CupertinoMenuLayerDescription _buildLayerDescription(CupertinoMenuCoordinates coordinates) {
    final String id = coordinates.layerId;
    return _CupertinoMenuLayerDescription(
        height: _layerIdToHeight[id] ?? 0,
        anchorOffset: _layerIdToAnchorOffset[id] ?? 0,
        coordinates: coordinates,
        menu: coordinates.depth == 0
                ? widget.rootMenuLayer
                : _visibleLayers[coordinates.depth - 1],
      );
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoMenuModel(
      edgeInsets: widget.edgeInsets,
      interactiveLayers: _interactiveLayers,
      nestingAnimation: _nestingAnimation!,
      anchorPosition: widget.anchorPosition,
      growthDirection: _growthDirection,
      layers: _layerCoordinates.map(_buildLayerDescription).toList(),
      child: widget.child,
    );
  }
}

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
    required this.childCount,
    required this.coordinates,
    required this.isInteractive,
    this.controller,
  });

  /// The constraints that describe the expansion of this menu layer.
  ///
  /// The [constraintsTween] animates between the size of the menu item
  /// anchoring this layer, and the intrinsic size of this layer (or the
  /// constraints provided by the user, if the constraints are smaller than the
  /// intrinsic size of the layer).
  final BoxConstraintsTween constraintsTween;

  /// Whether items on this layer should respond to user input.
  ///
  /// {@macro flutter.cupertino.MenuModel.interactiveLayers}
  final bool isInteractive;

  /// Whether any menu items in this layer have a leading widget.
  ///
  /// If true, all menu items without a leading widget will be given
  /// leading padding to align with their siblings.
  final bool hasLeadingWidget;

  /// The number of menu items on this layer.
  ///
  /// The child count is used to determine the initial border radius of this
  /// layer prior to animating open.
  final int childCount;

  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
  final CupertinoMenuCoordinates coordinates;

  /// Returns the menu controller for this layer.
  final CupertinoMenuController? controller;

  @override
  bool updateShouldNotify(CupertinoMenuLayerModel oldWidget) {
    return constraintsTween.begin != oldWidget.constraintsTween.begin
        || constraintsTween.end   != oldWidget.constraintsTween.end
        || hasLeadingWidget       != oldWidget.hasLeadingWidget
        || childCount             != oldWidget.childCount
        || coordinates            != oldWidget.coordinates
        || isInteractive          != oldWidget.isInteractive
        || controller             != oldWidget.controller;
  }
}

/// {@template CupertinoMenuTreeCoordinates.description}
/// [CupertinoMenuCoordinates] describe the 3-dimensional position (row,
/// column, depth) of a menu item or layer in a [CupertinoMenu], as well as the
/// anchor path taken to reach it. A menu layer will have the
/// same coordinates as it's anchor, except it's depth will be one greater.
/// {@endtemplate}
///
/// {@template CupertinoMenuTreeCoordinates.depth}
/// The [depth] parameter is defined as the number of menu layers below this
/// menu item or layer. The root menu is at depth 0.
/// {@endtemplate}
///
/// {@template CupertinoMenuTreeCoordinates.path}
/// The [path] parameter lists the row indices of the anchors that were opened
/// to reach this layer. Nested menus can only occupy a single column, so the
/// row indices uniquely identify the menus opened to reach this layer. The path
/// array is ordered from the root menu to the current layer.
/// {@endtemplate}
///
/// {@template CupertinoMenuTreeCoordinates.row}
/// The [row] specifies the 0-indexed vertical position of the menu item
/// relative to it's menu layer. Items that contain multiple menu item children,
/// such as [CupertinoMenuActionRow], will have the same row as their children.
/// {@endtemplate}
///
/// {@template CupertinoMenuTreeCoordinates.column}
/// The [column] is the 0-indexed horizontal position of a [Widget]
/// menu item. Full-width menu items will be at column 0.
/// {@endtemplate}
///
/// {@template CupertinoMenuTreeCoordinates.layerId}
/// The [layerId] is a unique identifier for a menu entity. The layer ID follows
/// the pattern `${path.join(".")}-$depth-$row-$column`.
/// {@endtemplate}
///
/// ```dart
///                            //  row  column  depth  path
/// CupertinoMenuActionItem    //  0    0       0      [0]
/// CupertinoMenuActionItem    //  0    1       0      [0]
/// CupertinoMenuActionItem    //  0    2       0      [0]
/// CupertinoMenuTitle         //  1    0       0      [0]
/// CupertinoLargeMenuDivider  //  2    0       0      [0]
/// CupertinoNestedMenu        //  3    0       0      [0]
/// ├── CupertinoMenuItem      //  0    0       1      [0.3]
/// ├── CupertinoMenuItem      //  1    0       1      [0.3]
/// ├── CupertinoNestedMenu    //  2    0       1      [0.3]
/// │   ├── CupertinoMenuTitle //  0    0       2      [0.3.2]
/// │   ├── CupertinoMenuItem  //  1    0       2      [0.3.2]
/// │   └── CupertinoMenuItem  //  2    0       2      [0.3.2]
/// └── CupertinoMenuItem      //  3    0       1      [0.3]
/// CupertinoCheckedMenuItem   //  4    0       0      [0]
/// CupertinoMenuItem          //  5    0       0      [0]
///
///  // Layer coordinates
///  // 0                          0    0       0      []
///  // 1                          3    0       1      [0]
///  // 2                          3    0       2      [0.3]
/// ```
// TODO(davidhicks980): Format the tree diagram for dartdoc.
@immutable
class CupertinoMenuCoordinates {
  /// Constructs [CupertinoMenuCoordinates] from the anchor
  /// coordinates of a menu layer.
  const CupertinoMenuCoordinates.fromAnchorCoordinates({
    required this.row,
    required this.column,
    required this.path,
    required int anchorDepth,
  }) : depth = anchorDepth + 1;

  /// Constructs [CupertinoMenuCoordinates] from the coordinates of a
  /// menu item.
  const CupertinoMenuCoordinates.fromLayerCoordinates({
    required this.depth,
    required this.row,
    required this.column,
    required this.path,
  });

  /// Constructs [CupertinoMenuCoordinates] from the layer ID of a menu
  /// layer.
  ///
  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
  ///
  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.layerId}
  factory CupertinoMenuCoordinates.fromLayerId({
    required String layerId,
  }) {
    final [
      String path,
      String depth,
      String row,
      String column
    ] = layerId.split('-');
    return CupertinoMenuCoordinates.fromLayerCoordinates(
      depth:  int.parse(depth),
      row:    int.parse(row),
      column: int.parse(column),
      path:   path.split('.').map(int.parse).toList(),
    );
  }

 /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.row}
  final int row;

 /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.column}
  final int column;

 /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.depth}
  final int depth;

  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.path}
  final List<int> path;

  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.layerId}
  String get layerId => '${path.join(".")}-$depth-$row-$column';

  /// The depth of the anchor that opened this layer.
  int get anchorDepth => depth - 1;

  @override
  String toString() =>
      'MenuItemDetails(row: $row, '
      'column: $column, '
      'anchorDepth: $anchorDepth, '
      'layerDepth: $depth, '
      'path: ${path.join(".")})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CupertinoMenuCoordinates &&
           other.row    == row    &&
           other.column == column &&
           other.depth  == depth  &&
           listEquals(other.path, path);
  }

  @override
  int get hashCode => Object.hash(row, column, depth, path);
}

/// An inherited wrapper that provides positional information to a
/// [Widget].
///
/// The [coordinates] parameter describes the position of this menu item in the
/// menu via [CupertinoMenuCoordinates].
///
/// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
class _MenuCoordinateScope extends InheritedWidget{
  /// Creates a [_MenuCoordinateScope] that provides positional information to a
  /// [Widget].
  const _MenuCoordinateScope({
    required this.coordinates,
    required super.child,
  });

  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
  final CupertinoMenuCoordinates coordinates;


  /// Returns the [CupertinoMenuCoordinates] for this [Widget].
  static CupertinoMenuCoordinates? maybeOf(BuildContext context) {
    return context
           .dependOnInheritedWidgetOfExactType<_MenuCoordinateScope>()
           ?.coordinates;
  }

  /// Returns the [CupertinoMenuCoordinates] for this [Widget].
  static CupertinoMenuCoordinates of(BuildContext context) {
    final CupertinoMenuCoordinates? result = maybeOf(context);
    assert(result != null, 'No ScopedMenuItemIndex found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_MenuCoordinateScope oldWidget) {
    return oldWidget.coordinates != coordinates;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ScopedMenuItemDetails($coordinates)';
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
    this.clip = Clip.antiAlias,
    this.offset = Offset.zero,
    this.physics,
    this.constraints,
    EdgeInsets? edgeInsets,
  }) : edgeInsets = edgeInsets ?? const EdgeInsets.all(defaultEdgeInsets);

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

  /// The insets to avoid when positioning the menu.
  final EdgeInsets edgeInsets;

  /// The [ui.Brightness] of the menu.
  final ui.Brightness? brightness;

  /// The [Radius] of the menu surface [ClipPath].
  static const Radius radius = Radius.circular(14);

  /// The amount of padding between the menu and the screen edge.
  static const double defaultEdgeInsets = 8;

  /// Returns the [CupertinoMenuCoordinates] of all menu layers which can
  /// respond to user input. Layers will only respond to user input when they are
  /// on top of the menu stack, or when they are below a closing menu layer.
  static Set<CupertinoMenuCoordinates> interactiveLayersOf(
    BuildContext context,
  ) {
    return InheritedModel.inheritFrom<_CupertinoMenuModel>(
      context,
      aspect: _MenuModelAspect.interactiveLayers,
    )!.interactiveLayers;
  }

  /// Returns the growth direction of the menu from the provided [BuildContext].
  ///
  /// The growth direction describes the [VerticalDirection] in which the menu
  /// grows, relative to the anchor it is attached to.
  static VerticalDirection growthDirectionOf(BuildContext context) {
    return InheritedModel.inheritFrom<_CupertinoMenuModel>(
      context,
      aspect: _MenuModelAspect.growthDirection,
    )!.growthDirection;
  }


  /// Returns the insets to avoid when positioning the menu.
  static EdgeInsets edgeInsetsOf(BuildContext context) {
    return InheritedModel.inheritFrom<_CupertinoMenuModel>(
      context,
      aspect: _MenuModelAspect.edgeInsets,
    )!.edgeInsets;
  }


  /// Pops the topmost menu layer from the menu. Returns whether or not the
  /// layer was successfully popped.
  static Future<bool> popLayer(BuildContext context) {
    return context.findAncestorStateOfType<_MenuScopeState>()!.popMenu();
  }

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
    mass: 5,
    stiffness: (2 * (math.pi / 0.2)) * (2 * math.pi / 0.2),
    damping: (4 * math.pi * 10) / 0.2,
  );

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

  /// The [CupertinoMenuCoordinates] of the root menu layer.
  ///
  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
  static const CupertinoMenuCoordinates rootMenuCoordinates =
    CupertinoMenuCoordinates.fromLayerCoordinates(
      path: <int>[],
      row: 0,
      column: 0,
      depth: 0,
    );

  /// Wraps [Widget]s with contextual information
  ///
  /// Modifications include:
  /// 1. [CupertinoMenuActionItem]s are grouped in sets of 2-4 and wrapped by
  ///    [CupertinoMenuActionRow]
  /// 2. Menu items are wrapped by [_MenuCoordinateScope] to provide location
  ///    information to the menu items
  ///
  // TODO(davidhicks980): Consider moving this logic to _MenuBody
  static List<_MenuCoordinateScope> _wrapMenuItems({
    required List<Widget> items,
    required int depth,
    required List<int> path,
  }) {
    List<Widget>? row;
    final List<_MenuCoordinateScope> entries = <_MenuCoordinateScope>[];
    for (int i = 0; i < items.length; i++) {
      final int rowIndex = entries.length;
      Widget child = items[i];
      assert(
        child is! CupertinoStickyMenuHeader || (i == 0 && depth == 0),
        'Sticky headers can only occupy the first position in the root layer of a CupertinoMenu.',
      );
      if (child is CupertinoMenuItemRowMixin) {
        // Group CupertinoMenuActionItems into rows of 2, 3 or 4.
        row ??= <Widget>[];
        row.add(
          _MenuCoordinateScope(
            coordinates: CupertinoMenuCoordinates.fromAnchorCoordinates(
              row: rowIndex,
              column: row.length,
              anchorDepth: depth,
              path: path,
            ),
            child: child,
          ),
        );
        if (
          row.length < 4 &&
          items.length > i + 1 &&
          items[i + 1] is CupertinoMenuItemRowMixin
        ) {
          continue;
        }
      }

      if (row?.isNotEmpty ?? false) {
        child = CupertinoMenuActionRow(
                  children: <Widget>[...row!],
                );
        row.clear();
      }

      assert(
        row?.isEmpty ?? true,
        'Row should be empty after wrapping action items',
      );

      entries.add(
        _MenuCoordinateScope(
          coordinates: CupertinoMenuCoordinates.fromAnchorCoordinates(
            row: rowIndex,
            column: 0,
            anchorDepth: depth,
            path: path,
          ),
          child: child,
        ),
      );
    }

    return entries;
  }

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
  List<Matrix4>? _flowTransformMatrices;
  Listenable? _repaintFlow;
  int _repaintAnimationHash = 0;

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

  void _cacheFlowTransformMatrices(List<Matrix4> value) {
    if (
      widget.animation.status == AnimationStatus.reverse &&
      _flowTransformMatrices == null
    ) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _flowTransformMatrices = value;
          });
        }
      });
    }
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

  void _updateRepaintListenable(Animation<double> nestingAnimation) {
    final int repaintAnimationsHash = Object.hash(
      _panPosition,
      _rootMenuRectNotifier,
      nestingAnimation,
      widget.animation,
    );
    if (repaintAnimationsHash != _repaintAnimationHash) {
      _repaintFlow = Listenable.merge(<Listenable?>[
        _panPosition,
        _rootMenuRectNotifier,
        nestingAnimation,
        widget.animation,
      ]);
      _repaintAnimationHash = repaintAnimationsHash;
    }
  }

  RelativeRect _insetAnchorPosition(
    BuildContext context,
    RelativeRect position
  ) {
    final ui.Size screenSize = MediaQuery.sizeOf(context);
    final EdgeInsets padding = widget.edgeInsets;
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
    final List<_MenuCoordinateScope> builtChildren =
      CupertinoMenu._wrapMenuItems(
        items: widget.children,
        depth: 0,
        path: <int>[0],
      );

    final Widget menu = _MenuContainer(
      depth: 0,
      animation: widget.animation,
      child: _MenuBody(
        physics: widget.physics,
        children: builtChildren,
      ),
    );

    final Widget rootMenuLayer = Builder(
      builder: (BuildContext context) {
        final MediaQueryData mediaQuery = MediaQuery.of(context);
        return CustomSingleChildLayout(
          delegate: _RootMenuLayout(
            onPositioned: _handleRootLayerPositioned(context),
            growthDirection: CupertinoMenu.growthDirectionOf(context),
            unboundedOffset: widget.offset,
            anchorPosition: _insetAnchorPosition(
              context,
              widget.anchorPosition,
            ),
            textDirection: Directionality.of(context),
            edgeInsets: CupertinoMenu.edgeInsetsOf(context),
            avoidBounds: DisplayFeatureSubScreen
                          .avoidBounds(mediaQuery)
                          .toSet(),
          ),
          child: menu,
        );
      },
    );

    final CupertinoThemeData theme = CupertinoTheme.of(context);
    return CupertinoTheme(
      data: theme.copyWith(
        brightness: widget.brightness
                      ?? theme.brightness
                      ?? CupertinoTheme.maybeBrightnessOf(context)
                      ?? ui.Brightness.light
      ),
      child: _MenuScope(
        edgeInsets: widget.edgeInsets,
        rootMenuLayer: rootMenuLayer,
        alignment: widget.alignment,
        anchorPosition: widget.anchorPosition,
        child: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                // Removes the top menu layer when the user taps on an underlying
                // layer.
                CupertinoMenu.popLayer(context);
              },
              child: CupertinoMenuLayer(
                isInteractive: CupertinoMenu
                                .interactiveLayersOf(context)
                                .contains(CupertinoMenu.rootMenuCoordinates),
                anchorSize: Size.zero,
                childCount: builtChildren.length,
                hasLeadingWidget: widget.hasLeadingWidget,
                coordinates: CupertinoMenu.rootMenuCoordinates,
                constraints: widget.constraints,
                child: CupertinoPanListener<PanTarget<StatefulWidget>>(
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  child: ScaleTransition(
                    alignment: widget.alignment,
                    scale: widget.animation,
                    child: Center(
                      child: Builder(
                        builder: (BuildContext context) {
                          final _CupertinoMenuModel model =
                              InheritedModel.inheritFrom<_CupertinoMenuModel>(context)!;
                          _updateRepaintListenable(model.nestingAnimation);
                          return Flow(
                            clipBehavior: Clip.none,
                            delegate: _CupertinoMenuFlowDelegate(
                              layers: model.layers,
                              repaint: _repaintFlow,
                              onPainted: _cacheFlowTransformMatrices,
                              alignment: widget.alignment,
                              routeAnimation: widget.animation,
                              nestingAnimation: model.nestingAnimation,
                              growthDirection: model.growthDirection,
                              overrideTransforms: _flowTransformMatrices,
                              rootMenuRectNotifier: _rootMenuRectNotifier,
                              rootAnchorPosition: _insetAnchorPosition(
                                context,
                                widget.anchorPosition,
                              ),
                              rootAnchorSize: widget.anchorSize,
                              pointerPositionNotifier: _panPosition,
                              padding: model.edgeInsets,
                            ),
                            children: model.layers
                                .map((_CupertinoMenuLayerDescription layer) => layer.menu)
                                .toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The amount of vertical shift applied to a menu layer after it has been
/// positioned.
typedef _CupertinoMenuVerticalOffset = ({
    double menuOffset,
    double layerOffset,
});

// Controls the position and scale of menu layers
class _CupertinoMenuFlowDelegate extends FlowDelegate {
  const _CupertinoMenuFlowDelegate( {
    super.repaint,
    required this.rootAnchorPosition,
    required this.rootMenuRectNotifier,
    required this.routeAnimation,
    required this.nestingAnimation,
    required this.alignment,
    required this.pointerPositionNotifier,
    required this.layers,
    required this.rootAnchorSize,
    this.overrideTransforms,
    this.onPainted,
    this.growthDirection = VerticalDirection.down,
    this.padding = EdgeInsets.zero,
  });

  final VerticalDirection growthDirection;
  final RelativeRect rootAnchorPosition;
  final Size rootAnchorSize;
  final Animation<double> nestingAnimation;
  final Animation<double> routeAnimation;
  final Alignment alignment;
  final ValueChanged<List<Matrix4>>? onPainted;
  final List<Matrix4>? overrideTransforms;
  final List<_CupertinoMenuLayerDescription> layers;
  final ValueNotifier<Rect?> rootMenuRectNotifier;
  final ValueNotifier<Offset?> pointerPositionNotifier;
  final EdgeInsets padding;

  static const double defaultShift = 16;

  Offset? get pointerPosition => pointerPositionNotifier.value;
  Rect get rootMenuRect => rootMenuRectNotifier.value ?? Rect.zero;

  @override
  void paintChildren(FlowPaintingContext context) {
    final List<Matrix4> transforms =
          overrideTransforms
            ?? List<Matrix4>.generate(
                context.childCount,
                (int int) => Matrix4.identity(),
                growable: false,
              );

    if (overrideTransforms == null) {
      _applyTransforms(context, transforms);
    }

    for (int i = 0; i < context.childCount; ++i) {
      context.paintChild(i, transform: transforms[i]);
    }

    onPainted?.call(transforms);
  }

  _CupertinoMenuVerticalOffset _positionChild({
    required Size size,
    required Rect anchorRect,
    required RelativeRect shiftedRootMenuAnchor,
    required int index,
  }) {
    final double finalLayerHeight = layers[index].height;
    // The fraction of the menu layer that is visible.
    // The top layer is allowed to be more than 100% visible to allow for
    // overshoot.
    double visibleFraction = 1.0;
    if(layers.length - 1 == index){
      visibleFraction = ui.clampDouble(nestingAnimation.value - index + 1, 0, 1.1);
    }

    // The offset of the menu layer from the top of the screen
    double layerYOffset = anchorRect.top;

    // The offset of the entire menu from the top of the screen
    double menuOffsetY = 0.0;

    if (growthDirection == VerticalDirection.up) {
      double rootAnchorTop = shiftedRootMenuAnchor.top;
      // A vertical shift is applied to each menu layer to create a cascading
      // effect. This shift is only noticeable when the menu layer would extend
      // beyond the top of the shifted root anchor position.
      rootAnchorTop -= defaultShift * (index - 1 + visibleFraction);
      // The menu layer, when fully extended, will overflow the larger of:
      //
      // 1. The area above the root anchor position.
      // 2. The largest underlying menu.
      //
      // The menu layer will be shifted upwards by the amount it overflows.
      if (rootAnchorTop + padding.top < finalLayerHeight + layerYOffset) {
        layerYOffset = ui.lerpDouble(
          layerYOffset,
          rootAnchorTop + padding.top - finalLayerHeight,
          visibleFraction,
        )!;
      }

      // Shift the menu down by the amount the menu overflows the top of the
      // root menu anchor.
      if (rootAnchorTop < finalLayerHeight) {
        menuOffsetY = ui.lerpDouble(
          0,
          finalLayerHeight - rootAnchorTop,
          visibleFraction,
        )!;
      }
    } else {
      final double rootAnchorBottom = shiftedRootMenuAnchor.bottom;
      // If the height of the menu layer is greater than the area underneath the
      // root anchor position minus bottom padding, shift the menu upwards by
      // the amount the menu overflows.
      if (size.height - padding.bottom < layerYOffset + finalLayerHeight) {
        if (finalLayerHeight > rootAnchorBottom - padding.bottom) {
          menuOffsetY = ui.lerpDouble(
            0,
            rootAnchorBottom - (finalLayerHeight + padding.bottom),
            visibleFraction,
          )!;
        } else {
          // If the layer overflows the bottom of the screen minus bottom padding,
          // shift the layer upwards by the amount it overflows.
          layerYOffset = ui.lerpDouble(
            layerYOffset,
            size.height - padding.bottom - finalLayerHeight,
            visibleFraction,
          )!;
        }
      }
    }

    return (
      layerOffset: layerYOffset,
      menuOffset: menuOffsetY,
    );
  }

  void _applyTransforms(
    FlowPaintingContext context,
    List<Matrix4> transforms,
  ) {
    final List<Offset> offsets = List<Offset>.generate(
      context.childCount,
      (int index) => Offset.zero,
      growable: false,
    );

    // The menuYOffset is the amount the menu extends past the top or bottom of
    // the root menu anchor position, depending on the growth direction.
    double menuYOffset = growthDirection == VerticalDirection.up
      ? math.max((rootMenuRect.height + padding.top) - rootAnchorPosition.top, 0)
      : math.min(rootAnchorPosition.bottom - (rootMenuRect.height + padding.bottom), 0);

    // The shiftedRootMenuAnchor is the anchor position of the root menu layer
    // after it has been shifted by the menuYOffset.
    RelativeRect shiftedRootMenuAnchor = rootAnchorPosition.shift(
        Offset(0, menuYOffset),
      );
    double previousLayerOffsetY = rootMenuRect.top;
    Rect totalMenuRect = rootMenuRect;
    // Two passes: First pass aggregates the offsets of each layer. Second pass
    // applies the offsets and scales the menu.
    /*  1st pass  */
    for (int depth = 1; depth < context.childCount; ++depth) {
        final Size size = context.getChildSize(depth) ?? Size.zero;
        Rect anchorRect = Rect.zero;
        if (layers.length > depth) {
          final double anchorOffset = layers[depth].anchorOffset;
          anchorRect = Rect.fromLTWH(
            rootMenuRect.left,
            anchorOffset + previousLayerOffsetY,
            size.width,
            size.height,
          );
        }
        final _CupertinoMenuVerticalOffset position = _positionChild(
          size: context.size,
          index: depth,
          anchorRect: anchorRect,
          shiftedRootMenuAnchor: shiftedRootMenuAnchor,
        );
        offsets[depth] = Offset(rootMenuRect.left, position.layerOffset);
        menuYOffset = position.menuOffset;
        for (int i = 0; i <= depth; i++) {
          final double height = i == 0
                                ? rootMenuRect.height
                                : context.getChildSize(i)!.height;
          double min = padding.top;
          double max = context.size.height - height - padding.bottom;
          if (i == 0) {
            min -= rootMenuRect.top;
            max -= rootMenuRect.top;
          }

          max = math.max(max, min);
          offsets[i] = Offset(
            offsets[i].dx,
            ui.clampDouble(
              offsets[i].dy + menuYOffset,
              min,
              max,
            ),
          );
        }

      previousLayerOffsetY = offsets[depth].dy;
      shiftedRootMenuAnchor = shiftedRootMenuAnchor.shift(Offset(0, menuYOffset));
    }

    // Calculate the total area the menu takes up, so panning can be scaled
    // based on the distance from the menu edge.
    //
    // A (presumably) more efficient way to calculate totalMenuRect that hurts
    // readability:
    //
    // var Rect(:double left, :double right, :double top, :double bottom) = rootMenuRect;
    // for (int i = 1; i < offsets.length; i++) {
    //   final ui.Size size = context.getChildSize(i)!;
    //   left   = math.min(left  , offsets[i].dx);
    //   top    = math.min(top   , offsets[i].dy);
    //   right  = math.max(right , offsets[i].dx + size.width);
    //   bottom = math.max(bottom, offsets[i].dy + size.height);
    // }
    for (int i = 1; i < offsets.length; i++) {
     totalMenuRect = totalMenuRect.expandToInclude(
       offsets[i] & context.getChildSize(i)!,
     );
    }

    double menuScale = 1.0;
    if (pointerPosition != null) {
      // Get squared distance to rect
      final double minDistanceToEdge = _calculateSquaredDistanceToMenuEdge(
        rect: totalMenuRect,
        position: pointerPosition!,
      );
      // Scales based on distance from menu edge. The divisor has an
      // inverse relationship with the amount of scaling that occurs for each
      // unit of distance.
      menuScale = math.max(
        1.0 - minDistanceToEdge / 50000,
        0.8,
      );
    }

    final Offset menuOrigin = alignment.alongSize(
      padding.deflateSize(
        context.getChildSize(0)!,
      ),
    );

    /*****  2nd pass  *****/
    for (int i = 0; i < context.childCount; ++i) {
      // Scale the menu based on the pointer position
      transforms[i]
        ..translate(menuOrigin.dx, menuOrigin.dy)
        ..scale(menuScale, menuScale, menuScale)
        ..translate(-menuOrigin.dx, -menuOrigin.dy);
      if (context.childCount > 1) {
        final double atOrAbove = nestingAnimation.value - i + 1;
        // Scale the layer based on depth. The top layer is 1.0, and each
        // subsequent layer is scaled down.
        final double layerScale = math.min(
          0.825 + 0.175 / math.sqrt(
                          math.max(atOrAbove, 1),
                        ),
          1,
        );
        // Apply layer and menu offsets
        transforms[i]
          ..translate(menuOrigin.dx, menuOrigin.dy)
          ..scale(layerScale, layerScale, layerScale)
          ..translate(offsets[i].dx, offsets[i].dy)
          ..translate(-menuOrigin.dx, -menuOrigin.dy);

      }
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
  bool shouldRelayout(_CupertinoMenuFlowDelegate oldDelegate) {
    return oldDelegate.padding != padding;
  }

  @override
  bool shouldRepaint(_CupertinoMenuFlowDelegate oldDelegate) {
    if (identical(this, oldDelegate)) {
      return false;
    }

    return oldDelegate.padding != padding
        || oldDelegate.alignment != alignment
        || oldDelegate.onPainted != onPainted
        || oldDelegate.growthDirection != growthDirection
        || oldDelegate.nestingAnimation != nestingAnimation
        || oldDelegate.routeAnimation != routeAnimation
        || oldDelegate.rootAnchorSize != rootAnchorSize
        || oldDelegate.rootAnchorPosition != rootAnchorPosition
        || oldDelegate.rootMenuRectNotifier != rootMenuRectNotifier
        || oldDelegate.pointerPositionNotifier != pointerPositionNotifier
        || !listEquals(oldDelegate.layers, layers)
        || !listEquals(oldDelegate.overrideTransforms, overrideTransforms);
  }
}

/// The opening and closing status of this menu layer.
enum CupertinoMenuStatus {
  /// The menu layer is finished opening.
  open,

  /// The menu layer is opening.
  opening,

  /// The menu layer is finished closing.
  closed,

  /// The menu layer is closing.
  closing,
}


/// A [State] mixin that delegates control of a nested menu layer to the nearest
/// [CupertinoMenu].
@optionalTypeArgs
mixin CupertinoNestedMenuControlMixin<U extends StatefulWidget>
      on State<U>
      implements CupertinoMenuControlMixin {
  _MenuScopeState? _menuScope;
  final ValueNotifier<int> _rebuildSignal = ValueNotifier<int>(0);

  /// The position of the menu relative to the root menu layer.
  ///
  /// {@macro flutter.cupertino.CupertinoMenuTreeCoordinates.description}
  CupertinoMenuCoordinates? get coordinates => _coordinates;
  CupertinoMenuCoordinates? _coordinates;

  /// The animation that drives the opening and closing of this menu layer.
  Animation<double> get animation => _animation;
  final ProxyAnimation _animation = ProxyAnimation(kAlwaysDismissedAnimation);

  /// The progress of the opening and closing animation of this menu layer.
  CupertinoMenuStatus get status => _status;
  CupertinoMenuStatus _status = CupertinoMenuStatus.closed;

  @override
  bool get isOpen => _status == CupertinoMenuStatus.open
                  || _status == CupertinoMenuStatus.opening
                  || (_scrolling && _status == CupertinoMenuStatus.closed);

  bool _scrolling = false;

  /// A builder that constructs a  layer. This is only called when the
  /// menu is opened -- it is the responsibility of the implementer to
  /// rebuild the menu when the [rebuildSignal] is triggered.
  Widget? buildMenu(BuildContext context, ValueNotifier<int> rebuildSignal);

  /// Called when the menu begins closing
  void didCloseMenu();

  /// Called when the menu begins opening
  void didOpenMenu();

  @override
  void initState() {
    super.initState();
    _animation.addStatusListener(_handleAnimationStatusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _menuScope = context.findAncestorStateOfType<_MenuScopeState>();
    if (_coordinates != _MenuCoordinateScope.of(context)) {
      _menuScope?._detachMenuControl(this);
      _coordinates = _MenuCoordinateScope.of(context);
      _menuScope?._attachMenuControl(this);
    }
  }

  @override
  void dispose() {
    _menuScope?._detachMenuControl(this);
    _animation.parent = null;
    _rebuildSignal.dispose();
    super.dispose();
  }

  @override
  void rebuild() {
    _rebuildSignal.value += 1;
  }

  @override
  void open() {
    _scrolling = true;
    Scrollable.ensureVisible(
      context,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInQuad,
    ).then((void value) {
      if (mounted) {
        _menuScope!.pushMenu(coordinates: coordinates!);
        rebuild();
        _scrolling = false;
      }
    });
  }

  @override
  void close() {
    _scrolling = true;
    Scrollable.ensureVisible(
      context,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInQuad,
    ).then((void value) {
        if(mounted) {
          _menuScope!.popMenu();
        }
        _scrolling = false;
      }
    );
  }

  void _handleAnimationStatusChange(AnimationStatus status) {
    setState(() {
      switch (status) {
        case AnimationStatus.completed:
          _status = CupertinoMenuStatus.open;
        case AnimationStatus.dismissed:
          _status = CupertinoMenuStatus.closed;
        case AnimationStatus.reverse:
          _status = CupertinoMenuStatus.closing;
          didCloseMenu();
        case AnimationStatus.forward:
          _status = CupertinoMenuStatus.opening;
          didOpenMenu();
      }
    });
  }

  // ignore: use_setters_to_change_properties
  void _attachAnimation(Animation<double> animation) {
    if (mounted) {
      _animation.parent = animation;
    }
  }

  void _detachAnimation(Animation<double> animation) {
    if (animation == _animation.parent) {
      _animation.parent = null;
    }
  }
}

/// A [Widget] that expands to show a new layer of menu items.
///
/// While a [CupertinoNestedMenu] can contain any [Widget], nesting
/// more than one [CupertinoNestedMenu] is not recommended because it can lead
/// to poor user experience.
///
/// The [itemBuilder] is called when the user triggers expansion and whenever a
/// rebuild signal is sent to the root menu. If provided, the [onTap] callback
/// will be called whenever the menu anchor is triggered by the user, regardless
/// of whether the [itemBuilder] returns items. In contrast, the [onOpen]
/// callback will only be called when the [itemBuilder] returns items, and will
/// be called regardless of whether the menu is programmatically or manually
/// opened. If the menu closing animation is interrupted by an opening
/// animation, [onOpen] **will** be called again. Similarly, [onClose] is called
/// regardless of whether the menu is programmatically or manually closed, and
/// will be called again if an opening animation is interrupted by a closing
/// animation.
///
/// The [constraints] parameter can be used to constrain the size of the nested
/// menu layer. If null, the nested menu layer will expand to fit its contents.
///
/// A [controller] can be used to programmatically open or close the nested menu
/// layer. If null, an internal controller will be created.
///
/// The [clip] parameter can be used to clip the menu's surface. In most cases,
/// the default value of [Clip.antiAlias] should be used. However,
/// [Clip.antiAliasWithSaveLayer] may be used if elements of the screen that are
/// not under the menu surface bleed onto the menu's backdrop. This occurs
/// because [BackdropFilter] is applied to the entire screen, and not just the
/// menu. Afterwards, the blurred screen is clipped to the menu's bounds. Save
/// layers are expensive, so this option should only be used if absolutely
/// necessary.
///
/// See also:
///
/// * [CupertinoMenuItem], a simple menu item with a trailing widget slot.
/// * [CupertinoCheckedMenuItem], a menu item that displays a leading checkmark
///   widget when selected
/// * [CupertinoMenuActionItem], a fractional-width menu item intended for menu
///   actions.
/// * [CupertinoMenuLargeDivider], a menu item that displays a large divider.
/// * [CupertinoMenuTitle], a menu item that displays a title.
/// * [showCupertinoMenu], a method used to show a Cupertino menu.
/// * [CupertinoMenuButton], a button that shows a Cupertino-style menu when
///   pressed.
class CupertinoNestedMenu extends StatefulWidget  with CupertinoMenuEntry {
  /// Creates a menu item that expands to show a new layer of menu items.
  const CupertinoNestedMenu({
    super.key,
    required this.title,
    required this.itemBuilder,
    this.pressedColor,
    this.trailing,
    this.subtitle,
    this.enabled = true,
    this.onTap,
    this.onClose,
    this.onOpen,
    this.expandedMenuAnchorKey,
    this.collapsedMenuAnchorKey,
    this.constraints,
    this.controller,
    this.menuLayerKey,
    this.clip = Clip.none,
  });

  /// A key that can be used to refer to the nested menu anchor while the menu
  /// is open, opening, or closing.
  // TODO(davidhicks980): This is only used for testing. Consider removing.
  final Key? expandedMenuAnchorKey;

  /// A key that can be used to refer to the nested menu anchor when it is fully
  /// closed.
  // TODO(davidhicks980): This is only used for testing. Consider removing.
  final Key? collapsedMenuAnchorKey;

  /// A key that can be used to refer to the [NestedMenuLayer] while the menu
  /// is open, opening, or closing.
  // TODO(davidhicks980): This is only used for testing. Consider removing.
  final Key? menuLayerKey;

  /// A label displayed in the center of the nested menu anchor
  // This is a TextSpan instead of a Widget because the title is duplicated
  // for the collapsed menu anchor and the nested menu anchor. If users were
  // to supply a GlobalKey, a duplicate key error would be thrown.
  final TextSpan title;

  /// A widget displayed below the [title] in the nested menu anchor
  final Widget? subtitle;

  /// An optional widget displayed at the end of the nested menu anchor
  final Widget? trailing;

  /// A builder that constructs the nested menu items
  final CupertinoMenuItemBuilder itemBuilder;

  /// Whether the menu is enabled. When the menu is disabled, it will not be
  /// focusable and [onTap] will not be called when pressed.
  final bool enabled;

  /// Called when the menu begins opening. Unlike [onTap], this callback is
  /// called regardless of whether the menu is programmatically or manually
  /// opened. If a closing animation is interrupted by an opening animation,
  /// this callback **will** be called again.
  //  TODO(davidhicks980): Should onOpen only be called when the menu is first opened?
  final VoidCallback? onOpen;

  /// A callback dispatched when the menu item is tapped
  final void Function()? onTap;

  /// Called when the menu begins closing. Unlike [onTap], this callback is
  /// called regardless of whether the menu is programmatically or manually
  /// closed. If an opening animation is interrupted by an closing animation,
  /// this callback **will** be called again.
  //  TODO(davidhicks980): Should onClose only be called when the menu is first closed?
  final FutureOr<void> Function()? onClose;

  /// Constraints to apply to the nested menu layer. If null, the nested menu
  /// layer will expand to fit its contents.
  final BoxConstraints? constraints;

  /// The controller that controls the nested menu. If null, an internal
  /// controller will be created.
  final CupertinoMenuController? controller;

  /// The clip behavior to use for the menu's surface.
  ///
  /// In most cases, the default value of [Clip.antiAlias] should be used.
  /// However, [Clip.antiAliasWithSaveLayer] may be used if elements of the
  /// screen that are not under the menu surface bleed onto the menu's backdrop.
  /// This occurs because [BackdropFilter] is applied to the entire screen, and
  /// not just the menu. Afterwards, the blurred screen is clipped to the menu's
  /// bounds. Save layers are expensive, so this option should only be used if
  /// absolutely necessary.
  final Clip clip;

  /// The color of the menu item when pressed.
  final Color? pressedColor;

  @override
  bool get hasLeading => true;

  @override
  double get height => 44;

  @override
  State<CupertinoNestedMenu> createState() => _CupertinoNestedMenuState();
}

class _CupertinoNestedMenuState
      extends State<CupertinoNestedMenu>
         with SingleTickerProviderStateMixin,
              CupertinoNestedMenuControlMixin<CupertinoNestedMenu> {
  late CupertinoMenuController _menuController;

  /// The clip path of this menu layer. Used to round the corners of the menu
  /// layer when animating edge menu layers in and out of view.
  BorderRadius _buildMenuRadius(BuildContext context) {
    final int index = coordinates!.row;
    final int childCount = CupertinoMenuLayer.of(context).childCount;

    if (index == 0) {
      return const BorderRadius.only(
        topLeft: CupertinoMenu.radius,
        topRight: CupertinoMenu.radius,
      );
    } else if (index == childCount - 1) {
      return const BorderRadius.only(
        bottomLeft: CupertinoMenu.radius,
        bottomRight: CupertinoMenu.radius,
      );
    } else {
      return BorderRadius.zero;
    }
  }

  @override
  void initState() {
    super.initState();
    _menuController = widget.controller ?? CupertinoMenuController();
    _menuController._attach(this);
  }

  @override
  void didUpdateWidget(CupertinoNestedMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _menuController._detach(this);
      _menuController = widget.controller ?? CupertinoMenuController();
      _menuController._attach(this);
    }

    if(oldWidget.itemBuilder != widget.itemBuilder) {
      // TODO(davidhicks980): Find faster way to rebuild a nested menu layer.
      //
      // Because each menu layer is built in a separate frame, there is a
      // considerable delay between the user tapping a stateful menu item (e.g.
      // a checked menu item) and the menu layer rebuilding for deeply nested
      // menus. Currently, [CupertinoNestedMenu.rebuild] is called on the
      // deepest menu layer when a menu item is tapped, which triggers and
      // immediate rebuild for the closest menu layer.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        rebuild();
      });
    }
  }

  @override
  void didOpenMenu() {
    widget.onOpen?.call();
  }

  @override
  void didCloseMenu() {
    widget.onClose?.call();
  }

  @override
  void dispose() {
    _menuController._detach(this);
    super.dispose();
  }

  @override
  Widget? buildMenu(
    BuildContext rootContext,
    ValueNotifier<int> rebuildSignal,
  ) {
    bool isMounted = false;
    List<Widget> items = widget.itemBuilder(rootContext);
    if (items.isEmpty) {
      return null;
    }

    return ListenableBuilder(
      listenable: rebuildSignal,
      builder: (BuildContext rootListenableContext, Widget? child) {
        if (isMounted) {
          items = widget.itemBuilder(rootListenableContext);
        } else {
          isMounted = true;
        }

        assert(
          items.isNotEmpty,
          'CupertinoNestedMenu.itemBuilder must return at least one item '
          'once the menu has opened.',
        );

        final ui.Size anchorSize = (context.findRenderObject()! as RenderBox).size;

        final List<_MenuCoordinateScope> wrappedItems =
          CupertinoMenu._wrapMenuItems(
            items: <Widget>[
              CupertinoNestedMenuItemAnchor(
                key: widget.expandedMenuAnchorKey,
                subtitle: widget.subtitle,
                trailing: widget.trailing,
                animation: animation.drive(_clampedAnimatable),
                visible: status != CupertinoMenuStatus.closed,
                onTap: widget.enabled ? _handleTap : null,
                expanded: true,
                enabled: widget.enabled,
                title: widget.title,
                height: anchorSize.height,
                pressedColor: widget.pressedColor,
              ),
              ...items,
            ],
            depth: coordinates!.depth,
            path: coordinates!.path + <int>[coordinates!.row],
          );

        return CupertinoMenuLayer(
          isInteractive: CupertinoMenu
                          .interactiveLayersOf(rootListenableContext)
                          .contains(coordinates),
          constraints: widget.constraints,
          childCount: wrappedItems.length,
          coordinates: coordinates!,
          anchorSize: (context.findRenderObject()! as RenderBox).size,
          hasLeadingWidget: true,
          menuController: _menuController,
          child: BlockSemantics(
            key: widget.menuLayerKey,
            child: _MenuContainer(
              animation: animation,
              depth: coordinates!.depth,
              anchorBorderRadius: _buildMenuRadius(context),
              child: _MenuBody(
                children: wrappedItems,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleTap() async {
    // The menu is closed or closing.
    if (status case CupertinoMenuStatus.closing || CupertinoMenuStatus.closed) {
      _menuController.open();
    } else {
      _menuController.close();
    }

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoNestedMenuItemAnchor(
      key: widget.collapsedMenuAnchorKey,
      onTap: widget.enabled ? _handleTap : null,
      animation: kAlwaysDismissedAnimation,
      expanded: false,
      visible: status == CupertinoMenuStatus.closed,
      subtitle: widget.subtitle,
      trailing: widget.trailing,
      enabled: widget.enabled,
      title: widget.title,
      pressedColor: widget.pressedColor,
      height: widget.height,
    );
  }
}


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
    required this.isInteractive,
    required this.childCount,
    required this.coordinates,
    required this.constraints,
    required this.anchorSize,
    this.menuController,
  });

  /// The menu layer.
  final Widget child;

  /// Whether any menu items on this layer has a leading widget.
  final bool hasLeadingWidget;

  /// The number of children on this layer.
  final int childCount;

  /// The constraints for this menu layer.
  final BoxConstraints? constraints;

  /// The anchor row, column, and depth of this menu layer
  final CupertinoMenuCoordinates coordinates;

  /// The size of the anchor that this menu layer is attached to.
  final Size anchorSize;

  /// Whether this menu layer should respond to user input.
  final bool isInteractive;

  /// An optional controller that can be used to open, close, and rebuild this
  /// menu layer.
  final CupertinoMenuController? menuController;

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
      isInteractive: widget.isInteractive,
      constraintsTween: _constraintsTween,
      hasLeadingWidget: widget.hasLeadingWidget,
      childCount: widget.childCount,
      coordinates: widget.coordinates,
      controller: widget.menuController,
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
    this.anchorBorderRadius,
  });

  final Widget child;
  final BorderRadius? anchorBorderRadius;
  final int depth;
  final Animation<double> animation;
  final Clip clip;

  @override
  State<_MenuContainer> createState() => _MenuContainerState();
}

class _MenuContainerState extends State<_MenuContainer>
      with SingleTickerProviderStateMixin {
  static final Animatable<double> positiveAnimatable =
    Animatable<double>.fromCallback((double value) => math.max(value, 0));
  final SnapshotController _snapshotController = SnapshotController();
  final BorderRadiusTween _borderRadiusTween = BorderRadiusTween(
    begin: const BorderRadius.all(CupertinoMenu.radius),
      end: const BorderRadius.all(CupertinoMenu.radius),
  );
  final ProxyAnimation _snapshotAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);
  late final _FadingSnapshotPainter _snapshotPainter =
      _FadingSnapshotPainter(repaint: _snapshotAnimation);
  late Animation<BoxConstraints> _constraintsAnimation;
  late Animation<double> _surfaceAnimation;
  late Animation<double> _nestingAnimation;
  late Animation<double> _nestingAnimationReciprocal;
  BoxConstraintsTween _constraintsTween = BoxConstraintsTween();
  Animation<double>? _routeAnimation;
  Animation<double> _truncatedRouteAnimation = kAlwaysDismissedAnimation;

  @override
  void initState() {
    super.initState();
    if(widget.anchorBorderRadius != null) {
      _borderRadiusTween.begin =  widget.anchorBorderRadius;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Animation<double>? routeAnimation = ModalRoute.of(context)?.animation;
    final Animation<double> nestingAnimation =
        InheritedModel.inheritFrom<_CupertinoMenuModel>(
          context,
          aspect: _MenuModelAspect.nestingAnimation,
        )!.nestingAnimation;
    if (
      _routeAnimation   != routeAnimation ||
      _nestingAnimation != nestingAnimation
    ) {
      _routeAnimation = routeAnimation ?? kAlwaysCompleteAnimation;
      _nestingAnimation = nestingAnimation;
      _truncatedRouteAnimation = _routeAnimation!
        .drive(_clampedAnimatable)
        .drive(CurveTween(curve: const Interval(0.4, 1.0)));
      _routeAnimation!.addListener(_updateSnapshotting);
      _nestingAnimation.addListener(_updateSnapshotting);
      _nestingAnimationReciprocal = _buildNestingAnimationReciprocal();
      _snapshotAnimation.parent = _nestingAnimationReciprocal;
      _surfaceAnimation = _buildSurfaceAnimation();
    }
  }

  @override
  void didUpdateWidget(_MenuContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.depth != widget.depth) {
      _nestingAnimationReciprocal = _buildNestingAnimationReciprocal();
      _snapshotAnimation.parent = _nestingAnimationReciprocal;
    }

    if (oldWidget.animation != widget.animation) {
      _surfaceAnimation = _buildSurfaceAnimation();
    }

    if (oldWidget.anchorBorderRadius != widget.anchorBorderRadius) {
      _borderRadiusTween.begin = widget.anchorBorderRadius;
    }
  }

  @override
  void dispose() {
    _snapshotController.dispose();
    _routeAnimation?.removeListener(_updateSnapshotting);
    _nestingAnimation.removeListener(_updateSnapshotting);
    super.dispose();
  }


  // Returns an animation containing the reciprocal of the number of layers
  // above this one. This is used to fade out layers as more layers are pushed.
  // Pattern: 1.0, 0.5, 0.33, 0.25, 0.2, 0.16, 0.14, 0.125, ...
  Animation<double> _buildNestingAnimationReciprocal() {
    return _AnimationProduct(
      _truncatedRouteAnimation,
      _nestingAnimation.drive(
        Animatable<double>.fromCallback(
          (double value) =>
              math.min(value - widget.depth + 1, 1) /
              math.max(value - widget.depth + 1, 1),
        ),
      ),
    );
  }

  Animation<double> _buildSurfaceAnimation() {
    if(widget.depth == 0){
      return _routeAnimation!;
    } else {
      return _AnimationProduct(
              widget.animation,
              _routeAnimation!,
             ).drive(positiveAnimatable);
    }
  }

  // Allow snapshotting when the entire menu is animating open or closed, or
  // when the layer above this one is at least 30% open.
  void _updateSnapshotting() {
    // TODO(davidhicks980): Will snapshotting layers improve performance?
    // My thought is that snapshotting layers could improve performance by
    // reducing the number of widgets that need to be rebuilt, especially for
    // deeply nested menus.
    _snapshotController.allowSnapshotting =
            _routeAnimation!.value < 1
              || _nestingAnimation.value - widget.depth > 0.3;
  }


  // Absorb pointers when the menu is animating open or closed.
  Widget _buildAbsorbPointer(BuildContext context, Widget? child) {
    return AbsorbPointer(
      absorbing: _snapshotController.allowSnapshotting,
      child: child,
    );
  }

  Widget _buildConstraints(
    BuildContext context,
    BoxConstraints constraints,
    Widget? child
  ) {
    return ConstrainedBox(
      constraints: constraints,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ListenableBuilder child = ListenableBuilder(
      listenable: _snapshotController,
      builder: _buildAbsorbPointer,
      child: _AnimatedSurface(
        shadowPainter: CustomPaint(
          painter: _ShadowPainter(
            brightness: CupertinoTheme.brightnessOf(context),
            depth: widget.depth,
            radius: CupertinoMenu.radius,
            repaint: _nestingAnimationReciprocal,
          ),
          child: const SizedBox.expand(),
        ),
        depth: widget.depth,
        borderRadiusTween: _borderRadiusTween,
        listenable: _surfaceAnimation,
        clip: widget.clip,
        child: SnapshotWidget(
          autoresize: true,
          controller: _snapshotController,
          painter: _snapshotPainter,
          child:  widget.child,
        ),
      ),
    );
    return  Builder(
      key: ValueKey<String>('_MenuContainer_${widget.depth}'),
      builder: (BuildContext context) {
        _constraintsTween = CupertinoMenuLayer.of(context).constraintsTween;
        _constraintsAnimation = _surfaceAnimation.drive(_constraintsTween);
        return ValueListenableBuilder<BoxConstraints>(
          valueListenable: _constraintsAnimation,
          builder: _buildConstraints,
          child: child
        );
      }
    );
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

  double get concentratedShadowOpacity =>
      shadowOpacity *
      (brightness == ui.Brightness.light
          ? math.max(shadowOpacity * 0.05, 0.03)
          : math.max(shadowOpacity * 0.3, 0.2));

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
    if (depth != 0) {
      final ui.Rect concentratedShadowRect = Rect.fromCenter(
        center: center,
        width: size.width - 12,
        height: size.height + 50 * shadowOpacity,
      );
      // Paints a vertical gradient that mimicks a concentrated vertical shadow
      // above this menu layer. A blurred mask filter is used to feather the
      // edges of the gradient.
      final Paint concentratedShadow = Paint()
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          shadowOpacity * 8,
        )
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: <double>[
            0.0,
            0.4 - 0.1 * shadowOpacity,
            0.6 + 0.1 * shadowOpacity,
            1.0,
          ],
          colors: <ui.Color>[
            const Color.fromRGBO(0, 0, 0, 0.0),
            Color.fromRGBO(0, 0, 0, concentratedShadowOpacity),
            Color.fromRGBO(0, 0, 0, concentratedShadowOpacity),
            const Color.fromRGBO(0, 0, 0, 0.0),
          ],
        ).createShader(
          concentratedShadowRect,
        );

      canvas.drawRect(
        concentratedShadowRect,
        concentratedShadow,
      );
    }
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

// The animated surface of a [CupertinoMenu].
//
// This widget is responsible for animating a menu's clip, blur, and
// background color.
//
// The [initialClip] property describes the border radius of the menu's surface
// when it is initially shown. This will animate to [CupertinoMenu.radius]
//
// The [depth] property describes the menu's depth in the menu
// hierarchy.
//
// The [routeAnimation] property describes the animation that reveals the
// entire menu
//
// The [nestingAnimation] property describes the animation that reveals
// individual menu layers.
class _AnimatedSurface extends AnimatedWidget {
 const  _AnimatedSurface({
    required this.child,
    required this.borderRadiusTween,
    required int depth,
    required this.shadowPainter,
    required Animation<double> super.listenable,
    required this.clip,
    // ignore: unused_element
    this.background = kIsWeb ? CupertinoMenu.opaqueBackground
                             : CupertinoMenu.background,
  })  : _depth = depth;

  final int _depth;
  final Widget child;
  final Widget shadowPainter;
  final CupertinoDynamicColor background;
  final BorderRadiusTween borderRadiusTween;
  final Clip clip;

  static const Interval _blurInterval = Interval(0.2, 0.4);
  static const Interval _rootOpacityInterval = Interval(0.3, 1);
  static const Interval _nestedOpacityInterval = Interval(0.0, 0.05);
  static const Color _nestedLighteningColor = ui.Color(0x33FFFFFF);

  double get value => (super.listenable as Animation<double>).value;
  Interval get opacityInterval => _depth == 0 ? _rootOpacityInterval
                                              : _nestedOpacityInterval;
  @override
  Widget build(BuildContext context) {
    final double clampedValue = ui.clampDouble(value, 0.0, 1.0);
    final BorderRadius borderRadius = borderRadiusTween.transform(clampedValue)!;
    Color color = background.resolveFrom(context);
    final bool transparent = color.alpha != 0xFF && !kIsWeb;
    if (transparent) {
      if (_depth > 0) {
        color = Color.alphaBlend(color, _nestedLighteningColor);
      }
      color = color.withOpacity(
        color.opacity * opacityInterval.transform(clampedValue),
      );
    }

    // TODO(davidhicks980): Draw a background that excludes dividers.
    // This appears to be what is done on the CupertinoDialog
    // (https://github.com/flutter/flutter/blob/aa82e222d3cd624edfcecd1a38455ff1c8215fe8/packages/flutter/lib/src/cupertino/dialog.dart#L2327C5-L2327C5),
    // but iOS appears seems to use overlapping dividers.
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        shadowPainter,
        ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: clip,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // Padding is used to prevent edge artifacts from the backdrop.
              if (transparent)
                Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: _BlurredSurface(
                    strength: _blurInterval.transform(clampedValue),
                    lightness: clampedValue * 20,
                    saturation: 1 + value,
                  ),
                ),
              ColoredBox(
                color: color,
                child: child,
              ),
            ],
          )
        ),
      ],
    );
  }
}

// The blurred and saturated background of the menu
//
// For performance, the backdrop filter is only applied if the menu's
// background is transparent. The backdrop is applied as a separate layer
// because opacity transitions applied to a backdrop filter have some visual
// artifacts. See https://github.com/flutter/flutter/issues/31706.
class _BlurredSurface extends StatelessWidget {
  const _BlurredSurface({
    required this.strength,
    required this.lightness,
    required this.saturation,
  });

  final double strength;
  final double lightness;
  final double saturation;

  /// A Color matrix that saturates and brightens
  ///
  /// Adapted from https://docs.rainmeter.net/tips/colormatrix-guide/, but
  /// changed to be more similar to iOS
  static List<double> _buildBrightnessAndSaturateMatrix({
    required double saturation,
    required double lightness,
  }) {
    const double lumR = 0.4;
    const double lumG = 0.3;
    const double lumB = 0.0;
    final double sr = (1 - saturation) * lumR;
    final double sg = (1 - saturation) * lumG;
    final double sb = (1 - saturation) * lumB;
    return <double>[
      sr + saturation, sg, sb, 0.0, lightness,
      sr, sg + saturation, sb, 0.0, lightness,
      sr, sg, sb + saturation, 0.0, lightness,
      0.0, 0.0, 0.0, 1.0, lightness,
    ];
  }

  @override
  Widget build(BuildContext context) {
    ui.ImageFilter? filter = ColorFilter.matrix(
      _buildBrightnessAndSaturateMatrix(
        saturation: saturation,
        lightness: lightness,
      ),
    );
    if (strength != 0) {
      filter = ui.ImageFilter.compose(
        outer: filter,
        inner: ui.ImageFilter.blur(
          tileMode: TileMode.mirror,
          sigmaX: 35 * strength,
          sigmaY: 35 * strength,
        ),
      );
    }

    return BackdropFilter(
      blendMode: BlendMode.src,
      filter: filter,
      child: const SizedBox.expand(),
    );
  }
}


class _StickyMenuHeaderDelegate
  extends SliverPersistentHeaderDelegate {
  const _StickyMenuHeaderDelegate({
    required this.child,
    required this.height,
  });
  final double height;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(
        stretchTriggerOffset: height,
      );

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(_StickyMenuHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _MenuBody extends StatefulWidget {
  const _MenuBody({
    required this.children,
    this.physics,
  });

  final List<_MenuCoordinateScope> children;
  final ScrollPhysics? physics;

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return children.map<DiagnosticsNode>((Widget child) => child.toDiagnosticsNode()).toList();
  }

  @override
  State<_MenuBody> createState() => _MenuBodyState();
}

class _MenuBodyState extends State<_MenuBody> {
  // Navigation shortcuts that we need to make sure are active when menus are
  // open.
  //
  // Taken from [MenuAnchor]
  static const Map<ShortcutActivator, Intent> _kMenuTraversalShortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
    SingleActivator(LogicalKeyboardKey.tab): NextFocusIntent(),
    SingleActivator(LogicalKeyboardKey.tab, shift: true): PreviousFocusIntent(),
    SingleActivator(LogicalKeyboardKey.arrowDown): DirectionalFocusIntent(TraversalDirection.down),
    SingleActivator(LogicalKeyboardKey.arrowUp): DirectionalFocusIntent(TraversalDirection.up),
    SingleActivator(LogicalKeyboardKey.arrowLeft): DirectionalFocusIntent(TraversalDirection.left),
    SingleActivator(LogicalKeyboardKey.arrowRight): DirectionalFocusIntent(TraversalDirection.right),
  };
  final ScrollController _controller = ScrollController();
  late List<double> _offsets;
  bool _isTopLayer = false;
  double _height = 0.0;
  // The height occupied by a [CupertinoStickyMenuHeader], if one is provided.
  double _headerOffset = 0.0;

  bool get hasStickyHeader => _headerOffset > 0;
  int get _topLayer {
    return CupertinoMenu.interactiveLayersOf(context)
            .reduce((CupertinoMenuCoordinates value,
                     CupertinoMenuCoordinates element) {
              return element.anchorDepth > value.anchorDepth ? element : value;
           }).depth;
  }

  @override
  void initState() {
    super.initState();
    _offsets = List<double>.filled(widget.children.length + 1, 0);
    _controller.addListener(_reportAnchorOffsets);
  }

  @override
  void didUpdateWidget(covariant _MenuBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _offsets = List<double>.filled(widget.children.length + 1, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reportAnchorOffsets() {
    final _MenuScopeState state = context.findAncestorStateOfType<_MenuScopeState>()!;
    for (int i = 0; i < widget.children.length; i++) {
      if (
        widget.children[i]
          case _MenuCoordinateScope(
            coordinates: final CupertinoMenuCoordinates coordinates,
            child: CupertinoNestedMenuItemAnchor()
                || CupertinoStickyMenuHeader()
                || CupertinoNestedMenu()
          )
      ) {
        state._setVerticalAnchorOffset(
          yOffset: _offsets[i] + _headerOffset - _controller.offset,
          coordinates: coordinates,
        );
      }
    }
  }

  void _reportLayoutChanged(Size childSize) {
    final CupertinoMenuCoordinates coordinates =
            CupertinoMenuLayer.of(context).coordinates;
    if (childSize != Size.zero) {
      SchedulerBinding.instance.addPostFrameCallback(
        (Duration timeStamp) {
          if(mounted) {
            _height = (childSize.height + _headerOffset).roundToDouble();
            // Report the height of the menu to the parent layer. See
            // _UnsafeSizeChangedLayoutNotifier for more information.
            context
              ..findAncestorStateOfType<_CupertinoMenuLayerState>()!._setLayerHeight(_height)
              ..findAncestorStateOfType<_MenuScopeState>()
                !._setNestedLayerHeight(
                  height: _height,
                  coordinates: coordinates,
                );
          }
        },
      );
    }
  }

  // Returns the [ScrollPhysics] that should be used for this menu layer. If the
  // menu layer is the top layer and is the same size as the scroll area, then
  // the menu layer should use the user-specified physics. Otherwise, the menu
  // layer should not be scrollable.
  ScrollPhysics? getScrollPhysics(double? layerHeight) {
    if (
      _isTopLayer &&
      _controller.hasClients &&
      _controller.position.extentTotal > (layerHeight ?? 0) + 2
    ) {
      return widget.physics;
    } else {
      return const NeverScrollableScrollPhysics();
    }
  }

  List<Widget> _buildChildren() {
    final List<Widget> children = <Widget>[];
    for (int i = hasStickyHeader ? 1 : 0; i < widget.children.length; i++) {
      if (
        i != 0 &&
        !(i == 1 && hasStickyHeader) &&
        // widget.children[i].child.hasSeparator &&
        widget.children[i - 1].child is! CupertinoMenuLargeDivider &&
        widget.children[i - 1].child is! CupertinoStickyMenuHeader
      ) {
        children.add(const CupertinoMenuDivider());
      }

      // If the first child is the CupertinoStickyMenuHeader, it will be placed
      // in the by the SliverPersistentHeader above. An empty SizedBox serves as
      // a placeholder
      children.add(
        _ParentDataInterceptor<ListBodyParentData, ListBody>(
          child: widget.children[i],
          onParentData: (ListBodyParentData? data) {
            SchedulerBinding.instance.addPostFrameCallback(
              (Duration timeStamp) {
                _offsets[i] = i == 0 && _headerOffset > 0
                  ? _controller.offset
                  : data?.offset.dy ?? 0;
                _reportAnchorOffsets();
              }
            );
          },
        ),
      );
    }
    return children;
  }

  Widget _wrapWithBorder({
    required Color color,
    required double thickness,
    required Widget child
  }) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: thickness,
            color: CupertinoDynamicColor.maybeResolve(color, context) ?? color,
          ),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final CupertinoMenuCoordinates coordinates = CupertinoMenuLayer.of(context).coordinates;
    final int depth = coordinates.depth;
    _isTopLayer = depth == _topLayer;

    Widget? stickyHeader;
    switch(widget.children.first){
      case _MenuCoordinateScope(:final CupertinoStickyMenuHeader child):
        _headerOffset = child.getScaledHeight(MediaQuery.textScalerOf(context));
        stickyHeader =
          _wrapWithBorder(
            color: CupertinoMenuLargeDivider.transparentColor,
            thickness: 8.0,
            child: child
          );
      case _MenuCoordinateScope(:final CupertinoNestedMenuItemAnchor child):
        _headerOffset = child.height;
        stickyHeader = _wrapWithBorder(
          color: CupertinoMenuDivider.dividerColor,
          thickness: 0.0,
          child: child
        );
      default:
        _headerOffset = 0.0;
    }

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      focusable: false,
      label: 'Popup menu',
      child: FocusScope(
        autofocus: true,
        canRequestFocus: _isTopLayer,
        skipTraversal: !_isTopLayer,
        child: Shortcuts(
           shortcuts: _kMenuTraversalShortcuts,
          child: CupertinoScrollbar(
            controller: _controller,
            thumbVisibility: false,
            child: CustomScrollView(
              clipBehavior: Clip.none,
              controller: _controller,
              physics: _isTopLayer
                        ? widget.physics
                        : const NeverScrollableScrollPhysics(),
              slivers: <Widget>[
                if (hasStickyHeader)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyMenuHeaderDelegate(
                      height: _headerOffset,
                      child: RepaintBoundary(
                        // TODO(davidhicks980): Find more efficient end alignment
                        // solution.
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Flexible(child: stickyHeader!)
                          ],
                        )
                      ),
                    ),
                  ),
                _SliverClippedInsets(
                  insets: RelativeRect.fromLTRB(0, _headerOffset, 0, 0),
                  child: SliverToBoxAdapter(
                    child: _UnsafeSizeChangedLayoutNotifier(
                      onLayoutChanged: _reportLayoutChanged,
                      child: ListBody(
                        children: _buildChildren(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A widget that measures its child's size and notifies its parent.
//
// From
// https://blog.gskinner.com/archives/2021/01/flutter-how-to-measure-widgets.html
//
// TODO(davidhicks980): Should a widget's size be measured to determine offset?
// Measuring a menu layer is a bad solution, but layer size
// is currently needed to reposition menu layers relative to eachother. Determine
// if there is a better solution.
class _UnsafeSizeChangedLayoutNotifier extends SingleChildRenderObjectWidget {
  // Creates a [_UnsafeSizeChangedLayoutNotifier] that dispatches layout
  // changed notifications when [child] changes layout size.
  const _UnsafeSizeChangedLayoutNotifier({
    required super.child,
    required this.onLayoutChanged,
  });

  final ValueChanged<Size> onLayoutChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeChangedWithCallback(onLayoutChanged: onLayoutChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeChangedWithCallback renderObject,
  ) {
    renderObject.onLayoutChanged = onLayoutChanged;
  }
}

class _RenderSizeChangedWithCallback extends RenderProxyBox {
  _RenderSizeChangedWithCallback({
    required this.onLayoutChanged,
  });

  ValueChanged<Size> onLayoutChanged;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (_oldSize != size) {
      onLayoutChanged(size);
    }

    _oldSize = size;
  }
}


// Clips a sliver's paint bounds to a given inset. Used to clip the area
// underneath a sticky menu item.
class _SliverClippedInsets extends SingleChildRenderObjectWidget {
  const _SliverClippedInsets({
    // ignore: unused_element
    super.key,
    required this.insets,
    required super.child,
  });
  final RelativeRect insets;

  @override
  _RenderSliverClippedInsets createRenderObject(BuildContext context) {
    return _RenderSliverClippedInsets()..insets = insets;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSliverClippedInsets renderObject,
  ) {
    renderObject.insets = insets;
  }
}

// Clips a sliver's paint bounds to a given inset. Used to clip the area
// underneath a sticky menu item.
class _RenderSliverClippedInsets extends RenderProxySliver {
  // The insets to apply to the sliver's paint bounds.
  RelativeRect get insets => _insets;
  RelativeRect _insets = RelativeRect.fill;
  set insets(RelativeRect value) {
    assert(
        value.top    >= 0 &&
        value.bottom >= 0 &&
        value.left   >= 0 &&
        value.right  >= 0,
      'The clip rect must have non-negative values for all edges.',
    );

    if (_insets != value) {
      _insets = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (geometry!.visible && insets != RelativeRect.fill) {
      final Rect rect = switch (constraints.axis) {
        Axis.horizontal => Rect.fromLTRB(
            insets.left,
            insets.top,
            geometry!.paintExtent
              - insets.right
              + offset.dx,
            constraints.crossAxisExtent
              - insets.bottom
              + offset.dy,
          ),
        Axis.vertical => Rect.fromLTRB(
            insets.left,
            insets.top,
            constraints.crossAxisExtent
              - insets.right
              + offset.dx,
            geometry!.paintExtent
              - insets.bottom
              + offset.dy,
          ),
      };
      context.canvas.clipRect(rect, doAntiAlias: false);
    }
    super.paint(context, offset);
  }
}

// An animation controller whose status can be overridden.
//
// This is used to override the status of the nested menu animations run by
// simulations so as to properly trigger status listeners.
class _AnimationControllerWithStatusOverride extends AnimationController {
  _AnimationControllerWithStatusOverride.unbounded({
    // ignore: unused_element
    super.value = 0.0,
    // ignore: unused_element
    super.duration,
    // ignore: unused_element
    super.reverseDuration,
    // ignore: unused_element
    super.debugLabel,
    // ignore: unused_element
    super.animationBehavior,
    required super.vsync,
  }) : super.unbounded();
  AnimationStatus? _statusOverride;

  @override
  AnimationStatus get status => _statusOverride ?? super.status;

  // Overrides the status of the animation controller.
  //
  // Call [clearStatus] to revert to status of the underlying AnimationController
  void overrideStatus(AnimationStatus value) {
    if (_statusOverride != value) {
      _statusOverride = value;
      notifyStatusListeners(_statusOverride ?? status);
    }
  }

  // Clears the status override, reverting to the status of the underlying
  // AnimationController.
  void clearStatus() {
    _statusOverride = null;
  }

  @override
  void notifyStatusListeners(AnimationStatus status) {
    super.notifyStatusListeners(_statusOverride ?? status);
  }
}


// Used to improve performance of underlying menu layers during route
// animations. Currently does not affect the menu surface or shadows, as these
// rely on BackdropFilter that are not captured by SnapshotWidget.
class _FadingSnapshotPainter implements SnapshotPainter {
  // Creates a custom painter.
  //
  // The painter will repaint whenever `repaint` notifies its listeners.
  const _FadingSnapshotPainter({
    required Animation<double> repaint,
  }) : _repaint = repaint;

  final Animation<double> _repaint;

  double get opacity => _repaint.value;

  @override
  void addListener(VoidCallback listener) => _repaint.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _repaint.removeListener(listener);

  @override
  void dispose() {}

  @override
  bool get hasListeners => true;

  @override
  void notifyListeners() {}

  @override
  void paint(
    PaintingContext context,
    ui.Offset offset,
    ui.Size size,
    PaintingContextCallback painter,
  ) {
    painter(context, offset);
  }

  @override
  void paintSnapshot(
    PaintingContext context,
    ui.Offset offset,
    ui.Size size,
    ui.Image image,
    Size sourceSize,
    double pixelRatio,
  ) {
    final ui.Rect src = Rect.fromLTWH(0, 0, sourceSize.width, sourceSize.height);
    final ui.Rect dst = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    final ui.Paint paint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, opacity)
      ..filterQuality = FilterQuality.medium;
    context.canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(_FadingSnapshotPainter oldPainter) => oldPainter.opacity != opacity;
}

// Multiplies the values of two animations. Used to multiply the route animation
// and the nesting animation to apply effects when the menu closes.
class _AnimationProduct extends CompoundAnimation<double> {
  _AnimationProduct(
    Animation<double> first,
    Animation<double> next,
  ) : super(first: first, next: next);

  @override
  double get value => super.first.value * super.next.value;
}


// A widget that intercepts the parent data of a child widget. Used by
// [_MenuBodyState] to report the anchor offsets of menu items to the
// [_MenuScope].
//
// TODO(davidhicks980): Find a idiomatic way to report anchor offsets.
// Because underlying layers are transformed during nesting
// animations, finding the anchor offsets of menu items via
// RenderBox.globalToLocal() can be unreliable without performing inverse
// transformations. Even when doing so, it is difficult to isolate only the
// transformations relative to the top-left corner of the menu layer. One
// solution was to sample the anchor offset from [ListBodyParentData], which is
// the purpose of the [_ParentDataInterceptor]. While it has been reliable and
// simple, it is unconventional and therefore may need to be replaced.
class _ParentDataInterceptor<T extends ParentData, U extends RenderObjectWidget>
      extends ParentDataWidget {
  const _ParentDataInterceptor({
    super.key,
    required super.child,
    required this.onParentData,
  });

  // The callback to invoke when the parent data of the child changes.
  final ValueSetter<T?> onParentData;

  @override
  void applyParentData(RenderObject renderObject) {
      onParentData(renderObject.parentData as T?);
  }

  @override
  Type get debugTypicalAncestorWidgetClass => U;
}
