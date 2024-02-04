// // Copyright 2014 The Flutter Authors. All rights reserved.
// // Use of this source code is governed by a BSD-style license that can be
// // found in the LICENSE file.

// import 'dart:async';
// import 'dart:math' as math;

// import 'package:flutter/cupertino.dart'
//     show
//         CupertinoColors,
//         CupertinoDynamicColor,
//         CupertinoLocalizations,
//         CupertinoTheme,
//         kMinInteractiveDimensionCupertino;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';

// import 'menu.dart';

// const bool _kDebugMenus = false;

// /// A widget that provides the default structure, semantics, and interactivity
// /// for menu items in a [CupertinoMenuAnchor].
// ///
// /// See also:
// /// * [_CupertinoInteractiveMenuItem], a widget that provides the default
// ///   typography, semantics, and interactivity for menu items in a
// class CupertinoMenuItem extends StatelessWidget with CupertinoMenuEntryMixin {
//   /// Creates a [CupertinoMenuItem]
//   const CupertinoMenuItem({
//     super.key,
//     required this.child,
//     Widget? subtitle,
//     this.leading,
//     this.leadingWidth,
//     this.leadingAlignment,
//     this.trailing,
//     this.trailingWidth,
//     this.trailingAlignment,
//     this.padding,
//     this.constraints,
//     this.focusNode,
//     this.onHover,
//     this.onFocusChange,
//     this.onPressed,
//     this.hoveredColor,
//     this.focusedColor,
//     this.pressedColor,
//     this.mouseCursor,
//     this.panActivationDelay,
//     this.behavior = HitTestBehavior.opaque,
//     this.requestFocusOnHover = false,
//     this.applyInsetScaling = true,
//     this.closeOnActivate = true,
//     this.isDefaultAction = false,
//     this.isDestructiveAction = false,
//   }) : _subtitle = subtitle;

//   /// The widget displayed in the center of this button.
//   ///
//   /// Typically this is the button's label, using a [Text] widget.
//   ///
//   /// {@macro flutter.widgets.ProxyWidget.child}
//   final Widget child;

//   /// The padding for the contents of the menu item.
//   final EdgeInsetsDirectional? padding;

//   /// The widget shown before the label. Typically a [CupertinoIcon].
//   final Widget? leading;

//   /// The widget shown after the label. Typically a [CupertinoIcon].
//   final Widget? trailing;

//   /// A widget displayed underneath the title. Typically a [Text] widget.
//   ///
//   /// If overriding the default [TextStyle.color] of the [_subtitle] widget,
//   /// [CupertinoDynamicColor.resolve] should be used to resolve the color
//   /// against the ambient [CupertinoTheme]. [TextStyle.inherit] must alst be set
//   /// to false, otherwise the [TextStyle.color] parameter will be overidden by
//   /// [TextStyle.foreground].
//   final Widget? _subtitle;

//   /// Called when the button is tapped or otherwise activated.
//   ///
//   /// If this callback is null, then the button will be disabled.
//   ///
//   /// See also:
//   ///
//   ///  * [enabled], which is true if the button is enabled.
//   final VoidCallback? onPressed;

//   /// Called when a pointer enters or exits the button response area.
//   ///
//   /// The value passed to the callback is true if a pointer has entered button
//   /// area and false if a pointer has exited.
//   final ValueChanged<bool>? onHover;

//   /// Determine if hovering can request focus.
//   ///
//   /// Defaults to false.
//   final bool requestFocusOnHover;

//   /// Handler called when the focus changes.
//   ///
//   /// Called with true if this widget's node gains focus, and false if it loses
//   /// focus.
//   final ValueChanged<bool>? onFocusChange;

//   /// {@macro flutter.widgets.Focus.focusNode}
//   final FocusNode? focusNode;

//   /// Delay between a user's pointer entering a menu item during a pan, and
//   /// the menu item being tapped.
//   ///
//   /// Defaults to null.
//   final Duration? panActivationDelay;

//   /// The color of menu item when focused.
//   final Color? focusedColor;

//   /// The color of menu item when hovered by the user's pointer.
//   final Color? hoveredColor;

//   /// The color of menu item while the menu item is swiped or pressed down.
//   final Color? pressedColor;

//   /// The mouse cursor to display on hover.
//   final MouseCursor? mouseCursor;

//   /// How the menu item should respond to hit tests.
//   final HitTestBehavior behavior;

//   /// {@macro flutter.material.menu_anchor.closeOnActivate}
//   final bool closeOnActivate;

//   /// Whether pressing this item will perform a destructive action
//   ///
//   /// Defaults to `false`. If `true`, [CupertinoColors.destructiveRed] will be
//   /// applied to this item's label and icon.
//   final bool isDestructiveAction;

//   /// Whether pressing this item performs the suggested or most commonly used action.
//   ///
//   /// Defaults to `false`. If `true`, [FontWeight.w600] will be
//   /// applied to this item's label.
//   final bool isDefaultAction;

//   /// The width of the leading portion of the menu item.
//   final double? leadingWidth;

//   /// The width of the trailing portion of the menu item.
//   final double? trailingWidth;

