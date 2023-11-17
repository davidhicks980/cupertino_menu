// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/cupertino/constants.dart';
import 'package:flutter/widgets.dart';

import 'menu.dart';
import 'menu_item.dart';



// A default layout wrapper for [CupertinoBaseMenuItem]s.
class Item extends StatelessWidget {
  // Creates a [_CupertinoMenuItemStructure]
  const Item({super.key,
    required this.title,
    this.height = kMinInteractiveDimensionCupertino,
    this.padding,
    this.leading,
    this.trailing,
    this.subtitle,
    this.scalePadding = true,
    double? leadingWidth,
    double? trailingWidth,
  })  : _trailingWidth = trailingWidth,
        _leadingWidth = leadingWidth;

  static const EdgeInsetsDirectional defaultPadding = EdgeInsetsDirectional.symmetric(vertical: 12.0);
  static const double defaultLeadingWidgetWidth = 32.0;
  static const double defaultTrailingWidgetInset = 44;
  static const double defaultHorizontalWidth = 16.0;
  static const AlignmentDirectional defaultLeadingAlignment = AlignmentDirectional(1/6, 0);
  static const AlignmentDirectional defaultTrailingAlignment = AlignmentDirectional(3/11, 0);
  static const EdgeInsetsDirectional defaultPadding2 = EdgeInsetsDirectional.symmetric(vertical: 12.0);
  static const double defaultLeadingWidgetInset = 32.0;
  static const double defaultTrailingCenterToTitleEndGap2 = 16.0;
  static const double defaultHorizontalWidth2 = 16.0;
  static const AlignmentDirectional defaultLeadingAlignment2 = AlignmentDirectional(-0.85, 0);
  static const AlignmentDirectional defaultTrailingAlignment2 = AlignmentDirectional(0.78, 0);

  // The padding for the contents of the menu item.
  final EdgeInsetsDirectional? padding;

  // The widget shown before the title. Typically a [CupertinoIcon].
  final Widget? leading;

  // The widget shown after the title. Typically a [CupertinoIcon].
  final Widget? trailing;

  // The width of the leading portion of the menu item.
  final double? _leadingWidth;

  // The width of the trailing portion of the menu item.
  final double? _trailingWidth;

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
    final double paddingScaler = scalePadding ? math.sqrt(textScale) : 1.0;
    final double trailingWidth = (showTrailingWidget
              ? _trailingWidth ?? defaultTrailingWidgetInset
              : defaultHorizontalWidth) * paddingScaler;
    final double leadingWidth = (leading != null
              ? _leadingWidth ?? defaultLeadingWidgetWidth
              : defaultHorizontalWidth) * paddingScaler;
    // AnimatedSize is used to limit jump when the contents of a menu item
    // change
    return AnimatedSize(
      curve: Curves.easeOutExpo,
      duration: const Duration(milliseconds: 600),
      child: _ListTile(
        title: title,
        subtitle: subtitle,
        textDirection: Directionality.of(context),
        padding: padding ?? defaultPadding,
        height: height,
        scale: scalePadding ? math.sqrt(paddingScaler) : 1.0,
        leading: showLeadingWidget ? leading ?? const SizedBox() : const SizedBox(),
        trailing: showTrailingWidget ? trailing : null,
        leadingWidth: leadingWidth,
        trailingWidth: trailingWidth,
        leadingAlignment: defaultLeadingAlignment,
        trailingAlignment: defaultTrailingAlignment,
      ),
    );
  }
}


class _ListTile extends SlottedMultiChildRenderObjectWidget<_ListTileSlot2, RenderBox> {
  const _ListTile({
    required this.textDirection,
    required this.height,
    required this.scale,
    required this.leadingWidth,
    required this.leadingAlignment,
    required this.trailingWidth,
    required this.trailingAlignment,
    required this.padding,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
  });

  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final double height;
  final double leadingWidth;
  final double trailingWidth;
  final double scale;
  final TextDirection textDirection;
  final EdgeInsetsDirectional padding;
  final AlignmentDirectional leadingAlignment;
  final AlignmentDirectional trailingAlignment;

  @override
  Iterable<_ListTileSlot2> get slots => _ListTileSlot2.values;

