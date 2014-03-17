/**
 * Build script for the library.
 *
 *
 * Part of this file was taken from
 * https://code.google.com/p/dart/source/browse/trunk/dart/samples/build_dart/build.dart
 * which is under this license:
 *    Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
 *    for details. All rights reserved. Use of this source code is governed by a
 *    BSD-style license that can be found in the LICENSE file.
 */

import "package:builder/builder.dart";

bool useMachineInterface = false;

void main(List<String> args) {
  make(Build, args);
}


class Build {
  @target.main('default project')
  void main(Project p) {

  }

  @target('deploy the project to the webapp', depends: ['main'])
  void deploy(Project p) {

  }
}
