import 'package:flutter/cupertino.dart';

import '../utils/controllers.dart';
import '../utils/gesture_detector.dart';

class CupertinoMenuValue<T> {
  const CupertinoMenuValue({this.value, this.popToDepth});
  final T? value;
  final int? popToDepth;
}

const isTransparent = false;

/// Pressed colors are based on the following:
///
/// Dark mode on white background => rgb(111, 111, 111)
/// Dark mode on black => rgb(61, 61, 61)
/// Light mode on black background => rgb(177, 177, 177)
/// Light mode on white => rgb(225, 225, 225)
const CupertinoDynamicColor kCupertinoMenuDefaultBackgroundOnPress =
    CupertinoDynamicColor.withBrightness(
  color: Color.fromRGBO(50, 50, 50, 0.105),
  darkColor: Color.fromRGBO(255, 255, 255, 0.15),
);

/// Background colors are based on the following:
///
/// Dark mode on white background => rgb(83, 83, 83)
/// Dark mode on black => rgb(31, 31, 31)
/// Light mode on black background => rgb(197,197,197)
/// Light mode on white => rgb(246, 246, 246)
const CupertinoDynamicColor kCupertinoMenuBackground = isTransparent
    ? CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(250, 250, 250, 0.795),
        darkColor: Color.fromRGBO(40, 40, 40, 0.8),
      )
    : CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(246, 246, 246, 1),
        darkColor: Color.fromRGBO(31, 31, 31, 1),
      );

const TextStyle kCupertinoMenuActionTextStyle = TextStyle(
  fontFamily: '.SF Pro Text',
  inherit: false,
  fontSize: 17.0,
  letterSpacing: -0.41,
  color: CupertinoColors.black,
  textBaseline: TextBaseline.alphabetic,
  fontWeight: FontWeight.w400,
);

mixin CupertinoMenuEntry<T> on Widget {
  /// The amount of vertical space occupied by this entry.
  ///
  /// This is not currently used, but it may be in the future.
  ///
  /// TODO determine whether to measure menu items based on user-provided height, or to
  /// calculate height at runtime.
  double get height => kMinInteractiveDimensionCupertino;
  bool get hasLeading => false;
}

class CupertinoInteractiveMenuItem<T> extends StatefulWidget
    implements CupertinoMenuEntry<T> {
  const CupertinoInteractiveMenuItem({
    super.key,
    required this.child,
    this.height = kMinInteractiveDimensionCupertino,
    this.hasLeading = false,
    this.shouldPopMenuOnPressed = true,
    this.enabled = true,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.swipePressActivationDelay = Duration.zero,
    this.onTap,
    this.value,
    this.pressedColor = kCupertinoMenuDefaultBackgroundOnPress,
  });

  @override
  final bool hasLeading;

  @override
  final double height;

  /// Whether the user can interact with this item.
  ///
  /// Defaults to true. If false, the item will inherit [CupertinoColors.inactiveGray]
  /// as it's text color.
  final bool enabled;

  /// Called when the menu item is tapped.
  final VoidCallback? onTap;

  /// The value that will be returned by [Navigator.pop] if this entry is selected.
  final T? value;

  /// The color of the menu item when pressed.
  ///
  /// This color will be overlapped on the menu item's base color.
  final Color pressedColor;

  /// Whether to dismiss the enclosing [CupertinoMenu] after this item has been pressed
  final bool shouldPopMenuOnPressed;

  /// The delay from when an item has been swiped over to the item being
  /// pressed.
  ///
  /// Swipe is a term describing the user pressing and dragging their finger over one or
  /// more items.
  ///
  /// [Duration.zero] indicates no press should occur.
  ///
  /// Defaults to [Duration.zero]
  final Duration swipePressActivationDelay;

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

  /// The widget to show as the menu item.
  final Widget child;

  /// The menu item contents.
  ///
  /// Used by the [build] method.
  ///
  /// By default, this returns [CupertinoInteractiveMenuItem.child]. Override this to put
  /// something else in the menu entry.
  @protected
  Widget buildChild(BuildContext context) => child;

  @override
  CupertinoInteractiveMenuItemState<T, CupertinoInteractiveMenuItem<T>>
      createState() => CupertinoInteractiveMenuItemState<T,
          CupertinoInteractiveMenuItem<T>>();
}

