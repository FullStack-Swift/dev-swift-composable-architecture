import SwiftUI

// MARK: - HState

/// A @propertyWrapper for useState
///
///     let count = useState(0)
///
///     @HState var count = 0
///
/// A binding to the state value.
///
///     let binding = $count
///
/// It's similar @State in swiftUI.


@propertyWrapper
public struct HState<Node> {
  
  internal let _value: Binding<Node>
  
  internal var _location: AnyLocation<((Node) -> Void)?>? = .init(value: nil)
  
  public init(wrappedValue: @escaping () -> Node) {
    _value = useState(wrappedValue())
  }
  
  public init(wrappedValue: Node) {
    _value = useState(wrappedValue)
  }
  
  public var wrappedValue: Node {
    get {
      _value.wrappedValue
    }
    nonmutating set {
      _value.wrappedValue = newValue
      /// Check and sends value to thẻ subscriber, and onChange perform.
      if let value = _location?.value {
        value(newValue)
      }
    }
  }
  
  /// A binding to the state value.
  ///
  ///     struct PlayerView: HookView {
  ///
  ///         var hookBody: some View {
  ///           @HState var count = 0
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
      if let value = _location?.value {
        value(newValue)
      }
    }
  }
  
  ///  No sends a value to the subscriber, and onChange doesn't perform.
  public func send(_ node: Node) {
    _value.wrappedValue = node
  }
  
  public func onChange(_ onChange: @escaping (Node) -> Void) -> Self {
    _location?.value = onChange
    return self
  }
}
