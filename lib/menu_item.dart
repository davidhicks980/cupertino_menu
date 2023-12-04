// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/cupertino/colors.dart';
import 'package:flutter/src/cupertino/constants.dart';
import 'package:flutter/src/cupertino/icons.dart';

import 'menu.dart';


// TODO(davidhicks980): Add fill properties.

/// A mixin that specifies that a widget can be used in a [CupertinoMenu] or a
/// [CupertinoNestedMenu].
mixin CupertinoMenuEntry on Widget {
  /// The constraints to apply to the contents of a [CupertinoMenuEntry].
  /// Constraints will be scaled by [MediaQuery.textScalerOf] to account for
  /// text scaling.
  ///
  /// The [BoxConstraints.maxWidth] can only be as large as the width of the
  /// menu.
  //
  // TODO(davidhicks980): Determine whether measuring menu items is necessary.
  // Or whether height could be calculated at runtime.
  double get height => kMinInteractiveDimensionCupertino;

  /// The color of a [CupertinoInteractiveMenuItem] when pressed.
  // Pressed colors were sampled from the iOS simulator and are based on the
  // following:
  //
  // Dark mode on white background     rgb(111, 111, 111)
  // Dark mode on black                rgb(61, 61, 61)
  // Light mode on black background    rgb(177, 177, 177)
  // Light mode on white               rgb(225, 225, 225)
  static const CupertinoDynamicColor backgroundOnPress =
    CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(50, 50, 50, 0.2),
      darkColor: Color.fromRGBO(255, 255, 255, 0.2),
    );

  /// The default constraints for a [CupertinoMenuEntry], corresponding to a
  /// minHeight of [kMinInteractiveDimensionCupertino].
  static const BoxConstraints defaultMenuItemConstraints = BoxConstraints(
    minHeight:  kMinInteractiveDimensionCupertino,
  );

  /// Whether this menu item has a leading widget. If it does, the menu
  /// items without a leading widget space will have leading space added to align
  /// the leading edges of all menu items.
  bool get hasLeading => false;

  /// Whether this menu item should have a separator drawn above it.
  bool get hasSeparator => true;
}

/// A widget that provides the default styling, semantics, and interactivity
/// for menu items in a [CupertinoMenu] or [CupertinoNestedMenu].
class CupertinoInteractiveMenuItem extends StatefulWidget
      with CupertinoMenuEntry {
  /// Creates a [CupertinoInteractiveMenuItem], a widget that provides the
  /// default styling, semantics, and interactivity for menu items in a
  /// [CupertinoMenu] or [CupertinoNestedMenu].
  const CupertinoInteractiveMenuItem({
    super.key,
    required this.child,
    this.height = kMinInteractiveDimensionCupertino,
    this.hasLeading = false,
    this.shouldPopMenuOnPressed = true,
    this.enabled = true,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.panPressActivationDelay = Duration.zero,
    this.onTap,
    this.pressedColor,
    this.focusNode,
    this.mouseCursor,
  });

  /// The type of mouse cursor to use when a mouse pointer is hovering over
  /// this menu item.
  final MouseCursor? mouseCursor;

  /// An optional focus node to use for this menu item.
  final FocusNode? focusNode;

  /// Whether the user can interact with this item.
  ///
  /// Defaults to true. If false, the item will inherit [CupertinoColors.inactiveGray]
  /// as it's text color.
  final bool enabled;

  /// Called when the menu item is tapped.
  final VoidCallback? onTap;

  /// The color of the menu item when pressed.
  ///
  /// This color will blend with the menu item's base color.
  final Color? pressedColor;

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
  final Duration panPressActivationDelay;

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

  /// The widget to show as the menu item's label.
  final Widget child;

  /// The menu item contents.
  ///
  /// Used by the [build] method.
  ///
  /// Defaults to [CupertinoInteractiveMenuItem.widget.child].
  /// Override this to put something else in the menu entry.
  @protected
  Widget buildChild(BuildContext context) => child;

  @override
  final bool hasLeading;

  @override
  final double height;

  /// The default text color for labels in a [CupertinoInteractiveMenuItem].
  static const CupertinoDynamicColor defaultTextColor =
      CupertinoDynamicColor.withBrightness(
          color: Color.fromRGBO(0, 0, 0, 0.96),
          darkColor: Color.fromRGBO(255, 255, 255, 0.96),
        );

  /// The default text style for labels in a [CupertinoInteractiveMenuItem].
  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: <String>[
      '.AppleSystemUIFont'
    ],
    fontSize: 17,
    letterSpacing: -0.21,
    color: defaultTextColor,
    fontWeight: FontWeight.w300,

  );

  @override
  State<CupertinoInteractiveMenuItem> createState() =>
      _CupertinoInteractiveMenuItemState();
}

