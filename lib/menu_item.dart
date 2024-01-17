// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoColors, CupertinoDynamicColor, CupertinoLocalizations, CupertinoTheme, kMinInteractiveDimensionCupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show MaterialLocalizations;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import './menu.dart';
import 'test_anchor.dart';

const bool _kDebugMenus = true;

bool get _isApple => defaultTargetPlatform == TargetPlatform.iOS ||
                     defaultTargetPlatform == TargetPlatform.macOS;

bool get _platformSupportsAccelerators {
  // On iOS and macOS, pressing the Option key (a.k.a. the Alt key) causes a
  // different set of characters to be generated, and the native menus don't
  // support accelerators anyhow, so we just disable accelerators on these
  // platforms.
  return !_isApple;
}


/// The color of a [_CupertinoInteractiveMenuItem] when pressed.
// Pressed colors were sampled from the iOS simulator and are based on the
// following:
//
// Dark mode on white background     rgb(111, 111, 111)
// Dark mode on black                rgb(61, 61, 61)
// Light mode on black               rgb(177, 177, 177)
// Light mode on white               rgb(225, 225, 225)
const CupertinoDynamicColor _kMenuBackgroundOnPress =
    CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(50, 50, 50, 0.1),
      darkColor: Color.fromRGBO(255, 255, 255, 0.1),
    );

/// A widget that provides the default styling, semantics, and interactivity
/// for menu items in a [_CupertinoMenuPanel] or [CupertinoNestedMenu].
class _CupertinoInteractiveMenuItem extends StatefulWidget {
  /// Creates a [_CupertinoInteractiveMenuItem], a widget that provides the
  /// default styling, semantics, and interactivity for menu items in a
  /// [_CupertinoMenuPanel] or [CupertinoNestedMenu].
  const _CupertinoInteractiveMenuItem({
    required this.child,
    this.requestFocusOnHover = false,
    this.focusNode,
    this.onFocusChange,
    this.onPressed,
    this.onHover,
    this.pressedColor = _kMenuBackgroundOnPress,
    this.focusedColor,
    this.hoveredColor,
    this.mouseCursor,
    this.behavior,
    this.closeOnActivate = true,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    this.panActivationDelay = Duration.zero,
    this.shortcut,
    this.debugChildLabel,
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

  /// The debug ID of this menu item.
  final String? debugChildLabel;

  bool get enabled => onPressed != null;

  @override
  State<_CupertinoInteractiveMenuItem> createState() =>
      _CupertinoInteractiveMenuItemState();
}

class _CupertinoInteractiveMenuItemState
      extends State<_CupertinoInteractiveMenuItem>
      with CupertinoMenuEntryMixin {

  /// The handler for when the user selects the menu item.
  @protected
  void _handleSelect() {
    assert(_debugMenuInfo('Selected ${widget.child} menu'));
    if (widget.closeOnActivate) {
      closeMenu(context);
    }
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
        child: CupertinoMenuItemGestureHandler(
          mouseCursor: widget.mouseCursor,
          panPressActivationDelay: widget.panActivationDelay,
          requestFocusOnHover: widget.requestFocusOnHover,
          onPressed: widget.onPressed != null ? _handleSelect : null,
          onHover: widget.onHover,
          onFocusChange: widget.onFocusChange,
          focusNode: widget.focusNode,
          debugChildLabel: widget.debugChildLabel,
          pressedColor: CupertinoDynamicColor.maybeResolve(
            widget.pressedColor,
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
          child: widget.child,

        ),
      ),
    );
  }
}

/// A widget that provides the default structure, semantics, and interactivity
/// for menu items in a [CupertinoMenuAnchor].
///
/// See also:
/// * [_CupertinoInteractiveMenuItem], a widget that provides the default
///   typography, semantics, and interactivity for menu items in a
class CupertinoMenuItem extends StatelessWidget with CupertinoMenuEntryMixin {
  /// Creates a [CupertinoMenuItem]
  const CupertinoMenuItem({
    super.key,
    required this.child,
    this.requestFocusOnHover = false,
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
      return _defaultTitleStyle.copyWith(
        color: CupertinoColors.systemGrey.resolveFrom(context),
      );
    }

    if (isDestructiveAction) {
      return _defaultTitleStyle.copyWith(
        color: CupertinoColors.destructiveRed,
      );
    }

    final Color? color = CupertinoDynamicColor.maybeResolve(
      _defaultTitleStyle.color,
      context,
    );

    if (isDefaultAction) {
      return _defaultTitleStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      );
    }

