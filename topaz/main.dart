// Copyright 2017 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart' show Directionality, TextDirection, runApp;

import 'root.dart';

void main() {
  runApp(
     const Directionality(
      textDirection: TextDirection.ltr,
      child:  RootWidget(),
    ),
  );
}