class _CupertinoInteractiveMenuItemState
      extends State<CupertinoInteractiveMenuItem> {
  /// The handler for when the user selects the menu item.
  ///
  /// Along with calling [CupertinoInteractiveMenuItem.widget.onTap], it uses [Navigator.pop]
  /// to return a [CupertinoMenuValue] from the menu route.
  @protected
  void handleTap() {
    widget.onTap?.call();
    if (widget.shouldPopMenuOnPressed && Navigator.canPop(context)) {
      Navigator.pop(
        context,
      );
    }
  }

  /// Provides text styles in response to changes in [CupertinoThemeData.brightness],
  /// [widget.isDefaultAction], [widget.isDestructiveAction], and [widget.enable].
  //
  // Eyeballed from the iOS simulator.
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

    final Color resolvedColor = CupertinoInteractiveMenuItem
                                    .defaultTextColor
                                    .resolveFrom(context);

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
        child: CupertinoMenuItemGestureHandler(
          mouseCursor: widget.mouseCursor,
          panPressActivationDelay: widget.panPressActivationDelay,
          onTap: widget.enabled ? handleTap : null,
          pressedColor: CupertinoDynamicColor.resolve(
            widget.pressedColor ?? CupertinoMenuEntry.backgroundOnPress,
            context,
          ),
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          child: DefaultTextStyle.merge(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
            child: IconTheme.merge(
              data: IconThemeData(
                color: textStyle.color,
                size: MediaQuery.textScalerOf(context).scale(21)
              ),
              child: widget.buildChild(context),
            ),
          ),
        ),
      ),
    );
  }
}

/// A title in a [CupertinoMenu].
class CupertinoMenuTitle extends StatelessWidget
       {
  /// Creates a title in a [CupertinoMenu].
  const CupertinoMenuTitle({
    super.key,
    required this.child,
    this.textStyle = defaultTextStyle,
    this.textAlign = TextAlign.center,
  });

  /// The alignment of the title.
  final TextAlign textAlign;
  final TextStyle textStyle;

  /// The widget to display as a title. Usually a [Text] widget.
  final Widget child;

  @override
  double get height => 33;

  @override
  bool get hasSeparator => false;

  /// The default divider color for a [CupertinoMenuTitle].
  CupertinoDynamicColor get dividerColor {
    return const CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(0, 0, 0, 0.2),
      darkColor: Color.fromRGBO(0, 0, 0, 0.15),
    );
  }

  /// The default text style for a [CupertinoMenuTitle].
  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
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
      child: _CupertinoMenuItemStructure(
        height: height,
        padding: EdgeInsetsDirectional.zero,
        title: DefaultTextStyle.merge(
          maxLines: 2,
          textAlign: textAlign,
          child: child,
          style: textStyle.copyWith(
            color: CupertinoDynamicColor.maybeResolve(
              textStyle.color,
              context,
            ),
          ),
        ),
      ),
    );
  }
}

/// An item in a Cupertino menu.
///
/// Defaults to a minimum of [kMinInteractiveDimensionCupertino]
/// pixels tall.
///
/// See also:
/// * [_CupertinoMenu], a menu widget that can be toggled on and off.
@immutable
class CupertinoMenuItem extends CupertinoBaseMenuItem {
  /// An item in a Cupertino menu.
  const CupertinoMenuItem({
    super.key,
    required super.child,
    super.onTap,
    super.padding,
    super.trailing,
    super.height,
    super.enabled = true,
    super.shouldPopMenuOnPressed = true,
    super.isDefaultAction,
    super.isDestructiveAction,
    super.mouseCursor,
    super.pressedColor,
    super.focusNode,
  });
}

/// An item in a Cupertino menu with a leading checkmark.
///
/// Whether or not the checkmark is displayed can be set by by [checked].
// TODO(davidhicks980): Figure out how to add documentation to super props.
@immutable
class CupertinoCheckedMenuItem extends CupertinoBaseMenuItem {
  /// An item in a Cupertino menu.
  const CupertinoCheckedMenuItem({
    required super.child,
    super.key,
    super.onTap,
    super.trailing,
    super.height,
    super.padding,
    super.mouseCursor,
    super.enabled = true,
    super.shouldPopMenuOnPressed = true,
    super.isDefaultAction,
    super.isDestructiveAction,
    super.pressedColor,
    super.focusNode,
    this.checked = true,
  });

  @override
  bool get hasLeading => true;

