// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import './cupertino_menu_anchor.dart';

const bool _kDebugMenus = false;


bool get _isApple => defaultTargetPlatform == TargetPlatform.iOS ||
                     defaultTargetPlatform == TargetPlatform.macOS;


bool get _platformSupportsAccelerators {
  // On iOS and macOS, pressing the Option key (a.k.a. the Alt key) causes a
  // different set of characters to be generated, and the native menus don't
  // support accelerators anyhow, so we just disable accelerators on these
  // platforms.
  return !_isApple;
}


/// The color of a [CupertinoInteractiveMenuItem] when pressed.
// Pressed colors were sampled from the iOS simulator and are based on the
// following:
//
// Dark mode on white background     rgb(111, 111, 111)
// Dark mode on black                rgb(61, 61, 61)
// Light mode on black background    rgb(177, 177, 177)
// Light mode on white               rgb(225, 225, 225)
const CupertinoDynamicColor _kMenuBackgroundOnPress =
    CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(50, 50, 50, 0.1),
      darkColor: Color.fromRGBO(255, 255, 255, 0.2),
    );

/// A widget that provides the default styling, semantics, and interactivity
/// for menu items in a [_CupertinoMenuPanel] or [CupertinoNestedMenu].
class CupertinoInteractiveMenuItem extends StatefulWidget {
  /// Creates a [CupertinoInteractiveMenuItem], a widget that provides the
  /// default styling, semantics, and interactivity for menu items in a
  /// [_CupertinoMenuPanel] or [CupertinoNestedMenu].
  const CupertinoInteractiveMenuItem({
    super.key,
    required this.child,
    required this.requestFocusOnHover,
    this.focusNode,
    this.onFocusChange,
    this.onPressed,
    this.onHover,
    this.pressedColor,
    this.focusedColor,
    this.hoveredColor,
    this.mouseCursor,
    this.behavior,
    this.closeOnActivate = true,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.panActivationDelay = Duration.zero,
    this.shortcut,
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
  /// Defaults to false.
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
  /// Defaults to [Duration.zero], which will not trigger a tap on pan. The
  /// menu item will recieve other gestures.
  final Duration panActivationDelay;

  /// The color of menu item when focused.
  final Color? focusedColor;

  /// The color of menu item when hovered by the user's pointer.
  final Color? hoveredColor;

  /// The color of menu item while the menu item is swiped or pressed down.
  final Color? pressedColor;

  /// The mouse cursor to display on hover.
  final MouseCursor? mouseCursor;

  /// How the menu item should respond to hit tests.
  final HitTestBehavior? behavior;

  /// {@macro flutter.material.menu_anchor.closeOnActivate}
  final bool closeOnActivate;

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

  bool get enabled => onPressed != null;

  /// The default text color for labels in a [CupertinoInteractiveMenuItem].
  static const CupertinoDynamicColor _defaultTextColor =
      CupertinoDynamicColor.withBrightness(
          color: Color.fromRGBO(0, 0, 0, 0.96),
          darkColor: Color.fromRGBO(255, 255, 255, 0.96),
        );

  /// The default text style for labels in a [CupertinoInteractiveMenuItem].
  static const TextStyle _defaultTextStyle = TextStyle(
    inherit: false,
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: <String>[
      '.AppleSystemUIFont'
    ],
    fontSize: 17,
    letterSpacing: -0.48,
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
  void _handleSelect() {
    assert(_debugMenuInfo('Selected ${widget.child} menu'));
    // Delay the call to onPressed until post-frame so that the focus is
    // restored to what it was before the menu was opened before the action is
    // executed.
    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      FocusManager.instance.applyFocusChangesIfNeeded();
      widget.onPressed?.call();
    }, debugLabel: 'MenuAnchor.onPressed');
  }


  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        enabled: widget.onPressed != null,
        button: true,
        child: CupertinoMenuItemGestureHandler(
          mouseCursor: widget.mouseCursor,
          panPressActivationDelay: widget.panActivationDelay,
          requestFocusOnHover: true,
          onPressed: _handleSelect,
          onHover: widget.onHover,
          onFocusChange: widget.onFocusChange,
          focusNode: widget.focusNode,
          pressedColor: CupertinoDynamicColor.resolve(
            widget.pressedColor ?? _kMenuBackgroundOnPress,
            context,
          ),
          focusedColor: CupertinoDynamicColor.maybeResolve(
            widget.focusedColor,
            context,
          ),
          hoveredColor: CupertinoDynamicColor.maybeResolve(
            widget.hoveredColor,
            context,
          ),
          child:  _platformSupportsAccelerators && widget.enabled
                      ? MenuAcceleratorCallbackBinding(child: widget.child)
                      : widget.child,

        ),
      ),
    );
  }
}

