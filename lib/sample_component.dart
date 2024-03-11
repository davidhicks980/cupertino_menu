import 'package:flutter/material.dart'
    hide
        MenuAcceleratorLabel,
        MenuAnchor,
        MenuBar,
        MenuController,
        MenuItemButton,
        SubmenuButton;
import 'package:flutter/services.dart';

void main() => runApp(const Main());

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> with SingleTickerProviderStateMixin {
  static BoxDecoration filledStyle = BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: Colors.deepOrange[600],
  );

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      color: Colors.blue,
      builder: (BuildContext context, Widget? widget) => FocusScope(
        autofocus: true,
        child: ColoredBox(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MenuItem(
                  onPressed: () {},
                  defaultPaint: filledStyle,
                  trailing: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  leading:  const Icon(Icons.access_alarm, color: Colors.white, size: 20),
                  hoveredPaint: filledStyle.copyWith(color: Colors.red[600]),
                  focusedPaint: filledStyle.copyWith(color: Colors.redAccent[700]),
                  pressedPaint: filledStyle.copyWith(color: Colors.deepOrangeAccent),
                  child: const Text(
                    'Howdy',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                MenuItem(
                  onPressed: () {},
                  defaultPaint: filledStyle,
                  hoveredPaint: filledStyle.copyWith(color: Colors.red[600]),
                  focusedPaint: filledStyle.copyWith(color: Colors.redAccent[700]),
                  pressedPaint: filledStyle.copyWith(color: Colors.deepOrangeAccent),
                  child: const Text(
                    'Partner',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A base class that is as simple as possible for new users to get started.
/// Similar to the Material library. The source code should read like a tutorial.
class MenuItem extends StatelessWidget with MenuItemParentContract {
  const MenuItem({
    super.key,
    required this.child,
    this.subtitle,
    this.leading,
    this.leadingWidth,
    this.trailing,
    this.trailingWidth,
    this.constraints,
    this.onHover,
    this.onFocusChange,
    this.onPressed,
    this.hoveredPaint,
    this.focusedPaint,
    this.pressedPaint,
    this.defaultPaint = const BoxDecoration(),
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final Widget? subtitle;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  final BoxDecoration? pressedPaint;
  final BoxDecoration? focusedPaint;
  final BoxDecoration? hoveredPaint;
  final BoxDecoration defaultPaint;
  final double? leadingWidth;
  final double? trailingWidth;
  final BoxConstraints? constraints;


  @override
  bool get allowLeadingSeparator => true;

  @override
  bool get allowTrailingSeparator => true;

  @override
  bool get hasLeading => leading != null;

  BoxDecoration _resolveStyle(ButtonState buttonState) {
    if (buttonState.isPressed) {
      return pressedPaint ?? defaultPaint;
    } else if (buttonState.isHovered) {
      return hoveredPaint ?? defaultPaint;
    } else if (buttonState.isFocused) {
      return focusedPaint ?? defaultPaint;
    } else {
      return defaultPaint;
    }
  }


  @override
  Widget build(BuildContext context) {
    return MenuItemGestureRecognizer(
      onPressed: onPressed,
      onHover: onHover,
      onFocusChange: onFocusChange,
      builder: (BuildContext context, ButtonState buttonState) {
        return MenuItemSemantics(
          enabled: onPressed != null,
          child: MenuItemStyleWrapper(
            painter: _resolveStyle(buttonState),
            child: MenuItemStructure(
              constraints: constraints,
              leading: leading,
              subtitle: subtitle,
              trailing: trailing,
              leadingWidth: leadingWidth,
              trailingWidth: trailingWidth,
              child: MenuItemTitleStyleWrapper(child: child),
            ),
          ),
        );
      },
    );
  }
}

/// Information necessary for the menu item to be properly handled by it's
/// parent should be clearly established. In this example, the user shouldn't
/// need to reimplement an entire menu for their custom menu item to behave
/// properly. This could also be achieved via an inherited widget, as long as
/// it's not private. What's important is that a user is able to achieve the
/// same behavior in a custom menu item.
///
/// To give an example, while implementing CupertinoMenuAnchor, lines like the
/// following made it so that I had to completely re-implement the entire menu
/// item. Ideally, I could have looked at the "contract" (ignore the nomenclature)
/// and implemented the necessary behavior without having to think about it.
///
/// ```dart
/// void _handleFocusChange() {
///    if (!_focusNode.hasPrimaryFocus) {
///      // Close any child menus of this button's menu.
///      _MenuAnchorState._maybeOf(context)?._closeChildren();
///    }
///  }
/// ```

mixin MenuItemParentContract {
  bool get allowLeadingSeparator => true;
  bool get allowTrailingSeparator => true;
  bool get hasLeading => false;
}

/// Style the widget's container.
class MenuItemStyleWrapper extends StatelessWidget {
  const MenuItemStyleWrapper({
    super.key,
    required this.child,
    required this.painter,
  });
  // final MenuButtonTheme theme
  final Widget child;
  final BoxDecoration painter;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: painter,
      child: IconTheme(
        data: const IconThemeData(color: Colors.blue),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.blue),
          child: child,
        ),
      ),
    );
  }
}

// If a slot has a more-specific style associated with it, a unique wrapper
// widget could be used.
class MenuItemTitleStyleWrapper extends StatelessWidget {
  const MenuItemTitleStyleWrapper({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      child: child,
    );
  }
}

/// A layout wrapper.
class MenuItemStructure extends StatelessWidget {
  /// Creates a [MenuItemStructure]
  const MenuItemStructure({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.subtitle,
    this.shortcut,
    this.constraints = defaultConstraints,
    this.leadingAlignment = defaultLeadingAlignment,
    this.trailingAlignment = defaultTrailingAlignment,
    this.leadingWidth,
    this.trailingWidth,
  });

  // Easily accessible constants for the default values.
  static const double defaultHorizontalWidth = 16.0;
  static const double leadingWidgetWidth = 32.0;
  static const double trailingWidgetWidth = 44.0;

  static const AlignmentDirectional defaultLeadingAlignment =
      AlignmentDirectional(1 / 6, 0.0);
  static const AlignmentDirectional defaultTrailingAlignment =
      AlignmentDirectional(-3 / 11, 0.0);
  static const BoxConstraints defaultConstraints = BoxConstraints(
    maxHeight: 44,
    minHeight: 44,
    maxWidth: 200,
  );

  final Widget? leading;
  final Widget? trailing;
  final double? leadingWidth;
  final double? trailingWidth;
  final AlignmentGeometry leadingAlignment;
  final AlignmentGeometry trailingAlignment;
  final BoxConstraints? constraints;
  final Widget child;
  final Widget? subtitle;
  final Widget? shortcut;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints ?? defaultConstraints,
      child: Row(
        children: <Widget>[
          // The leading and trailing widgets are wrapped in SizedBoxes and
          // then aligned, rather than just padded, because the alignment
          // behavior of the SizedBoxes appears to be more consistent with
          // AutoLayout (iOS).
          SizedBox(
            width: leadingWidth ??
                (leading != null
                    ? leadingWidgetWidth
                    : defaultHorizontalWidth),
            child: leading != null
                ? Align(alignment: leadingAlignment, child: leading)
                : null,
          ),
          Expanded(
            child: subtitle == null
                ?  child
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      child,
                      const SizedBox(height: 1),
                      subtitle!,
                    ],
                  ),
          ),
          if (shortcut != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: shortcut,
            ),
          SizedBox(
            width: trailingWidth ??
                (trailing != null
                    ? trailingWidgetWidth
                    : defaultHorizontalWidth),
            child: trailing != null
                ? Align(alignment: trailingAlignment, child: trailing)
                : null,
          ),
        ],
      ),
    );
  }
}

