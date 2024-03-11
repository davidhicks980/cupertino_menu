// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';


import 'package:meta/meta.dart';

import '../model.dart';

/// Signature of tab ownership change callbacks.
typedef OwnershipChangeCallback = void Function(TabData data);

/// Representation of tab ids.
class TabId {
  @override
  String toString() => hashCode.toString();
}

/// Data associated with a tab.
class TabData {

  /// Constructor.
  TabData(this.name, this.color) : id = TabId();
  /// The tab's id.
  final TabId id;

  /// The tab's name.
  final String name;

  /// The tab's color.
  final Color color;

  /// Called when the owner of the tab changed.
  OwnershipChangeCallback? onOwnerChanged;
}

/// Signature of the callback to claim a tab owned by a window.
typedef ClaimTabCallback = TabData Function(TabId id);

/// Representation of window ids.
class WindowId {
  @override
  String toString() => hashCode.toString();
}

/// Data associated with a window.
class WindowData extends Model {

  /// Constructor.
  WindowData({required this.claimTab, this.tabs = const <TabData>[]})
      : id = WindowId();
  /// The window's id.
  final WindowId id;

  /// The tabs hosted by the window.
  final List<TabData> tabs;

  /// Called to claim a tab ownerd by another window.
  final ClaimTabCallback claimTab;

  /// Returns true if this window contains the given tab.
  bool has(TabId? id) => tabs.any((TabData tab) => tab.id == id);

  /// Returns the data for the [id] tab, or the result of calling [orElse], or
  /// `null`.
  TabData? find(TabId id, {TabData Function()? orElse}) =>( tabs as List<TabData?>).where(
        (TabData? tab) => tab?.id == id,
      ).firstOrNull ?? orElse?.call();

  /// Attaches the given tab to this window, removing it from its previous
  /// parent window.
  bool claim(TabId id) {
    final TabData? tab = find(id, orElse: () => claimTab(id));
    if (tabs.contains(tab)) {
      tabs.remove(tab);
    }
    tabs.add(tab!);
    notifyListeners();
    return true;
  }

  /// Removes the given tab from this window and returns its data if applicable.
  TabData remove(TabId id) {
    final TabData? result = find(id);
    tabs.remove(result);
    notifyListeners();
      return result!;
  }

  /// Returns the tab adjacent to [id] in the list in the direction specified by
  /// [forward].
  TabId? next({required TabId id, required bool forward}) {
    final int index = List<int>.generate(tabs.length, (int x) => x)
        .firstWhere((int i) => tabs[i].id == id, orElse: () => -1);
    if (index == -1) {
      return null;
    }
    final int nextIndex = (index + (forward ? 1 : -1)) % tabs.length;
    return tabs[nextIndex].id;
  }
}

/// A collection of windows.
class WindowsData extends Model {
  /// The actual windows.
  final List<WindowData> windows = <WindowData>[];

  /// Called by a window to claim a tab owned by another window.
  TabData _claimTab(TabId id) {
    final WindowData? window = windows.where(
      (WindowData window) => window.has(id),
    ).firstOrNull;
    final TabData result = window!.remove(id);
    if (window.tabs.isEmpty) {
      windows.remove(window);
      notifyListeners();
    }
    return result;
  }

  /// Adds a new window, with an optional existing tab.
  void add({TabId? id}) {
    final TabData? tab = id != null ? _claimTab(id) : null;
    windows.add(WindowData(
      tabs: tab != null
          ? <TabData>[tab]
          : <TabData>[
              TabData('Alpha', const Color(0xff008744)),
              TabData('Beta', const Color(0xff0057e7)),
              TabData('Gamma', const Color(0xffd62d20)),
              TabData('Delta', const Color(0xffffa700)),
            ],
      claimTab: _claimTab,
    ));
    notifyListeners();
  }

  /// Moves the given [window] to the front of the pack.
  void moveToFront(WindowData window) {
    if (windows.isEmpty ||
        !windows.contains(window) ||
        windows.last == window) {
      return;
    }
    windows
      ..remove(window)
      ..add(window);
    notifyListeners();
  }

  /// Returns the data for the [id] window, or the result of calling [orElse],
  /// or `null`.
  WindowData? find(WindowId id, {WindowData Function()? orElse}) => windows.where(
        (WindowData window) => window.id == id,
      ).firstOrNull;

  /// Returns the window adjacent to [id] in the list in the direction specified
  /// by [forward].
  WindowId? next({required WindowId id, required bool forward}) {
    final int index = List<int>.generate(windows.length, (int x) => x)
        .firstWhere((int i) => windows[i].id == id, orElse: () => -1);
    if (index == -1) {
      return null;
    }
    final int nextIndex = (index + (forward ? 1 : -1)) % windows.length;
    return windows[nextIndex].id;
  }
}