/// A widget that provides the default structure, semantics, and interactivity
/// for menu items in a [_CupertinoMenuPanel] or [CupertinoNestedMenu].
///
/// See also:
/// * [CupertinoInteractiveMenuItem], a widget that provides the default
///   typography, semantics, and interactivity for menu items in a
///   [_CupertinoMenuPanel], while allowing for customization of the menu item's
///   structure.
class CupertinoMenuItem extends StatelessWidget with CupertinoMenuEntryMixin {
  /// Creates a [CupertinoMenuItem]
  const CupertinoMenuItem({
    super.key,
    required this.child,
    this.requestFocusOnHover = true,
    this.leading,
    this.trailing,
    this.subtitle,
    this.padding,
    this.focusNode,
    this.onFocusChange,
    this.onPressed,
    this.onHover,
    this.pressedColor,
    this.focusedColor,
    this.hoveredColor,
    this.mouseCursor,
    this.behavior,
    this.closeOnActivate = true,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.panActivationDelay = Duration.zero,
    this.shortcut,
  });

  /// The widget displayed in the center of this button.
  ///
  /// Typically this is the button's label, using a [Text] widget.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The padding for the contents of the menu item.
  final EdgeInsetsDirectional? padding;

  /// The widget shown before the label. Typically a [CupertinoIcon].
  final Widget? leading;

  /// The widget shown after the label. Typically a [CupertinoIcon].
  final Widget? trailing;

  /// A widget displayed underneath the title. Typically a [Text] widget.
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

  /// The optional shortcut that selects this [CupertinoMenuItemGestureHandler].
  ///
  /// {@macro flutter.material.MenuBar.shortcuts_note}
  final MenuSerializableShortcut? shortcut;

  /// Delay between a user's pointer entering a menu item during a pan, and
  /// the menu item being tapped.
  ///
  /// Defaults to [Duration.zero], which will not trigger a tap on pan. The
  /// menu item will recieve other gestures.
  final Duration panActivationDelay;

  /// The color of menu item when focused.
  final Color? focusedColor;

  /// The color of menu item when hovered by the user's pointer.
  final Color? hoveredColor;

  /// The color of menu item while the menu item is swiped or pressed down.
  final Color? pressedColor;

  /// The mouse cursor to display on hover.
  final MouseCursor? mouseCursor;

  /// How the menu item should respond to hit tests.
  final HitTestBehavior? behavior;

  /// {@macro flutter.material.menu_anchor.closeOnActivate}
  final bool closeOnActivate;

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

  bool get enabled => onPressed != null;

  /// Provides text styles in response to changes in [CupertinoThemeData.brightness],
  /// [widget.isDefaultAction], [widget.isDestructiveAction], and [widget.enable].
  //
  // Eyeballed from the iOS simulator.
  TextStyle _getTitleTextStyle(BuildContext context) {
    if (!enabled) {
      return CupertinoInteractiveMenuItem._defaultTextStyle.copyWith(
        color: CupertinoColors.systemGrey.resolveFrom(context),
      );
    }

    if (isDestructiveAction) {
      return CupertinoInteractiveMenuItem._defaultTextStyle.copyWith(
        color: CupertinoColors.destructiveRed,
      );
    }

    final Color color =
        CupertinoInteractiveMenuItem._defaultTextColor.resolveFrom(context);

    if (isDefaultAction) {
      return CupertinoInteractiveMenuItem._defaultTextStyle
          .copyWith(fontWeight: FontWeight.w600, color: color);
    }

    return CupertinoInteractiveMenuItem._defaultTextStyle
        .copyWith(color: color);
  }

