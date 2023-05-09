import Foundation

public protocol AsyncActionHandler {
  
  associatedtype ActionType

  func dispatch(_ dispatchedAction: DispatchedAction<ActionType>) async
}

extension AsyncActionHandler {
  /// The func creates an action that excutes some work in the real world
  /// ```swift
  /// store.dispatch(.decrementButtonTapped)
  /// viewStore.dispatch(decrementButtonTapped)
  /// ...
  /// ```
  public func dispatch(_ action: ActionType, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) async {
    await self.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func dispatch(_ action: ActionType, from dispatcher: ActionSource) async {
    await self.dispatch(DispatchedAction(action, dispatcher: dispatcher))
  }
}
