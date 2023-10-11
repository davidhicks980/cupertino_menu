import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'cupertino_menu.dart';

const bool isTransparent = true;

/// The color of a [CupertinoInteractiveMenuItem] when pressed.
// Pressed colors are based on the following:
//
// Dark mode on white background => rgb(111, 111, 111)
// Dark mode on black => rgb(61, 61, 61)
// Light mode on black background => rgb(177, 177, 177)
// Light mode on white => rgb(225, 225, 225)
const CupertinoDynamicColor _kCupertinoMenuDefaultBackgroundOnPress =
  CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(50, 50, 50, 0.105),
    darkColor: Color.fromRGBO(255, 255, 255, 0.15),
  );

/// Default color for [CupertinoMenuDivider] and [CupertinoVerticalMenuDivider].
///
/// The following colors were measured from the iOS simulator, and opacity was extrapolated:
/// ```dart
/// // Dark mode on white:
/// Color.fromRGBO(97, 97, 97)
/// // Dark mode on black:
/// Color.fromRGBO(51, 51, 51)
/// // Light mode on black:
/// Color.fromRGBO(147, 147, 147)
/// // Light mode on white:
/// Color.fromRGBO(187, 187, 187)
/// ```
const CupertinoDynamicColor kCupertinoMenuDividerColor = isTransparent
    ? CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(70, 70, 70, 0.35),
        darkColor: Color.fromRGBO(230, 230, 230, 0.3),
      )
    : CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(181, 181, 181, 1),
        darkColor: Color.fromRGBO(51, 51, 51, 1),
      );

/// Color for [CupertinoMenuLargeDivider].
///
/// The following colors were measured from the iOS simulator and opacity was extrapolated:
/// ```dart
/// // Dark mode on white:
/// Color.fromRGBO(70, 70, 70, 1)
/// // Dark mode on black:
/// Color.fromRGBO(26, 26, 26, 1)
/// // Light mode on black:
/// Color.fromRGBO(181, 181, 181, 1)
/// // Light mode on white:
/// Color.fromRGBO(226, 226, 226, 1)
/// ```
const CupertinoDynamicColor _kCupertinoMenuLargeDividerColor = isTransparent
    ? CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        darkColor: Color.fromRGBO(0, 0, 0, 0.16),
      )
    : CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(226, 226, 226, 1),
        darkColor: Color.fromRGBO(26, 26, 26, 1),
      );

mixin CupertinoMenuEntry<T> on Widget {
  /// The amount of vertical space occupied by this entry.
  ///
  /// This is not currently used, but it may be in the future.
  ///
  // TODO(davidhicks980): determine whether to measure menu items based on
  // user-provided height, or to calculate height at runtime.
  double get height => kMinInteractiveDimensionCupertino;

  /// Whether this menu item has a leading widget. If it does, the entire menu layer
  /// will have leading space added to align the leading edges of all menu items.
  CupertinoDynamicColor get dividerColor => kCupertinoMenuDividerColor;

  /// Whether this menu item has a leading widget. If it does, the menu
  /// items without a leading widget space will have leading space added to align
  /// the leading edges of all menu items.
  bool get hasLeading => false;

  /// Whether this menu item should have a separator drawn above it.
  bool get hasSeparator => true;
}

class CupertinoInteractiveMenuItem<T> 
  extends StatefulWidget
  with CupertinoMenuEntry<T> {
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
    this.pressedColor = _kCupertinoMenuDefaultBackgroundOnPress,
    this.focusNode,
    this.mouseCursor,
  });

  final MouseCursor? mouseCursor;

  /// An optional focus node to use for this menu item.
  final FocusNode? focusNode;

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

  /// Whether to dismiss the enclosing [_CupertinoMenu] after this item has been pressed
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
  /// By default, this returns [CupertinoInteractiveMenuItem.widget.child].
  /// Override this to put something else in the menu entry.
  @protected
  Widget buildChild(BuildContext context) => child;

  static const CupertinoDynamicColor defaultTextColor =
      CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.96),
    darkColor: Color.fromRGBO(255, 255, 255, 0.96),
  );
  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: 'SF Pro',
    fontFamilyFallback: <String>[
      '.AppleSystemUIFont',
    ],
    fontSize: 17,
    color: defaultTextColor,
    letterSpacing: -0.21,
    fontWeight: FontWeight.normal,
  );

  @override
  State<CupertinoInteractiveMenuItem<T>> createState() =>
      _CupertinoInteractiveMenuItemState<T>();
}