  @override
  Widget? get leading {
    return ExcludeSemantics(child:
       checked ?? false ? const _MenuLeadingIcon(CupertinoIcons.check_mark, fontSize: 15) : null,
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


/// A sticky header in a [CupertinoMenu].
///
/// The header is always visible, and can be overscrolled. The main text content
/// can be displayed by providing a [child] widget, and an optional [subtitle]
/// can be displayed below the main text. A [leading] and [trailing] widget can
/// be provided to display widgets at the horizontal edges of the header.
///
/// To change the size of the header, [padding] can be provided. Defaults to 79
/// logical pixels tall.
class CupertinoStickyMenuHeader extends StatelessWidget with CupertinoMenuEntry
       {
  /// Creates a sticky header in a [CupertinoMenu].
  CupertinoStickyMenuHeader({
    super.key,
    required this.child,
    required this.leading,
    this.trailing,
    this.subtitle,
    this.padding = const EdgeInsetsDirectional.only(
      top: 16,
      start: 12,
      end: 12,
      bottom: 20,
    ),
  });

  /// The default text style for a [CupertinoStickyMenuHeader] title.
  static const TextStyle defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: 'CupertinoSystemText',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: CupertinoInteractiveMenuItem.defaultTextColor,
    letterSpacing: -0.21,
  );

  /// The default text style for a [CupertinoStickyMenuHeader] subtitle.
  static const TextStyle defaultSubtitleStyle = TextStyle(
    fontSize: 13,
    height: 1.25,
    package: 'CupertinoSystemText',
    textBaseline: TextBaseline.alphabetic,
    color: CupertinoColors.secondaryLabel,
    letterSpacing: -0.21,
    fontWeight: FontWeight.w400,
  );

  /// The widget to display as the title of the header. Usually a [Text] widget.
  final Widget child;

  /// A widget displayed underneath the title. Usually a [Text] widget.
  final Widget? subtitle;

  /// A widget displayed at the trailing edge of the header.
  final Widget? trailing;

  /// A widget to displayed at the leading edge of the header.
  final Widget leading;

  /// Padding to apply to the contents of the header.
  final EdgeInsetsDirectional padding;

  @override
  double get height => 43 + padding.vertical + 8;

  @override
  bool get hasLeading => true;

  double getScaledHeight(TextScaler scaler) {
    return scaler.clamp(
            minScaleFactor: 0.9,
            maxScaleFactor:  2.0
          ).scale(height - padding.vertical - 8) + padding.vertical;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = defaultTextStyle.copyWith(
      color: CupertinoDynamicColor.maybeResolve(
        defaultTextStyle.color,
        context,
      ),
    );
    final TextScaler scaler = MediaQuery
                                .textScalerOf(context)
                                .clamp(
                                  minScaleFactor: 0.9,
                                  maxScaleFactor: 2.0
                                );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: getScaledHeight(scaler),
      ),
      child: MediaQuery.withClampedTextScaling(
        minScaleFactor: 0.9,
        maxScaleFactor: 2,
        child: IconTheme(
          data: IconThemeData(
            color: textStyle.color,
            size: scaler.scale(20.333),
          ),
          child: _CupertinoMenuItemStructure(
            scalePadding: false,
            padding: padding,
            trailing: trailing,
            leading:  Padding(
              padding: const EdgeInsetsDirectional.only(end: 4.0),
              child: leading,
            ),
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
        ),
      ),
    );
  }
}

/// A widget that provides the default structure, semantics, and interactivity
/// for menu items in a [CupertinoMenu] or [CupertinoNestedMenu].
///
/// See also:
/// * [CupertinoInteractiveMenuItem], a widget that provides the default
///   typography, semantics, and interactivity for menu items in a
///   [CupertinoMenu], while allowing for customization of the menu item's
///   structure.
class CupertinoBaseMenuItem extends CupertinoInteractiveMenuItem {
  /// Creates a [CupertinoBaseMenuItem]
  const CupertinoBaseMenuItem({
    required super.child,
    super.key,
    super.onTap,
    super.hasLeading,
    super.panPressActivationDelay,
    super.mouseCursor,
    super.height,
    super.shouldPopMenuOnPressed = true,
    super.enabled = true,
    super.isDestructiveAction,
    super.isDefaultAction,
    super.pressedColor,
    super.focusNode,
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

  /// A widget displayed underneath the title. Typically a [Text] widget.
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

// A default layout wrapper for [CupertinoBaseMenuItem]s.
class _CupertinoMenuItemStructure extends StatelessWidget {

  // Creates a [_CupertinoMenuItemStructure]
  const _CupertinoMenuItemStructure({
    required this.title,
    this.height = kMinInteractiveDimensionCupertino,
    this.leading,
    this.trailing,
    this.subtitle,
    this.scalePadding = true,
    this.leadingAlignment = defaultLeadingAlignment,
    this.trailingAlignment = defaultTrailingAlignment,
    EdgeInsetsDirectional? padding,
    double? leadingWidth,
    double? trailingWidth,
  })  : _trailingWidth = trailingWidth,
        _leadingWidth = leadingWidth,
        _padding = padding ?? defaultPadding;

  static const EdgeInsetsDirectional defaultPadding =
      EdgeInsetsDirectional.symmetric(vertical: 12);
  static const double defaultHorizontalWidth = 16;
  static const double leadingWidgetWidth = 32.0;
  static const double trailingWidgetWidth = 44.0;
  static const AlignmentDirectional defaultLeadingAlignment = AlignmentDirectional(1/6, 0);
  static const AlignmentDirectional defaultTrailingAlignment = AlignmentDirectional(-3/11, 0);

  // The padding for the contents of the menu item.
  final EdgeInsetsDirectional _padding;

  // The widget shown before the title. Typically a [CupertinoIcon].
  final Widget? leading;

  // The widget shown after the title. Typically a [CupertinoIcon].
  final Widget? trailing;

  // The width of the leading portion of the menu item.
  final double? _leadingWidth;

  // The width of the trailing portion of the menu item.
  final double? _trailingWidth;

  // The alignment of the leading widget within the leading portion of the menu
  // item.
  final AlignmentDirectional leadingAlignment;

  // The alignment of the trailing widget within the trailing portion of the
  // menu item.
  final AlignmentDirectional trailingAlignment;

  // The height of the menu item.
  final double height;

  // The center content of the menu item
  final Widget title;

  // The subtitle of the menu item
  final Widget? subtitle;

  // Whether to scale the padding of the menu item with textScaleFactor
  final bool scalePadding;

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.maybeTextScalerOf(context)?.scale(1) ?? 1.0;
    final bool showLeadingWidget = leading != null
            || (CupertinoMenuLayer.maybeOf(context)?.hasLeadingWidget ?? false);
    final bool showTrailingWidget = textScale < 1.25 && trailing != null;
    // Padding scales with textScale, but at a slower rate than text. Square
    // root is used to estimate the padding scaling factor.
    final double scaledPadding = scalePadding ? math.sqrt(textScale) : 1.0;
    final double trailingWidth = (_trailingWidth
                                   ?? (showTrailingWidget
                                        ? trailingWidgetWidth
                                        : defaultHorizontalWidth)) * scaledPadding;
    final double leadingWidth = (_leadingWidth
                                  ?? (showLeadingWidget
                                       ? leadingWidgetWidth
                                       : defaultHorizontalWidth)) * scaledPadding;
    // AnimatedSize is used to limit jump when the contents of a menu item
    // change
    return ConstrainedBox(
        constraints: BoxConstraints(minHeight: height * scaledPadding),
        child: Padding(
          padding: _padding * scaledPadding,
          child: Row(
            children: <Widget>[
              // The leading and trailing widgets are wrapped in SizedBoxes and
              // then aligned, rather than just padded, because the alignment
              // behavior of the SizedBoxes appears to be more consistent with
              // AutoLayout (iOS).
              SizedBox(
                width: leadingWidth,
                child: showLeadingWidget
                         ? Align(alignment: defaultLeadingAlignment, child: leading)
                         : null,
              ),
              Expanded(
                child: subtitle == null
                    ? title
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          title,
                          subtitle!,
                        ],
                      ),
              ),
              SizedBox(
                width: trailingWidth,
                child: showTrailingWidget
                         ? Align(alignment: defaultTrailingAlignment, child: trailing)
                         : null,
              ),
            ],
          ),
      ),
    );
  }
}


mixin CupertinoNoDividerMixin on Widget {
  /// Whether this menu item should have a separator drawn above it.
  bool get hasSeparator => false;
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
       {
  /// Creates a large horizontal divider for a [CupertinoMenu].
  const CupertinoMenuLargeDivider({
    super.key,
    this.color = transparentColor,
  });

  /// Color for a transparent [CupertinoMenuLargeDivider].
  // The following colors were measured from the iOS simulator and opacity was
  // extrapolated:
  // ---------------------------
  // Dark mode on white:
  // Color.fromRGBO(70, 70, 70, 1)
  //
  // Dark mode on black:
  // Color.fromRGBO(26, 26, 26, 1)
  //
  // Light mode on black:
  // Color.fromRGBO(181, 181, 181, 1)
  //
  // Light mode on white:
  // Color.fromRGBO(226, 226, 226, 1)
  static const CupertinoDynamicColor transparentColor =
    CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      darkColor: Color.fromRGBO(0, 0, 0, 0.16),
    );

  /// The color of the divider.
  ///
  /// If this property is null, [CupertinoMenuLargeDivider.transparentColor] is
  /// used.
  final CupertinoDynamicColor color;

  @override
  bool get hasLeading => false;

  @override
  double get height => 8;

  @override
  bool get hasSeparator => false;

  @override
  Widget build(BuildContext context) {
    final Color background = color.resolveFrom(context);
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
       {
  /// A [CupertinoMenuEntry] that adds a top border to it's child
  const CupertinoMenuDivider({
    super.key,
    this.color  = dividerColor,
    this.thickness = 0.0,
  });
  /// Default transparent color for [CupertinoMenuDivider] and
  /// [CupertinoVerticalMenuDivider].
  ///
  // The following colors were measured from the iOS simulator, and opacity was
  // extrapolated:
  // Dark mode on white       Color.fromRGBO(97, 97, 97)
  // Dark mode on black       Color.fromRGBO(51, 51, 51)
  // Light mode on black      Color.fromRGBO(147, 147, 147)
  // Light mode on white      Color.fromRGBO(187, 187, 187)
  static const CupertinoDynamicColor dividerColor =
      CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(70, 70, 70, 0.35),
        darkColor: Color.fromRGBO(230, 230, 230, 0.3),
      );

  /// The color of divider.
  ///
  /// If this property is null, [CupertinoMenuDivider.dividerColor] is used.
  final CupertinoDynamicColor color;

  /// The thickness of the divider.
  ///
  /// Defaults to 0.0, which is equivalent to 1 physical pixel.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final double pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    return CustomPaint(
        size: Size(double.infinity, thickness / math.max(pixelRatio, 1)),
        foregroundPainter: _AliasedBorderPainter(
          // Antialiasing is disabled to match the iOS native menu divider, but
          // is enabled on devices with a device pixel ratio < 1.0 to ensure the
          // divider is visible on low resolution devices.
          isAntiAlias: (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0) < 1.0,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.topEnd,
          border: BorderSide(
            color: color.resolveFrom(context),
            width: 0.0,
            strokeAlign:  BorderSide.strokeAlignCenter,
          ),
        ),
    );
  }
}