  @override
  Widget? childForSlot(_ListTileSlot2 slot) {
    return switch (slot) {
      _ListTileSlot2.leading => leading,
      _ListTileSlot2.title => title,
      _ListTileSlot2.subtitle => subtitle,
      _ListTileSlot2.trailing => trailing
    };
  }

  @override
  _RenderListTile createRenderObject(BuildContext context) {
    return _RenderListTile(
      textDirection: textDirection,
      minimumTitlePadding: padding,
      height: height,
      leadingWidth: leadingWidth,
      trailingWidth: trailingWidth,
      leadingAlignment: leadingAlignment,
      trailingAlignment: trailingAlignment,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderListTile renderObject) {
    renderObject
      ..textDirection = textDirection
      ..height = height
      ..padding = padding
      ..leadingWidth = leadingWidth
      ..trailingWidth = trailingWidth
      ..leadingAlignment = leadingAlignment
      ..trailingAlignment = trailingAlignment;
  }
}

enum _ListTileSlot {
  leading,
  title,
  subtitle,
  trailing,
}

class _RenderListTile extends RenderBox with SlottedContainerRenderObjectMixin<_ListTileSlot2, RenderBox> {
  _RenderListTile({
    required TextDirection textDirection,
    required double height,
    required double leadingWidth,
    required double trailingWidth,
    required EdgeInsetsDirectional minimumTitlePadding,
    required AlignmentDirectional leadingAlignment,
    required AlignmentDirectional trailingAlignment,
  }) : _textDirection = textDirection,
       _padding = minimumTitlePadding,
       _leadingWidth = leadingWidth,
       _trailingWidth = trailingWidth,
       _height = height,
       _leadingAlignment = leadingAlignment,
       _trailingAlignment = trailingAlignment;

  RenderBox? get leading => childForSlot(_ListTileSlot2.leading);
  RenderBox? get title => childForSlot(_ListTileSlot2.title);
  RenderBox? get subtitle => childForSlot(_ListTileSlot2.subtitle);
  RenderBox? get trailing => childForSlot(_ListTileSlot2.trailing);
  static const BoxConstraints _iconConstraints = BoxConstraints(
      maxWidth: 21,
      maxHeight: 21
    );

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  double get height => _height;
  double _height;
  set height(double value) {
    if (_height == value) {
      return;
    }
    _height = value;
    markNeedsLayout();
  }

  EdgeInsetsDirectional get padding => _padding;
  EdgeInsetsDirectional _padding;
  set padding(EdgeInsetsDirectional value) {
    assert(
      value.isNonNegative ?? true,
      'Menu padding must be non-negative.'
    );
    if (_padding == value) {
      return;
    }
    _padding = value;
    markNeedsLayout();
  }

  double get leadingWidth => _leadingWidth;
  double _leadingWidth;
  set leadingWidth(double value) {
    if (_leadingWidth == value) {
      return;
    }
    _leadingWidth = value;
    markNeedsLayout();
  }

  AlignmentDirectional get leadingAlignment => _leadingAlignment;
  AlignmentDirectional _leadingAlignment;
  set leadingAlignment(AlignmentDirectional value) {
    if (_leadingAlignment == value) {
      return;
    }
    _leadingAlignment = value;
    markNeedsLayout();
  }

  double get trailingWidth => _trailingWidth;
  double _trailingWidth;
  set trailingWidth(double value) {
    if (_trailingWidth == value) {
      return;
    }

    _trailingWidth = value;
    markNeedsLayout();
  }

  AlignmentDirectional get trailingAlignment => _trailingAlignment;
  AlignmentDirectional _trailingAlignment;
  set trailingAlignment(AlignmentDirectional value) {
    if (_trailingAlignment == value) {
      return;
    }

    _trailingAlignment = value;
    markNeedsLayout();
  }

  // The returned list is ordered for hit testing.
  @override
  Iterable<RenderBox> get children {
    return <RenderBox>[
      if (leading != null) leading!,
      if (title != null) title!,
      if (subtitle != null) subtitle!,
      if (trailing != null) trailing!,
    ];
  }

  @override
  bool get sizedByParent => false;