class _CupertinoInteractiveMenuItemState<T>
    extends State<CupertinoInteractiveMenuItem<T>> {
  /// The handler for when the user selects the menu item.
  ///
  /// Along with calling [CupertinoInteractiveMenuItem.widget.onTap], it uses [Navigator.pop]
  /// to return a [CupertinoMenuValue] from the menu route.
  @protected
  void handleTap() {
    widget.onTap?.call();
    if (widget.shouldPopMenuOnPressed && Navigator.canPop(context)) {
      Navigator.pop<T>(
        context,
        widget.value,
      );
    }
  }

  /// Provides text styles in response to changes in [CupertinoThemeData.brightness],
  /// [widget.isDefaultAction], [widget.isDestructiveAction], and [widget.enable].
  ///
  /// Eyeballed from the iOS simulator.
  TextStyle get textStyle {
    if (!widget.enabled) {
      return CupertinoInteractiveMenuItem.defaultTextStyle.copyWith(
        color: CupertinoColors.systemGrey.resolveFrom(context),
      );
    }

    if (widget.isDestructiveAction) {
      return CupertinoInteractiveMenuItem.defaultTextStyle.copyWith(
        color: CupertinoColors.destructiveRed,
      );
    }

    final Color resolvedColor =
        CupertinoInteractiveMenuItem.defaultTextColor.resolveFrom(context);

    if (widget.isDefaultAction) {
      return CupertinoInteractiveMenuItem.defaultTextStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: resolvedColor,
      );
    }

    return CupertinoInteractiveMenuItem.defaultTextStyle.copyWith(
      color: resolvedColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        enabled: widget.enabled,
        button: true,
        child: CupertinoMenuItemGestureHandler<T>(
          mouseCursor: widget.mouseCursor,
          swipePressActivationDelay: widget.swipePressActivationDelay,
          onTap: widget.enabled ? handleTap : null,
          pressedColor: CupertinoDynamicColor.resolve(
            widget.pressedColor,
            context,
          ),
          enabled: widget.enabled,
          focusNode: widget.focusNode,
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

/// A title in a [_CupertinoMenu].
class CupertinoMenuTitle extends StatelessWidget
    with CupertinoMenuEntry<Never> {
  /// Creates a title in a [_CupertinoMenu].
  const CupertinoMenuTitle({
    super.key,
    required this.child,
    this.textAlign = TextAlign.center,
  });

  /// The alignment of the title.
  final TextAlign textAlign;

  /// The title to be displayed. Usually a [Text] widget.
  final Widget child;

  @override
  double get height => 32.67;

  @override
  bool get hasSeparator => false;

  @override
  CupertinoDynamicColor get dividerColor {
    return const CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      darkColor: Color.fromRGBO(0, 0, 0, 0.15),
    );
  }

  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: 'SF Pro',
    fontFamilyFallback: <String>[
      '.AppleSystemUIFont',
    ],
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: CupertinoColors.secondaryLabel,
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        children: <Widget>[
          const CupertinoMenuLargeDivider(),
          _CupertinoMenuItemStructure(
            height: height,
            padding: EdgeInsetsDirectional.zero,
            title: DefaultTextStyle.merge(
              maxLines: 2,
              textAlign: textAlign,
              child: child,
              // Color is obtained from the defaultTextStyle to allow for customization
              style: defaultTextStyle.copyWith(
                color: CupertinoDynamicColor.maybeResolve(
                  defaultTextStyle.color,
                  context,
                ),
              ),
            ),
          ),
          CupertinoMenuDivider(
            color: dividerColor.resolveFrom(context),
            thickness: 1,
          ),
        ],
      ),
    );
  }
}

/// An item in a Cupertino menu.
///
/// By default, a [CupertinoMenuItem] is minimum of [kMinInteractiveDimensionCupertino]
/// pixels height.
///
/// See also:
/// * [_CupertinoMenu], a menu widget that can be toggled on and off.
@immutable
class CupertinoMenuItem<T> extends CupertinoBaseMenuItem<T> {
  /// An item in a Cupertino menu.
  const CupertinoMenuItem({
    super.key,
    required super.child,
    super.value,
    super.onTap,
    super.padding,
    super.trailing,
    super.height,
    super.enabled = true,
    super.shouldPopMenuOnPressed = true,
    super.isDefaultAction,
    super.isDestructiveAction,
  });
}

/// A checkmark in a [CupertinoCheckedMenuItem].
class _CupertinoCheckMark extends StatelessWidget {
  const _CupertinoCheckMark({this.checked = true});