/// A [CupertinoMenuEntry] that adds a left border to it's child
///
/// The divider can be customized with a [color] and [thickness]. The [color]
/// defaults to [CupertinoMenuDivider.dividerColor], and the [thickness] defaults
/// to 0.0, which is equivalent to 1 physical pixel. The divider occupies 0.67
/// logical pixels, which was inspected from the iOS simulator.
///
///
/// See also:
/// * [CupertinoMenuActionItem], horizontally-arranged menu items that are
///   separated by [CupertinoMenuVerticalDivider]s.
class CupertinoMenuVerticalDivider extends StatelessWidget
       {
  /// Creates a vertical divider for a side-by-side appearance row.
  ///
  /// Divider has width and thickness of 0 logical pixels.
  const CupertinoMenuVerticalDivider({
    super.key,
    this.color = CupertinoMenuDivider.dividerColor,
    this.height = double.infinity,
    this.thickness = 0.0,
  });

  /// The color of divider.
  final CupertinoDynamicColor color;

  /// The thickness of the divider.
  ///
  /// Defaults to 0.0, which is equivalent to 1 physical pixel.
  final double thickness;

  @override
  bool get hasLeading => false;

  @override
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _AliasedBorderPainter(
        // Antialiasing is disabled to match the iOS native menu divider, but
        // is enabled on devices with a device pixel ratio < 1.0 to ensure the
        // divider is visible.
        isAntiAlias: (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0) < 1.0,
        begin: const AlignmentDirectional(0 , -0.985),
        end: AlignmentDirectional.bottomCenter,
        border: BorderSide(
          color: color.resolveFrom(context),
          width: 0.0,
        ),
      ),
      size : const Size(0, double.infinity),
    );
  }
}

