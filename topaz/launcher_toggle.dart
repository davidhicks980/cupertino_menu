// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'widgets/toggle.dart';

/// A toggle button for the launcher.
class LauncherToggleWidget extends StatelessWidget {

  /// Constructor.
  LauncherToggleWidget({super.key, 
    required GlobalKey<ToggleState> toggleKey,
    required ValueChanged<bool> callback,
  })
      : _toggleKey = toggleKey,
        _callback = callback;
  final ValueChanged<bool> _callback;
  final GlobalKey<ToggleState> _toggleKey;

  final Tween<double> _backgroundOpacityTween =
       Tween<double>(begin: 0.0, end: 0.33);

  @override
  Widget build(BuildContext context) =>  Toggle(
        key: _toggleKey,
        callback: _callback,
        builder: (Animation<double> animation) =>  AspectRatio(
              aspectRatio: 1.0,
              child:  AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) =>
                     CustomPaint(
                      painter:  _Painter(
                        _backgroundOpacityTween.evaluate(animation),
                      ),
                    ),
              ),
            ),
      );
}

class _Painter extends CustomPainter {

 const _Painter(this._backgroundOpacity);
  final double _backgroundOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(8.0, size.shortestSide / 2);
    if (_backgroundOpacity > 0) {
      canvas.drawCircle(
        size.center(Offset.zero),
        min(radius + 8.0, size.shortestSide),
         Paint()..color = Colors.grey.withOpacity(_backgroundOpacity),
      );
    }
    canvas.drawArc(
         Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: radius,
        ),
        0.0,
        2 * pi,
        false,
         Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_Painter oldDelegate) {
    return _backgroundOpacity != oldDelegate._backgroundOpacity;
  }
}