//   /// The alignment of the leading widget within the leading portion of the menu
//   /// item.
//   final AlignmentDirectional? leadingAlignment;

//   /// The alignment of the trailing widget within the trailing portion of the
//   /// menu item.
//   final AlignmentDirectional? trailingAlignment;

//   /// Whether the insets of the menu item should scale with the
//   /// [MediaQuery.textScalerOf].
//   ///
//   /// Defaults to `true`.
//   final bool applyInsetScaling;


//   /// Whether the menu item will respond to user input.
//   bool get enabled => onPressed != null;

//   @override
//   bool get hasLeading => leading != null;

//   /// The constraints to apply to the menu item.
//   ///
//   /// Because padding is applied to the menu item prior to constraints, padding
//   /// will only affect the size of the menu item iff the height of the padding
//   /// plus the height of the menu item's children exceeds the
//   /// [BoxConstraints.minHeight].
//   ///
//   /// By default, the only constraint applied to the menu item is a
//   /// [BoxConstraints.minHeight] of [kMinInteractiveDimensionCupertino].
//   final BoxConstraints? constraints;

//   /// Handles user selection of the menu item.
//   ///
//   /// To prevent redundant presses, selection is blocked if the menu has already
//   /// started closing.
//   ///
//   /// If [closeOnActivate] is true, this method is responsible for notifying the
//   /// [CupertinoMenuAnchor] that the menu should begin closing.
//   void _handleSelect(BuildContext context) {
//     assert(_debugMenuInfo('Selected $child menu'));
//     if (closeOnActivate) {
//       // If the menu is already closing or closed, then block selection and
//       // return early.
//       if (getMenuStatus(context) case MenuStatus.closing || MenuStatus.closed) {
//         return;
//       }

//       closeMenu(context);
//     }

//     // Delay the call to onPressed until post-frame so that the focus is
//     // restored to what it was before the menu was opened before the action is
//     // executed.
//     SchedulerBinding.instance.addPostFrameCallback((Duration _) {
//       FocusManager.instance.applyFocusChangesIfNeeded();
//       onPressed?.call();
//     }, debugLabel: '$CupertinoMenuItem.onPressed');
//   }

//   static const TextStyle defaultTitleStyle = TextStyle(
//     height: 1.25,
//     fontFamily: 'SF Pro Text',
//     fontFamilyFallback: <String>['.AppleSystemUIFont'],
//     fontSize: 17,
//     letterSpacing: -0.41,
//     textBaseline: TextBaseline.ideographic,
//     overflow: TextOverflow.ellipsis,
//     color: CupertinoDynamicColor.withBrightness(
//       color: Color.fromRGBO(0, 0, 0, 0.96),
//       darkColor: Color.fromRGBO(255, 255, 255, 0.96),
//     ),
//   );

//   static const TextStyle defaultSubtitleStyle = TextStyle(
//     height: 1.25,
//     fontFamily: 'SF Pro Text',
//     fontFamilyFallback: <String>['.AppleSystemUIFont'],
//     fontSize: 15,
//     letterSpacing: -0.21,
//     textBaseline: TextBaseline.ideographic,
//     overflow: TextOverflow.ellipsis,
//     color: CupertinoDynamicColor.withBrightnessAndContrast(
//       color: Color.fromRGBO(0, 0, 0, 0.4),
//       darkColor: Color.fromRGBO(255, 255, 255, 0.4),
//       highContrastColor: Color.fromRGBO(0, 0, 0, 0.8),
//       darkHighContrastColor: Color.fromRGBO(255, 255, 255, 0.8),
//     ),
//   );

//   /// The color of a [_CupertinoInteractiveMenuItem] when pressed.
//   // Pressed colors were sampled from the iOS simulator and are based on the
//   // following:
//   //
//   // Dark mode on white background     rgb(111, 111, 111)
//   // Dark mode on black                rgb(61, 61, 61)
//   // Light mode on black               rgb(177, 177, 177)
//   // Light mode on white               rgb(225, 225, 225)
//   static const CupertinoDynamicColor defaultPressedColor =
//       CupertinoDynamicColor.withBrightnessAndContrast(
//           color: Color.fromRGBO(50, 50, 50, 0.1),
//           darkColor: Color.fromRGBO(255, 255, 255, 0.1),
//           highContrastColor: Color.fromRGBO(50, 50, 50, 0.2),
//           darkHighContrastColor: Color.fromRGBO(255, 255, 255, 0.2),
//         );

//   /// Resolves the title [TextStyle] in response to [CupertinoThemeData.brightness],
//   ///  [isDefaultAction], [isDestructiveAction], and [enabled].
//   //
//   // Eyeballed from the iOS simulator.
//   TextStyle _resolveTitleStyle(BuildContext context) {
//     final Color color;

//     if (!enabled) {
//       color = CupertinoColors.systemGrey;
//     } else if (isDestructiveAction) {
//       color = CupertinoColors.systemRed;
//     } else {
//       color = defaultTitleStyle.color!;
//     }

