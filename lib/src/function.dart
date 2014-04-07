
part of drs.engine.engine;

class FunctionInstanceId {
  final String _id;

  const FunctionInstanceId(this._id);

  String get id => _id;
}


class AttributeSignal {
  final AttributeId attr;
  final SignalId sig;

  const AttributeSignal(this.attr, this.sig);
}


class FunctionInstance<T> {
  final FunctionInstanceId id;

  final AttributeFunction<T> func;

  final List<AttributeSignal> input;

  T _lastCalcValue;

  T _nextValue;


  factory FunctionInstance(Pragma boundToPragma, AttributeId boundToAttribute,
      AttributeFunction<T> func, Iterable<AttributeId> inputs, World world) {

    func.validateInputs(inputs);

    this.func = func;
    this.id = new FunctionInstanceId(boundToPragma.id.id + "-" +
      boundToAttribute.id);
    this.input = <AttributeSignal>[];

    var that = this;

    SignalAction signal = (SignalId id, World world) {
      that._recalculate(id, world);
    };


// FIXME create calculation function to pass as the signal function,
    // use it as the return data value that this caches, and save off all the
    // bound values.

  }



  const FunctionInstance._(this.id, this.func, this.input);


  void _recalculate(SignalId id, World world) {

  }
}