/// The [State] for [CupertinoInteractiveMenuItem] subclasses.
///
/// By default this implements the basic styling and layout of
///
/// The [buildChild] method can be overridden to adjust exactly what gets placed
/// in the menu. By default it returns [CupertinoInteractiveMenuItem.child].
///
/// The [handleTap] method can be overridden to adjust exactly what happens when
/// the item is tapped. By default, it uses [Navigator.pop] to return the
/// [CupertinoInteractiveMenuItem.value] from the menu route.
///
/// This class takes two type arguments. The second, [W], is the exact type of
/// the [Widget] that is using this [State]. It must be a subclass of
/// [CupertinoInteractiveMenuItem]. The first, [T], must match the type argument of that
/// widget class, and is the type of values returned from this menu.
class CupertinoInteractiveMenuItemState<T,
    W extends CupertinoInteractiveMenuItem<T>> extends State<W> {
  /// The handler for when the user selects the menu item.
  ///
  /// Along with calling [CupertinoInteractiveMenuItem.onTap], it uses [Navigator.pop]
  /// to return a [CupertinoMenuValue] from the menu route.
  @protected
  void handleTap() {
    widget.onTap?.call();
    if (widget.shouldPopMenuOnPressed) {
      Navigator.pop<CupertinoMenuValue<T>>(
        context,
        CupertinoMenuValue(value: widget.value),
      );
    }
  }

  /// Provides text styles in response to changes in [CupertinoThemeData.brightness],
  /// [widget.isDefaultAction], [widget.isDestructiveAction], and [widget.enable].
  TextStyle get textStyle {
    if (widget.isDefaultAction) {
      return kCupertinoMenuActionTextStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: CupertinoDynamicColor.resolve(CupertinoColors.label, context),
      );
    }

    if (!widget.enabled) {
      return kCupertinoMenuActionTextStyle.copyWith(
        color: CupertinoColors.systemGrey.resolveFrom(context),
      );
    }

    if (widget.isDestructiveAction) {
      return kCupertinoMenuActionTextStyle.copyWith(
        color: CupertinoColors.destructiveRed,
      );
    }

    return kCupertinoMenuActionTextStyle.copyWith(
      color: CupertinoColors.label.resolveFrom(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        enabled: widget.enabled,
        button: true,
        child: CupertinoMenuItemGestureDetector(
          swipePressActivationDelay: widget.swipePressActivationDelay,
          onTap: widget.enabled ? handleTap : null,
          pressedColor: CupertinoDynamicColor.resolve(
            widget.pressedColor,
            context,
          ),
          child: DefaultTextStyle.merge(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
            child: IconTheme.merge(
              data: IconThemeData(color: textStyle.color, size: 21),
              child: widget.buildChild(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that provides the default structure, semantics, and interactivity for
/// menu items in a [CupertinoMenu] or [CupertinoNestedRoutedMenu].
///
///
/// For more flexibility, [CupertinoInteractiveMenuItem] can be overridden to customize the appearance and
/// layout of menu items.

class CupertinoMenuItemBase<T> extends CupertinoInteractiveMenuItem<T> {
  /// An item in a Cupertino menu.
  const CupertinoMenuItemBase({
    required super.child,
    super.key,
    super.onTap,
    super.enabled = true,
    super.isDestructiveAction,
    super.isDefaultAction,
    super.hasLeading,
    super.value,
    super.shouldPopMenuOnPressed = true,
    super.swipePressActivationDelay,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      6.5,
      8,
      17.5,
      8,
    ),
    super.height,
    this.leading,
    this.trailing,
  });

  /// The padding for the contents of the menu item.
  final EdgeInsetsDirectional padding;

  /// The widget shown before the title. Typically a [CupertinoIcon].
  final Widget? leading;

  /// The widget shown after the title. Typically a [CupertinoIcon].
  final Widget? trailing;

  @override
  Widget buildChild(BuildContext context) {
    return CupertinoMenuItemStructure(
      padding: padding,
      trailing: trailing,
      leading: leading,
      height: height,
      child: child,
    );
  }
}

class CupertinoMenuItemStructure extends StatelessWidget {
  final bool removeLeadingSpace;

  /// An item in a Cupertino menu.
  const CupertinoMenuItemStructure({
    required this.child,
    super.key,
    this.height = kMinInteractiveDimensionCupertino,
    this.padding = const EdgeInsetsDirectional.fromSTEB(
      6.5,
      8,
      17.5,
      8,
    ),
    this.removeLeadingSpace = false,
    this.leading,
    this.trailing,
  });

  /// The padding for the contents of the menu item.
  final EdgeInsetsDirectional padding;

  /// The widget shown before the title. Typically a [CupertinoIcon].
  final Widget? leading;

  /// The widget shown after the title. Typically a [CupertinoIcon].
  final Widget? trailing;

  /// The height of the menu item.
  final double height;

  /// The center content of the menu item
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: height,
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!removeLeadingSpace)
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 4.5),
                child: leading != null ||
                        CupertinoMenuLayerController.of(context)
                            .hasLeadingWidget
                    ? SizedBox(
                        width: 16.5,
                        child: leading,
                      )
                    : const SizedBox.shrink(),
              ),
            Expanded(child: child),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