//     return defaultTitleStyle.copyWith(
//       color: CupertinoDynamicColor.maybeResolve(color, context) ?? color,
//       fontWeight: isDefaultAction ? FontWeight.bold : FontWeight.normal,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final TextStyle titleTextStyle = _resolveTitleStyle(context);
//     final double textScale =
//         (MediaQuery.maybeTextScalerOf(context) ?? TextScaler.noScaling).scale(1);
//     Widget? subtitle =  _subtitle;
//     if (subtitle != null) {
//       final bool isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
//       final Paint subtitlePainter = Paint()
//         ..blendMode = isDark ? BlendMode.plus : BlendMode.hardLight
//         ..color = CupertinoDynamicColor.maybeResolve(
//                   defaultSubtitleStyle.color,
//                     context
//                   ) ?? defaultSubtitleStyle.color!;
//       subtitle = DefaultTextStyle.merge(
//         style: defaultSubtitleStyle.copyWith(foreground: subtitlePainter),
//         child: _AnimatedTitleSwitcher(
//           child: subtitle,
//         ),
//       );
//     }

//     Widget structure = _CupertinoMenuItemStructure(
//       padding: padding,
//       constraints: constraints,
//       trailing: textScale <= 1.25 ? trailing : null,
//       leading: leading,
//       subtitle: subtitle,
//       leadingAlignment: leadingAlignment,
//       trailingAlignment: trailingAlignment,
//       leadingWidth: leadingWidth,
//       trailingWidth: trailingWidth,
//       applyInsetScaling: applyInsetScaling,
//       child: DefaultTextStyle.merge(
//         style: titleTextStyle,
//         child: _AnimatedTitleSwitcher(
//           child: child,
//         ),
//       ),
//     );

//     if (leading != null || trailing != null) {
//       structure = IconTheme.merge(
//         data: IconThemeData(
//           size: math.sqrt(textScale) * 21,
//           color: titleTextStyle.color,
//         ),
//         child: structure,
//       );
//     }

//     final Color pressedColor = this.pressedColor ?? defaultPressedColor;
//     return MergeSemantics(
//       child: Semantics(
//         enabled: onPressed != null,
//         child: CupertinoMenuItemGestureHandler(
//           mouseCursor: mouseCursor,
//           panActivationDelay: panActivationDelay,
//           requestFocusOnHover: requestFocusOnHover,
//           onPressed: onPressed != null ? () => _handleSelect(context) : null,
//           onHover: onHover,
//           onFocusChange: onFocusChange,
//           focusNode: focusNode,
//           focusNodeDebugLabel: child.toString(),
//           pressedColor: CupertinoDynamicColor.maybeResolve(pressedColor, context)
//                           ?? pressedColor,
//           focusedColor: CupertinoDynamicColor.maybeResolve(focusedColor, context)
//                           ?? focusedColor,
//           hoveredColor: CupertinoDynamicColor.maybeResolve(hoveredColor, context)
//                           ?? hoveredColor,
//           behavior: behavior,
//           child: DefaultTextStyle.merge(
//               // The maximum number of lines appears to be infinite on the iOS
//               // simulator, so just use a large number. This will apply to all
//               // descendents with maxLines = null.
//               maxLines: textScale > 1.25 ? 100 : 2,
//               overflow: TextOverflow.ellipsis,
//               softWrap: true,
//               style: titleTextStyle,
//               child: structure
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(properties);
//     properties.add(DiagnosticsProperty<Color?>('pressedColor', pressedColor));
//     properties.add(DiagnosticsProperty<Color?>('hoveredColor', hoveredColor,
//         defaultValue: pressedColor?.withOpacity(0.075)));
//     properties.add(DiagnosticsProperty<Color?>('focusedColor', focusedColor,
//         defaultValue: pressedColor?.withOpacity(0.05)));
//     properties.add(EnumProperty<HitTestBehavior>('hitTestBehavior', behavior));
//     properties.add(DiagnosticsProperty<Duration>(
//         'panActivationDelay', panActivationDelay,
//         defaultValue: Duration.zero));
//     properties.add(DiagnosticsProperty<FocusNode?>('focusNode', focusNode,
//         defaultValue: null));
//     properties.add(
//         FlagProperty('enabled', value: onPressed != null, ifFalse: 'DISABLED'));
//     properties.add(DiagnosticsProperty<Widget?>('title', child));
//     properties.add(DiagnosticsProperty<Widget?>('subtitle', _subtitle));
//     properties.add(
//         DiagnosticsProperty<Widget?>('leading', leading, defaultValue: null));
//     properties.add(
//         DiagnosticsProperty<Widget?>('trailing', trailing, defaultValue: null));
//   }
// }

// class _AnimatedTitleSwitcher extends StatelessWidget {
//   const _AnimatedTitleSwitcher({required this.child});
//   final Widget child;

//   static Widget _layoutBuilder(
//     Widget? currentChild,
//     List<Widget> previousChildren,
//   ) {
//     return Stack(
//       clipBehavior: Clip.none,
//       alignment: AlignmentDirectional.centerStart,
//       children: <Widget>[
//         for (final Widget child in previousChildren)
//           SizedOverflowBox(
//             size: Size.zero,
//             alignment: AlignmentDirectional.centerStart,
//             child: child,
//           ),
//         if (currentChild != null)
//           AnimatedSize(
//             clipBehavior: Clip.none,
//             alignment: AlignmentDirectional.centerStart,
//             curve: const Cubic(0.33, 0.2, 0.16, 1.04),
//             duration: const Duration(milliseconds: 400),
//             child: currentChild,
//           )
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       reverseDuration: const Duration(milliseconds: 200),
//       duration: const Duration(milliseconds: 200),
//       layoutBuilder: _layoutBuilder,
//       child:  child,