  final bool checked;
  @override
  Widget build(BuildContext context) {
    if (!checked) {
      return const SizedBox.shrink();
    }
    return Text.rich(
      TextSpan(
        text: String.fromCharCode(
          CupertinoIcons.check_mark.codePoint,
        ),
        style: TextStyle(
          fontSize: 15,
          height: 1.25,
          fontWeight: FontWeight.w600,
          fontFamily: CupertinoIcons.check_mark.fontFamily,
          package: CupertinoIcons.check_mark.fontPackage,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// An item in a Cupertino menu with a leading checkmark.
///
/// Whether or not the checkmark is displayed can be set by by [checked].
@immutable
class CupertinoCheckedMenuItem<T> extends CupertinoBaseMenuItem<T> {
  /// An item in a Cupertino menu.
  const CupertinoCheckedMenuItem({
    required super.child,
    super.key,
    super.onTap,
    super.trailing,
    super.value,
    super.height,
    super.padding,
    super.mouseCursor,
    this.checked = true,
    super.enabled = true,
    super.shouldPopMenuOnPressed = true,
    super.isDefaultAction,
    super.isDestructiveAction,
  });

  @override
  bool get hasLeading => true;

  @override
  Widget? get leading {
    return ExcludeSemantics(child: 
        _CupertinoCheckMark(checked: checked!),
      );
  }

  @override
  VoidCallback? get onTap => () {
        HapticFeedback.selectionClick();
        super.onTap?.call();
      };

  /// Whether to display a checkmark next to the menu item.
  ///
  /// Defaults to false.
  ///
  /// When true, the [CupertinoIcons.check_mark] checkmark icon is displayed at 
  /// the leading edge of the menu item.
  final bool? checked;

  @override
  Widget buildChild(BuildContext context) {
    return Semantics(
      checked: checked,
      child: super.buildChild(context),
    );
  }
}

class CupertinoStickyMenuHeader extends StatelessWidget
    with CupertinoMenuEntry<Never> {
  CupertinoStickyMenuHeader({
    required this.child,
    super.key,
    required this.leading,
    this.trailing,
    this.subtitle,
    this.padding = const EdgeInsetsDirectional.only(
      top: 16,
      start: 16,
      end: 12,
      bottom: 12,
    ),
  });

  final Widget child;

  /// A widget displayed underneath the title.
  final Widget? subtitle;

  /// A widget displayed at the trailing edge of the header.
  final Widget? trailing;

  /// A widget to displayed at the leading edge of the header.
  final Widget leading;

  /// Padding to apply to the contents of the header. 
  final EdgeInsetsDirectional padding;

  @override
  double get height => 71 + 8;

  @override
  bool get hasLeading => true;

  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: '.AppleSystemUIFont',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: CupertinoInteractiveMenuItem.defaultTextColor,
    letterSpacing: -0.21,
  );
  static const TextStyle defaultSubtitleStyle = TextStyle(
    fontSize: 13,
    height: 17 / 12,
    package: '.AppleSystemUIFont',
    textBaseline: TextBaseline.alphabetic,
    color: CupertinoColors.secondaryLabel,
    letterSpacing: 0,
    fontWeight: FontWeight.w300,
  );

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = defaultTextStyle.copyWith(
      color: CupertinoDynamicColor.maybeResolve(
        defaultTextStyle.color,
        context,
      ),
    );

    return IconTheme(
      data: IconThemeData(
        color: textStyle.color,
        size: 20.333,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CupertinoMenuItemStructure(
            padding: padding,
            trailing: trailing,
            leading: Align(
              alignment: AlignmentDirectional.centerStart,
              child: leading,
            ),
            height: height - 8,
            title: DefaultTextStyle.merge(
              overflow: TextOverflow.ellipsis,
              style: textStyle,
              child: child,
            ),
            leadingWidth: 50,
            subtitle: DefaultTextStyle.merge(
              maxLines: 1,
              style: defaultSubtitleStyle.copyWith(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
              child: subtitle!,
            ),
          ),
          const CupertinoMenuLargeDivider(),
        ],
      ),
    );
  }
}

/// A widget that provides the default structure, semantics, and interactivity
/// for menu items in a [CupertinoMenu] or [CupertinoNestedMenu].
///
/// For more flexibility, [CupertinoInteractiveMenuItem] can be overridden to
/// customize the appearance and layout of menu items.
class CupertinoBaseMenuItem<T> extends CupertinoInteractiveMenuItem<T> {
  /// Creates a [CupertinoBaseMenuItem]
  const CupertinoBaseMenuItem({
    required super.child,
    super.key,
    super.onTap,
    super.hasLeading,
    super.value,
    super.swipePressActivationDelay,
    super.mouseCursor,
    super.height,
    super.shouldPopMenuOnPressed = true,
    super.enabled = true,
    super.isDestructiveAction,
    super.isDefaultAction,
    this.padding,
    this.leading,
    this.trailing,
    this.subtitle,
  });

  /// The padding for the contents of the menu item.
  final EdgeInsetsDirectional? padding;

  /// The widget shown before the label. Typically a [CupertinoIcon].
  final Widget? leading;

  /// The widget shown after the label. Typically a [CupertinoIcon].
  final Widget? trailing;

  // A widget displayed underneath the title. Typically a [Text] widget.
  final Widget? subtitle;

  @override
  Widget buildChild(BuildContext context) {
    return _CupertinoMenuItemStructure(
      padding: padding,
      trailing: trailing,
      leading: leading,
      height: height,
      title: child,
      subtitle: subtitle,
    );
  }
}

/// A default layout wrapper for [CupertinoBaseMenuItem]s.
class _CupertinoMenuItemStructure extends StatelessWidget {
  /// Creates a [_CupertinoMenuItemStructure]
  const _CupertinoMenuItemStructure({
    required this.title,
    this.height = kMinInteractiveDimensionCupertino,
    this.padding,
    this.leading,
    this.trailing,
    this.subtitle,
    double? leadingWidth,
    double? trailingWidth,
  })  : _trailingWidth = trailingWidth,
        _leadingWidth = leadingWidth;

  static const EdgeInsetsDirectional defaultVerticalPadding =
      EdgeInsetsDirectional.symmetric(vertical: 12);
  static const double defaultHorizontalWidth = 16;
  static const double leadingWidgetWidth = 32.0;
  static const double trailingWidgetWidth = 38.5;

  /// The padding for the contents of the menu item.
  final EdgeInsetsDirectional? padding;

  /// The widget shown before the title. Typically a [CupertinoIcon].
  final Widget? leading;

  /// The widget shown after the title. Typically a [CupertinoIcon].
  final Widget? trailing;

  /// The width of the leading portion of the menu item.
  final double? _leadingWidth;

  /// The width of the trailing portion of the menu item. 
  final double? _trailingWidth;

  /// The height of the menu item.
  final double height;

  /// The center content of the menu item
  final Widget title;

  /// The subtitle of the menu item
  final Widget? subtitle;

  @override
  Widget build(BuildContext context) {
    final double textScaler = MediaQuery.textScalerOf(context).scale(1);
    final bool hasLeading = leading != null || 
                            CupertinoMenuLayerScope.of(context).hasLeadingWidget;
    // Used to limit jump when the contents of a menu item change
    return AnimatedSize(
      curve: Curves.easeOutExpo,
      duration: const Duration(milliseconds: 600),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height * textScaler),
        child: Padding(
          padding: (padding ?? defaultVerticalPadding) * textScaler,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: _leadingWidth ?? 
                        (hasLeading 
                          ? leadingWidgetWidth 
                          : defaultHorizontalWidth),
                child: hasLeading
                    ? Align(
                        alignment: const AlignmentDirectional(0.167, 0),
                        child: leading,
                      )
                    : null,
              ),
              Expanded(
                child: subtitle != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          title, 
                          subtitle!,
                        ],
                      )
                    : title,
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: _trailingWidth ?? 
                        (trailing != null
                          ? trailingWidgetWidth
                          : defaultHorizontalWidth),
                child: trailing != null
                    ? Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: trailing,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The size of a [CupertinoMenuActionRow].
///
/// Used by [CupertinoMenuItemRowMixin] to determine the height and layout of a
/// row.
enum CupertinoMenuRowPreferredElementSize {
  /// A row that contains 4 children with a height of 44.0px.
  small,

  /// A row that contains 2 - 3 children with a height of 64.0px.
  medium,
}

/// Mixin this class to arrange a Cupertino menu item horizontally.
///
/// See also:
///   * [CupertinoMenuActionItem], a horizontally-arranged menu item that
///     consumes this class
///   * [CupertinoMenuActionRow], the widget that wraps [CupertinoMenuItemRowMixin]
mixin CupertinoMenuItemRowMixin<T> on CupertinoMenuEntry<T> {
  /// The [CupertinoMenuRowPreferredElementSize] of the row this widget is in.
  ///
  /// Can be used to determine the height and layout of this widget.
  CupertinoMenuRowPreferredElementSize preferredElementSizeOf(
    BuildContext context,
  ) {
    return CupertinoMenuActionRow.sizeOf(context);
  }
}

/// A horizontally-placed Cupertino menu item.
///
/// Action items should be placed adjacent to each other in a group of 2, 3 or 4.
///
/// When placed in a group of 2 or 3, each item will display an
/// [icon] above a [child]. In a group of 4, items will only display an [icon].
///
/// Setting [isDestructiveAction] to `true` indicates that the action is
/// irreversible or will result in deleted data. When `true`, the item's
/// label and icon will be [CupertinoColors.destructiveRed]
///
/// If the [onPressed] callback is null, the item will not react to touch and
/// it's contents will be [CupertinoColors.inactiveGray].
///
/// See also:
///  * [CupertinoMenuLargeDivider], a large divider in a Cupertino menu
///  * [CupertinoMenuItem], a full-width Cupertino menu item
class CupertinoMenuActionItem<T> extends CupertinoInteractiveMenuItem<T>
    with CupertinoMenuItemRowMixin<T> {
  const CupertinoMenuActionItem({
    super.key,
    required super.child,
    required this.icon,
    super.isDestructiveAction,
    super.enabled = true,
    super.onTap,
    super.value,
    super.mouseCursor,
  });

  /// An icon to display above the [child] in a group of 2 or 3, or centrally in a group of 4.
  final Icon icon;

  static const Color defaultColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.96),
    darkColor: Color.fromRGBO(255, 255, 255, 0.96),
  );

  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: '.AppleSystemUIFont',
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: defaultColor,
  );

  @override
  Widget buildChild(BuildContext context) {
    final Widget actionIcon = IconTheme.merge(
      data: IconThemeData(size: MediaQuery.textScalerOf(context).scale(16)),
      child: icon,
    );
    return switch (preferredElementSizeOf(context)) {
      CupertinoMenuRowPreferredElementSize.small => Center(child: actionIcon),
      CupertinoMenuRowPreferredElementSize.medium => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Spacer(),
            actionIcon,
            const SizedBox(
              height: 8,
            ),
            DefaultTextStyle.merge(
              maxLines: 1,
              textAlign: TextAlign.center,
              style: defaultTextStyle.copyWith(
                color: CupertinoDynamicColor.maybeResolve(
                  defaultTextStyle.color,
                  context,
                ),
              ),
              child: child,
            ),
            const Spacer(),
          ],
        )
    };
  }
}

