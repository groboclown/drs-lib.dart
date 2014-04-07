
part of drs.engine.engine;



class StdAttributeId<T> extends AttributeId<T> {
  final String _id;
  final ValueType<T> _type;
  final AttributeJoinCommit _joinCommitsFunction;


  const StdAttributeId(this._id, this._type, this._joinCommitsFunction);

  @override
  String get id => _id;

  @override
  ValueType<T> get type => _type;

  // FIXME use a template [AttributeJoinCommit] when Dart supports it.
  @override
  AttributeJoinCommit get joinCommitsFunction => _joinCommitsFunction;
}


class StdPragmaLink implements PragmaLink {
  final String _id;

  const StdPragmaLink(this._id);

  @override
  String get id => _id;
}


class StdAttributeLink<T> implements AttributeLink<T> {
  final PragmaLink _pragmaLink;
  final AttributeId<T> _id;

  const StdAttributeLink(this._pragmaLink, this._id);


  @override
  PragmaLink get pragmaLink => _pragmaLink;

  @override
  AttributeId<T> get id => _id;
}


// FIXME needs to have a strong connection to the world for communication
// on changes.
class StdPragmaHandle implements PragmaHandle {
  final PragmaHandle _boundTo;
  final PragmaLink _link;
  final World _world;

  const StdPragmaHandle(this._world, this._boundTo, this._link);


  @override
  PragmaHandle get boundTo => _boundTo;

  @override
  PragmaLink get link => _link;

  /**
   * Does the pragma this handle reference exist?
   */
  @override
  Fuzzy get exists => _world.getPragma(this) != null;
}


class StdAttributeHandle<T> implements AttributeHandle<T> {
  final PragmaHandle _boundTo;
  final AttributeLink _link;
  final World _world;

  const StdAttributeHandle(this._world, this._boundTo, this._link);

  @override
  PragmaHandle get boundTo => _boundTo;

  @override
  AttributeLink<T> get link => _link;

  @override
  T get data => _world.getAttributeValue(this);
}