//     );
//   }
// }

// // A default layout wrapper for [CupertinoBaseMenuItem]s.
// @immutable
// class _CupertinoMenuItemStructure extends StatelessWidget
//     with CupertinoMenuEntryMixin {
//   // Creates a [_CupertinoMenuItemStructure]
//   const _CupertinoMenuItemStructure({
//     required this.child,
//     BoxConstraints? constraints,
//     this.leading,
//     this.trailing,
//     this.subtitle,
//     this.applyInsetScaling = true,
//     EdgeInsetsDirectional? padding,
//     AlignmentDirectional? leadingAlignment,
//     AlignmentDirectional? trailingAlignment,
//     double? leadingWidth,
//     double? trailingWidth,
//   })  : _padding = padding, _leadingAlignment = leadingAlignment ?? defaultLeadingAlignment,
//         _trailingAlignment = trailingAlignment ?? defaultTrailingAlignment,
//         _trailingWidth = trailingWidth,
//         _leadingWidth = leadingWidth,
//         _constraints = constraints ?? defaultConstraints;

//   static const EdgeInsetsDirectional defaultPadding =
//       EdgeInsetsDirectional.symmetric(vertical: 11.5);
//   static const double defaultHorizontalWidth = 16;
//   static const double leadingWidgetWidth = 32.0;
//   static const double trailingWidgetWidth = 44.0;
//   static const AlignmentDirectional defaultLeadingAlignment =
//       AlignmentDirectional(1 / 6, 0);
//   static const AlignmentDirectional defaultTrailingAlignment =
//       AlignmentDirectional(-3 / 11, 0);
//   static const BoxConstraints defaultConstraints = BoxConstraints(
//     minHeight: kMinInteractiveDimensionCupertino,
//   );

//   // The padding for the contents of the menu item.
//   final EdgeInsetsDirectional? _padding;

//   // The widget shown before the title. Typically a [CupertinoIcon].
//   final Widget? leading;

//   // The widget shown after the title. Typically a [CupertinoIcon].
//   final Widget? trailing;

//   // The width of the leading portion of the menu item.
//   final double? _leadingWidth;

//   // The width of the trailing portion of the menu item.
//   final double? _trailingWidth;

//   // The alignment of the leading widget within the leading portion of the menu
//   // item.
//   final AlignmentDirectional _leadingAlignment;

//   // The alignment of the trailing widget within the trailing portion of the
//   // menu item.
//   final AlignmentDirectional _trailingAlignment;

//   // The height of the menu item.
//   final BoxConstraints? _constraints;

//   // The center content of the menu item
//   final Widget child;

//   // The subtitle of the menu item
//   final Widget? subtitle;

//   // Whether the insets of the menu item should scale with the
//   // [MediaQuery.textScalerOf].
//   final bool applyInsetScaling;

//   BoxConstraints get constraints => _constraints ?? defaultConstraints;

//   @override
//   Widget build(BuildContext context) {
//     final double textScale = MediaQuery.maybeTextScalerOf(context)?.scale(1) ?? 1.0;
//     final bool showLeadingWidget = leading != null || shouldApplyLeading(context);
//     // Padding scales with textScale, but at a slower rate than text. Square
//     // root is used to estimate the padding scaling factor.
//     final double paddingScaler = applyInsetScaling ? math.sqrt(textScale) : 1.0;
//     final double trailingWidth = _trailingWidth
//                                    ?? (trailing != null
//                                         ? trailingWidgetWidth
//                                         : defaultHorizontalWidth) * paddingScaler;
//     final double leadingWidth = _leadingWidth
//                                   ?? (showLeadingWidget
//                                         ? leadingWidgetWidth
//                                         : defaultHorizontalWidth) * paddingScaler;


//     EdgeInsetsDirectional? padding = _padding;
//     double physicalPixel;