    return _defaultTitleStyle.copyWith(color: color);
  }

  static const Color _lightSubtitleColor =  Color.fromRGBO(0, 0, 0, 0.4);
  static const Color _darkSubtitleColor =  Color.fromRGBO(255, 255, 255, 0.4);
  /// The default text style for labels in a [_CupertinoInteractiveMenuItem].
  static const TextStyle _defaultTitleStyle = TextStyle(
    inherit: false,
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: <String>[
      '.AppleSystemUIFont'
    ],
    height: 1.25,
    fontSize: 17,
    letterSpacing: -0.41,
    fontWeight: FontWeight.normal,
    color: CupertinoDynamicColor.withBrightness(
          color: Color.fromRGBO(0, 0, 0, 0.96),
          darkColor: Color.fromRGBO(255, 255, 255, 0.96),
        ),
    textBaseline: TextBaseline.alphabetic,
  );
  /// The default text style for a [CupertinoStickyMenuHeader] subtitle.
  static const TextStyle _subtitleStyle = TextStyle(
    height: 1.25,
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: <String>['.AppleSystemUIFont'],
    fontSize: 15,
    letterSpacing: -0.21,
    fontWeight: FontWeight.w400,
    textBaseline: TextBaseline.ideographic,
  );

  @override
  Widget build(BuildContext context) {
    final TextStyle titleTextStyle = _getTitleTextStyle(context);
    final TextScaler textScale = MediaQuery.textScalerOf(context);
    final bool darkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final Paint subtitlePainter = Paint()
      ..blendMode = darkMode ? BlendMode.plus : BlendMode.hardLight
      ..color = CupertinoDynamicColor
        .resolve(darkMode ? _darkSubtitleColor : _lightSubtitleColor, context);
  if(shortcut != null) {
    print(LocalizedShortcutLabeler.instance.getShortcutLabel(
                        shortcut!,
                        MaterialLocalizations.of(context),
                      ),);
  }
    return _CupertinoInteractiveMenuItem(
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      onPressed: onPressed,
      onHover: onHover,
      pressedColor: pressedColor ?? _kMenuBackgroundOnPress,
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
      debugChildLabel: child.toString(),
      child: IconTheme.merge(
        data: IconThemeData(
          color: titleTextStyle.color,
          size: textScale.scale(21),
        ),
        child: _CupertinoMenuItemStructure(
          padding: padding,
          trailing: trailing,
          leading: leading,
          title: DefaultTextStyle.merge(
            maxLines: textScale.scale(1) > 1.25 ? null : 2,
            overflow: TextOverflow.ellipsis,
            style: titleTextStyle,
            child: _TitleSwitcher(child: child),
          ),
          subtitle: subtitle != null
              ? DefaultTextStyle.merge(
                  maxLines: textScale.scale(1) > 1.25 ? null : 2,
                  overflow: TextOverflow.ellipsis,
                  style: _subtitleStyle.copyWith(
                    foreground: subtitlePainter,
                  ),
                  child: _TitleSwitcher(child: child),
                )
              : null,
        ),
      ),
    );
  }


  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
      properties.add(DiagnosticsProperty<Color?>('pressedColor', pressedColor));
      properties.add(DiagnosticsProperty<Color?>('hoveredColor', hoveredColor,
         defaultValue: pressedColor?.withOpacity(0.075)) );
      properties.add(DiagnosticsProperty<Color?>('focusedColor', focusedColor,
         defaultValue: pressedColor?.withOpacity(0.05)));
      properties.add(EnumProperty<HitTestBehavior>('hitTestBehavior', behavior));
      properties.add(DiagnosticsProperty<Duration>(
         'panActivationDelay', panActivationDelay,
         defaultValue: Duration.zero));
      properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode,
         defaultValue: null));
      properties.add(FlagProperty('enabled',
         value: onPressed != null, ifFalse: 'DISABLED'));
      properties.add(DiagnosticsProperty<MenuSerializableShortcut?>('shortcut', shortcut,
         defaultValue: null));
      properties.add(DiagnosticsProperty<Widget?>('title', child));
      properties.add(DiagnosticsProperty<Widget?>('subtitle', subtitle));
      properties.add(
         DiagnosticsProperty<Widget?>('leading', leading, defaultValue: null));
      properties.add(DiagnosticsProperty<Widget?>('trailing', trailing,
         defaultValue: null));

  }
}

