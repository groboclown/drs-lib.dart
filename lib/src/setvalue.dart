
part of drs.engine.engine;



/**
 * Callback from within a pragma or value to indicate that it changed.  The
 * object that passes this into the value will manage the corresponding value
 * that is updated.
 */
typedef void OnUpdate();



/**
 * Callback from within a pragma or value to indicate that just a subset of
 * keys within a set value were updated.
 */
typedef void OnSetValuesUpdated(Iterable updatedKeys);



/**
 * A lazy loaded [SetValue] for outputting values in a function.  It must be
 * constructed by the caller, and passed in as an input.  The engine must
 * explicitly know when to use these, because it implies a series of highly
 * parallelizable processes.
 */
class DefaultLazySetValue<T> extends LazySetValue<T> {
  final OnUpdate _onUpdate;
  final StreamController<BasicValue<T>> _data;

  DefaultLazySetValue(BasicValueType<T> type, OnUpdate onUpdate) :
  _data = new StreamController<BasicValue<T>>.broadcast(),
  _onUpdate = onUpdate,
  super(type);

  @override
  void add(Value<T> value) {
    assert (value != null);
    _data.add(value);
  }

  @override
  void close() {
    _data.close();
    _onUpdate();
  }

  @override
  Stream<BasicValue<T>> get data => _data.stream;
}


/**
 * Used for data associated long term on a pragma that can change associations
 * over time.
 */
class KeyedSetValue<K, T> extends SetValue<T> {
  final Map<K, BasicValue<T>> _data;
  final OnSetValuesUpdated _callback;

  KeyedSetValue(ValueType<T> type, OnSetValuesUpdated callback) :
  _data = <K, T>{
  },
  _callback = callback,
  super(type);

  @override
  Stream<BasicValue<T>> get data {
    var sc = new StreamController<BasicValue<T>>.broadcast();
    _data.forEach((k, v) => sc.add(v));
    sc.close();
    return sc.stream;
  }


  BasicValue<T> get(K key) {
    return _data[key];
  }


  void setValue(K key, BasicValue<T> value) {
    _data[key] = value;
    _callback([ key ]);
  }


  void setMap(Map<K, BasicValue<T>> values) {
    _data.addAll(values);
    _callback(values.keys);
  }
}
