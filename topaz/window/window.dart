// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../model.dart';
import 'model.dart';

/// Signature of window interaction callbacks.
typedef WindowInteractionCallback = void Function();

/// A window container.
class Window extends StatefulWidget {

  /// Constructor.
  const Window(
      {super.key,
      required this.onWindowInteraction,
      this.initialPosition = Offset.zero,
      this.initialSize = Size.zero});
  /// The window's initial position.
  final Offset initialPosition;

  /// The window's initial size.
  final Size initialSize;

  /// Called when the user started interacting with this window.
  final WindowInteractionCallback onWindowInteraction;

  @override
  WindowState createState() => WindowState();
}

/// Holds the state of a Window widget.
class WindowState extends State<Window> {
  /// The currently selected tab.
  TabId? _selectedTabId;

  /// The tab currently being dragged.
  TabId? _draggedTabId;

  /// The window's position.
  late Offset _position;

  /// The window's size.
  late Size _size;

  /// Controls focus on this window.
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _size = widget.initialSize;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// Requests this window to be focused.
  void focus() => FocusScope.of(context).requestFocus(_focusNode);

  /// Called when a new tab was dropped on this window.
  void _onTabDropped(WindowData window, TabId id) {
    if (window.claim(id)) {
      setState(() => _selectedTabId = id);
    }
  }

  /// Registers that some interaction has occurred with the present window.
  void _registerInteraction() {
    widget.onWindowInteraction.call();
    focus();
  }

  /// Constructs the visual representation of a tab.
  Widget _buildTab({required TabData tab, bool? selected}) {
    Widget buildVisual({required bool withSelection}) => Container(
          width: 80.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: withSelection ? const Color(0xff777777) : null,
            border: Border.all(color: tab.color),
          ),
          child: Center(
            child: Text(
              tab.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabId = tab.id;
        });
      },
      child: Draggable<TabId>(
        childWhenDragging: Container(),
        feedback: buildVisual(withSelection: false),
        data: tab.id,
        onDragStarted: () => setState(() {
              _draggedTabId = tab.id;
            }),
        onDraggableCanceled: (_, __) {
          _registerInteraction();
          setState(() {
            _draggedTabId = null;
          });
        },
        onDragCompleted: () => setState(() {
              _draggedTabId = null;
            }),
        child: buildVisual(withSelection: selected!),
      ),
    );
  }

  /// Returns the selected tab, accounting for drag'n'drop operations.
  TabData? _getCurrentSelection(WindowData model) {
    if (!model.has(_selectedTabId)) {
      // Default to the last tab if there's no valid selection.
      _selectedTabId = model.tabs.isNotEmpty ? model.tabs.last.id : null;
    }
    // If the selected tab is currently being dragged, temporarily select
    // another one.
    return _draggedTabId != _selectedTabId
        ? (_selectedTabId != null ? model.find(_selectedTabId!) : null)
        : model.tabs.where((TabData tab) => tab.id != _draggedTabId).lastOrNull;
  }

  /// Handles key events received by this window and interprets chords.
  void _handleKeyEvent(RawKeyEvent event, WindowData model, TabId selectedTab) {
    final bool isDown = event is RawKeyDownEvent;
    final RawKeyEventDataFuchsia data = event.data as RawKeyEventDataFuchsia;
    // Switch the selected tab with Ctrl-(Shift-)Q
    if (!isDown // Trigger on up to avoid repeats.
            &&
            (data.codePoint == 113 || data.codePoint == 81) // q or Q
            &&
            (data.modifiers & 24) != 0 // Ctrl down
        ) {
      setState(() {
        _selectedTabId = model.next(
          id: _selectedTabId!,
          forward: data.codePoint == 113, // Q means shift is down
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) => ScopedModelDescendant<WindowData>(
        builder: (
          BuildContext context,
          Widget child,
          WindowData model,
        ) {
          // Make sure the focus tree is properly updated.
          if (model.tabs.length == 1 && model.tabs[0].id == _draggedTabId) {
            // If the lone tab is being dragged, hide this window.
            return Container();
          }
          final TabData? selectedTab = _getCurrentSelection(model);
          return Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onTapDown: (_) => _registerInteraction(),
              child: RawKeyboardListener(
                focusNode: _focusNode,
                onKey: (RawKeyEvent event) =>
                    _handleKeyEvent(event, model, selectedTab!.id),
                child: RepaintBoundary(
                  child: Container(
                    width: _size.width,
                    height: _size.height,
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: const Color(0xffbcbcbc),
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: kElevationToShadow[12],
                    ),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            GestureDetector(
                              onPanUpdate: (DragUpdateDetails details) {
                                setState(() {
                                  _position += details.delta;
                                });
                              },
                              child: DragTarget<TabId>(
                                builder: (BuildContext context,
                                        List<TabId?> candidateData,
                                        List<dynamic> rejectedData) =>
                                    Container(
                                      height: 44.0,
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      color: candidateData.isEmpty
                                          ? const Color(0x003377bb)
                                          : const Color(0x33111111),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: model.tabs
                                            .map((TabData tab) => _buildTab(
                                                tab: tab,
                                                selected: tab == selectedTab))
                                            .toList(),
                                      ),
                                    ),
                                onWillAcceptWithDetails: (_) {
                                  _registerInteraction();
                                  return true;
                                },
                                onAcceptWithDetails: ( DragTargetDetails<TabId> id) =>
                                    _onTabDropped(model, id.data),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: selectedTab?.color,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0.0,
                          bottom: 0.0,
                          child: GestureDetector(
                            onPanUpdate: (DragUpdateDetails details) {
                              setState(() {
                                _size += details.delta;
                              });
                            },
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              color: const Color(0xffcccccc),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }, child: const SizedBox(),
      );
}
