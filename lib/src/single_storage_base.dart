/// Generic Base class for storage implementations.
///
/// Allows you to work with a platform-agnostic storage interface.
///
/// Extend this class and provide an implementation at the platform level.
abstract class StorageBase<T> {
  const StorageBase();

  Future<T> get(String key);

  Future<void> set(String key, T value);

  Future<void> remove(String key);

  Future<bool> exists(String key);

  /// Returns the concrete key that will be used on [get], [set], [remove] and [exists].
  /// Returns [key] when no decorators like with [map] have been applied to this storage.
  String location(String key);

  /// Gives access to this storage at a specific key.
  StorageBaseAt<T> at(String key) => _StorageBaseAtImpl(this, key);

  /// Maps this storage to a different location.
  ///
  /// Typically used to specify a more specific location for example by
  /// prepending a specific domain/path. This maps all calls to the new
  /// location.
  ///
  /// Example:
  ///
  ///     .map((String str) => "somewhere/$str");
  ///
  /// Would prepend the string "somewhere/" to all new calls to the StorageBase
  /// methods.
  StorageBase<T> map(String Function(String) m) =>
      _StorageBasePathDecorator(this, m);

  /// Convenience function for
  ///
  ///     map((String str) => "$somewhere$str");
  ///
  StorageBase<T> forDomain(String domain) => map((String str) => "$domain$str");
}

/// Concrete storage at a specific location.
///
/// Same as [StorageBase] but the key is fixed.
abstract class StorageBaseAt<T> {
  Future<T> get();

  Future<void> set(T value);

  Future<void> remove();

  Future<bool> exists();

  String get location;
}

class _StorageBasePathDecorator<T> extends StorageBase<T> {
  final StorageBase<T> _storage;

  final String Function(String key) _keyTransformer;

  const _StorageBasePathDecorator(this._storage, this._keyTransformer);

  @override
  Future<bool> exists(String key) => _storage.exists(_keyTransformer(key));

  @override
  Future<T> get(String key) => _storage.get(_keyTransformer(key));

  @override
  Future<void> remove(String key) => _storage.remove(_keyTransformer(key));

  @override
  Future<void> set(String key, T value) =>
      _storage.set(_keyTransformer(key), value);

  @override
  String location(String key) => _storage.location(_keyTransformer(key));
}

class _StorageBaseAtImpl<T> implements StorageBaseAt<T> {
  final StorageBase<T> _storage;

  final String key;

  const _StorageBaseAtImpl(this._storage, this.key);

  @override
  Future<T> get() => _storage.get(key);

  @override
  Future<void> set(T value) => _storage.set(key, value);

  @override
  Future<void> remove() => _storage.remove(key);

  @override
  Future<bool> exists() => _storage.exists(key);

  @override
  String get location => _storage.location(key);
}
