/**
 * Unit tests for the solver.
 */
library solver_test;

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:drs-lib/engine/engine.dart';


test_NumericType() {
    test('NumericType', () => expect(
        (new BasicValue<num>(NumericType, 1.0)).data,
        equals(1.0)
    ));
}


test_FuzzyType() {
    test('FuzzyType unweighted data', () => expect(
        (new BasicValue<FuzzyType>(FuzzyType, new Fuzzy(0.6))).data.data,
        equals(0.6)
    ));
    test('FuzzyType unweighted weight', () => expect(
        (new BasicValue<FuzzyType>(FuzzyType, new Fuzzy(0.01))).data.weight,
        equals(1.0)
    ));
    test('FuzzyType weighted data', () => expect(
        (new BasicValue<FuzzyType>(FuzzyType, new Fuzzy.withWeight(0.801, 3.1))).data.data,
        equals(0.801)
    ));
    test('FuzzyType weighted weight', () => expect(
        (new BasicValue<FuzzyType>(FuzzyType, new Fuzzy.withWeight(0.801, 3.1))).data.weight,
        equals(3.1)
    ));
    test('FuzzyType range', () => expect(
        () => new Fuzzy(1.2),
        throwsA(new isInstanceOf<DataTypeException>())
    ));
}


all_tests() {
    group('NumericType', test_NumericType);
    test_FuzzyType();
}



main(List<String> args) {
    useVMConfiguration();
    all_tests();
    if (! args.isEmpty) {
        filterTests(args[0]);
    }
}