/// Used to communicate the size of a [CupertinoMenuActionRow] to child elements
/// that mixin [CupertinoMenuItemRowMixin].
class _ActionRowState extends InheritedWidget {
  const _ActionRowState({
    required this.size,
    required super.child,
  });

  final CupertinoMenuRowPreferredElementSize size;

  @override
  bool updateShouldNotify(_ActionRowState oldWidget) => oldWidget.size != size;
}

class CupertinoMenuActionRow extends StatelessWidget
    with CupertinoMenuEntry<Never> {
  const CupertinoMenuActionRow({
    super.key,
    required this.children,
  }) : assert(
          children.length > 1 && children.length < 5,
          'CupertinoMenuActionRow can only have 2, 3 or 4 children',
        );

  final List<Widget> children;

  CupertinoMenuRowPreferredElementSize get size {
    return children.length == 4
        ? CupertinoMenuRowPreferredElementSize.small
        : CupertinoMenuRowPreferredElementSize.medium;
  }

  @override
  bool get hasLeading => false;

  @override
  double get height =>
      size == CupertinoMenuRowPreferredElementSize.small ? 44.0 : 64.0;

  static CupertinoMenuRowPreferredElementSize sizeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ActionRowState>()!.size;
  }

  @override
  Widget build(BuildContext context) {
    final double rowHeight =
        height * max(MediaQuery.textScalerOf(context).scale(1), 0.9);

    return _ActionRowState(
      size: size,
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(height: rowHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // Add vertical divider between each item
          children: List<Widget>.generate(
            children.length * 2 - 1,
            (int index) => index.isEven
                ? Expanded(child: children[index ~/ 2])
                : const CupertinoMenuVerticalDivider(),
            growable: false,
          ),
        ),
      ),
    );
  }
}

