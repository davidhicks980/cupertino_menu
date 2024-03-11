// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'animated_content_builder.dart';

/// Base class for UI elements behaving as toggles.
class Toggle extends StatefulWidget {

  /// Constructor.
  const Toggle(
      {super.key, required AnimatedContentBuilder builder, required ValueChanged<bool> callback})
      : _builder = builder,
        _callback = callback;

  final AnimatedContentBuilder _builder;
  final ValueChanged<bool> _callback;

  @override
  ToggleState createState() => ToggleState();
}

/// Manages the state of a [Toggle].
class ToggleState extends State<Toggle> with TickerProviderStateMixin {
  bool _toggled = false;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: GestureDetector(
          onTap: () {
            setState(() {
              toggled = !_toggled;
              widget._callback.call(_toggled);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: widget._builder(_animation),
        ),
      );

  /// Sets the toggle state.
  set toggled(bool value) {
    if (value == _toggled) {
      return;
    }
    setState(() {
      _toggled = value;
      _toggled ? _controller.forward() : _controller.reverse();
    });
  }
}
