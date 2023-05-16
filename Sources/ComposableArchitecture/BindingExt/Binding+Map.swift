import SwiftUI

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
