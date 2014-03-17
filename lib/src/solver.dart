
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

  // FIXME needs OnUpdate object


  final StreamController<BasicValue<T>> _data;

  DefaultLazySetValue(BasicValueType<T> type) :
      _data = new StreamController<T>.broadcast(),
      super(type);

  @override
  void add(Value<T> value) {
    assert (value != null);
    _data.add(value);
  }

  @override
  void close() {
    _data.close();
  }

  @override
  Stream<BasicValue<T>> get data => _data.stream;
}


/**
 * Used for data associated long term on a pragma that can change associations
 * over time.
 */
class KeyedSetValue<K, T> extends SetValue<T> {
  final Map<K, T> _data;
  final OnSetValuesUpdated _callback;

  KeyedSetValue(ValueType<T> type, OnSetValuesUpdated callback) :
      _data = <K, T>{},
      _callback = callback,
      super(type);

  @override
  Stream<BasicValue<T>> get data;

}


//class
