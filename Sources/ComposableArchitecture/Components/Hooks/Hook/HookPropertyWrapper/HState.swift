import SwiftUI

// MARK: - HState

/// A @propertyWrapper for useState
///
///     let count = useState(0)
///
///     @MHState var count = 0
///
/// A binding to the state value.
///
///     let binding = $count
///
/// It's similar @State in swiftUI.
///
/// On the other hand, it's similar ``useState(_:)-3ah9l`` and ``useState(_:)-11lki``.
@propertyWrapper
public struct HState<Node> {
  
  internal let _value: Binding<Node>
  
  public init(wrappedValue: @escaping () -> Node) {
    _value = useState(wrappedValue())
  }
  
  public init(wrappedValue: Node) {
    _value = useState(wrappedValue)
  }
  
  public init(wrappedValue: @escaping () -> Binding<Node>) {
    _value = wrappedValue()
  }
  
  public init(wrappedValue: Binding<Node>) {
    _value = wrappedValue
  }
  
  public var wrappedValue: Node {
    get {
      _value.wrappedValue
    }
    nonmutating set {
      _value.wrappedValue = newValue
    }
  }
  
  /// A binding to the state value.
  ///
  ///     struct PlayerView: HookView {
  ///
  ///         var hookBody: some View {
  ///
  ///           @HState var count = 0
  ///
  ///            Button("\(count)") {
  ///               count += 1
  ///            }
  ///
  ///            Stepper(value: $state) {
  ///             Text(state.description)
  ///            }
  ///     }
  ///
  public var projectedValue: Binding<Node> {
    _value
  }
}


// MARK: - MHState

/// A @propertyWrapper for useState
///
///```swift
///
///     let count = useState(0)
///
///     @HState var count = 0
///
///     @HState<Int> var count = { 0 }
///
///```
/// A binding to the state value.
///
///``HState/value`` and ``HState/binding``
///
///```swift
///
///     let binding = $count.value
///
///     let binding = $count.binding
///
///```
///
/// It's similar @State in swiftUI but it have function ``HState/onChange(_:)`` and ``HState/send(_:)``.
///
/// On the other hand, it's similar ``useState(_:)-3ah9l`` and ``useState(_:)-11lki``.
@propertyWrapper
public struct MHState<Node> {
  
  internal let _value: Binding<Node>
  
  @SRefObject
  internal var _ref: ((Node) -> Void)? = nil
  
  public init(wrappedValue: @escaping () -> Node) {
    _value = useState(wrappedValue())
  }
  
  public init(wrappedValue: Node) {
    _value = useState(wrappedValue)
  }
  
  public init(wrappedValue: @escaping () -> Binding<Node>) {
    _value = wrappedValue()
  }
  
  public init(wrappedValue: Binding<Node>) {
    _value = wrappedValue
  }
  
  public var wrappedValue: Node {
    get {
      _value.wrappedValue
    }
    nonmutating set {
      _value.wrappedValue = newValue
      /// Check and sends value to thẻ subscriber, and onChange perform.
      if let value = _ref {
        value(newValue)
      }
    }
  }
  
  /// A binding to the state value.
  ///
  ///     struct PlayerView: HookView {
  ///
  ///         var hookBody: some View {
  ///           @MHState var count = 0
  ///
  ///            Button("\(count)") {
  ///                count += 1
  ///            }
  ///     }
  ///
  public var projectedValue: Self {
    self
  }
  
  
  public var binding: Binding<Node> {
    value
  }
  
  public var value: Binding<Node> {
    _value.didChange { newValue in
      /// Check and sends value to the subscriber, and onChange perform.
      if let value = _ref {
        value(newValue)
      }
    }
  }
  
  ///  No sends a value to the subscriber, and onChange doesn't perform.
  public func send(_ node: Node) {
    _value.wrappedValue = node
  }
  
  public func onChange(_ onChange: @escaping (Node) -> Void) -> Self {
    _ref = onChange
    return self
  }
}
