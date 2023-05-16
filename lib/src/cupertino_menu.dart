import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../cupertino_menu.dart';
import 'items/base.dart';

/// Signature used by [CupertinoMenuButton] to lazily construct the items shown when
/// the button is pressed.
///
/// Used by [CupertinoMenuButton.itemBuilder].
typedef CupertinoMenuItemBuilder<T> = List<CupertinoMenuEntry<T>> Function(
  BuildContext context,
);

/// Signature used by [CupertinoMenuButton] to build button widget.
///
/// Used by [CupertinoMenuButton.buttonBuilder].
typedef CupertinoMenuButtonBuilder = Widget Function(
  BuildContext context,
  Future<void> Function() showMenu,
);

/// A button that launches a [CupertinoMenuOverlay] when pressed.
///
/// See also:
///
/// * [CupertinoMenuItem], a menu item with a trailing widget slot.
/// * [CupertinoCheckedMenuItem], a menu item that displays a leading checkmark widget when selected
/// * [CupertinoMenuLargeDivider], a menu entry for a divider.
/// * [CupertinoMenuTitle], a pull-down menu entry for a menu title.
/// * [CupertinoMenuActionItem], a fractional-width menu item intended for menu actions.
/// * [showCupertinoMenu], a alternative way of displaying a pull-down menu.
@immutable
class CupertinoMenuButton<T> extends StatefulWidget {
  /// Called when the button is pressed to create the items to show in the menu.
  final VoidCallback? onOpened;

  /// Creates a button that shows a pull-down menu.
  const CupertinoMenuButton({
    super.key,
    required this.itemBuilder,
    this.enabled = true,
    this.onCanceled,
    this.onClosed,
    this.onOpened,
    this.onSelected,
    this.offset = Offset.zero,
    this.child,
    this.enableFeedback,
  });

  /// Called when the button is pressed to create the items to show in the menu.
  final CupertinoMenuItemBuilder<T> itemBuilder;

  final Widget? child;

  /// The offset is applied relative to the initial position set by the
  /// [alignment].
  ///
  /// When not set, the offset defaults to [Offset.zero].
  final Offset offset;

  /// Whether this button is enabled or disabled.
  final bool enabled;

  /// Whether detected gestures should provide haptic feedback.
  final bool? enableFeedback;

  /// Called when the user dismisses the menu without selecting a value.
  final VoidCallback? onCanceled;

  /// Called when the menu is closed after selecting a value.
  final VoidCallback? onClosed;

  /// Called when a menu item is selected.
  final ValueChanged<T?>? onSelected;

  @override
  State<CupertinoMenuButton<T>> createState() => _CupertinoMenuButtonState<T>();
}

class _CupertinoMenuButtonState<T> extends State<CupertinoMenuButton<T>> {
  Future<void> showMenu() async {
    if (_shouldGiveFeedback) {
      Feedback.forTap(context);
    }

    final anchor = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final Rect anchorPosition = Rect.fromPoints(
      anchor.localToGlobal(Offset.zero, ancestor: overlay),
      anchor.localToGlobal(
        anchor.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    );

    final items = widget.itemBuilder(context);
    if (items.isEmpty) {
      return;
    }

    widget.onOpened?.call();
    showCupertinoMenu<T>(
      offset: widget.offset,
      context: context,
      items: items,
      overlaySize: overlay.size,
      anchorPosition: anchorPosition,
    ).then((value) {
      if (!mounted) {
        return;
      }

      if (value == null) {
        widget.onCanceled?.call();
        return;
      }

      widget.onSelected?.call(value);
    });
  }

  bool get _shouldGiveFeedback {
    return widget.enableFeedback ?? true;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.child != null) {
      return CupertinoButton(
        onPressed: widget.enabled ? showMenu : null,
        child: widget.child!,
      );
    }

    return CupertinoButton(
      pressedOpacity: 1,
      onPressed: widget.enabled ? showMenu : null,
      child: const Icon(CupertinoIcons.add),
    );
  }
}

/// Show the a Cupertino-style menu at a given position.
///
/// The [anchorPosition] parameter determines the size and position of the
/// menu relative to the [overlaySize].
///
/// The [alignment] parameter is the alignment of the CupertinoMenu relative
/// to the [anchorPosition].

Future<T?> showCupertinoMenu<T>({
  required BuildContext context,
  required Rect anchorPosition,
  required Size overlaySize,
  required Offset offset,
  required List<CupertinoMenuEntry<T>> items,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final hasLeadingWidget = menuHasLeadingWidget<T>(items);
  final menuItems = CupertinoMenuOverlay.buildMenuItems(items);

  final dyAnchorCenterRatio = anchorPosition.center.dy / overlaySize.height;
  final dxAnchorCenterRatio = anchorPosition.center.dx / overlaySize.width;
  final anchorAlignment = Alignment(
    dxAnchorCenterRatio * 2 - 1,
    dyAnchorCenterRatio > 0.45 ? 1.0 : -1.0,
  );

  return navigator
      .push<CupertinoMenuValue<T?>>(
        CupertinoMenuRoute(
          barrierLabel: getLocalizedBarrierLabel(context),
          menuBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return CupertinoMenu(
              offset: offset,
              animation: animation,
              anchorPosition: anchorPosition,
              hasLeadingWidget: hasLeadingWidget,
              secondaryAnimation: secondaryAnimation,
              alignment: anchorAlignment,
              childCount: menuItems.length,
              child: InheritedTheme.capture(
                from: context,
                to: navigator.context,
              ).wrap(
                CupertinoMenuOverlay(
                  transformOrigin: anchorAlignment,
                  items: menuItems,
                  animation: animation,
                ),
              ),
            );
          },
          curve: const ElasticOutCurve(1.65),
          reverseCurve: Curves.easeInCubic,
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 600),
        ),
      )
      .then((value) => value?.value);
}

bool menuHasLeadingWidget<T>(List<CupertinoMenuEntry<T>> menuItems) {
  final index = menuItems.indexWhere((item) => item.hasLeading);
  return index != -1;
}

String getLocalizedBarrierLabel(BuildContext context) {
  // Use this instead of `MaterialLocalizations.of(context)` because
  // [MaterialLocalizations] might be null in some cases.
  final materialLocalizations =
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations);

  // Use this instead of `CupertinoLocalizations.of(context)` because
  // [CupertinoLocalizations] might be null in some cases.
  final cupertinoLocalizations =
      Localizations.of<CupertinoLocalizations>(context, CupertinoLocalizations);

  // If both localizations are null, fallback to
  // [DefaultMaterialLocalizations().modalBarrierDismissLabel].
  return cupertinoLocalizations?.modalBarrierDismissLabel ??
      materialLocalizations?.modalBarrierDismissLabel ??
      const DefaultMaterialLocalizations().modalBarrierDismissLabel;
}
