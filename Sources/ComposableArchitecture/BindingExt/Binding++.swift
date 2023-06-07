import SwiftUI

extension Binding {
  public init<Root>(
    _ root: Root,
    keyPath: ReferenceWritableKeyPath<Root, Value>
  ) {
    self.init {
      root[keyPath: keyPath]
    } set: { newValue in
      root[keyPath: keyPath] = newValue
    }
  }
  
  public init(value: Value) {
    var innerValue = value
    self.init {
      innerValue
    }
    set: {
      innerValue = $0
    }
  }
}

extension Binding {

  /// TextField("", text: $text ?? "default value")
  public static func ?? <T>(lhs: Self, rhs: Value) -> Binding<Value> where Value == T? {
    Binding {
      lhs.wrappedValue ?? rhs
    } set: { newValue in
      lhs.wrappedValue = newValue
    }
    .transaction(lhs.transaction)
  }

  /// TextField("", text: $text ?? "default value")
  public static func ?? <T>(lhs: Self, rhs: T) -> Binding<T> where Value == T? {
    Binding<T> {
      lhs.wrappedValue ?? rhs
    } set: { newValue in
      lhs.wrappedValue = newValue
    }
    .transaction(lhs.transaction)
  }
}

extension Binding {
  public func didSet(effect: @escaping (Value) -> Void) -> Self {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        self.wrappedValue = newValue
        effect(newValue)
      }
    )
    .transaction(transaction)
  }
  
  public func willSet(effect: @escaping (Value) -> Void) -> Self {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        effect(newValue)
        self.wrappedValue = newValue
      }
    )
    .transaction(transaction)
  }
}

extension Binding {
  public func map<NewValue>(
    get: @escaping (Value) -> NewValue,
    set: @escaping (NewValue) -> Value
  ) -> Binding<NewValue> {
    Binding<NewValue>(
      get: { get(wrappedValue) },
      set: { wrappedValue = set($0) }
    )
    .transaction(transaction)
  }
  
  public func map<NewValue>(
    _ keyPath: WritableKeyPath<Value, NewValue>
  ) -> Binding<NewValue> {
    Binding<NewValue>(
      get: { wrappedValue[keyPath: keyPath] },
      set: { wrappedValue[keyPath: keyPath] = $0 }
    )
    .transaction(transaction)
  }
}

extension Binding {
  public func willChange(
    _ handler: @escaping (Value) -> Void
  ) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        handler(newValue)
        self.wrappedValue = newValue
      }
    )
  }

  public func didChange(
    _ handler: @escaping (Value) -> Void
  ) -> Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { newValue in
        self.wrappedValue = newValue
        handler(newValue)
      }
    )
  }
}

public func useBinding<Value>(_ bindings: [Binding<Value?>]) -> Binding<Value?> {
  bindings.reduce(into: .constant(nil)) { result, next in
    result = result.binding(next)
  }
}

extension Binding {
  @discardableResult
  public func binding(_ binding: Binding<Value>) -> Binding<Value> {
    Binding {
      binding.wrappedValue = self.wrappedValue
      return self.wrappedValue
    } set: { newValue, transaction in
      withTransaction(transaction) {
        self.wrappedValue = newValue
        binding.wrappedValue = newValue
      }
    }
  }
}

extension Binding {
  static var none: Binding<Value?> {
    .constant(nil)
  }
}

public func <> <V>(lhs: Binding<V>, rsh: Binding<V>) -> Binding<V> {
  lhs.binding(rsh)
}

@propertyWrapper
struct MBinding<Value> {
  var wrappedValue: Value {
    get { return getValue() }
    nonmutating set { setValue(newValue) }
  }

  private let getValue: () -> Value
  private let setValue: (Value) -> Void

  init(getValue: @escaping () -> Value, setValue: @escaping (Value) -> Void) {
    self.getValue = getValue
    self.setValue = setValue
  }

  var projectedValue: Binding<Value> {
    Binding(get: getValue, set: setValue)
  }
}
