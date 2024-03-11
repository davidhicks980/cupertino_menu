// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'widgets/toggle.dart';

/// Hosts a collection of status icons.
class StatusTrayWidget extends StatelessWidget {

  /// Constructor.
  StatusTrayWidget({super.key, 
    required GlobalKey<ToggleState> toggleKey,
  required  ValueChanged<bool> callback,
  })
      : _toggleKey = toggleKey,
        _callback = callback;
  final ValueChanged<bool> _callback;
  final GlobalKey<ToggleState> _toggleKey;

  final Tween<double> _backgroundOpacityTween =
      Tween<double>(begin: 0.0, end: 0.33);

  @override
  Widget build(BuildContext context) => Toggle(
        key: _toggleKey,
        callback: _callback,
        builder: (Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: Colors.grey.withOpacity(
                        _backgroundOpacityTween.evaluate(animation)),
                  ),
                  child: child,
                ),
            child: const Center(
              child: Text('3:14'),
            ),
          );
        },
      );
}