class _TitleSwitcher extends StatelessWidget {
  const _TitleSwitcher({ required this.child });

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
      EdgeInsetsDirectional.symmetric(vertical: 11.5);
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
                          const SizedBox(height: 1),
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
class CupertinoMenuLargeDivider extends StatelessWidget
      with CupertinoMenuEntryMixin {
  /// Creates a large horizontal divider for a [_CupertinoMenuPanel].
  const CupertinoMenuLargeDivider({
    super.key,
    this.color = _color,
  });

  /// Color for a transparent [CupertinoMenuLargeDivider].
  // The following colors were measured from debug mode on the iOS simulator,
  static const CupertinoDynamicColor _color =
    CupertinoDynamicColor.withBrightness(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      darkColor: Color.fromRGBO(0, 0, 0, 0.16),
    );

  /// The color of the divider.
  ///
  /// If this property is null, [CupertinoMenuLargeDivider._color] is
  /// used.
  final Color color;

  @override
  bool get hasSeparatorAfter => false;

  @override
  bool get hasSeparatorBefore => false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: CupertinoDynamicColor.resolve(color, context),
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
    this.baseColor = color,
    this.tint = tintColor,
    this.thickness = 0.0,
  }): _child = null;

  /// A [CupertinoMenuEntryMixin] that adds a top border to it's child
  const CupertinoMenuDivider.wrap({
    super.key,
    this.baseColor = color,
    this.tint = tintColor,
    this.thickness = 0.0,
    required Widget child,
  }): _child = child;

  /// Default transparent color for [CupertinoMenuDivider] and
  /// [CupertinoVerticalMenuDivider].
  ///
  // The following colors were measured from the iOS simulator, and opacity was
  // extrapolated:
  // Dark mode on black       Color.fromRGBO(97, 97, 97)
  // Dark mode on white       Color.fromRGBO(132, 132, 132)
  // Light mode on black      Color.fromRGBO(147, 147, 147)
  // Light mode on white      Color.fromRGBO(187, 187, 187)
  static const CupertinoDynamicColor color =
      CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(140, 140, 140, 0.5),
        darkColor: Color.fromRGBO(255, 255, 255, 0.25),
      );
  static const CupertinoDynamicColor tintColor =
      CupertinoDynamicColor.withBrightness(
        color: Color.fromRGBO(0, 0, 0, 0.24),
        darkColor: Color.fromRGBO(255, 255, 255, 0.23),
      );

  /// The color of divider.
  ///
  /// If this property is null, [CupertinoMenuDivider.color] is used.
  final CupertinoDynamicColor baseColor;
  /// The color of divider.
  ///
  /// If this property is null, [CupertinoMenuDivider.color] is used.
  final CupertinoDynamicColor tint;

  /// The thickness of the divider.
  ///
  /// Defaults to 0.0, which is equivalent to 1 physical pixel.
  final double thickness;

  /// The widget below this widget in the tree.
  final Widget? _child;

  @override
  Widget build(BuildContext context) {
    final double physicalThickness = (thickness == 0.0 ? 1.0 : thickness) / (MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0);
    return  CustomPaint(
      painter: _AliasedBorderPainter(
        tint: CupertinoDynamicColor.maybeResolve(tintColor, context) ?? tintColor,
        color: CupertinoDynamicColor.maybeResolve(baseColor, context) ?? baseColor,
        isAntiAlias: physicalThickness > 1.0,
        begin: Alignment.bottomLeft,
        end: Alignment.bottomRight,
        border: BorderSide(
          width: thickness,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      child: _child,
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
    required this.tint,
    required this.color,
    required this.begin,
    required this.end,
    this.isAntiAlias = false,
  });

  final BorderSide border;
  final Color tint;
  final Color color;
  final Alignment begin;
  final Alignment end;
  final bool isAntiAlias;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset p1 = begin.alongSize(size);
    final Offset p2 = end.alongSize(size);
    if (!kIsWeb) {
      final Paint basePainter = border.toPaint()
        ..color = color
        ..isAntiAlias = isAntiAlias
        ..blendMode = BlendMode.overlay;
      canvas.drawLine(p1, p2, basePainter);
    }

    final Paint tintPainter = border.toPaint()
                              ..color = tint
                              ..isAntiAlias = isAntiAlias;
    canvas.drawLine(p1, p2, tintPainter);
  }

  @override
  bool shouldRepaint(_AliasedBorderPainter oldDelegate) {
    return tint != oldDelegate.tint ||
        color != oldDelegate.color ||
        end != oldDelegate.end ||
        begin != oldDelegate.begin ||
        border != oldDelegate.border ||
        isAntiAlias != oldDelegate.isAntiAlias;
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
    this.debugChildLabel,
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
  final Duration panPressActivationDelay;

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

  final String? debugChildLabel;

  bool get enabled => onPressed != null;

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
  bool _isFocused = false;
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
  void didPanLeave({required bool complete}) {
    _longPanPressTimer?.cancel();
    _longPanPressTimer = null;
    if (mounted) {
      if (complete) {
        _simulateTap();
      } else if (_isSwiped || _isPressed) {
        setState(() {
          _isSwiped = false;
          _isPressed = false;
        });
      }
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

  void _simulateTap([Intent? intent]) {
    if (widget.enabled) {
      _handleTap();
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
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (widget.focusNode != null) {
        _internalFocusNode?.dispose();
        _internalFocusNode = null;
      }
      _createInternalFocusNodeIfNeeded();
      _focusNode.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange([bool? focused]) {
    setState(() {
      _isFocused = focused ?? _focusNode.hasFocus;
    });

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
      });
    }
  }

  void _createInternalFocusNodeIfNeeded() {
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      assert(() {
        if (_internalFocusNode != null) {
          _internalFocusNode!.debugLabel = '$CupertinoMenuItem(${widget.debugChildLabel})';
        }
        return true;
      }());
    }
  }

  Color? get backgroundColor {
    if (widget.enabled) {
      if (_isPressed || _isSwiped) {
        return widget.pressedColor;
      }

      if (_isFocused) {
        return widget.focusedColor ?? widget.pressedColor?.withOpacity(0.075);
      }

      if (_isHovered) {
        return widget.hoveredColor ?? widget.pressedColor?.withOpacity(0.05);
      }
    }

    return null;
  }


  @override
  Widget build(BuildContext context) {
    Widget? child = widget.child;
    final Color? backgroundColor = this.backgroundColor;
    if (backgroundColor != null) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          backgroundBlendMode:
              CupertinoTheme.maybeBrightnessOf(context) == Brightness.light
                  ? BlendMode.multiply
                  : BlendMode.plus,
          color: backgroundColor,
        ),
        child: child,
      );
    }
    return MetaData(
      metaData: this,
      child: MouseRegion(
        onEnter: widget.enabled ? _handleHover : null,
        onExit: (_isHovered || widget.enabled) ? _handleHover  : null,
        hitTestBehavior: HitTestBehavior.deferToChild,
        cursor: widget.enabled
                ? widget.mouseCursor ?? SystemMouseCursors.click
                : MouseCursor.defer,
        child: Actions(
          actions: _actionMap,
          child: Focus(
            focusNode: _focusNode,
            canRequestFocus: widget.enabled,
            skipTraversal: !widget.enabled,
            onFocusChange: widget.enabled || _isFocused
                            ? _handleFocusChange
                            : null,
            child: GestureDetector(
              behavior: widget.behavior ?? HitTestBehavior.opaque,
              onTap: widget.enabled ? _handleTap : null,
              onTapDown: widget.enabled && !_isPressed
                          ? _handleTapDown
                          : null,
              onTapCancel: _isPressed || _isSwiped
                            ? _handleTapCancel
                            : null,
              child: child,
            ),
          ),
        ),
      ),
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
  void didPanLeave({required bool complete});

  /// The group that this [PanTarget] belongs to.
  ///
  /// If a PanRegion is given a group, only PanTargets with the same group will
  /// be notified when a pointer enters or leaves the PanRegion.
  Object? get group => null;
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