//     // Subtract a physical pixel from the default padding if no padding is
//     // specified by the user. (iOS 17.2 simulator)
//     if (_padding == null) {
//       final double pixelRatio = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
//       physicalPixel =  1 / pixelRatio;
//       padding = defaultPadding.copyWith(
//         top:    math.max(defaultPadding.top    - physicalPixel / 2, 0),
//         bottom: math.max(defaultPadding.bottom - physicalPixel / 2, 0),
//       );
//     } else {
//       padding = _padding;
//       physicalPixel = 0;
//     }
//     return ConstrainedBox(
//       constraints: BoxConstraints(
//         minWidth: constraints.minWidth * paddingScaler,
//         maxWidth: constraints.maxWidth * paddingScaler,
//         minHeight: (constraints.minHeight - physicalPixel) * paddingScaler,
//         maxHeight: constraints.maxHeight * paddingScaler,
//       ).normalize(),
//       child: Padding(
//         padding: padding * paddingScaler,
//         child: Row(
//           children: <Widget>[
//             // The leading and trailing widgets are wrapped in SizedBoxes and
//             // then aligned, rather than just padded, because the alignment
//             // behavior of the SizedBoxes appears to be more consistent with
//             // AutoLayout (iOS).
//             SizedBox(
//               width: leadingWidth,
//               child: showLeadingWidget
//                   ? Align(alignment: _leadingAlignment, child: leading)
//                   : null,
//             ),
//             Expanded(
//               child: subtitle == null
//                   ? child
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         child,
//                         const SizedBox(height: 1),
//                         subtitle!,
//                       ],
//                     ),
//             ),
//             SizedBox(
//               width: trailingWidth,
//               child: trailing != null
//                   ? Align(alignment: _trailingAlignment, child: trailing)
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// A [CupertinoMenuEntryMixin] that inserts a large horizontal divider.
// ///
// /// The divider has a height of 8 logical pixels. A [color] parameter can be
// /// provided to customize the color of the divider.
// ///
// /// See also:
// ///
// /// * [CupertinoMenuItem], a Cupertino menu item.
// /// * [CupertinoMenuActionItem], a horizontal menu item.
// @immutable
// class CupertinoLargeMenuDivider extends StatelessWidget
//     with CupertinoMenuEntryMixin {
//   /// Creates a large horizontal divider for a [_CupertinoMenuPanel].
//   const CupertinoLargeMenuDivider({
//     super.key,
//     this.color = _color,
//   });

//   /// Color for a transparent [CupertinoLargeMenuDivider].
//   // The following colors were measured from debug mode on the iOS simulator,
//   static const CupertinoDynamicColor _color =
//       CupertinoDynamicColor.withBrightness(
//     color: Color.fromRGBO(0, 0, 0, 0.08),
//     darkColor: Color.fromRGBO(0, 0, 0, 0.16),
//   );

//   /// The color of the divider.
//   ///
//   /// If this property is null, [CupertinoLargeMenuDivider._color] is
//   /// used.
//   final Color color;

//   @override
//   bool get allowTrailingSeparator => false;

//   @override
//   bool get allowLeadingSeparator => false;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 8,
//       color: CupertinoDynamicColor.resolve(color, context),
//     );
//   }
// }


// /// A horizontal divider used to separate [CupertinoMenuItem]s
// ///
// /// The default width of the divider is 1 physical pixel, Unlike a [Border],
// /// the [thickness] of the divider does occupy layout space.
// @immutable
// class CupertinoMenuDivider extends StatelessWidget {
//   /// Creates a [CupertinoMenuDivider] with a default width of 1 physical pixel.
//   const CupertinoMenuDivider({
//     super.key,
//     this.color = baseColor,
//     this.tint = tintColor,
//     this.thickness,
//   }) : _child = null,
//        _alignmentStart = AlignmentDirectional.centerStart,
//        _alignmentEnd = AlignmentDirectional.centerEnd;


//   /// Creates a [CupertinoMenuDivider] with a default width of 1 physical pixel.
//   const CupertinoMenuDivider.wrapTop({
//     super.key,
//     this.color = baseColor,
//     this.tint = tintColor,
//     this.thickness,
//     required Widget child,
//   }) : _child = child,
//        _alignmentStart = AlignmentDirectional.topStart,
//        _alignmentEnd = AlignmentDirectional.topEnd;

//   /// Creates a [CupertinoMenuDivider] with a default width of 1 physical pixel.
//   const CupertinoMenuDivider.wrapBottom({
//     super.key,
//     this.color = baseColor,
//     this.tint = tintColor,
//     this.thickness,
//     required Widget child,
//   }) : _child = child,
//        _alignmentStart = AlignmentDirectional.bottomStart,
//        _alignmentEnd = AlignmentDirectional.bottomEnd;


//   /// Default transparent color for [CupertinoMenuDivider] and
//   /// [CupertinoVerticalMenuDivider].
//   ///
//   // The following colors were measured from the iOS simulator, and opacity was
//   // extrapolated:
//   // Dark mode on black       Color.fromRGBO(97, 97, 97)
//   // Dark mode on white       Color.fromRGBO(132, 132, 132)
//   // Light mode on black      Color.fromRGBO(147, 147, 147)
//   // Light mode on white      Color.fromRGBO(187, 187, 187)
//   static const CupertinoDynamicColor baseColor =
//     CupertinoDynamicColor.withBrightness(
//         color: Color.fromRGBO(140, 140, 140, 0.5),
//         darkColor: Color.fromRGBO(255, 255, 255, 0.25),
//       );
//   static const CupertinoDynamicColor tintColor =
//     CupertinoDynamicColor.withBrightness(
//         color: Color.fromRGBO(0, 0, 0, 0.24),
//         darkColor: Color.fromRGBO(255, 255, 255, 0.23),
//       );

//   /// The color of divider.
//   ///
//   /// If this property is null, [CupertinoMenuDivider.baseColor] is used.
//   final CupertinoDynamicColor color;

//   /// The color of divider.
//   ///
//   /// If this property is null, [CupertinoMenuDivider.baseColor] is used.
//   final CupertinoDynamicColor tint;

