import SwiftUI

/// A property wrapper type that can read and write a value managed by SwiftUI.
///
///     @RefState private var ref: AnyClass = ...
///
/// DynamicProperty

@dynamicMemberLookup
@propertyWrapper
public struct RefState<Wrapped>: DynamicProperty {

  @StateObject
  private var observable: RefStateObservable<Wrapped>

  public init(wrappedValue value: Wrapped) {
    self.init(wrappedValue: RefStateObservable(wrappedValue: value))
  }

  public init(wrappedValue value: RefStateObservable<Wrapped>) {
    self._observable = StateObject(wrappedValue: value)
  }

  public var wrappedValue: Wrapped {
    get {
      observable.value
    }
    nonmutating set {
      observable.value = newValue
    }
  }

  public subscript<Value: Equatable>(
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> Value {
    get {
      observable.value[keyPath: keyPath]
    }
    set {
      observable.value[keyPath: keyPath] = newValue
    }
  }

  public var projectedValue: Binding<Wrapped> {
    $observable.wrappedValue
  }

  public var value: Wrapped {
    _read { yield self.observable.value }
    _modify { yield &self.observable.value }
  }
}

@dynamicMemberLookup
public class RefStateObservable<Wrapped>: ObservableObject {

  @Published public var wrappedValue: Wrapped

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

  public var projectedValue: Self {
    self
  }
  
  public var value: Wrapped {
    _read { yield self.wrappedValue }
    _modify { yield &self.wrappedValue }
  }
}
