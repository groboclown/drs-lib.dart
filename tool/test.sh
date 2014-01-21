#!/bin/bash

cd $(dirname $0)/..
dartanalyzer --fatal-warnings --fatal-type-errors $(find lib -name '*.dart')
dart --enable-type-checks --enable-asserts test/all_test.dart $@

