import 'dart:math';
import 'dart:ui';

import 'package:cupertino_menu/src/utils/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../cupertino_menu.dart';
import '../items/base.dart';

class CupertinoMenuOverlay extends StatelessWidget {
  const CupertinoMenuOverlay({
    super.key,
    required this.items,
    required this.animation,
    required this.transformOrigin,
  });

  final Alignment transformOrigin;
  final Animation<double> animation;
  final List<Widget> items;

  static List<CupertinoMenuEntry<T>> buildMenuItems<T>(
    List<CupertinoMenuEntry<T>> items,
  ) {
    final props = <CupertinoMenuEntry<T>>[];
    List<CupertinoMenuEntry<T>>? row;
    Widget? previousChild;
    for (var i = 0; i < items.length; i++) {
      var child = items[i];

      if (child is CupertinoMenuActionItem) {
        row ??= [];
        row.add(child);
        if (row.length < 4) {
          continue;
        }
      }
      if (row?.isNotEmpty ?? false) {
        child = CupertinoMenuActionRow(children: [...row!]);
        row.clear();
      }

      // If this item and the item before it are not CupertinoMenuDividers covariants,
      // then add a CupertinoMenuDivider between them.
      // A separate widget is not
      if (i != 0 &&
          props.isNotEmpty &&
          child is! CupertinoMenuLargeDivider &&
          previousChild is! CupertinoMenuLargeDivider) {
        props.add(CupertinoMenuDividerWrapper(child: child));
      } else {
        props.add(child);
      }

      previousChild = child;
    }

    for (var i = 0; i < props.length; i++) {
      props[i] = InheritedIndex(index: i, child: props[i]);
    }

    return props;
  }