  /// The default text style for a [CupertinoStickyMenuHeader] subtitle.
  TextStyle getDefaultSubtitleStyle (BuildContext context)=>   TextStyle(
    height: 1.25,
    // color: const CupertinoDynamicColor.withBrightness(
    //     color: Color.fromRGBO(130, 130, 130, 1),
    //     darkColor:  Color.fromRGBO(110, 110, 110, 1)).resolveFrom(context),
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: const <String>['.AppleSystemUIFont'],
    fontSize: 15,
    letterSpacing: -0.41,
    fontWeight: FontWeight.w300,
    foreground: Paint()

          ..color = const Color.fromRGBO(200, 200, 200, 0.55)
          ..blendMode = BlendMode.colorDodge

        ,
        textBaseline: TextBaseline.alphabetic,
  );

  @override
  Widget build(BuildContext context) {
    final TextStyle titleTextStyle = _getTitleTextStyle(context);
    final TextScaler textScale = MediaQuery.textScalerOf(context);
    return CupertinoInteractiveMenuItem(
        focusNode: focusNode,
        onFocusChange: onFocusChange,
        onPressed: onPressed,
        onHover: onHover,
        pressedColor: pressedColor,
        focusedColor: focusedColor,
        hoveredColor: hoveredColor,
        mouseCursor: mouseCursor,
        behavior: behavior,
        closeOnActivate: closeOnActivate,
        isDefaultAction: isDefaultAction,
        isDestructiveAction: isDestructiveAction,
        panActivationDelay: panActivationDelay,
        shortcut: shortcut,
        requestFocusOnHover: requestFocusOnHover,
        child: IconTheme.merge(
        data: IconThemeData(
            color: titleTextStyle.color, size: textScale.scale(21)),
        child: _CupertinoMenuItemStructure(
          padding: padding,
          // trailing: trailing,
          leading: leading != null
                    ? _ChildSwitcher(
                        layoutBuilder: AnimatedSwitcher.defaultLayoutBuilder,
                        child: leading!
                      )
                    : null,
          title: DefaultTextStyle.merge(
            maxLines: textScale.scale(1) > 1.25 ? null : 2,
            overflow: TextOverflow.ellipsis,
            style: titleTextStyle,
            child: IconTheme.merge(
              data: IconThemeData(
                  color: titleTextStyle.color, size: textScale.scale(21)),
              child: _ChildSwitcher(child: child),
            ),
          ),
          subtitle: subtitle != null
              ? DefaultTextStyle.merge(
                  maxLines: textScale.scale(1) > 1.25 ? null : 2,
                  overflow: TextOverflow.ellipsis,
                  style: getDefaultSubtitleStyle(context),
                  child: _ChildSwitcher(child: child),
                )
              : null,
        ),
      ),
    );
  }
}

class _ChildSwitcher extends StatelessWidget {
  const _ChildSwitcher({
    required this.child,
    this.layoutBuilder = _layoutBuilder,
  });
  final AnimatedSwitcherLayoutBuilder layoutBuilder;
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
      child: KeyedSubtree(
        key: ObjectKey(child),
        child: child,
      ),
    );
  }
}

// A default layout wrapper for [CupertinoBaseMenuItem]s.
class _CupertinoMenuItemStructure extends StatelessWidget with CupertinoMenuEntryMixin {