//   /// The thickness of the divider.
//   ///
//   /// If null, the default divider thickness is 1 physical pixel.
//   final double? thickness;

//   /// The widget below this widget in the tree.
//   final Widget? _child;

//   /// The relative start point of the divider's path.
//   final AlignmentDirectional _alignmentStart;

//   /// The relative end point of the divider's path.
//   final AlignmentDirectional _alignmentEnd;

//   @override
//   Widget build(BuildContext context) {
//     final double pixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
//     final double displacement = thickness ??  (1 / pixelRatio);
//     final TextDirection textDirection = Directionality.of(context);
//     final Alignment begin = _alignmentStart.resolve(textDirection);
//     final Alignment end = _alignmentEnd.resolve(textDirection);
//     assert(
//       begin.y == end.y &&
//           begin.y.roundToDouble() == begin.y,
//       'CupertinoMenuDivider must either inhabit the top, bottom, or center of its parent. ',
//     );
//     return CustomPaint(
//       painter: _AliasedBorderPainter(
//         begin: begin,
//         end: end,
//         tint: CupertinoDynamicColor.maybeResolve(tint, context)  ?? tint,
//         color: CupertinoDynamicColor.maybeResolve(color, context) ?? color,
//         offset: Offset(0, -displacement / 2) * begin.y,
//         border: BorderSide(width: thickness ?? 0.0),
//         antiAlias: pixelRatio < 1.0,
//       ),
//       size:  _child == null ? Size(double.infinity, displacement) : Size.zero,
//       child: _child != null
//           ? Padding(
//               padding: EdgeInsets.only(
//                 top:    begin.y == -1 ? displacement : 0.0,
//                 bottom: begin.y ==  1 ? displacement : 0.0,
//               ),
//               child: _child,
//             )
//           : null,
//     );
//   }
// }

// // A custom painter that draws a border without antialiasing
// //
// // If not used, hairline borders are antialiased, which make them look
// // thicker compared to iOS native menus.
// class _AliasedBorderPainter extends CustomPainter {
//   const _AliasedBorderPainter({
//     required this.border,
//     required this.tint,
//     required this.color,
//     required this.begin,
//     required this.end,
//     this.offset = Offset.zero,
//     this.antiAlias = false,
//   });

//   final BorderSide border;
//   final Color tint;
//   final Color color;
//   final Alignment begin;
//   final Alignment end;
//   final Offset offset;
//   final bool antiAlias;

//   @override
//   void paint(Canvas canvas, Size size) {
//     final Offset p1 = begin.alongSize(size) + offset;
//     final Offset p2 = end.alongSize(size) + offset;
//     if (!kIsWeb) {
//       final Paint basePainter = border.toPaint()
//         ..color = color
//         ..isAntiAlias = antiAlias
//         ..blendMode = BlendMode.overlay;
//       canvas.drawLine(p1, p2, basePainter);
//     }

//     final Paint tintPainter = border.toPaint()
//       ..color = tint
//       ..isAntiAlias = antiAlias;

//     canvas.drawLine(p1, p2, tintPainter);
//   }

//   @override
//   bool shouldRepaint(_AliasedBorderPainter oldDelegate) {
//    return tint      != oldDelegate.tint   ||
//           color     != oldDelegate.color  ||
//           end       != oldDelegate.end    ||
//           begin     != oldDelegate.begin  ||
//           border    != oldDelegate.border ||
//           offset    != oldDelegate.offset ||
//           antiAlias != oldDelegate.antiAlias;
//   }
// }

// /// A menu item wrapper that handles gestures, including taps, pans, and long
// /// presses.
// ///
// /// This widget is used by [CupertinoMenuItem] and
// /// [CupertinoMenuActionItem], and can be used to wrap custom menu items.
// ///
// /// The [onTap] callback is called when the user taps the menu item, pans over
// /// the menu item and lifts their finger, or when the user long-presses a menu
// /// item that has a [panActivationDelay] greater than [Duration.zero]. If
// /// provided, a [pressedColor] will highlight the menu item whenever a pointer
// /// is in contact with the menu item.
// ///
// /// A [mouseCursor] can be provided to change the cursor that appears when a
// /// mouse hovers over the menu item. If [mouseCursor] is null, the
// /// [SystemMouseCursors.click] cursor is used. A [hoveredColor] can be provided
// /// to change the color of the menu item when a mouse hovers over the menu item.
// /// If [hoveredColor] is null, the [pressedColor] is used with opacity 0.05.
// ///
// /// If [focusNode] is provided, the menu item will be focusable. When the menu
// /// item is focused, the [focusedColor] will be used to highlight the menu item.
// ///
// /// If [enabled] is false, the [onTap] callback is not called, the menu item
// /// will not be focusable, and no appearance changes will occur in response to
// /// user input.
// class CupertinoMenuItemGestureHandler extends StatefulWidget {
//   /// Creates default menu gesture detector.
//   const CupertinoMenuItemGestureHandler({
//     super.key,
//     required this.pressedColor,
//     required this.child,
//     this.mouseCursor,
//     this.focusedColor,
//     this.focusNode,
//     this.hoveredColor,
//     this.panActivationDelay,
//     this.onPressed,
//     this.onHover,
//     this.onFocusChange,
//     this.shortcut,
//     this.focusNodeDebugLabel,
//     this.requestFocusOnHover = false,
//     this.behavior = HitTestBehavior.opaque,
//   });

