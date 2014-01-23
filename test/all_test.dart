/**
 * Runs all the tests.  This expects all test files to conform to the
 * standard boilerplate "main" and "all_tests" functions.
 */
library all_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'solver_test.dart' as solver_test;


all_tests() {
  group('solver_test.dart', solver_test.all_tests);
}


main(List<String> args) {
  useVMConfiguration();
  all_tests();
  if (!args.isEmpty) {
    filterTests(args[0]);
  }
}
