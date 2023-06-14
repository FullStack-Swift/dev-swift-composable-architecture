import Combine
import SwiftUI
import CustomDump
import Foundation

@propertyWrapper
public struct SharedState<Value>: DynamicProperty {

  @StateObject
  private var viewState: ViewState = ViewState()

  var keyPath: WritableKeyPath<SharedStateReducer.State, Value>

  public init(_ keyPath: WritableKeyPath<SharedStateReducer.State, Value>) {
    self.keyPath = keyPath
  }

  public var projectedValue: Binding<Value> {
    Binding {
      viewState._state.value[keyPath: keyPath]
    } set: { newValue, transition in
      withTransaction(transition) {
        viewState._state.value[keyPath: keyPath] = newValue
      }
    }
  }

  public var wrappedValue: Value {
    get {
      viewState._state.value[keyPath: keyPath]
    }
    nonmutating set {
      viewState._state.value[keyPath: keyPath] = newValue
    }
  }

  public subscript<Subject>(
    dynamicMember keyPath: WritableKeyPath<Value, Subject>
  ) -> SharedState<Subject> {
    get { .init(self.keyPath.appending(path: keyPath)) }
    set { self.wrappedValue[keyPath: keyPath] = newValue.wrappedValue }
  }

  @dynamicMemberLookup
  private final class ViewState: ObservableObject {

    @Dependency(\.sharedStateStore)
    fileprivate var sharedStateStore
    fileprivate let _state: CurrentValueRelay<SharedStateReducer.State>
    fileprivate var viewCancellable: AnyCancellable?
    fileprivate var cancellables = Set<AnyCancellable>()

    init() {
      self._state = CurrentValueRelay(SharedStateReducer.State.shared)
      self.viewCancellable = sharedStateStore.state
        .sink(receiveValue: { [weak objectWillChange = self.objectWillChange, weak _state = self._state] in
          guard let objectWillChange = objectWillChange, let _state = _state else { return }
          objectWillChange.send()
          _state.value = $0
        })
    }

    public subscript<Value>(
      dynamicMember keyPath: WritableKeyPath<SharedStateReducer.State, Value>
    ) -> Value {
      get {
        self._state.value[keyPath: keyPath]
      }
      set {
        self._state.value[keyPath: keyPath] = newValue
      }
    }
  }
}

extension SharedState: Equatable where Value: Equatable {
  public static func == (lhs: SharedState<Value>, rhs: SharedState<Value>) -> Bool {
    return lhs.wrappedValue == rhs.wrappedValue
  }
}

extension SharedState: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(reflecting: self.wrappedValue)
  }
}

extension SharedState: CustomDumpRepresentable {
  public var customDumpValue: Any {
    self.wrappedValue
  }
}

public struct SharedStateReducer: ReducerProtocol {

  public struct State {

    @Dependency(\.sharedStateStore) var sharedStateStore

    public static let shared = State()

    /// The internal storage area.
    var storage: [ObjectIdentifier: AnySharedStorageValue] {
      didSet {
        sharedStateStore.withState({$0 = self})
      }
    }

    /// A container for a stored value and an associated optional `deinit`-like closure.
    struct Value<T>: AnySharedStorageValue {
      var value: T
    }

    public init(storage: [ObjectIdentifier : AnySharedStorageValue] = [:]) {
      self.storage = storage
    }

    /// Delete all values from the container.
    public mutating func clear() {
      self.storage = [:]
    }

    /// Read/write access to values via keyed subscript.
    public subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: SharedStorageKey {
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
    public subscript<Key>(_ key: Key.Type, default defaultValue: @autoclosure () -> Key.Value) -> Key.Value where Key: SharedStorageKey {
      mutating get {
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
    public func get<Key>(_ key: Key.Type) -> Key.Value? where Key: SharedStorageKey {
      guard let value = self.storage[ObjectIdentifier(Key.self)] as? Value<Key.Value> else {
        return nil
      }
      return value.value
    }

    /// Set or remove a value for a given key, optionally providing a shutdown closure for the value.
    public mutating func set<Key>(
      _ key: Key.Type,
      to value: Key.Value?
    ) where Key: SharedStorageKey {
      let key = ObjectIdentifier(Key.self)
      if let value = value {
        self.storage[key] = Value(value: value)
      } else if self.storage[key] != nil {
        self.storage[key] = nil
      }
    }
  }

  public enum Action { }

  public var body: some ReducerProtocolOf<Self> {
    NoneEffectReducer({ state, action in

    })
  }
}

/// ``Storage`` uses this protocol internally to generically invoke shutdown closures for arbitrarily-
/// typed key values.
public protocol AnySharedStorageValue {}

/// A key used to store values in a ``Storage`` must conform to this protocol.
public protocol SharedStorageKey {
  /// The type of the stored value associated with this key type.
  associatedtype Value
}

// MARK: DependencyValues + SharedState (Store, ViewStore, State, State Publisher)
extension DependencyValues {
  /// store
  public var sharedStateStore: StoreOf<SharedStateReducer> {
    self[SharedStateDependencyKey.self]
  }

  /// viewStore
  public var sharedStateViewStore: ViewStoreOf<SharedStateReducer> {
    ViewStoreOf<SharedStateReducer>(sharedStateStore, removeDuplicates: {_, _ in false})
  }

  /// state
  public var sharedState: BoxWrapped<SharedStateReducer.State> {
      BoxWrapped(wrappedValue: sharedStateViewStore.state)
  }

  /// state pulisher
  public var sharedStatePublisher: StorePublisher<SharedStateReducer.State> {
    sharedStateViewStore.publisher
  }
}

// MARK: StorageDependencyKey
struct SharedStateDependencyKey: DependencyKey {
  static var liveValue = Store<SharedStateReducer.State, SharedStateReducer.Action>(
    initialState: SharedStateReducer.State.shared,
    reducer: EmptyReducer()
  )
}

@dynamicMemberLookup
final public class BoxWrapped<Wrapped> {

  var wrappedValue: Wrapped

  public init(wrappedValue: Wrapped) {
    self.wrappedValue = wrappedValue
  }

  public subscript<Value: Equatable>(
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> Value {
    get {
      wrappedValue[keyPath: keyPath]
    }
    set {
      wrappedValue[keyPath: keyPath] = newValue
    }
  }

  public var boxedValue: Wrapped {
    _read { yield self.wrappedValue }
    _modify { yield &self.wrappedValue }
  }

  public var value: Wrapped {
    _read { yield self.wrappedValue }
    _modify { yield &self.wrappedValue }
  }
}