//   /// The widget displayed in the center of this button.
//   ///
//   /// Typically this is the button's label, using a [Text] widget.
//   ///
//   /// {@macro flutter.widgets.ProxyWidget.child}
//   final Widget child;

//   /// Called when the button is tapped or otherwise activated.
//   ///
//   /// If this callback is null, then the button will be disabled.
//   ///
//   /// See also:
//   ///
//   ///  * [enabled], which is true if the button is enabled.
//   final VoidCallback? onPressed;

//   /// Called when a pointer enters or exits the button response area.
//   ///
//   /// The value passed to the callback is true if a pointer has entered button
//   /// area and false if a pointer has exited.
//   final ValueChanged<bool>? onHover;

//   /// Determine if hovering can request focus.
//   ///
//   /// Defaults to false.
//   final bool requestFocusOnHover;

//   /// Handler called when the focus changes.
//   ///
//   /// Called with true if this widget's node gains focus, and false if it loses
//   /// focus.
//   final ValueChanged<bool>? onFocusChange;

//   /// {@macro flutter.widgets.Focus.focusNode}
//   final FocusNode? focusNode;

//   /// The optional shortcut that selects this [CupertinoMenuItemGestureHandler].
//   ///
//   /// {@macro flutter.material.MenuBar.shortcuts_note}
//   final MenuSerializableShortcut? shortcut;

//   /// Delay between a user's pointer entering a menu item during a pan, and
//   /// the menu item being tapped.
//   final Duration? panActivationDelay;

//   /// The color of menu item when focused.
//   final Color? focusedColor;

//   /// The color of menu item when hovered by the user's pointer.
//   final Color? hoveredColor;

//   /// The color of menu item while the menu item is swiped or pressed down.
//   final Color? pressedColor;

//   /// The mouse cursor to display on hover.
//   final MouseCursor? mouseCursor;

//   /// How the menu item should respond to hit tests.
//   ///
//   /// Defaults to [HitTestBehavior.opaque].
//   final HitTestBehavior behavior;

//   final String? focusNodeDebugLabel;

//   /// Whether the menu item will respond to user input.
//   bool get enabled => onPressed != null;

//   @override
//   State<CupertinoMenuItemGestureHandler> createState() =>
//       _CupertinoMenuItemGestureHandlerState();
// }

// class _CupertinoMenuItemGestureHandlerState
//     extends State<CupertinoMenuItemGestureHandler>
//     with PanTarget<CupertinoMenuItemGestureHandler> {
//   late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
//     ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _simulateTap),
//     ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: _simulateTap),
//   };

//   Timer? _longPanPressTimer;
//   bool _isFocused = false;
//   bool _isSwiped = false;
//   bool _isPressed = false;
//   bool _isHovered = false;

//   // If a focus node isn't given to the widget, then we have to manage our own.
//   FocusNode? _internalFocusNode;
//   FocusNode? get _focusNode => widget.focusNode ?? _internalFocusNode;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.focusNode == null) {
//       _createInternalFocusNode();
//     }
//     _focusNode?.addListener(_handleFocusChange);
//   }

//   @override
//   bool didPanEnter() {
//     if (!widget.enabled) {
//       return false;
//     }

//     if (widget.panActivationDelay != null) {
//       _longPanPressTimer = Timer(widget.panActivationDelay!, () {
//         if (mounted) {
//           _handleTap();
//         }

//         _longPanPressTimer = null;
//       });
//     }

//     if (!_isSwiped) {
//       setState(() {
//         _isSwiped = true;
//       });
//     }
//     return true;
//   }

//   @override
//   void didPanLeave({required bool pointerUp}) {
//     _longPanPressTimer?.cancel();
//     _longPanPressTimer = null;
//     if (mounted) {
//       if (pointerUp) {
//         _simulateTap();
//       } else if (_isSwiped || _isPressed) {
//         setState(() {
//           _isSwiped = false;
//           _isPressed = false;
//         });
//       }
//     }
//   }

//   @override
//   void didUpdateWidget(CupertinoMenuItemGestureHandler oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.focusNode != oldWidget.focusNode) {
//       (oldWidget.focusNode ?? _internalFocusNode)?.removeListener(_handleFocusChange);
//       if (widget.focusNode != null) {
//         _internalFocusNode?.dispose();
//         _internalFocusNode = null;
//       } else {
//         _createInternalFocusNode();
//       }
//       _focusNode!.addListener(_handleFocusChange);
//     }

//     if (oldWidget.enabled && !widget.enabled) {
//       _isHovered = false;
//       _isPressed = false;
//       _isSwiped = false;
//       _handleFocusChange(false);
//     }
//   }

//   @override
//   void dispose() {
//     _longPanPressTimer?.cancel();
//     _focusNode?.removeListener(_handleFocusChange);
//     _internalFocusNode?.dispose();
//     _internalFocusNode = null;
//     super.dispose();
//   }