// A custom painter that draws a border without antialiasing
//
// If not used, hairline borders are antialiased, which make them look
// thicker compared to iOS native menus.
class _AliasedBorderPainter extends CustomPainter {
  const _AliasedBorderPainter({
    required this.border,
    required this.begin,
    required this.end,
    this.isAntiAlias = false,
  });

  final BorderSide border;
  final AlignmentDirectional begin;
  final AlignmentDirectional end;
  final bool isAntiAlias;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = border.toPaint()..isAntiAlias = isAntiAlias;
    canvas.drawLine(
      Offset(
        size.width * (begin.start * 0.5 + 0.5),
        size.height * (begin.y * 0.5 + 0.5),
      ),
      Offset(
        size.width * (end.start * 0.5 + 0.5),
        size.height * (end.y * 0.5 + 0.5),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(_AliasedBorderPainter oldDelegate) {
    return border != oldDelegate.border
        || end != oldDelegate.end
        || begin != oldDelegate.begin
        || isAntiAlias != oldDelegate.isAntiAlias;
  }
}




/// A menu item wrapper that handles gestures, including taps, pans, and long
/// presses.
///
/// This widget is used by [CupertinoBaseMenuItem] and
/// [CupertinoMenuActionItem], and can be used to wrap custom menu items.
///
/// The [onTap] callback is called when the user taps the menu item, pans over
/// the menu item and lifts their finger, or when the user long-presses a menu
/// item that has a [panPressActivationDelay] greater than [Duration.zero]. If
/// provided, a [pressedColor] will highlight the menu item whenever a pointer
/// is in contact with the menu item.
///
/// A [mouseCursor] can be provided to change the cursor that appears when a
/// mouse hovers over the menu item. If [mouseCursor] is null, the
/// [SystemMouseCursors.click] cursor is used. A [hoveredColor] can be provided
/// to change the color of the menu item when a mouse hovers over the menu item.
/// If [hoveredColor] is null, the [pressedColor] is used with opacity 0.05.
///
/// If [focusNode] is provided, the menu item will be focusable. When the menu
/// item is focused, the [focusedColor] will be used to highlight the menu item.
///
/// If [enabled] is false, the [onTap] callback is not called, the menu item
/// will not be focusable, and no appearance changes will occur in response to
/// user input.
class CupertinoMenuItemGestureHandler extends StatefulWidget {
  /// Creates default menu gesture detector.
  const CupertinoMenuItemGestureHandler({
    super.key,
    required this.onTap,
    required this.pressedColor,
    required this.child,
    this.mouseCursor,
    this.focusedColor,
    this.focusNode,
    this.hoveredColor,
    this.panPressActivationDelay = Duration.zero,
    this.enabled = true,
    this.behavior,
  });

  /// The menu item to wrap with gestures.
  final Widget child;

  /// Called when the menu item is tapped.
  final VoidCallback? onTap;

  /// Delay between a user's pointer entering a menu item during a pan, and
  /// the menu item being tapped.
  ///
  /// Defaults to [Duration.zero], which will not trigger a tap on pan. The
  /// menu item will still recieve regular taps.
  final Duration panPressActivationDelay;

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

  /// The focus node to use for this menu item.
  final FocusNode? focusNode;

  /// How the menu item should respond to hit tests.
  final HitTestBehavior? behavior;


  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
    ..add(DiagnosticsProperty<bool>('enabled', enabled))
    ..add(DiagnosticsProperty<String>('child', child.toString()))
    ..add(DiagnosticsProperty<Color?>('pressedColor', pressedColor))
    ..add(DiagnosticsProperty<Color?>('hoveredColor', hoveredColor, defaultValue: pressedColor.withOpacity(0.075)))
    ..add(DiagnosticsProperty<Color?>('focusedColor', focusedColor, defaultValue: pressedColor.withOpacity(0.05)))
    ..add(DiagnosticsProperty<MouseCursor?>('mouseCursor', mouseCursor, defaultValue: null))
    ..add(EnumProperty<HitTestBehavior>('hitTestBehavior', behavior))
    ..add(DiagnosticsProperty<Duration>('panPressActivationDelay', panPressActivationDelay, defaultValue: Duration.zero))
    ..add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode, defaultValue: null));
  }

  @override
  State<CupertinoMenuItemGestureHandler> createState() =>
      _CupertinoMenuItemGestureHandlerState();
}

