/**
 * Defines the basic data types used by the engine.  This is the public API
 * usable by the user.
 */
library drs.engine.core;

import 'dart:async';
import 'dart:collection';


// ------------------------------------------------------------------------
// Exceptions


/**
 * Top level exception for all drs-lib errors.
 */
class DrsException implements Exception {
  final String msg;

  const DrsException(this.msg);

  @override
  String toString() => msg;
}


/**
 * Thrown when the simulation setup has an incorrect configuration.
 */
class DrsConfigurationException extends DrsException {
  DrsConfigurationException(String message) : super(message);
}


/**
 * Thrown when the execution of an Action or Function performs an illegal
 * operation.
 */
class DrsExecutionException extends DrsException {
  DrsExecutionException(String message) : super(message);
}


/**
 * Indicates an inconsistency between the data value and its assigned-to type.
 */
class DataTypeException extends DrsConfigurationException {
  final _value;

  final ValueType _type;

  get value => _value;

  ValueType get type => _type;

  DataTypeException(var value,
      ValueType type) : _value = value, _type = type,
          super("could not assign [$value] to $type");
}


/**
 * Indicates that a function was not wired to its inputs correctly.
 */
class FunctionConnectionException extends DrsConfigurationException {
  final Function function;

  final List<Value> inputs;

  FunctionConnectionException(Function function, List<Value> inputs) :
    this.function = function,
    this.inputs = inputs,
    super("function ${function.id} expected input types ${function.inputTypes} but encountered ${inputs}");
}


/**
 * Indicates that a function did not follow its contract, and returned a
 * different type than it was supposed to.
 */

class FunctionReturnException extends DrsExecutionException {
  final Function function;

  final List<Value> inputs;

  final Value output;

  FunctionReturnException(Function function, List<Value> inputs,
      Value output) :
    this.function = function,
    this.inputs = inputs,
    this.output = output,
    super("function ${function.id} with inputs ${inputs} should return type ${function.outputType} but returned ${output}");
}


/**
 * A poll on a Set timed out, or was interrupted by an external request.
 * These should always be handled to ensure the errors do not propigate.
 */
class PollInterruptedException extends DrsException {
  final AttributeHandle attribute;

  final SetValue value;

  PollInterruptedException(AttributeHandle attribute, SetValue value) :
    this.attribute = attribute,
    this.value = value,
    super("interruption while waiting on ${attribute} = ${value}");
}



// ------------------------------------------------------------------------
// Non-Trivial Types
//   Additional types beyond the language built-in "num" and "String" types
//   used by the engine typing system.


/**
 * Fuzzy value, or multi-valence value.  The fuzzy value ([data]) is represented
 * as a numeric between
 * 0 and 1, and can be assigned a numeric [weight], which allows the value to
 * be altered during specific calculations, such as averages.  [Fuzzy] value
 * computations must support a variable number of arguments.
 */
class Fuzzy {
  final double data;

  final double weight;


  factory Fuzzy(double data) {
    return new Fuzzy._internal(_argIsFuzzy(data), 1.0);
  }

  factory Fuzzy.withWeight(double data, double weight) {
    return new Fuzzy._internal(_argIsFuzzy(data),
    _argNotNull(weight, FuzzyType));
  }


  const Fuzzy._internal(this.data, this.weight);


  String toString() {
    if (this.weight != 1) {
      return "<${data}|${weight}>";
    }
    else {
      return "<${data}>";
    }
  }


// TODO add group operations to the data type, such as average etc.
}


/**
 * Joins zero or more committed values into a single result.  The committed
 * values may trickle in, so it should avoid using [SetValue#pollContents]
 * where possible to maximize parallel behavior.
 *
 * FIXME when Dart supports the semantics, the signature should use templated
 * [SetValue] and [Value] arguments and return value so that they have the same
 * underlying type.
 */
typedef Value AttributeJoinCommit(Value original, SetValue commited);



/**
 * A simulation-wide unique identifier for an attribute.  All attributes with
 * this ID must share the same qualifications.  The user must use the correct
 * API to create one of these.  The parameterized [T] represents the data
 * type for the corresponding [ValueType] parameter.
 */
abstract class AttributeId<T> {
  String get id;

  ValueType<T> get type;

  /**
   * FIXME use a templated [AttributeJoinCommit] when Dart supports it.
   */
  AttributeJoinCommit get joinCommitsFunction;
}