  Widget _buildMenuContainer(
    BuildContext context,
    Widget? child,
  ) {
    // TODO: Determine whether looking up an inherited widget during an animation
    // hurts performance.
    final height = CupertinoMenuLayerController.sizeOf(context).height;
    return Container(
      alignment: Alignment.topRight,
      transformAlignment: transformOrigin,
      transform: Matrix4.identity()..scale(animation.value),
      height: height * animation.value,
      width: 250,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _CupertinoMenuNestingEffect(
      builder: (value, child) => Transform.scale(
        alignment: transformOrigin,
        scale: 0.9 + 0.1 / value,
        child: child,
      ),
      child: AnimatedBuilder(
        builder: _buildMenuContainer,
        animation: animation,
        child: CupertinoBlurredMenuSurface(
          animation: animation,
          child: FadeTransition(
            opacity: animation,
            child: _MenuSurface(
              animation: animation,
              child: _CupertinoMenuNestingEffect(
                builder: (value, child) => Opacity(
                  opacity: 0.5 + 0.5 / value,
                  child: child,
                ),
                child: _MenuBody(
                  width: 250,
                  children: items,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CupertinoNestedMenuOverlay extends StatelessWidget {
  const CupertinoNestedMenuOverlay({
    super.key,
    required this.items,
    required this.nestedAnchor,
    required this.animation,
    required this.initialClip,
  });

  final Animation<double> animation;
  final List<Widget> items;
  final Rect nestedAnchor;
  final BorderRadius? initialClip;

  Widget _sizeBuilder(BuildContext context, Widget? child) {
    final height = CupertinoMenuLayerController.sizeOf(context).height;
    final anchorHeight = max(nestedAnchor.height, 20);
    return SizedBox(
      width: 250,
      height: CupertinoMenuController.of(context).isClosing.value
          ? height
          : (height - anchorHeight) * animation.value + anchorHeight,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final menu = CupertinoMenuController.of(context);

    return AnimatedBuilder(
      animation: animation,
      builder: _sizeBuilder,
      child: _CupertinoMenuNestingEffect(
        builder: (value, child) => Transform.scale(
          alignment: menu.alignment,
          scale: 0.9 + 0.1 / value,
          child: child,
        ),
        child: CupertinoAnimatedMenuExit(
          child: CupertinoBlurredMenuSurface(
            initialClip: initialClip,
            animation: animation,
            child: _MenuSurface(
              initialClip: initialClip,
              animation: animation,
              child: _CupertinoMenuNestingEffect(
                builder: (value, child) => Opacity(
                  opacity: 0.7 + 0.3 / value,
                  child: child,
                ),
                child: _MenuBody(
                  width: 250,
                  children: items,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CupertinoAnimatedMenuExit extends StatelessWidget {
  const CupertinoAnimatedMenuExit({
    super.key,
    required this.child,
  });
  final Widget child;
  static const duration = Duration(milliseconds: 350);
  @override
  Widget build(BuildContext context) {
    final menu = CupertinoMenuController.of(context);
    final anchorPosition =
        CupertinoMenuLayerController.of(context).anchorPosition;
    final height = CupertinoMenuLayerController.sizeOf(context).height;
    final anchorDistance =
        anchorPosition!.center.dy - menu.anchorPosition.center.dy;

    // Slide the menu towards the base anchor upon close.
    final offset = Offset(0, (anchorDistance / height) * -0.5);

    return ValueListenableBuilder(
      valueListenable: menu.isClosing,
      builder: (BuildContext context, isClosing, Widget? _) {
        return AnimatedSlide(
          duration: duration,
          offset: isClosing ? offset : Offset.zero,
          child: AnimatedScale(
            scale: isClosing ? 0 : 1,
            duration: duration,
            alignment: isClosing ? menu.alignment : Alignment.center,
            child: AnimatedOpacity(
              duration: duration,
              curve: Curves.easeOut,
              opacity: isClosing ? 0 : 1,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _CupertinoMenuNestingEffect extends StatelessWidget {
  const _CupertinoMenuNestingEffect({
    required this.child,
    required this.builder,
  });
  final Widget child;
  final Widget Function(double value, Widget? child) builder;

  @override
  Widget build(BuildContext context) {
    final menu = CupertinoMenuController.of(context);
    final layerDepth = CupertinoMenuLayerController.of(context).depth;
    final animation = menu.visibilityAnimation;
    double progress = 0.0;
    double remainder = 0.0;
    double previousProgress = 0.0;
    Widget? builtChild = child;
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, _) {
        remainder = animation.value.remainder(1);
        progress = animation.value - layerDepth - remainder;
        if (animation.status == AnimationStatus.forward) {
          if (remainder <= 0.7) {
            remainder = pow(remainder / 0.7, 0.75).toDouble();
          } else {
            remainder = 0;
            progress += 1;
          }
        } else {
          if (remainder >= 0.3) {
            remainder = pow((remainder - 0.3) / 0.7, 3).toDouble();
          } else {
            remainder = 0;
          }
        }
        progress = max(progress + remainder, 1);
        if (progress != previousProgress) {
          previousProgress = progress;
          builtChild = builder(progress, child);
        }
        return builtChild!;
      },
    );
  }
}

class _MenuSurface extends StatelessWidget {
  const _MenuSurface({
    required this.child,
    required this.animation,
    this.initialClip = _finalClip,
  });

  final BorderRadius? initialClip;
  final Widget child;
  final Animation<double> animation;
  CurveTween get tween => CurveTween(curve: const Interval(0.0, 0.1));

  static const _finalClip = BorderRadius.all(Radius.circular(14));
  @override
  Widget build(BuildContext context) {
    final menu = CupertinoMenuController.of(context);
    final layer = CupertinoMenuLayerController.of(context);
    final layerAnimation = menu.visibilityAnimation;
    final level = layer.depth;
    final backgroundColor = kCupertinoMenuBackground.resolveFrom(context);

    return AnimatedBuilder(
      animation: Listenable.merge([animation, layerAnimation]),
      builder: (context, _) {
        final visibilityProgress = clampDouble(
          animation.value, 0.0, 1.0, //
        );

        final surfaceOpacity = tween.transform(visibilityProgress) *
            kCupertinoMenuBackground.opacity;

        // Prevents the shadow from being too dark when the menu is nested.
        final nestedShadowOpacityDivisor = clampDouble(
          layerAnimation.value - level, 1.0, 10, //
        );

        final shadowOpacity =
            (0.1 * visibilityProgress) / nestedShadowOpacityDivisor;
        return Container(
          key: const ValueKey('keys.cupertino-menu-surface'),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(13)),
            color: backgroundColor.withOpacity(surfaceOpacity),
            boxShadow: [
              BoxShadow(
                spreadRadius: 40 * visibilityProgress,
                blurRadius: 50 * visibilityProgress,
                color: Color.fromRGBO(0, 0, 0, shadowOpacity),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.lerp(
              initialClip,
              _finalClip,
              animation.value,
            )!,
            child: child,
          ),
        );
      },
    );
  }
}

/// The blurred and saturated background of the [CupertinoMenuOverlay].
///
/// For performance, the backdrop filter is only applied if the menu's background is transparent.
/// The backdrop is applied as a separate layer because opacity transitions applied to a backdrop
/// filter have some visual artifacts.
/// I believe this is a relevant issue: https://github.com/flutter/flutter/issues/31706.
class CupertinoBlurredMenuSurface extends StatelessWidget {
  const CupertinoBlurredMenuSurface({
    super.key,
    required this.animation,
    required this.child,
    this.initialClip = _finalClip,
  });

  final Widget child;
  final Animation<double> animation;
  final BorderRadius? initialClip;

  static const curve = Interval(0.2, 0.8);
  static const _finalClip = BorderRadius.all(Radius.circular(14));

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (kCupertinoMenuBackground.alpha != 0xFF)
          AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final value = curve.transform(animation.value.clamp(0, 1));
              return ClipRRect(
                borderRadius: BorderRadius.lerp(
                  initialClip,
                  _finalClip,
                  value,
                )!,
                child: BackdropFilter(
                  blendMode: BlendMode.src,
                  filter: ImageFilter.compose(
                    outer: ImageFilter.blur(
                      sigmaX: 33 * value,
                      sigmaY: 33 * value,
                    ),
                    inner: ColorFilter.matrix(
                      saturationAdjustMatrix(
                        value: 1.025 * pow(animation.value, 2),
                      ),
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              );
            },
          ),
        child,
      ],
    );
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody({
    required this.children,
    required this.width,
  });

  final List<Widget> children;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Focus(
      includeSemantics: false,
      child: Semantics(
        scopesRoute: true,
        namesRoute: true,
        explicitChildNodes: true,
        container: true,
        label: 'Popup menu',
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: _UnsafeSizeChangedLayoutNotifier(
            child: Column(
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that measures its child's size and notifies its parent.
///
/// From https://blog.gskinner.com/archives/2021/01/flutter-how-to-measure-widgets.html
///
/// I'm fairly certain this is a bad practice, but it was the least bad solution I could think up.
///
/// The main issues pushing me towards this solution are:
/// 1. A nested menus appears to begin expanding at the height of it's anchors (at least in this implementation). Normally, the Align
/// widget could be used with a sizeFactor to scale the menu relative to it's final height, but I would need to know the ratio of the
/// nested menu's anchor to the nested menu's total surface in order to do this. This problem may be fixable by separating the nested
/// anchor from its siblings.
/// 2. When using a ClipPath/Align widget to perform relative scaling, the menu's shadow is clipped. This is because the shadow is drawn
///  outside of the menu's bounds.
class _UnsafeSizeChangedLayoutNotifier extends SingleChildRenderObjectWidget {
  /// Creates a [_UnsafeSizeChangedLayoutNotifier] that dispatches layout changed
  /// notifications when [child] changes layout size.
  const _UnsafeSizeChangedLayoutNotifier({
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeChangedWithCallback(
      context: context,
      onLayoutChangedCallback: (Size area) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          MenuLayerPositionNotification(rect: area).dispatch(context);
        });
      },
    );
  }
}

class _RenderSizeChangedWithCallback extends RenderProxyBox {
  _RenderSizeChangedWithCallback({
    RenderBox? child,
    required this.onLayoutChangedCallback,
    required this.context,
  }) : super(child);

  final ValueChanged<Size> onLayoutChangedCallback;

  final BuildContext context;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _oldSize) {
      onLayoutChangedCallback(size);
    }

    _oldSize = size;
  }
}

/// From https://stackoverflow.com/questions/64639589/how-to-adjust-hue-saturation-and-brightness-of-an-image-or-widget-in-flutter
List<double> saturationAdjustMatrix({required double value}) {
  value *= 100;

  if (value == 0) {
    return [
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  final x = 1 + ((value > 0) ? ((3 * value) / 100) : (value / 100));
  const lumR = 0.3086;
  const lumG = 0.6094;
  const lumB = 0.082;

  return List<double>.from(<double>[
    (lumR * (1 - x)) + x, lumG * (1 - x), lumB * (1 - x), 0, 0, //
    lumR * (1 - x), (lumG * (1 - x)) + x, lumB * (1 - x), 0, 0, //
    lumR * (1 - x), lumG * (1 - x), (lumB * (1 - x)) + x, 0, 0, //
    0, 0, 0, 1, 0, //
  ]).map((i) => i).toList();
}
