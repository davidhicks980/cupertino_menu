// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';


import 'model.dart';
import 'window/model.dart';
import 'window/window.dart';

/// Displays a set of windows.
class WindowPlaygroundWidget extends StatefulWidget {
  const WindowPlaygroundWidget({super.key});

  @override
  _PlaygroundState createState() => _PlaygroundState();
}

class _PlaygroundState extends State<WindowPlaygroundWidget> {
  final WindowsData _windows = WindowsData()..add()..add();
  final Map<WindowId, GlobalKey<WindowState>> _windowKeys =
      <WindowId, GlobalKey<WindowState>>{};
  final FocusScopeNode _focusNode = FocusScopeNode();

  /// Currently highlighted window when paging through windows.
  WindowId? _highlightedWindow;

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleKeyEvent);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    super.dispose();
  }

  /// Interprets key chords.
  void _handleKeyEvent(RawKeyEvent event) {
    final bool isDown = event is RawKeyDownEvent;
    final RawKeyEventDataFuchsia data = event.data as RawKeyEventDataFuchsia;
    // Switch the focused window with Ctrl-(Shift-)A
    if (isDown &&
            (data.logicalKey == LogicalKeyboardKey.keyA || data.codePoint == 65) // a or A
            &&
            (data.modifiers & 24) != 0 // Ctrl down
        ) {
      setState(() {
        _highlightedWindow = _windows.next(
          id: _highlightedWindow ?? _windows.windows.last.id,
          forward: data.codePoint == 65, // A means shift is down
        );
      });
    } else if (!isDown && (data.codePoint == 97 || data.codePoint == 65)) {
      setState(() {
        if (_highlightedWindow != null) {
          _windows.moveToFront(_windows.find(_highlightedWindow!)!);
          _windowKeys[_highlightedWindow]?.currentState?.focus();
          _highlightedWindow = null;
        }
      });
    }
  }

  /// Builds the widget representations of the current windows.
  List<Widget> _buildWindows(
      WindowsData model, double maxWidth, double maxHeight) {
    // Remove keys that are no longer useful.
    final List<WindowId> obsoleteIds = <WindowId>[];
    for (final WindowId id in _windowKeys.keys) {
      if (!model.windows.any((WindowData window) => window.id == id)) {
        obsoleteIds.add(id);
      }
    }
    obsoleteIds.forEach(_windowKeys.remove);

    // Adjust window order if there's a highlighted window.
    final List<WindowData> windows = List<WindowData>.from(model.windows);
    if (_highlightedWindow != null) {
      final WindowData? window = model.find(_highlightedWindow!);
      windows
        ..remove(window)
        ..add(window!);
        }

    return windows
        .map((WindowData window) => ScopedModel<WindowData>(
              model: window,
              child: Window(
                key: _windowKeys.putIfAbsent(
                  window.id,
                  () => GlobalKey<WindowState>(),
                ),
                initialPosition: Offset(maxWidth / 4, maxHeight / 4),
                initialSize: Size(maxWidth / 2, maxHeight / 2),
                onWindowInteraction: () => model.moveToFront(window),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          return Overlay(
            initialEntries: <OverlayEntry>[
              OverlayEntry(
                builder: (BuildContext context) => FocusScope(
                      node: _focusNode,
                      autofocus: true,
                      child: ScopedModel<WindowsData>(
                        model: _windows,
                        child: ScopedModelDescendant<WindowsData>(
                          child: Container(),
                          builder: (
                            BuildContext context,
                            Widget child,
                            WindowsData model,
                          ) =>
                              Stack(
                                children: <Widget>[
                                  DragTarget<TabId>(
                                    builder: (BuildContext context,
                                            List<TabId?> candidateData,
                                            List<dynamic> rejectedData) =>
                                         Container(),
                                    onAcceptWithDetails: ( DragTargetDetails<TabId> id) => model.add(id: id.data),
                                  ), ..._buildWindows(model, width, height)
                                ],
                              ),
                        ),
                      ),
                    ),
              ),
            ],
          );
        },
      );
}
