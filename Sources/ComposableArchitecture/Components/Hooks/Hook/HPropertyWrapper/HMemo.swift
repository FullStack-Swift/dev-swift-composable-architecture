import Foundation

// MARK: - HMemo

/// A @propertyWrapper for useMemo
///
///```swift
///
///     @HState var state = 0
///
///     @HMemo(.preserved(by: state))
///     var randomColor = Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
///
///     @HMemo<Color>(.preserved(by: state))
///     var randomColor = {
///       Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
///     }
///
///```
///
/// It's similar ``useMemo(_:)-4ans9`` and ``useMemo(_:)-5fu7z``, but using propertyWrapper instead.

@propertyWrapper
public struct HMemo<Node> {
  
  private let initialNode: () -> Node
  
  private let updateStrategy: HookUpdateStrategy
  
  public init(
    wrappedValue: Node,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    initialNode = { wrappedValue }
    self.updateStrategy = updateStrategy
  }
  
  public init(
    wrappedValue: @escaping () -> Node,
    _ updateStrategy: HookUpdateStrategy = .once
  ) {
    initialNode = wrappedValue
    self.updateStrategy = updateStrategy
  }
  
  public var wrappedValue: Node {
    useMemo(updateStrategy, initialNode)
  }
  
  public var projectedValue: Self {
    self
  }
  
  public var value: Node {
    wrappedValue
  }
}