  @override
  double computeMinIntrinsicWidth(double height) {
    return math.max(
             title!.computeMinIntrinsicWidth(height),
             subtitle?.computeMinIntrinsicWidth(height) ?? 0.0
           ) + _leadingWidth + _trailingWidth;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return computeMinIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return math.max(
      title!.getMinIntrinsicHeight(width)
      + (subtitle?.getMinIntrinsicHeight(width) ?? 0.0),
      math.max(
        leading?.getMinIntrinsicHeight(width) ?? 0,
        trailing?.getMinIntrinsicHeight(width) ?? 0,
      )
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    assert(title != null);
    final BoxParentData parentData = title!.parentData! as BoxParentData;
    return parentData.offset.dy + title!.getDistanceToActualBaseline(baseline)!;
  }

  static Size _layoutBox(RenderBox? box, BoxConstraints constraints) {
    if (box == null) {
      return Size.zero;
    }

    box.layout(constraints, parentUsesSize: true);
    return box.size;
  }

  static void _positionBox(RenderBox box, Offset offset) {
    final BoxParentData parentData = box.parentData! as BoxParentData;
    parentData.offset = offset;
  }

  @override
  void performLayout() {
    final bool hasLeading = leading != null;
    final bool hasSubtitle = subtitle != null;
    final bool hasTrailing = trailing != null;
    final EdgeInsets resolvedPadding = _padding.resolve(_textDirection);
    final BoxConstraints looseConstraints = constraints.loosen();
    final double tileWidth = looseConstraints.maxWidth;
    final BoxConstraints textConstraints = looseConstraints.tighten(
      width: tileWidth - _leadingWidth - _trailingWidth - resolvedPadding.horizontal,
    );
    final Size leadingSize = _layoutBox(leading, _iconConstraints);
    final Size trailingSize = _layoutBox(trailing, _iconConstraints);
    final Size titleSize = _layoutBox(title, textConstraints);
    final Size subtitleSize = _layoutBox(subtitle, textConstraints);
    final double tileHeight = math.max(
        math.max(
          _height - resolvedPadding.vertical,
          titleSize.height + subtitleSize.height
        ),
        math.max(
          leadingSize.height,
          trailingSize.height,
        ),
    ) + resolvedPadding.vertical;
    final Offset resolvedLeading = leadingAlignment
                                      .resolve(_textDirection)
                                      .alongSize(Size(_leadingWidth, tileHeight));
    final Offset resolvedTrailing = trailingAlignment
                                      .resolve(_textDirection)
                                      .alongSize(Size(_trailingWidth, tileHeight));
    Offset clampOffset({
      required Size size,
      required double x,
      required double y,
    }) {
      return Offset(
        ui.clampDouble(
          x,
          resolvedPadding.left,
          tileWidth - resolvedPadding.right - size.width
        ),
        ui.clampDouble(
          y,
          resolvedPadding.top,
          tileHeight - resolvedPadding.bottom - size.height
        )
      );
    }
    switch (textDirection) {
      case TextDirection.rtl: {
        if (hasLeading) {
          _positionBox(
            leading!,
            Offset(
              tileWidth - resolvedLeading.dx - leadingSize.width / 2,
              resolvedLeading.dy - leadingSize.height / 2,
            )
          );
        }
        _positionBox(
          title!,
          Offset(
            tileWidth - _leadingWidth,
            0
          )
        );
        if (hasSubtitle) {
          _positionBox(
            subtitle!,
            Offset(
              tileWidth - _leadingWidth,
              tileHeight - subtitleSize.height - resolvedPadding.bottom,
            )
          );
        }
        if (hasTrailing) {
          _positionBox(
            trailing!,
            Offset(
              resolvedTrailing.dx - trailingSize.width / 2,
              resolvedTrailing.dy - trailingSize.height / 2 + resolvedPadding.top
            )
          );
        }
        break;
      }
      case TextDirection.ltr: {
        if (hasLeading) {
          _positionBox(
            leading!,
            clampOffset(
              size: leadingSize,
              x: resolvedLeading.dx - leadingSize.width / 2,
              y: resolvedLeading.dy - leadingSize.height / 2,
            )
          );
        }
        _positionBox(
          title!,
          clampOffset(
            size: titleSize,
            x: _leadingWidth + resolvedPadding.left,
            y: resolvedPadding.top,
          )
        );

        if (hasSubtitle) {
          _positionBox(
            subtitle!,
            clampOffset(
              size: subtitleSize,
              x: _leadingWidth,
              y: tileHeight - resolvedPadding.bottom - subtitleSize.height,
            )
          );
        }

        if (hasTrailing) {
          _positionBox(
            trailing!,
            clampOffset(
              size: trailingSize,
              x: tileWidth - resolvedTrailing.dx - trailingSize.width / 2 - resolvedPadding.right,
              y: resolvedTrailing.dy - trailingSize.height / 2,
            )
          );
        }
        break;
      }
    }

    size = constraints.constrain(Size(tileWidth, tileHeight));
    assert(size.width == constraints.constrainWidth(tileWidth));
    assert(size.height == constraints.constrainHeight(tileHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for(final RenderBox child in children){
      final BoxParentData parentData = child.parentData! as BoxParentData;
      context.paintChild(child, parentData.offset + offset);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    for (final RenderBox child in children) {
      final BoxParentData parentData = child.parentData! as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - parentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }
}


class ListTile2 extends SlottedMultiChildRenderObjectWidget<_ListTileSlot2, RenderBox> {
  const ListTile2({super.key,
    required this.textDirection,
    required this.leadingAlignment,
    required this.trailingAlignment,
    required this.titleInsets,
    required this.title,
    required this.minimumHeight,
    this.leading,
    this.subtitle,
    this.trailing,
  });

  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? trailing;
  final TextDirection textDirection;
  // final double height;
  final EdgeInsetsDirectional titleInsets;
  final double minimumHeight;
  // final EdgeInsetsDirectional padding;
  final AlignmentDirectional leadingAlignment;
  final AlignmentDirectional trailingAlignment;

  @override
  Iterable<_ListTileSlot2> get slots => _ListTileSlot2.values;

  @override
  Widget? childForSlot(_ListTileSlot2 slot) {
    return switch (slot) {
      _ListTileSlot2.leading => leading,
      _ListTileSlot2.title => title,
      _ListTileSlot2.subtitle => subtitle,
      _ListTileSlot2.trailing => trailing
    };
  }

  @override
  _RenderListTile2 createRenderObject(BuildContext context) {
    return _RenderListTile2(
      textDirection: textDirection,
      leadingAlignment: leadingAlignment,
      trailingAlignment: trailingAlignment,
      titleInsets: titleInsets,
      elementSize: CupertinoMenuItemElementSize.medium, minimumHeight: minimumHeight,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderListTile2 renderObject) {
    renderObject
      ..textDirection = textDirection
      ..leadingInsetAlignment = leadingAlignment
      ..trailingInsetAlignment = trailingAlignment
      ..titleInsets = titleInsets
      ..elementSize = CupertinoMenuItemElementSize.medium
      ..minimumHeight = minimumHeight;

  }
}

enum _ListTileSlot2 {
  leading,
  title,
  subtitle,
  trailing,
}

class _RenderListTile2 extends RenderBox with SlottedContainerRenderObjectMixin<_ListTileSlot2, RenderBox> {

  _RenderListTile2({
    required TextDirection textDirection,
    // required double height,
    required EdgeInsetsDirectional titleInsets,
    // required EdgeInsetsDirectional minimumTitlePadding,
    required AlignmentDirectional leadingAlignment,
    required AlignmentDirectional trailingAlignment,
    required CupertinoMenuItemElementSize elementSize,
    required double minimumHeight,
  }) : _textDirection = textDirection,
       _leadingInsetAlignment = leadingAlignment,
       _trailingInsetAlignment = trailingAlignment,
       _titleInsets = titleInsets,
       _elementSize = elementSize,
        _minimumHeight = minimumHeight;

  // static const int titleGap = 8;
  RenderBox? get leading => childForSlot(_ListTileSlot2.leading);
  RenderBox? get title => childForSlot(_ListTileSlot2.title);
  RenderBox? get subtitle => childForSlot(_ListTileSlot2.subtitle);
  RenderBox? get trailing => childForSlot(_ListTileSlot2.trailing);
  static const BoxConstraints _iconConstraints = BoxConstraints(
      maxWidth: 21,
      maxHeight: 21
    );

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  CupertinoMenuItemElementSize get elementSize => _elementSize;
  CupertinoMenuItemElementSize _elementSize;
  set elementSize(CupertinoMenuItemElementSize value) {
    if (_elementSize == value) {
      return;
    }

    _elementSize = value;
    markNeedsLayout();
  }

  double get minimumHeight => _minimumHeight;
  double _minimumHeight;
  set minimumHeight(double value) {
    if (_minimumHeight == value) {
      return;
    }

    _minimumHeight = value;
    markNeedsLayout();
  }

  EdgeInsetsDirectional get titleInsets => _titleInsets;
  EdgeInsetsDirectional _titleInsets;
  set titleInsets(EdgeInsetsDirectional value) {
    if (_titleInsets == value) {
      return;
    }

    _titleInsets = value;
    markNeedsLayout();
  }


  AlignmentDirectional get leadingInsetAlignment => _leadingInsetAlignment;
  AlignmentDirectional _leadingInsetAlignment;
  set leadingInsetAlignment(AlignmentDirectional value) {
    if (_leadingInsetAlignment == value) {
      return;
    }
    _leadingInsetAlignment = value;
    markNeedsLeadingAlignmentResolution();
  }

  AlignmentDirectional get trailingInsetAlignment => _trailingInsetAlignment;
  AlignmentDirectional _trailingInsetAlignment;
  set trailingInsetAlignment(AlignmentDirectional value) {
    if (_trailingInsetAlignment == value) {
      return;
    }

    _trailingInsetAlignment = value;
    markNeedsTrailingAlignmentResolution();
  }

  void markNeedsLeadingAlignmentResolution() {
    _resolvedLeadingAlignment = null;
    markNeedsLayout();
  }

  void markNeedsTrailingAlignmentResolution() {
    _resolvedTrailingAlignment = null;
    markNeedsLayout();
  }

  Alignment? _resolvedLeadingAlignment;
  Alignment? _resolvedTrailingAlignment;

  void _resolveAlignment() {
    _resolvedLeadingAlignment ??= _leadingInsetAlignment.resolve(textDirection);
    _resolvedTrailingAlignment ??= _trailingInsetAlignment.resolve(textDirection);
  }

  // The returned list is ordered for hit testing.
  @override
  Iterable<RenderBox> get children {
    return <RenderBox>[
      if (leading != null) leading!,
      if (title != null) title!,
      if (subtitle != null) subtitle!,
      if (trailing != null) trailing!,
    ];
  }

  @override
  bool get sizedByParent => false;

   static double _minWidth(RenderBox? box, double height) {
    return box == null ? 0.0 : box.getMinIntrinsicWidth(height);
  }

  static double _maxWidth(RenderBox? box, double height) {
    return box == null ? 0.0 : box.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _resolveAlignment();
    final double leadingWidth = leading != null
      ? math.max(leading!.getMinIntrinsicWidth(height), _titleInsets.start)
      : _titleInsets.start;
    return leadingWidth
      + math.max(_minWidth(title, height), _minWidth(subtitle, height))
      + _maxWidth(trailing, height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    _resolveAlignment();
    return _titleInsets.start
      + math.max(_maxWidth(title, height), _maxWidth(subtitle, height))
      + _maxWidth(trailing, height);
  }


  @override
  double computeMinIntrinsicHeight(double width) {
    assert(
      (leading == null  || leading!.getMinIntrinsicHeight(width) < _minimumHeight) &&
      (trailing == null || trailing!.getMinIntrinsicHeight(width) < _minimumHeight),
    );

    return math.max(
      _minimumHeight,
      title!.getMinIntrinsicHeight(width) + (subtitle?.getMinIntrinsicHeight(width) ?? 0.0),
    );
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return computeMinIntrinsicHeight(width);
  }

  static Size _layoutBox(RenderBox? box, BoxConstraints constraints, { bool parentUsesSize = false }) {
    if (box == null) {
      return Size.zero;
    }

    box.layout(constraints, parentUsesSize: parentUsesSize);
    return box.size;
  }

  static void _positionBox(RenderBox box, Offset offset) {
    final BoxParentData parentData = box.parentData! as BoxParentData;
    parentData.offset = offset;
  }


  Offset _resolveWidth(Alignment alignment, Size insetSize, Size widgetSize) {
    final ui.Offset position = alignment
                                .alongSize(insetSize)
                                .translate(
                                  -widgetSize.width / 2,
                                  -widgetSize.height / 2
                                );
    return Offset(
      ui.clampDouble(position.dx, 0.0, math.max(insetSize.width - widgetSize.width, 0)),
      ui.clampDouble(position.dy, 0.0, math.max(insetSize.height - widgetSize.height, 0))
    );
  }

  @override
  void performLayout() {
    _resolveAlignment();
    final bool hasSubtitle = subtitle != null;
    final bool hasLeading = leading != null;
    final bool hasTrailing = trailing != null;
    final BoxConstraints looseConstraints = constraints.loosen();
    final double tileWidth = looseConstraints.maxWidth;
    final Size leadingSize = _layoutBox(leading, _iconConstraints, parentUsesSize: true);
    final Size trailingSize = _layoutBox(trailing, _iconConstraints, parentUsesSize: true);
    final BoxConstraints textConstraints = BoxConstraints(
      maxWidth: math.max(
        tileWidth - titleInsets.start - titleInsets.end
        , 0),
    );
    final Size titleSize = _layoutBox(title, textConstraints, parentUsesSize: true);
    final Size subtitleSize = _layoutBox(subtitle, textConstraints, parentUsesSize: true);
    final double tileHeight =
          math.max(
            titleSize.height + subtitleSize.height + _titleInsets.vertical,
            _minimumHeight,
          );
    Offset? leadingPosition;
    Offset? trailingPosition;
    if (leading != null) {
      leadingPosition = _resolveWidth(
        _resolvedLeadingAlignment!,
        Size(titleInsets.start, tileHeight),
        leadingSize,
      );
    }

    if (trailing != null) {
      trailingPosition = _resolveWidth(
        _resolvedTrailingAlignment!,
        Size(titleInsets.end, tileHeight),
        trailingSize,
      );
    }

    switch(_textDirection){
      case TextDirection.rtl: {
        if (hasLeading) {
          _positionBox(
            leading!,
            leadingPosition!.translate(tileWidth - titleInsets.start, 0)
          );
        }

        _positionBox(
          title!,
          Offset(
            tileWidth - titleSize.width - titleInsets.start,
            hasSubtitle ? 0 : (tileHeight - titleSize.height) / 2,
          )
        );

        if (hasSubtitle) {
          _positionBox(
            subtitle!,
            Offset(
              tileWidth - titleSize.width  - titleInsets.start,
              titleSize.height,
            )
          );
        }

        if (hasTrailing) {
          _positionBox(
            trailing!,
            trailingPosition!
          );
        }

        break;
      }
      case TextDirection.ltr: {
        if (hasLeading) {
          _positionBox(
            leading!,
            leadingPosition!,
          );
        }

        _positionBox(
          title!,
          Offset(
            titleInsets.start,
            hasSubtitle ? 0 : (tileHeight - titleSize.height) / 2,
          )
        );

        if (hasSubtitle) {
          _positionBox(
            subtitle!,
            Offset(
              titleInsets.start,
              titleSize.height,
            )
          );
        }

        if (hasTrailing) {
          _positionBox(
            trailing!,
            trailingPosition!.translate(tileWidth - titleInsets.end, 0),
          );
        }
        break;
      }
    }

    size = constraints.constrain(Size(tileWidth, tileHeight));
    assert(size.width == constraints.constrainWidth(tileWidth));
    assert(size.height == constraints.constrainHeight(tileHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    for(final RenderBox child in children){
      final BoxParentData parentData = child.parentData! as BoxParentData;
      context.paintChild(child, parentData.offset + offset);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    for (final RenderBox child in children) {
      final BoxParentData parentData = child.parentData! as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - parentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }
}