class _CupertinoMenuItemGestureHandlerState
      extends State<CupertinoMenuItemGestureHandler>
         with PanTarget<CupertinoMenuItemGestureHandler> {
  late final Map<Type, Action<Intent>> _actionMap =
  <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _simulateTap),
    ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: _simulateTap),
  };
  bool get enabled => widget.enabled;
  Timer? _longPanPressTimer;
  bool _isFocused = false;
  bool _isSwiped = false;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  bool didPanEnter() {
    if (!widget.enabled) {
      return false;
    }

    if (widget.panPressActivationDelay > Duration.zero) {
      _longPanPressTimer = Timer(widget.panPressActivationDelay, () {
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
  void didPanLeave() {
    _longPanPressTimer?.cancel();
    _longPanPressTimer = null;
    if ((_isSwiped || _isPressed || _isHovered) && mounted) {
      setState(() {
        _isSwiped = false;
        _isPressed = false;
        _isHovered = false;
      });
    }
  }

  @override
  void dispose() {
    _longPanPressTimer?.cancel();
    super.dispose();
  }

  void _simulateTap(Intent intent) {
    if (widget.enabled) {
      widget.onTap?.call();
    }
  }

  void _handleTap() {
    if (widget.enabled) {
      widget.onTap?.call();
      setState(() {
        _isPressed = false;
        _isSwiped = false;
      });
    }
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _isSwiped = false;
    });
  }

  void _handleMouseExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
    });
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    setState(() {
      _isHovered = true;
    });
  }

  void _handleFocusChange(bool focused) {
    setState(() {
      _isFocused = focused;
    });
  }


 Color get backgroundColor {
    if (enabled) {
      if (_isPressed || _isSwiped) {
        return widget.pressedColor;
      }

      if (_isFocused) {
        return widget.focusedColor ?? widget.pressedColor.withOpacity(0.075);
      }

      if (_isHovered) {
        return widget.hoveredColor ?? widget.pressedColor.withOpacity(0.05);
      }
    }

    return const Color(0x00000000);
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      child: MouseRegion(
        onEnter: widget.enabled ? _handleMouseEnter : null,
        onExit: (_isHovered || widget.enabled) ? _handleMouseExit : null,
        hitTestBehavior: HitTestBehavior.deferToChild,
        // TODO(davidhicks980): Determine which mouse cursor to use.
        cursor: widget.enabled
                ? widget.mouseCursor ?? SystemMouseCursors.click
                : MouseCursor.defer,
        child: Actions(
          actions: _actionMap,
          child: Focus(
            canRequestFocus: widget.enabled,
            skipTraversal: !widget.enabled,
            onFocusChange: widget.enabled || _isFocused ? _handleFocusChange : null,
            focusNode: widget.focusNode,
            child: GestureDetector(
              behavior: widget.behavior ?? HitTestBehavior.opaque,
              onTap: _handleTap,
              onTapDown: widget.enabled && !_isPressed ? _handleTapDown : null,
              onTapUp: _isPressed ? _handleTapUp : null,
              onTapCancel: _isPressed || _isSwiped ? _handleTapCancel : null,
              child: CustomPaint(
                painter: MultiplyPainter(
                  color: backgroundColor,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MultiplyPainter extends CustomPainter {
  const MultiplyPainter(
    {required this.color}
  );

  final Color color ;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = color
        ..blendMode = BlendMode.softLight,
    );

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return true;
  }
}


// Icon used in [CupertinoNestedMenuItemAnchor] and [CupertinoCheckedMenuItem].
// TODO(davidhicks980): Font variation weight is not reflected by CupertinoIcon.
// I need to file an issue with the Cupertino team to see whether this is
// intentional.
class _MenuLeadingIcon extends StatelessWidget {
  const _MenuLeadingIcon(
    this.icon,
    { this.fontSize }
  );
  final IconData icon;
  final double? fontSize;
  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);
    final Text iconWidget = Text.rich(
      TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          textBaseline: TextBaseline.alphabetic,
        ),
      ),
      textDirection: textDirection,
      overflow: TextOverflow.visible,
      textAlign: TextAlign.center,
    );

    if (icon.matchTextDirection && textDirection == TextDirection.rtl) {
      return  Transform(
        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
        alignment: Alignment.center,
        transformHitTests: false,
        child: iconWidget,
      );
    }
    return iconWidget;
  }
}


/// Called when a [PanTarget] is entered or exited.
///
/// The [position] describes the global position of the pointer.
///
/// The [onTarget] parameter is true when the pointer is on a [PanTarget].
typedef CupertinoPanUpdateCallback = void Function(Offset position, bool onTarget);

/// Called when the user stops panning.
///
/// This can occur when the user lifts their
/// finger or if the user drags the pointer outside of the
/// [CupertinoPanListener].
///
/// The [position] describes the global position of the pointer.
typedef CupertinoPanEndCallback = void Function(Offset position);

/// Called when the user starts panning.
///
/// The [position] describes the global position of the pointer.
typedef CupertinoPanStartCallback = Drag? Function(Offset position);

/// This widget is used by [CupertinoInteractiveMenuItem]s to determine whether
/// the menu item should be highlighted. On items with a defined
/// [CupertinoInteractiveMenuItem.panPressActivationDelay], menu items will be
/// selected after the user's finger has made contact with the menu item for the
/// specified duration
class CupertinoPanListener<T extends PanTarget<StatefulWidget>>
      extends StatefulWidget {
  /// Creates [CupertinoPanListener] that wraps a Cupertino menu and notifies the layer's children during user swiping.
  const CupertinoPanListener({
    super.key,
    required this.child,
     this.onPanUpdate,
     this.onPanEnd,
     this.onPanStart,
  });

  /// Called when a [PanTarget] is entered or exited.
  ///
  /// The [position] describes the global position of the pointer.
  ///
  /// The [onTarget] parameter is true when the pointer is on a [PanTarget].
  final CupertinoPanUpdateCallback? onPanUpdate;

  /// Called when the user stops panning.
  ///
  /// This can occur when the user lifts their
  /// finger or if the user drags the pointer outside of the
  /// [CupertinoPanListener].
  ///
  /// The [position] describes the global position of the pointer.
  final CupertinoPanEndCallback? onPanEnd;

  /// Called when the user starts panning.
  ///
  /// The [position] describes the global position of the pointer.
  final CupertinoPanEndCallback? onPanStart;

  /// The menu layer to wrap.
  final Widget child;

  /// Creates a [ImmediateMultiDragGestureRecognizer] to recognize the start of
  /// a pan gesture.
  ImmediateMultiDragGestureRecognizer createRecognizer(
    CupertinoPanStartCallback onStart,
  ) {
    return ImmediateMultiDragGestureRecognizer()..onStart = onStart;
  }

  @override
  State<CupertinoPanListener<T>> createState() {
    return _CupertinoPanListenerState<T>();
  }
}

class _CupertinoPanListenerState<T extends PanTarget<StatefulWidget>>
      extends State<CupertinoPanListener<T>> {
  ImmediateMultiDragGestureRecognizer? _recognizer;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _recognizer = widget.createRecognizer(_beginDragging);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recognizer!.gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
  }

  @override
  void dispose() {
    _disposeRecognizerIfInactive();
    super.dispose();
  }

  void _disposeRecognizerIfInactive() {
    if (!_isDragging && _recognizer != null) {
      _recognizer!.dispose();
      _recognizer = null;
    }
  }

  void _routePointer(PointerDownEvent event) {
    _recognizer?.addPointer(event);
  }

  Drag? _beginDragging(Offset position) {
    if (_isDragging) {
      return null;
    }

    _isDragging = true;
    widget.onPanStart?.call(position);
    return _PanHandler<T>(
      initialPosition: position,
      viewId: View.of(context).viewId,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: (Offset position) {
        if (mounted) {
          setState(() {
            _isDragging = false;
          });
        } else {
          _isDragging = false;
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

/// Can be mixed into a [State] to receive callbacks when a pointer enters or
/// leaves a [PanTarget]. The [PanTarget] is should be an ancestor of a
/// [CupertinoPanListener].
mixin PanTarget<T extends StatefulWidget> on State<T> {
  /// Called when a pointer enters the [PanTarget]. Return true if the pointer
  /// should be considered "on" the [PanTarget], and false otherwise (for
  /// example, when the [PanTarget] is disabled).
  bool didPanEnter();

  /// Called when the pointer leaves the [PanTarget]. If [pointerUp] is true,
  /// then the pointer left the screen while over this menu item.
  void didPanLeave();
}

// Handles panning events for a [CupertinoPanListener]
//
// Calls [onPanUpdate] when the user's finger moves over a [PanTarget] and
// [onPanEnd] when the user's finger leaves the [PanTarget].
//
// This class was adapted from [_DragAvatar].
class _PanHandler<T extends PanTarget<StatefulWidget>> extends Drag {
  _PanHandler({
    required Offset initialPosition,
    required this.viewId,
    this.onPanEnd,
    this.onPanUpdate,
  }) : _position = initialPosition {
    _updateDrag(initialPosition);
  }

  final int viewId;
  final List<T> _enteredTargets = <T>[];
  final CupertinoPanEndCallback? onPanEnd;
  final CupertinoPanUpdateCallback? onPanUpdate;
  Offset _position;

  @override
  void update(DragUpdateDetails details) {
    final Offset oldPosition = _position;
    _position += details.delta;
    _updateDrag(_position);
    if (_position != oldPosition) {
      onPanUpdate?.call(_position, _enteredTargets.isNotEmpty);
    }
  }

  @override
  void end(DragEndDetails details) {
    _finishDrag();
  }

  @override
  void cancel() {
    _finishDrag();
  }

  void _updateDrag(Offset globalPosition) {
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, globalPosition, viewId);
    // Look for the RenderBoxes that corresponds to the hit target (the hit target
    // widgets build RenderMetaData boxes for us for this purpose).
    final List<T> targets = <T>[];
    for (final HitTestEntry entry in result.path) {
      final HitTestTarget target = entry.target;
      if (target is RenderMetaData && target.metaData is T) {
        targets.add(target.metaData as T);
      }
    }

    bool listsMatch = false;
    if (
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

  void _leaveAllEntered() {
    for (int i = 0; i < _enteredTargets.length; i += 1) {
      _enteredTargets[i].didPanLeave();
    }
    _enteredTargets.clear();
  }

  void _finishDrag() {
    _leaveAllEntered();
    onPanEnd?.call(_position);
  }
}
