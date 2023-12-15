import Foundation

// MARK: HEffect

/// A @propertyWrapper for useEffect
///
///       @HEffect
///       var event = {
///
///       }
///
/// A call back from hook update.it's will call after view render
///
/// It's similar ``useEffect(_:where:effect:)``
///
@propertyWrapper
public struct HEffect {
  private let updateStrategy: HookUpdateStrategy
  
  public var wrappedValue: (() -> Void)?
  
  public init(updateStrategy: HookUpdateStrategy = .once, wrappedValue: ( () -> Void)? = nil) {
    self.updateStrategy = updateStrategy
    self.wrappedValue = wrappedValue
    useEffect(effect: wrappedValue)
  }
  
  public var projectedValue: Self {
    self
  }
}

// MARK: HLayoutEffect

/// A @propertyWrapper for useEffect
///
///       @HLayoutEffect
///       var event = {
///
///       }
///
/// A call back from hook update. it's will call before view render.
///
/// It's similar ``useEffect(_:where:effect:)``
///
@propertyWrapper
public struct HLayoutEffect {
  private let updateStrategy: HookUpdateStrategy
  
  public var wrappedValue: (() -> Void)?
  
  public init(updateStrategy: HookUpdateStrategy = .once, wrappedValue: ( () -> Void)? = nil) {
    self.updateStrategy = updateStrategy
    self.wrappedValue = wrappedValue
    useLayoutEffect(effect: wrappedValue)
  }
  
  public var projectedValue: Self {
    self
  }
}
