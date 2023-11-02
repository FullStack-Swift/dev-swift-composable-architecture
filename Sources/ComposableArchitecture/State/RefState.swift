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
  private var storeValue: RefStateObservableObject<Wrapped>

  public init(wrappedValue value: Wrapped) {
    self.init(wrappedValue: RefStateObservableObject<Wrapped>(wrappedValue: value))
  }

  public init(wrappedValue value: RefStateObservableObject<Wrapped>) {
    self._storeValue = StateObject(wrappedValue: value)
  }

  public var wrappedValue: Wrapped {
    get {
      storeValue.value
    }
    nonmutating set {
      storeValue.value = newValue
    }
  }

  public subscript<Value: Equatable>(
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> Value {
    get {
      storeValue.value[keyPath: keyPath]
    }
    set {
      storeValue.value[keyPath: keyPath] = newValue
    }
  }

  public var projectedValue: Binding<Wrapped> {
    $storeValue.wrappedValue
  }

  private var boxedValue: Wrapped {
    _read { yield self.storeValue.value }
    _modify { yield &self.storeValue.value }
  }

  public var value: Wrapped {
    _read { yield self.storeValue.value }
    _modify { yield &self.storeValue.value }
  }
}

@dynamicMemberLookup
public class RefStateObservableObject<Wrapped>: ObservableObject {

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

  public var boxedValue: Wrapped {
    _read { yield self.wrappedValue }
    _modify { yield &self.wrappedValue }
  }

  public var value: Wrapped {
    _read { yield self.wrappedValue }
    _modify { yield &self.wrappedValue }
  }
}
