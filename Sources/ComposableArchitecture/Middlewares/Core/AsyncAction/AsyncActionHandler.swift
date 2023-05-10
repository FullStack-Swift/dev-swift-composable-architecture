import Foundation

public protocol AsyncActionHandler {
  
  associatedtype Action

  func dispatch(_ dispatchedAction: DispatchedAction<Action>) async
}

extension AsyncActionHandler {
  /// The func creates an action that excutes some work in the real world
  /// ```swift
  /// store.dispatch(.decrementButtonTapped)
  /// viewStore.dispatch(decrementButtonTapped)
  /// ...
  /// ```
  public func dispatch(_ action: Action, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) async {
    await self.dispatch(action, from: .init(file: file, function: function, line: line, info: info))
  }

  public func dispatch(_ action: Action, from dispatcher: ActionSource) async {
    await self.dispatch(DispatchedAction(action, dispatcher: dispatcher))
  }
}

extension AsyncActionHandler {
  public func contramap<NewAction>(_ transform: @escaping(NewAction) -> Action) -> AsyncAnyActionHandler<NewAction> {
    AsyncAnyActionHandler { dispatchedAction in
      await self.dispatch(dispatchedAction.map(transform))
    }
  }
}
