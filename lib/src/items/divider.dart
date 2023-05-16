import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../cupertino_menu.dart';
import 'base.dart';

/// Default color for [CupertinoMenuDivider] and [CupertinoVerticalMenuDivider].
///
/// The following colors were measured from the iOS simulator, and opacity was extrapolated:
/// ```dart
/// // Dark mode on white:
/// Color.fromRGBO(97, 97, 97)
/// // Dark mode on black:
/// Color.fromRGBO(51, 51, 51)
/// // Light mode on black:
/// Color.fromRGBO(181, 181, 181)
/// // Light mode on white:
/// Color.fromRGBO(226, 226, 226)
/// ```
const CupertinoDynamicColor kCupertinoMenuDividerColor = isTransparent
    ? CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(44, 44, 44, 0.35),
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
const kCupertinoLargeMenuDividerColor = isTransparent
    ? CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(50, 50, 50, 0.105),
        darkColor: Color.fromRGBO(0, 0, 0, 0.15),
      )
    : CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(226, 226, 226, 1),
        darkColor: Color.fromRGBO(26, 26, 26, 1),
      );

/// A horizontal divider for cupertino style pull-down menu.
///
/// This widget adapts the [Divider] for use in pull-down menus.
///
/// See also:
///
/// * [CupertinoMenuItem], a full-sized menu item
/// * [CupertinoMenuActionItem], a small horizontal menu item
/// * [CupertinoMenuTitle], a pull-down menu entry for a menu title.
@immutable
class CupertinoMenuLargeDivider extends StatelessWidget
    implements CupertinoMenuEntry<Never> {
  /// Creates a horizontal divider for a pull-down menu.
  ///
  /// Divider has height and thickness of 8 logical pixels.
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
  Widget build(BuildContext context) {
    final bg = color ?? kCupertinoLargeMenuDividerColor.resolveFrom(context);
    return Container(
      height: height,
      color: bg,
    );
  }
}

class CupertinoMenuDividerWrapper extends StatelessWidget
    implements CupertinoMenuEntry<Never> {
  /// Creates a horizontal divider for a [CupertinoMenuItem]. The divider has a width of
  /// 1 pixel,
  const CupertinoMenuDividerWrapper({
    super.key,
    required this.child,
    this.color,
  });

  /// The menu item to wrap with horizontal divider on it's top end.
  final Widget child;

  /// The color of divider.
  ///
  /// If this property is null, [kCupertinoMenuDividerColor] is used.
  final Color? color;

  @override
  bool get hasLeading => false;
  @override
  double get height => 0.00;

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        color ?? kCupertinoMenuDividerColor.resolveFrom(context);
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1 / (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0),
          ),
        ),
      ),
      child: child,
    );
  }
}

/// A vertical divider for horizontally-arranged [CupertinoMenuActionItem]s.
class CupertinoMenuVerticalDividerWrapper extends StatelessWidget
    implements CupertinoMenuEntry<Never> {
  /// Creates a vertical divider for a side-by-side appearance row.
  ///
  /// Divider has width and thickness of 0 logical pixels.
  const CupertinoMenuVerticalDividerWrapper({
    super.key,
    required this.child,
    this.color,
  });

  /// The color of divider.
  ///
  /// If this property is null then [CMenuDividerThemeData.dividerColor] from
  /// [CMenuThemeData.dividerTheme] is used.
  final Color? color;

  final Widget child;

  @override
  bool get hasLeading => false;
  @override
  double get height => 0.00;

  @override
  Widget build(BuildContext context) {
    final Color bg = color ?? kCupertinoMenuDividerColor.resolveFrom(context);

    // I don't like this approach, but it produces a divider that is most
    // visually-representative of the native iOS divider
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: bg,
            width: 1 / (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0),
          ),
        ),
      ),
      child: child,
    );
  }
}