abstract class PragmaLink {
  String get id;
}


abstract class AttributeLink<T> {
  PragmaLink get pragmaLink;
  AttributeId<T> get id;
}



abstract class PragmaHandle {
  Pragma get boundTo;
  PragmaLink get link;

  PragmaHandle bindToPragma(PragmaLink link);

  AttributeHandle bindToAttribute(AttributeLink link);

  /**
   * Does the pragma this handle reference exist?
   */
  Fuzzy get exists;
}


abstract class AttributeHandle<T> {
  Pragma get boundTo;
  AttributeLink get link;

  T get data;
}



// ------------------------------------------------------------------------
// Value Types

/**
 * The top level definition for the acceptable types in the engine.
 */
abstract class ValueType<T> {
  String get name;

  @override
  String toString() {
    return name;
  }
}


/**
 * Simple value types represented by a Dart type.  There exists a hard-coded
 * set of value types usable by the engine, contained in the list
 * [ALLOWABLE_TYPES].
 */
class BasicValueType<T> implements ValueType<T> {
  final String _name;

  const BasicValueType(this._name);

  @override
  String get name => _name;
}


/**
 * Type representing a set of basic values.  Unlike the BasicValueType,
 * this one directly represents the type contained by the set.  This allows
 * for much easier syntax to represent the Value.
 */
class SetValueType<T> extends ValueType<List<T>> {
  final BasicValueType<T> entriesOf;

  SetValueType(this.entriesOf);

  @override
  String get name => entriesOf.name + "[]";
}



final BasicValueType<String> StringType =
    new BasicValueType<String>("String");

final SetValueType<String> StringSetType =
    new SetValueType<String>(StringType);

final BasicValueType<num> NumericType =
    new BasicValueType<num>("Numeric");

final SetValueType<num> NumericSetType =
    new SetValueType<num>(NumericType);

final BasicValueType<Fuzzy> FuzzyType =
    new BasicValueType<Fuzzy>("Fuzzy");

final SetValueType<Fuzzy> FuzzySetType =
    new SetValueType<Fuzzy>(FuzzyType);

final BasicValueType<AttributeId> AttributeIdType =
    new BasicValueType<AttributeId>("AttributeId");

final SetValueType<AttributeId> AttributeIdSetType =
    new SetValueType<AttributeId>(AttributeIdType);

final BasicValueType<PragmaLink> PragmaLinkType =
    new BasicValueType<PragmaLink>("PragmaLink");

final SetValueType<PragmaLink> PragmaLinkSetType =
    new SetValueType<PragmaLink>(PragmaLinkType);

final BasicValueType<AttributeLink> AttributeLinkType =
    new BasicValueType<AttributeLink>("AttributeLink");

final SetValueType<AttributeLink> AttributeLinkSetType =
    new SetValueType<AttributeLink>(AttributeLinkType);

final BasicValueType<PragmaHandle> PragmaHandleType =
    new BasicValueType<PragmaHandle>("PragmaHandle");

final SetValueType<PragmaHandle> PragmaHandleSetType =
    new SetValueType<PragmaHandle>(PragmaHandleType);

final BasicValueType<AttributeHandle> AttributeHandleType =
    new BasicValueType<AttributeHandle>("AttributeHandle");

final SetValueType<AttributeHandle> AttributeHandleSetType =
    new SetValueType<AttributeHandle>(AttributeHandleType);

final List<ValueType> ALLOWABLE_TYPES = new UnmodifiableListView<ValueType>([
    StringType,
    StringSetType,
    NumericType,
    NumericSetType,
    FuzzyType,
    FuzzySetType,
    AttributeIdType,
    AttributeIdSetType,
    PragmaLinkType,
    PragmaLinkSetType,
    AttributeLinkType,
    AttributeLinkSetType,
    PragmaHandleType,
    PragmaHandleSetType,
    AttributeHandleType,
    AttributeHandleSetType
]);


/**
 * Is this object one of the allowable types?
 */
bool isAllowableType(var obj) {
  if (obj == null) {
    return false;
  }
  for (var x in ALLOWABLE_TYPES) {
    if (obj == x) {
      return true;
    }
  }
  return false;
}



// ------------------------------------------------------------------------
// Value