class MenuItemSemantics extends StatelessWidget {
  const MenuItemSemantics(
      {super.key, required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: false,
      enabled: enabled,
      child: child,
    );
  }
}

/// Handles menu item behavior (e.g. hover, focus, press)
class MenuItemGestureRecognizer extends StatefulWidget {
  const MenuItemGestureRecognizer({
    super.key,
    required this.builder,
    this.onPressed,
    this.onHover,
    this.onFocusChange,
  });

  final Widget Function(BuildContext, ButtonState) builder;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocusChange;
  bool get enabled => onPressed != null;

  @override
  State<MenuItemGestureRecognizer> createState() =>
      _MenuItemGestureRecognizerState();
}

class _MenuItemGestureRecognizerState extends State<MenuItemGestureRecognizer> {
  // Actions could also be parameterized
  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: _simulateTap),
    ButtonActivateIntent:
        CallbackAction<ButtonActivateIntent>(onInvoke: _simulateTap),
  };

  ButtonState _buttonState = const ButtonState(
    isPressed: false,
    isHovered: false,
    isFocused: false,
  );

  @override
  void didUpdateWidget(covariant MenuItemGestureRecognizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onPressed != oldWidget.onPressed) {
      if (!widget.enabled) {
        updateState(isPressed: false, isHovered: false, isFocused: false);
      }
    }
  }

  void updateState({bool? isPressed, bool? isHovered, bool? isFocused}) {
    _buttonState = _buttonState.copyWith(
      isPressed: isPressed ?? _buttonState.isPressed,
      isHovered: isHovered ?? _buttonState.isHovered,
      isFocused: isFocused ?? _buttonState.isFocused,
    );
  }

  void _handleTapDown(TapDownDetails event) {
    updateState(isPressed: true);
    setState(() {});
  }

  void _handleTapUp(TapUpDetails event) {
    updateState(isPressed: false);
    widget.onPressed?.call();
    setState(() {});
  }

  void _handleTapCancel() {
    updateState(isPressed: false);
    setState(() {});
  }

  void _handlePointerExit(PointerExitEvent event) {
    updateState(isHovered: false);
    widget.onHover?.call(false);
    setState(() {});
  }

  void _handlePointerEnter(PointerEnterEvent event) {
    updateState(isHovered: true);
    widget.onHover?.call(true);
    setState(() {});
  }

  void _handleFocusChange(bool value) {
    widget.onFocusChange?.call(value);
    updateState(isFocused: value);
    setState(() {});
  }

  void _simulateTap([Intent? intent]) {}

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.builder(context, _buttonState);
    }
    return MetaData(
      metaData: this,
      child: MouseRegion(
        onEnter: _handlePointerEnter,
        onExit: _handlePointerExit,
        hitTestBehavior: HitTestBehavior.deferToChild,
        child: Actions(
          actions: _actionMap,
          child: Focus(
            canRequestFocus: true,
            skipTraversal: false,
            onFocusChange: _handleFocusChange,
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: widget.builder(context, _buttonState),
            ),
          ),
        ),
      ),
    );
  }
}


@immutable
class ButtonState {
  const ButtonState({
    required this.isPressed,
    required this.isHovered,
    required this.isFocused,
  });

  final bool isPressed;
  final bool isHovered;
  final bool isFocused;

  ButtonState copyWith({
    bool? isPressed,
    bool? isHovered,
    bool? isFocused,
  }) {
    return ButtonState(
      isPressed: isPressed ?? this.isPressed,
      isHovered: isHovered ?? this.isHovered,
      isFocused: isFocused ?? this.isFocused,
    );
  }

  @override
  String toString() =>
      'ButtonState(isPressed: $isPressed, isHovered: $isHovered, isFocused: $isFocused)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ButtonState &&
        other.isPressed == isPressed &&
        other.isHovered == isHovered &&
        other.isFocused == isFocused;
  }

  @override
  int get hashCode =>
      isPressed.hashCode ^ isHovered.hashCode ^ isFocused.hashCode;
}
