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
  
  public init(wrappedValue: @escaping () -> Node) {
    value = useState(wrappedValue)
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
    value
  }
}