  // Creates a [_CupertinoMenuItemStructure]
  const _CupertinoMenuItemStructure({
    required this.title,
    this.minimumHeight = kMinInteractiveDimensionCupertino,
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
  final double minimumHeight;

  // The center content of the menu item
  final Widget title;

  // The subtitle of the menu item
  final Widget? subtitle;

  // Whether to scale the padding of the menu item with textScaleFactor
  final bool scalePadding;

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.maybeTextScalerOf(context)?.scale(1) ?? 1.0;
    final bool showLeadingWidget = leading != null || getMenuLayerHasLeading(context);
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
        constraints: BoxConstraints(minHeight: minimumHeight * scaledPadding),
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

/// A [CupertinoMenuEntryMixin] that inserts a large horizontal divider.
///
/// The divider has a height of 8 logical pixels. A [color] parameter can be
/// provided to customize the color of the divider.
///
/// See also:
///
/// * [CupertinoMenuItem], a Cupertino menu item.
/// * [CupertinoMenuActionItem], a horizontal menu item.
@immutable
class CupertinoMenuLargeDivider extends StatelessWidget with CupertinoMenuEntryMixin
       {
  /// Creates a large horizontal divider for a [_CupertinoMenuPanel].
  const CupertinoMenuLargeDivider({
    super.key,
    this.color = transparentColor,
  });

  /// Color for a transparent [CupertinoMenuLargeDivider].
  // The following colors were measured from debug mode on the iOS simulator,
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
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: color.resolveFrom(context),
    );
  }
}

/// A [CupertinoMenuEntryMixin] that inserts a horizontal divider.
///
/// The default width of the divider is 1 physical pixel,
@immutable
class CupertinoMenuDivider extends StatelessWidget {
  /// A [CupertinoMenuEntryMixin] that adds a top border to it's child
  const CupertinoMenuDivider({
    super.key,
    this.color = dividerColor,
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
        color: Color.fromRGBO(0, 0, 0, 1),
        darkColor: Color.fromRGBO(255, 255, 255, 0.1),
      );
  static const CupertinoDynamicColor tintColor =
      CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        darkColor: Color.fromRGBO(255, 255, 255, 0.1),
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
    return CustomPaint(
        foregroundPainter: _AliasedBorderPainter(
          // Antialiasing is disabled to match the iOS native menu divider, but
          // is enabled on devices with a device pixel ratio < 1.0 to ensure the
          // divider is visible on low resolution devices.
          isAntiAlias: (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0) < 1.0,
          tint: tintColor.resolveFrom(context),
          begin: Alignment.topLeft,
          end: Alignment.topRight,
          cutoutPainter: BorderSide(
            color: color.resolveFrom(context),
            width: thickness / MediaQuery.of(context).devicePixelRatio,
            strokeAlign:  BorderSide.strokeAlignCenter,
          ),
        ),
    );
  }
}

// A custom painter that draws a border without antialiasing
//
// If not used, hairline borders are antialiased, which make them look
// thicker compared to iOS native menus.
class _AliasedBorderPainter extends CustomPainter {
  const _AliasedBorderPainter({
    required this.cutoutPainter,
    required this.tint,
    required this.begin,
    required this.end,
    this.isAntiAlias = false,
  });

  final BorderSide cutoutPainter;
  final Color tint;
  final Alignment begin;
  final Alignment end;
  final bool isAntiAlias;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint cutout = cutoutPainter.toPaint()
                          ..blendMode = BlendMode.overlay
                          ..isAntiAlias = isAntiAlias;
    final Offset p1 = begin.alongSize(size);
    final Offset p2 = end.alongSize(size);
    canvas.drawLine(
      p1,
      p2,
      cutout,
    );
    canvas.drawLine(
      p1,
      p2,
      Paint()..color = tint..isAntiAlias = isAntiAlias,
    );
  }

  @override
  bool shouldRepaint(_AliasedBorderPainter oldDelegate) {
    return cutoutPainter != oldDelegate.cutoutPainter
        || tint != oldDelegate.tint
        || end != oldDelegate.end
        || begin != oldDelegate.begin
        || isAntiAlias != oldDelegate.isAntiAlias;
  }
}




