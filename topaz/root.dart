// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';


import 'launcher.dart';
import 'launcher_toggle.dart';
import 'status_panel.dart';
import 'status_tray.dart';
import 'widgets/system_overlay.dart';
import 'widgets/toggle.dart';
import 'window_playground.dart';

/// Base widget of the session shell.
class BaseWidget extends StatefulWidget {
  const BaseWidget({super.key});

  @override
  _RootState createState() =>  _RootState();
}

class _RootState extends State<BaseWidget> with TickerProviderStateMixin {
  final GlobalKey<ToggleState> _launcherToggleKey =
       GlobalKey<ToggleState>();
  final GlobalKey<SystemOverlayState> _launcherOverlayKey =
       GlobalKey<SystemOverlayState>();
  final GlobalKey<ToggleState> _statusToggleKey =  GlobalKey<ToggleState>();
  final GlobalKey<SystemOverlayState> _statusOverlayKey =
       GlobalKey<SystemOverlayState>();

  final Tween<double> _overlayScaleTween =
       Tween<double>(begin: 0.9, end: 1.0);
  final Tween<double> _overlayOpacityTween =
       Tween<double>(begin: 0.0, end: 1.0);

  @override
  Widget build(BuildContext context) {
    return  Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        // 1 - Desktop background image.
         Image.asset(
          'packages/capybara_session_shell/res/background.jpg',
          fit: BoxFit.cover,
        ),

        // 2 - The space where windows live.
         const WindowPlaygroundWidget(),

        // 3 - Launcher panel.
         SystemOverlay(
          key: _launcherOverlayKey,
          builder: (Animation<double> animation) =>  Center(
                child:  AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) =>
                       FadeTransition(
                        opacity: _overlayOpacityTween.animate(animation),
                        child:  ScaleTransition(
                          scale: _overlayScaleTween.animate(animation),
                          child: child,
                        ),
                      ),
                  child:  Launcher(),
                ),
              ),
          callback: (bool visible) {
            _launcherToggleKey.currentState?.toggled = visible;
          },
        ),

        // 4 - Status panel.
         SystemOverlay(
          key: _statusOverlayKey,
          builder: (Animation<double> animation) =>  Positioned(
                right: 0.0,
                bottom: 48.0,
                child:  AnimatedBuilder(
                  animation: animation,
                  builder: (BuildContext context, Widget? child) =>
                       FadeTransition(
                        opacity: _overlayOpacityTween.animate(animation),
                        child:  ScaleTransition(
                          scale: _overlayScaleTween.animate(animation),
                          alignment: FractionalOffset.bottomRight,
                          child: child,
                        ),
                      ),
                  child:  StatusPanel(),
                ),
              ),
          callback: (bool visible) {
            _statusToggleKey.currentState?.toggled = visible;
          },
        ),

        // 5 - The bottom bar.
         Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child:  GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hideOverlays,
            child:  Container(
              height: 48.0,
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Colors.black87,
              ),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                   LauncherToggleWidget(
                    toggleKey: _launcherToggleKey,
                    callback: (bool toggled) => _setOverlayVisibility(
                        overlay: _launcherOverlayKey, visible: toggled),
                  ),
                   StatusTrayWidget(
                    toggleKey: _statusToggleKey,
                    callback: (bool toggled) => _setOverlayVisibility(
                        overlay: _statusOverlayKey, visible: toggled),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Hides all overlays except [except] if applicable.
  void _hideOverlays({GlobalKey<SystemOverlayState>? except}) {
    for (final GlobalKey<SystemOverlayState> overlay
        in <GlobalKey<SystemOverlayState>>[
      _launcherOverlayKey,
      _statusOverlayKey,
    ].where((GlobalKey<SystemOverlayState> overlay) => overlay != except)) {
      overlay.currentState?.visible = false;
    }
  }

  /// Sets the given [overlay]'s visibility to [visible].
  /// When showing an overlay, this also hides every other overlay.
  void _setOverlayVisibility({
    required GlobalKey<SystemOverlayState> overlay,
    required bool visible,
  }) {
    if (visible) {
      _hideOverlays(except: overlay);
    }
    overlay.currentState?.visible = visible;
  }
}