/**
 * General API access to a value.  Note that there is never a null value,
 * but instead a value with null data, because all values are typed,
 * even nulls.  The public API must not distinguish between hard values
 * and values resulting from a function, and as such all Functions and
 * Actions that access a Value receive a [Value] copy, rather than
 * the actual source of the value.  Discovery of whether the source is
 * a Function or a hard-value is done on the [AttributeHandle] level.
 */
abstract class Value<T> {
  ValueType<T> get type;
}



class BasicValue<T> implements Value<T> {
  final BasicValueType<T> _type;

  final T _data;

  const BasicValue(this._type, this._data);

  @override
  BasicValueType<T> get type => _type;

  T get data => _data;

  @override
  String toString() {
    return "Value<" + type.toString() + ">(" +
    (_data == null ? "<null>" : _data.toString()) + ")";
  }
}


/**
 * Sets may be lazy loaded, so the general API remains abstract and vague
 * to allow for different implementations.  As a result of the lazy load,
 * there is no direct way to discover the size of the set.
 */
abstract class SetValue<T> implements Value<T> {
  final SetValueType<T> _type;

  const SetValue(this._type);

  @override
  SetValueType<T> get type => _type;

  Iterator<T> get iterator => iteratorTimeout(0);

  /**
   * A slightly different method signature for the iterator call.  It can
   * take a numeric representing number of seconds to wait before a timeout,
   * which will cause a [PollInterruptedException] if the list is lazy loaded
   * and does not return a value in a timely manner.
   */
  Iterator<T> iteratorTimeout(num timeoutSeconds);

  /**
   * Return the list when the contents have been fully read.
   */
  List<T> pollContents();
}


/**
 * A simple [SetValue] used for standard user creation of a value.  The
 * parameter type [T] is the underlying data type of the contained [BasicValue].
 */
class ImmutableSetValue<T> extends SetValue<T> {
  List<BasicValue<T>> _data;

  ImmutableSetValue(BasicValueType<T> type, List<T> data) : super(type) {
    List<Value> t = new List<Value>();
    for (var v in data) {
      t.add(new BasicValue<T>(type, v));
    }
    _data = new UnmodifiableListView(t);
  }


  @override
  Iterator<BasicValue<T>> iteratorTimeout(num timeoutSeconds) {
    return _data.iterator;
  }


  @override
  List<BasicValue<T>> pollContents() {
    return _data;
  }
}


/**
 * A lazy loaded [SetValue] for outputting values in a function.  It must be
 * constructed by the caller, and passed in as an input.  The engine must
 * explicitly know when to use these, because it implies a series of highly
 * parallelizable processes.
 */
abstract class LazySetValue<T> extends SetValue<T> {
  LazySetValue(SetValueType<T> type) : super(type);

  void add(Value<T> value);
}


// ------------------------------------------------------------------------
// Function


/**
 * The type for a function that runs over the typed inputs and generates the
 * typed output.
 */
typedef Value FunctionDef(List<Value> inputs);


/**
 * Definition for a fully typed function.  The engine may allow for specialized
 * construction of variations on this.
 */
class Function {
  final String id;

  final ValueType outputType;

  final List<ValueType> inputTypes;

  final FunctionDef _functionDef;

  const Function(this.id, this.outputType, this.inputTypes, this._functionDef);


  /**
   * Validates the input values, executes the function definition, validates
   * the output, and returns the output value.
   */
  Value compute(List<Value> values) {
    _validateInputs(values);
    Value ret = this._functionDef(values);
    _validateOutput(values, ret);
    return ret;
  }


  void _validateInputs(List<Value> values) {
    if (values.length != inputTypes.length) {
      throw new FunctionConnectionException(this, values);
    }
    for (int i = 0; i < values.length; ++i) {
      if (values[i] == null || this.inputTypes[i] != values[i].type) {
        throw new FunctionConnectionException(this, values);
      }
    }
  }


  void _validateOutput(List<Value> values, Value ret) {
    if (ret == null || this.outputType != ret.type) {
      throw new FunctionReturnException(this, values, ret);
    }
  }
}



// ------------------------------------------------------------------------
// Helper Functions


/**
 * Used by const constructors to perform validation that the argument is not
 * null.
 */

_argNotNull(arg, ValueType type) {
  if (arg == null) {
    throw new DataTypeException(arg, type);
  }
  return arg;
}


num _argIsFuzzy(num arg) {
  _argNotNull(arg, FuzzyType);
  if (arg < 0.0 || arg > 1.0) {
    throw new DataTypeException(arg, FuzzyType);
  }
  return arg;
}