/// A [CupertinoMenuEntry] that inserts a large horizontal divider.
/// 
/// The divider has a height of 8 logical pixels. A [color] parameter can be
/// provided to customize the color of the divider.
///
/// See also:
///
/// * [CupertinoMenuItem], a Cupertino menu item.
/// * [CupertinoMenuActionItem], a horizontal menu item.
@immutable
class CupertinoMenuLargeDivider extends StatelessWidget
    with CupertinoMenuEntry<Never> {
  /// Creates a large horizontal divider for a [CupertinoMenu].
  const CupertinoMenuLargeDivider({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  bool get hasLeading => false;

  @override
  double get height => 8;

  @override
  bool get hasSeparator => false;

  @override
  Widget build(BuildContext context) {
    final Color background =
        color ?? _kCupertinoMenuLargeDividerColor.resolveFrom(context);
    return Container(
      height: height,
      color: background,
    );
  }
}

/// A [CupertinoMenuEntry] that inserts a horizontal divider.
///
/// The default width of the divider is 1 physical pixel,
@immutable
class CupertinoMenuDivider extends StatelessWidget
    with CupertinoMenuEntry<Never> {
  /// A [CupertinoMenuEntry] that adds a top border to it's child
  const CupertinoMenuDivider({
    super.key,
    this.color,
    this.thickness = 0.0,
  });

  /// The color of divider.
  ///
  /// If this property is null, [CupertinoMenuEntry.dividerColor] is used.
  final Color? color;

  final double thickness;

  @override
  bool get hasLeading => false;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = color ?? dividerColor.resolveFrom(context);
    return CustomPaint(
      foregroundPainter: _AliasedBorderPainter(
        p1: AlignmentDirectional.topStart,
        p2: AlignmentDirectional.topEnd,
        border: BorderSide(
          color: borderColor,
          width: thickness,
        ),
      ),
    );
  }
}

/// A [CupertinoMenuEntry] that adds a left border to it's child
///
/// The divider has a width of 1 pixel. It is used [CupertinoMenuActionItem]
///
/// See also:
/// * [CupertinoMenuActionItem], a horizontally-arranged menu item
class CupertinoMenuVerticalDivider extends StatelessWidget
    with CupertinoMenuEntry<Never> {
  /// Creates a vertical divider for a side-by-side appearance row.
  ///
  /// Divider has width and thickness of 0 logical pixels.
  const CupertinoMenuVerticalDivider({
    super.key,
    this.color,
  });

  /// The color of divider.
  ///
  /// If this property is null then [CMenuDividerThemeData.dividerColor] from
  /// [CMenuThemeData.dividerTheme] is used.
  final Color? color;

  @override
  bool get hasLeading => false;
  @override
  double get height => 0.00;

  @override
  Widget build(BuildContext context) {
    final Color background = color ?? dividerColor.resolveFrom(context);
    // Using a custom paint to draw a hairline border without antialiasing
    return CustomPaint(
      foregroundPainter: _AliasedBorderPainter(
        p1: AlignmentDirectional.topStart,
        p2: AlignmentDirectional.bottomStart,
        border: BorderSide(color: background, width: 0.0),
      ),
      child: const SizedBox(height: double.infinity, width: 0.67),
    );
  }
}

// A custom painter that draws a border without antialiasing
class _AliasedBorderPainter extends CustomPainter {
  const _AliasedBorderPainter({
    required this.border,
    required this.p1,
    required this.p2,
  });

  final BorderSide border;
  final AlignmentDirectional p1;
  final AlignmentDirectional p2;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = border.toPaint()..isAntiAlias = false;

    canvas.drawLine(
      Offset(
        size.width * (p1.start * 0.5 + 0.5),
        size.height * (p1.y * 0.5 + 0.5),
      ),
      Offset(
        size.width * (p2.start * 0.5 + 0.5),
        size.height * (p2.y * 0.5 + 0.5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_AliasedBorderPainter oldDelegate) =>
      border != oldDelegate.border ||
      p1 != oldDelegate.p1 ||
      p2 != oldDelegate.p2;
}

@optionalTypeArgs
mixin CoordinateAwareCupertinoMenuItemMixin<T extends StatefulWidget>
    on State<T> {
  CupertinoMenuTreeCoordinates? _menuItemDetails;
  CupertinoMenuTreeCoordinates? get menuItemDetails => _menuItemDetails;

  bool _isInteractive = true;
  bool get isInteractive => _isInteractive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _menuItemDetails = ScopedMenuTreeCoordinates.of(context);
    // Whether the menu layer containing this item is interactive.
    _isInteractive = CupertinoMenuLayerScope.of(context).isInteractive;
  }
}

class CupertinoMenuItemGestureHandler<T> extends StatefulWidget {
  /// Creates default menu gesture detector.
  const CupertinoMenuItemGestureHandler({
    super.key,
    required this.onTap,
    required this.pressedColor,
    required this.child,
    this.mouseCursor,
    this.swipePressActivationDelay = Duration.zero,
    this.focusedColor,
    this.focusNode,
    this.hoveredColor,
    this.enabled = true,
  });

  /// The menu item to wrap with touch gestures.
  final Widget child;

  /// Called when the menu item is tapped.
  final VoidCallback? onTap;

  /// Delay between a user's pointer entering a menu item during a swipe, and
  /// when the menu item should be tapped.
  ///
  /// Defaults to [Duration.zero], which will not trigger a tap on swipe. The
  /// menu item will still recieve regular taps.
  final Duration swipePressActivationDelay;

  /// The color of menu item when focused.
  final Color? focusedColor;

  /// The color of menu item when hovered by the user's pointer.
  final Color? hoveredColor;

  /// The color of menu item while the menu item is swiped or pressed down.
  final Color pressedColor;

  /// The color of menu item while the menu item is swiped or pressed down.
  final bool enabled;

  /// The mouse cursor to display on hover.
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;

  @override
  State<CupertinoMenuItemGestureHandler<T>> createState() =>
      _CupertinoMenuItemGestureHandlerState<T>();
}

class _CupertinoMenuItemGestureHandlerState<T>
    extends State<CupertinoMenuItemGestureHandler<T>>
    with
        PanTarget<CupertinoMenuItemGestureHandler<T>>,
        CoordinateAwareCupertinoMenuItemMixin {
  bool get enabled => widget.enabled && isInteractive;
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: simulateTap),
    ButtonActivateIntent:
        CallbackAction<ButtonActivateIntent>(onInvoke: simulateTap),
  };

  Timer? _pressOnHoldTimerCallback;
  bool _isFocused = false;
  bool _isSwiped = false;
  bool _isPressed = false;
  bool _isHovered = false;

  void _handleTap() {
    if (enabled) {
      widget.onTap?.call();
      setState(() {
        _isPressed = false;
        _isSwiped = false;
      });
    } else {
      CupertinoMenu.popLayer(context);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
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

  @override
  bool didPanEnter() {
    if (!enabled) {
      return false;
    }

    if (widget.swipePressActivationDelay > Duration.zero) {
      _pressOnHoldTimerCallback = Timer(widget.swipePressActivationDelay, () {
        if (mounted) {
          _handleTap();
        }

        _pressOnHoldTimerCallback = null;
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
  void didPanLeave(bool pointerUp) {
    _pressOnHoldTimerCallback?.cancel();
    _pressOnHoldTimerCallback = null;

    if (_isSwiped && mounted) {
      setState(() {
        _isSwiped = false;
      });
    }
  }

  @override
  void dispose() {
    _pressOnHoldTimerCallback?.cancel();
    super.dispose();
  }

  void simulateTap(Intent intent) {
    if (enabled) {
      widget.onTap?.call();
    }
  }

  void _handleMouseExit(PointerExitEvent event) {
    if (_isHovered) {
      setState(() {
        _isHovered = false;
      });
    }
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    if (enabled) {
      setState(() {
        _isHovered = true;
      });
    }
  }

  void _handleFocusChange(bool focused) {
    if (enabled) {
      setState(() {
        _isFocused = focused;
      });
    }
  }

  Color? get backgroundColor {
    if (!enabled) {
      return null;
    }

    if (_isPressed || _isSwiped) {
      return widget.pressedColor;
    }

    if (_isFocused) {
      return widget.focusedColor ?? widget.pressedColor.withOpacity(0.075);
    }

    if (_isHovered) {
      return widget.hoveredColor ?? widget.pressedColor.withOpacity(0.05);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      child: MouseRegion(
        cursor: enabled && kIsWeb
            ? widget.mouseCursor ?? SystemMouseCursors.click
            : MouseCursor.defer,
        onEnter: enabled ? _handleMouseEnter : null,
        onExit: _isHovered || enabled ? _handleMouseExit : null,
        hitTestBehavior: HitTestBehavior.deferToChild,
        child: Actions(
          actions: _actionMap,
          child: Focus(
            debugLabel: 'MenuItem layer: $_menuItemDetails}',
            canRequestFocus: enabled,
            skipTraversal: !enabled,
            onFocusChange: enabled || _isFocused ? _handleFocusChange : null,
            focusNode: widget.focusNode,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              onTapDown: enabled ? _handleTapDown : null,
              onTapUp: _isPressed ? _handleTapUp : null,
              onTapCancel: _isPressed || _isSwiped ? _handleTapCancel : null,
              child: ColoredBox(
                color: backgroundColor ?? const Color(0x00000000),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// Chevron used in [CupertinoNestedMenuItemAnchor]
class _CupertinoNestedMenuChevron extends StatelessWidget {
  const _CupertinoNestedMenuChevron();
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: String.fromCharCode(
          CupertinoIcons.chevron_forward.codePoint,
        ),
        style: TextStyle(
          fontSize: 17.5,
          height: 1.25,
          fontWeight: FontWeight.w600,
          fontFamily: CupertinoIcons.chevron_forward.fontFamily,
          package: CupertinoIcons.chevron_forward.fontPackage,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      textAlign: TextAlign.center,
    );
  }
}

// A [CupertinoMenuEntry] that is used as an anchor for a nested menu.
class CupertinoNestedMenuItemAnchor<T> extends StatefulWidget
    with CupertinoMenuEntry<Never> {
  const CupertinoNestedMenuItemAnchor({
    super.key,
    required this.child,
    required this.subtitle,
    required this.onTap,
    required this.animation,
    required this.isTopButton,
    this.trailing,
    required this.semanticsHint,
  });

  final Widget child;

  /// A widget displayed underneath the title. Typically a [Text] widget.
  final Widget? subtitle;

  /// A widget displayed at the trailing edge of the anchor. 
  /// 
  /// Typically a [CupertinoIcon].
  final Widget? trailing;

  /// The animation that controls the rotation of the chevron and the
  /// fade-in/fade-out of the title. 
  final Animation<double> animation;

  /// Called when the anchor is tapped.
  final void Function()? onTap;

  /// [CupertinoNestedMenu]s contain two anchors: one on the underlying menu
  /// and one on the nested menu. When the nested menu is open, the underlying
  /// anchor is hidden and the nested anchor is shown. 
  /// When false, the anchor is hidden using a [Visibility] widget.
  final bool isTopButton;

  /// A semantic hint for the anchor that will be read out by screen readers.
  final String semanticsHint;

  @override
  bool get hasLeading => true;

  @override
  double get height => 44;

  static const CupertinoDynamicColor defaultSubtitleColor =
    CupertinoDynamicColor.withBrightness(
            color: Color.fromRGBO(119, 120, 119, 1.00),
        darkColor: Color.fromRGBO(255, 255, 255, 0.48),
      );

  static const TextStyle defaultSubtitleStyle = 
      TextStyle(
        inherit: false,
        fontSize: 15,
        color: defaultSubtitleColor,
        letterSpacing: -0.21,
      );

  @override
  State<CupertinoNestedMenuItemAnchor<T>> createState() =>
      _CupertinoNestedMenuItemAnchorState<T>();
}

class _CupertinoNestedMenuItemAnchorState<T>
      extends State<CupertinoNestedMenuItemAnchor<T>> {
  late Animation<double>? _chevronRotationAnimation;
  late Animation<TextStyle>? _bottomTextStyleAnimation;
  late Animation<TextStyle>? _topTextStyleAnimation;
  static const Interval bottomTextInterval = Interval(0.3, 0.6, curve: Curves.easeIn);
  static const Interval topTextInterval = Interval(0.2, 0.6);
  late TextStyle _defaultTextStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Color labelColor = CupertinoDynamicColor.maybeResolve(
                             CupertinoInteractiveMenuItem.defaultTextColor,
                               context,
                             ) 
                            ?? const Color(0x00000000);
    _defaultTextStyle = CupertinoInteractiveMenuItem
                          .defaultTextStyle
                          .copyWith(color: labelColor,);
    _buildAnimations();
  }

  @override
  void didUpdateWidget(CupertinoNestedMenuItemAnchor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _buildAnimations();
    }
  }

  void _buildAnimations() {
    // Chevron rotates
    _chevronRotationAnimation = widget.animation.drive(
      Tween<double>(begin: 0, end: 0.25),
    );

    // Bottom text fades out
    _bottomTextStyleAnimation = widget.animation
        .drive(CurveTween(curve: bottomTextInterval))
        .drive(TextStyleTween(
            begin: _defaultTextStyle,
            end: _defaultTextStyle.copyWith(
              color: _defaultTextStyle.color?.withOpacity(0),
              letterSpacing: 0,
            ),
          ),);
    // Top text fades in when opening.
    _topTextStyleAnimation = widget.animation
        .drive(CurveTween(curve: topTextInterval))
        .drive(TextStyleTween(
            begin: _defaultTextStyle.copyWith(
              color: _defaultTextStyle.color?.withOpacity(0),
              fontWeight: FontWeight.w500,
              letterSpacing: -0.41,
            ),
            end: _defaultTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: -0.21,
            ),
          ),);
  }
  Widget _buildSubtitle(BuildContext context) {
    return DefaultTextStyle.merge(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CupertinoNestedMenuItemAnchor.defaultSubtitleStyle.copyWith(
        color: CupertinoDynamicColor.maybeResolve(
          CupertinoNestedMenuItemAnchor.defaultSubtitleStyle.color,
          context,
        ),
      ),
      child: widget.subtitle!,
    );
  }

  @override
  Widget build(BuildContext context) {
    // When the top anchor is shown, we hide the anchor item's contents but
    // maintain the size.
    return Visibility(
      visible: widget.isTopButton,
      maintainAnimation: true,
      maintainState: true,
      maintainSize: true,
      child: Semantics(
        hint: widget.semanticsHint,
        child: CupertinoBaseMenuItem<T>(
          swipePressActivationDelay: const Duration(milliseconds: 500),
          shouldPopMenuOnPressed: false,
          onTap: widget.onTap,
          trailing: widget.trailing,
          leading: ExcludeSemantics(
            child: RotationTransition(
              turns: _chevronRotationAnimation!,
              child: const _CupertinoNestedMenuChevron(),
            ),
          ),
          subtitle: widget.subtitle != null ? _buildSubtitle(context) : null,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              DefaultTextStyleTransition(
                overflow: TextOverflow.ellipsis,
                style: _bottomTextStyleAnimation!,
                child: widget.child,
              ),
              DefaultTextStyleTransition(
                overflow: TextOverflow.ellipsis,
                style: _topTextStyleAnimation!,
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}

typedef PanUpdateCallback = void Function(Offset position, bool onTarget);
typedef PanEndCallback = void Function(Offset position);
typedef PanTargetFilter<T extends PanTarget<StatefulWidget>> = bool Function(T target);
typedef PanStartCallback = Drag? Function(Offset position);

/// This widget is used by [CupertinoInteractiveMenuItem]s to determine whether
/// the menu item should be highlighted. On items with a defined
/// [CupertinoInteractiveMenuItem.swipePressActivationDelay], menu items will be
/// selected after the user's finger has made contact with the menu item for the
/// specified duration
class CupertinoPanListener<T extends PanTarget<StatefulWidget>>
    extends StatefulWidget {
  /// Creates [CupertinoPanListener] that wraps a Cupertino menu and notifies the layer's children during user swiping.
  const CupertinoPanListener({
    required this.child,
    required this.onPanUpdate,
    required this.onPanEnd,
    super.key,
  });

  final PanUpdateCallback? onPanUpdate;
  final PanEndCallback? onPanEnd;

  /// The menu layer to wrap.
  final Widget child;

  ImmediateMultiDragGestureRecognizer createRecognizer(
    PanStartCallback onStart,
  ) {
    return ImmediateMultiDragGestureRecognizer()..onStart = onStart;
  }

  @override
  State<CupertinoPanListener<T>> createState() =>
      _CupertinoPanListenerState<T>();
}

class _CupertinoPanListenerState<T extends PanTarget<StatefulWidget>>
    extends State<CupertinoPanListener<T>> {
  ImmediateMultiDragGestureRecognizer? _recognizer;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _recognizer = widget.createRecognizer(_startDrag);
  }

  @override
  void didChangeDependencies() {
    _recognizer!.gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _disposeRecognizerIfInactive();
    super.dispose();
  }

  void _disposeRecognizerIfInactive() {
    if (_dragging || _recognizer == null) {
      return;
    }
    _recognizer!.dispose();
    _recognizer = null;
  }

  void _routePointer(PointerDownEvent event) {
    _recognizer?.addPointer(event);
  }

  Drag? _startDrag(Offset position) {
    if (_dragging) {
      return null;
    }

    _dragging = true;

    return _PanHandler<T>(
      initialPosition: position,
      viewId: View.of(context).viewId,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: (Offset position) {
        if (mounted) {
          setState(() {
            _dragging = false;
          });
        } else {
          _dragging = false;
          _disposeRecognizerIfInactive();
        }
        widget.onPanEnd?.call(position);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _routePointer,
      child: widget.child,
    );
  }
}

mixin PanTarget<T extends StatefulWidget> on State<T> {
  /// Called when a pointer enters the [PanTarget]. Return true if the pointer
  /// should be considered "on" the [PanTarget], and false otherwise (for
  /// example, when the [PanTarget] is disabled).
  bool didPanEnter();

  /// Called when the pointer leaves the [PanTarget]. If [pointerUp] is true,
  /// then the pointer left the screen while over this menu item.
  void didPanLeave(bool pointerUp);
}

// Handles panning events for a [CupertinoPanListener]
//
// Calls [onPanUpdate] when the user's finger moves over a [PanTarget] and
// [onPanEnd] when the user's finger leaves the [PanTarget].
class _PanHandler<T extends PanTarget<StatefulWidget>> extends Drag {
  _PanHandler({
    required Offset initialPosition,
    required this.viewId,
    this.onPanEnd,
    this.onPanUpdate,
  }) : _position = initialPosition {
    updateDrag(initialPosition);
  }

  final int viewId;
  final List<T> _enteredTargets = <T>[];
  final PanEndCallback? onPanEnd;
  final PanUpdateCallback? onPanUpdate;
  Offset _position;

  @override
  void update(DragUpdateDetails details) {
    _position += details.delta;
    updateDrag(_position);
  }

  @override
  void end(DragEndDetails details) {
    finishDrag(pointerUp: true);
  }

  @override
  void cancel() {
    finishDrag();
  }

  void updateDrag(Offset globalPosition) {
    final HitTestResult result = HitTestResult();

    WidgetsBinding.instance.hitTestInView(result, globalPosition, viewId);

    final List<T> targets = _getDragTargets(result.path).toList();

    bool listsMatch = false;
    if (targets.length >= _enteredTargets.length &&
        _enteredTargets.isNotEmpty) {
      listsMatch = true;
      final Iterator<T> iterator = targets.iterator;

      for (int i = 0; i < _enteredTargets.length; i++) {
        iterator.moveNext();
        if (iterator.current != _enteredTargets[i]) {
          listsMatch = false;
          break;
        }
      }
    }

    onPanUpdate?.call(globalPosition, targets.isNotEmpty);

    // If everything is the same, report moves, and bail early.
    if (listsMatch) {
      return;
    }

    // Leave old targets.
    _leaveAllEntered();

    // Enter new targets.
    targets.cast<T?>().firstWhere(
      (T? target) {
        if (target == null) {
          return false;
        }

        _enteredTargets.add(target);
        if (target.didPanEnter()) {
          HapticFeedback.selectionClick();
          return true;
        }

        return false;
      },
      orElse: () => null,
    );
  }

  Iterable<T> _getDragTargets(
    Iterable<HitTestEntry> path,
  ) {
    // Look for the RenderBoxes that corresponds to the hit target (the hit target
    // widgets build RenderMetaData boxes for us for this purpose).
    final List<T> targets = <T>[];
    for (final HitTestEntry entry in path) {
      final HitTestTarget target = entry.target;
      if (target is RenderMetaData && target.metaData is T) {
        targets.add(target.metaData as T);
      }
    }
    return targets;
  }

  void _leaveAllEntered({bool pointerUp = false}) {
    for (int i = 0; i < _enteredTargets.length; i += 1) {
      _enteredTargets[i].didPanLeave(pointerUp);
    }
    _enteredTargets.clear();
  }

  void finishDrag({bool pointerUp = false}) {
    _leaveAllEntered(pointerUp: pointerUp);
    onPanEnd?.call(_position);
  }
}