//   void _handleFocusChange([bool? focused]) {
//     if (_focusNode?.hasFocus != _isFocused) {
//       setState(() {
//         _isFocused = _focusNode?.hasFocus ?? focused ?? false;
//       });
//       widget.onFocusChange?.call(_isFocused);
//     }
//   }

//   void _handleHover(PointerEvent event) {
//     final bool hovered = event is PointerEnterEvent;
//     if (!widget.enabled) {
//       if (_isHovered) {
//         setState(() {
//           _isHovered = false;
//         });
//       }
//       return;
//     }

//     if (hovered != _isHovered) {
//       widget.onHover?.call(hovered);
//       if (hovered && widget.requestFocusOnHover) {
//         assert(_debugMenuInfo('Requesting focus for $_focusNode from hover'));
//         _focusNode?.requestFocus();
//       }

//       setState(() {
//         _isHovered = hovered;
//       });
//     }
//   }

//   void _simulateTap([Intent? intent]) {
//     if (widget.enabled) {
//       _handleTap();
//     }
//   }

//   void _handleTap() {
//     if (widget.enabled) {
//       widget.onPressed?.call();
//       setState(() {
//         _isPressed = false;
//         _isSwiped = false;
//       });
//     }
//   }

//   void _handleTapDown(TapDownDetails details) {
//     if (widget.enabled && !_isPressed) {
//       setState(() {
//         _isPressed = true;
//         _isSwiped = true;
//       });
//     }
//   }

//   void _handleTapCancel() {
//     if (_isPressed || _isSwiped) {
//       setState(() {
//         _isPressed = false;
//         _isSwiped = false;
//       });
//     }
//   }

//   void _createInternalFocusNode() {
//     _internalFocusNode = FocusNode();
//     assert(() {
//       _internalFocusNode!.debugLabel =
//             '$CupertinoMenuItem(${widget.focusNodeDebugLabel})';
//       return true;
//     }());
//   }

//   Color? get backgroundColor {
//     if (widget.enabled) {
//       if (_isPressed || _isSwiped) {
//         return widget.pressedColor;
//       }

//       if (_isFocused) {
//         return widget.focusedColor ?? widget.pressedColor?.withOpacity(0.075);
//       }

//       if (_isHovered) {
//         return widget.hoveredColor ?? widget.pressedColor?.withOpacity(0.05);
//       }
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget? child = widget.child;
//     final Color? backgroundColor = this.backgroundColor;
//     if (backgroundColor != null) {
//       child = DecoratedBox(
//         decoration: BoxDecoration(
//           backgroundBlendMode:
//               CupertinoTheme.maybeBrightnessOf(context) == Brightness.light
//                   ? BlendMode.multiply
//                   : BlendMode.plus,
//           color: backgroundColor,
//         ),
//         child: child,
//       );
//     }

//     return MetaData(
//       metaData: this,
//       child: MouseRegion(
//         onEnter: _handleHover,
//         onExit: _handleHover,
//         hitTestBehavior: HitTestBehavior.deferToChild,
//         cursor: widget.enabled
//             ? widget.mouseCursor ?? SystemMouseCursors.click
//             : MouseCursor.defer,
//         child: Actions(
//           actions: _actionMap,
//           child: Focus(
//             focusNode: _focusNode,
//             canRequestFocus: widget.enabled,
//             skipTraversal: !widget.enabled,
//             onFocusChange: _handleFocusChange,
//             child: GestureDetector(
//               behavior: widget.behavior,
//               onTap: _handleTap,
//               onTapDown: _handleTapDown,
//               onTapCancel: _handleTapCancel,
//               child: child,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Can be mixed into a [State] to receive callbacks when a pointer enters or
// /// leaves a [PanTarget]. The [PanTarget] is should be an ancestor of a
// /// [CupertinoPanListener].
// mixin PanTarget<T extends StatefulWidget> on State<T> {
//   /// Called when a pointer enters the [PanTarget]. Return true if the pointer
//   /// should be considered "on" the [PanTarget], and false otherwise (for
//   /// example, when the [PanTarget] is disabled).
//   bool didPanEnter();

//   /// Called when the pointer leaves the [PanTarget]. If [pointerUp] is true,
//   /// then the pointer left the screen while over this menu item.
//   void didPanLeave({required bool pointerUp});

//   /// The group that this [PanTarget] belongs to.
//   ///
//   /// If a PanRegion is given a group, only PanTargets with the same group will
//   /// be notified when a pointer enters or leaves the PanRegion.
//   Object? get group => null;
// }

// /// A debug print function, which should only be called within an assert, like
// /// so:
// ///
// ///   assert(_debugMenuInfo('Debug Message'));
// ///
// /// so that the call is entirely removed in release builds.
// ///
// /// Enable debug printing by setting [_kDebugMenus] to true at the top of the
// /// file.
// bool _debugMenuInfo(String message, [Iterable<String>? details]) {
//   assert(() {
//     if (_kDebugMenus) {
//       debugPrint('MENU: $message');
//       if (details != null && details.isNotEmpty) {
//         for (final String detail in details) {
//           debugPrint('    $detail');
//         }
//       }
//     }
//     return true;
//   }());
//   // Return true so that it can be easily used inside of an assert.
//   return true;
// }
