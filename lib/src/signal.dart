
part of drs.engine.engine;

/**
 * The interfaces that manage the binding of signals.
 */


class StdSignalId implements SignalId {
  final PragmaId _pragma;
  final AttributeId _attribute;
  final SignalAction _action;

  const StdSignalId(this._pragma, this._attribute, this._action);


  @override
  PragmaId get pragma => _pragma;

  @override
  AttributeId get attribute => _attribute;

  SignalAction get action => _action;
}


class SolverAttributeRow {
  final PragmaId pragmaId;
  final AttributeId attributeId;
  dynamic lastValue;
  dynamic nextValue;
  int lastTurnChanged;
  final FunctionInstanceId functionId;
}


class SolverAttributeTable {

}


class SignalTable {

}