/// A menu item wrapper that handles gestures, including taps, pans, and long
/// presses.
///
/// This widget is used by [CupertinoMenuItem] and
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
    required this.pressedColor,
    required this.child,
    this.requestFocusOnHover = false,
    this.mouseCursor,
    this.focusedColor,
    this.focusNode,
    this.hoveredColor,
    this.panPressActivationDelay = Duration.zero,
    this.behavior,
    this.onPressed,
    this.onHover,
    this.onFocusChange,
    this.shortcut,
  });

  /// The widget displayed in the center of this button.
  ///
  /// Typically this is the button's label, using a [Text] widget.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

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

  /// The optional shortcut that selects this [CupertinoMenuItemGestureHandler].
  ///
  /// {@macro flutter.material.MenuBar.shortcuts_note}
  final MenuSerializableShortcut? shortcut;

  /// Delay between a user's pointer entering a menu item during a pan, and
  /// the menu item being tapped.
  ///
  /// Defaults to [Duration.zero], which will not trigger a tap on pan. The
  /// menu item will recieve other gestures.
  final Duration panPressActivationDelay;

  /// The color of menu item when focused.
  final Color? focusedColor;

  /// The color of menu item when hovered by the user's pointer.
  final Color? hoveredColor;

  /// The color of menu item while the menu item is swiped or pressed down.
  final Color pressedColor;

  /// The mouse cursor to display on hover.
  final MouseCursor? mouseCursor;

  /// How the menu item should respond to hit tests.
  final HitTestBehavior? behavior;

  bool get enabled => onPressed != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
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
  Timer? _longPanPressTimer;
  final bool _isFocused = false;
  bool _isSwiped = false;
  bool _isPressed = false;
  bool _isHovered = false;

  // If a focus node isn't given to the widget, then we have to manage our own.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

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
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    _internalFocusNode = null;
    super.dispose();
  }

  void _simulateTap(Intent intent) {
    if (widget.enabled) {
      widget.onPressed?.call();
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
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
      _isSwiped = false;
    });
  }



  @override
  void initState() {
    super.initState();
    _createInternalFocusNodeIfNeeded();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(CupertinoMenuItemGestureHandler oldWidget) {
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _createInternalFocusNodeIfNeeded();
      _focusNode.addListener(_handleFocusChange);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleFocusChange([bool? focused]) {
    widget.onFocusChange?.call(_focusNode.hasFocus);
  }

  void _handleHover(PointerEvent event) {
    final bool hovered = event is PointerEnterEvent;
    if(hovered != _isHovered) {
      widget.onHover?.call(hovered);
      if (hovered && widget.requestFocusOnHover) {
        assert(_debugMenuInfo('Requesting focus for $_focusNode from hover'));
        _focusNode.requestFocus();
      }
      setState(() {
        _isHovered = hovered;
      });}
  }

  void _createInternalFocusNodeIfNeeded() {
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      assert(() {
        if (_internalFocusNode != null) {
          _internalFocusNode!.debugLabel = '$CupertinoMenuItemGestureHandler(${widget.child})';
        }
        return true;
      }());
    }
  }

  Color get backgroundColor {
    if (widget.enabled) {
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
        onEnter: widget.enabled ? _handleHover : null,
        onExit: (_isHovered || widget.enabled) ? _handleHover  : null,
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
              onTapCancel: _isPressed || _isSwiped ? _handleTapCancel : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  backgroundBlendMode: BlendMode.luminosity,
                  color: backgroundColor
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


/// Called when a [PanTarget] is entered or exited.
///
/// The [position] describes the global position of the pointer.
///
/// The [onTarget] parameter is true when the pointer is on a [PanTarget].
typedef CupertinoPanUpdateCallback = void Function(Offset position, Rect? dragArea);

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
/// [CupertinoInteractiveMenuItem.panActivationDelay], menu items will be
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
      onPanUpdate: widget.onPanUpdate != null ? (Offset offset, _) {
        Rect? areaRect;
        if(mounted) {
          final RenderBox area = context.findRenderObject()! as RenderBox;
          final Offset localPosition = area.localToGlobal(Offset.zero);
          areaRect = Rect.fromLTWH(
            localPosition.dx,
            localPosition.dy,
            area.size.width,
            area.size.height,
          );
        }
        widget.onPanUpdate?.call(offset, areaRect);
      } : null,
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
      onPanUpdate?.call(_position, Rect.zero);
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
