// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A notification sent to indicate that a user has finished swiping.
///
/// Swiping is a term describing the action of moving a finger across the screen.
/// On some interactive elements, such as [CupertinoNestedMenuButton], It can be used to toggle through nested menus.
class SwipeCompletedNotification extends Notification {}

/// Adds continuous swipe support to menus
@immutable
@internal
class CupertinoSwipeListener extends StatefulWidget {
  final bool root;

  /// Creates [CupertinoSwipeListener] to support continuous swipe for menus
  const CupertinoSwipeListener({
    required this.child,
    required this.notifier,
    this.root = false,
    super.key,
  });

  /// Menu widget that requires a continuous swipe
  final Widget child;
  final ValueNotifier<CupertinoSwipeDetails> notifier;

  /// The closest instance of this class that encloses the given
  /// context.
  static ValueNotifier<CupertinoSwipeDetails> notifierOf(BuildContext context) {
    return context
        .findAncestorStateOfType<CupertinoSwipeListenerState>()!
        .notifier;
  }

  @override
  State<CupertinoSwipeListener> createState() => CupertinoSwipeListenerState();
}

class CupertinoSwipeListenerState extends State<CupertinoSwipeListener> {
  ValueNotifier<CupertinoSwipeDetails> get notifier => widget.notifier;

  void _onPanUpdate(DragUpdateDetails details) {
    widget.notifier.value = CupertinoSwipeDetails(
      globalPosition: details.globalPosition,
    );
  }

  void _onPanEnd(DragEndDetails? details) {
    widget.notifier.value = widget.notifier.value.copyWith(complete: true);
  }

  bool _handleCompletedSwipe(_) {
    _onPanEnd(null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SwipeCompletedNotification>(
      onNotification: _handleCompletedSwipe,
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: widget.child,
      ),
    );
  }
}

@immutable
class CupertinoSwipeDetails {
  /// Creates [CupertinoSwipeDetails].
  const CupertinoSwipeDetails({
    required this.globalPosition,
    this.complete = false,
  });

  /// The coordinates of the swipe
  final Offset globalPosition;

  /// Whether the user has finished swiping
  ///
  /// In other words, this indicates that the user's pointer is no longer touching the screen
  final bool complete;

  CupertinoSwipeDetails copyWith({
    Offset? globalPosition,
    bool? complete,
  }) {
    return CupertinoSwipeDetails(
      globalPosition: globalPosition ?? this.globalPosition,
      complete: complete ?? this.complete,
    );
  }
}
