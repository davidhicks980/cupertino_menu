// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'animated_content_builder.dart';

/// An overlay which animates its content and dismisses it if a click occurs
/// outside of the content bounds.
class SystemOverlay extends StatefulWidget {

  /// Constructor.
  /// [builder] is invoked to build the content of the overlay. [callback]
  /// receives notifications when the overlay is shown or hidden.
  const SystemOverlay(
      { super.key, required AnimatedContentBuilder builder, required ValueChanged<bool> callback})
      : _builder = builder,
        _callback = callback;
  final AnimatedContentBuilder _builder;
  final ValueChanged<bool> _callback;


  @override
  SystemOverlayState createState() => SystemOverlayState();
}

/// Holds the state of a [SystemOverlay].
class SystemOverlayState extends State<SystemOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Sets the visibility of the overlay.
  set visible(bool visible) {
    if (_isShowing == visible) {
      return;
    }
    setState(() {
      _isShowing = visible;
      _isShowing ? _controller.forward() : _controller.reverse();
    });
    widget._callback.call(visible);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) => Offstage(
              // Only display this overlay if it is actually visible.
              offstage: _animation.isDismissed,
              child: child,
            ),
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            // Dismiss the launcher if a click occurs outside of its bounds.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                visible = false;
              },
            ),
            widget._builder(_animation),
          ],
        ),
      );
}
