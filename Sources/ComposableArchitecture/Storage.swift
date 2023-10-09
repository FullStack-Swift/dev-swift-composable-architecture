/// A container providing arbitrary storage for extensions of an existing type, designed to obviate
/// the problem of being unable to add stored properties to a type in an extension. Each stored item
/// is keyed by a type conforming to ``StorageKey`` protocol.
public class Storage {
  /// The internal storage area.
  var storage: [ObjectIdentifier: AnyStorageValue]

  /// A container for a stored value and an associated optional `deinit`-like closure.
  struct Value<T>: AnyStorageValue {
    var value: T
  }

  public init(storage: [ObjectIdentifier : AnyStorageValue] = [:]) {
    self.storage = storage
  }

  /// Delete all values from the container.
  public func clear() {
    self.storage = [:]
  }

  /// Read/write access to values via keyed subscript.
  public subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: StorageKey {
    get {
      self.get(Key.self)
    }
    set {
      self.set(Key.self, to: newValue)
    }
  }

  /// Read access to a value via keyed subscript, adding the provided default
  /// value to the storage if the key does not already exist. Similar to
  /// ``Swift/Dictionary/subscript(key:default:)``. The `defaultValue` autoclosure
  /// is evaluated only when the key does not already exist in the container.
  public subscript<Key>(_ key: Key.Type, default defaultValue: @autoclosure () -> Key.Value) -> Key.Value where Key: StorageKey {
    get {
      if let existing = self[key] { return existing }
      let new = defaultValue()
      self.set(Key.self, to: new)
      return new
    }
  }

  /// Test whether the given key exists in the container.
  public func contains<Key>(_ key: Key.Type) -> Bool {
    self.storage.keys.contains(ObjectIdentifier(Key.self))
  }

  /// Get the value of the given key if it exists and is of the proper type.
  public func get<Key>(_ key: Key.Type) -> Key.Value? where Key: StorageKey {
    guard let value = self.storage[ObjectIdentifier(Key.self)] as? Value<Key.Value> else {
      return nil
    }
    return value.value
  }

  /// Set or remove a value for a given key, optionally providing a shutdown closure for the value.
  public func set<Key>(
    _ key: Key.Type,
    to value: Key.Value?
  ) where Key: StorageKey {
    let key = ObjectIdentifier(Key.self)
    if let value = value {
      self.storage[key] = Value(value: value)
    } else if self.storage[key] != nil {
      self.storage[key] = nil
    }
  }
}

/// ``Storage`` uses this protocol internally to generically invoke shutdown closures for arbitrarily-
/// typed key values.
public protocol AnyStorageValue {}

/// A key used to store values in a ``Storage`` must conform to this protocol.
public protocol StorageKey {
  /// The type of the stored value associated with this key type.
  associatedtype Value
  
  var defaultValue: Value {get set}
}

extension DependencyValues {
  
  @DependencyValue
  public var storage: Storage = Storage()
}
