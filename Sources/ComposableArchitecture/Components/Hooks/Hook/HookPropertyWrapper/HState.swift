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
  
  private let value: Binding<Node>
  
  internal var _location: AnyLocation<((Node) -> Void)?>? = .init(value: nil)
  
  public init(wrappedValue: @escaping () -> Node) {
    value = useState(wrappedValue())
  }
  
  public init(wrappedValue: Node) {
    value = useState(wrappedValue)
  }
  
  public var wrappedValue: Node {
    get {
      value.wrappedValue
    }
    nonmutating set {
      value.wrappedValue = newValue
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
  public var projectedValue: Binding<Node> {
    value.didChange { newValue in
      if let value = _location?.value {
        value(newValue)
      }
    }
  }
  
  public func send(_ node: Node) {
    value.wrappedValue = node
  }
  
  public func onChange(_ onChange: @escaping (Node) -> Void) -> Self {
    _location?.value = onChange
    return self
  }
}
