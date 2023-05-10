import Foundation

public struct DispatchedAction<Action> {
  public let action: Action
  
  public let dispatcher: ActionSource
  
  public init(_ action: Action, dispatcher: ActionSource) {
    self.action = action
    self.dispatcher = dispatcher
  }
}

extension DispatchedAction {
  public func map<NewAction>(
    _ transform: (Action) -> NewAction
  ) -> DispatchedAction<NewAction> {
    DispatchedAction<NewAction>(transform(action), dispatcher: dispatcher)
  }
  
  public func compactMap<NewAction>(
    _ transform: (Action) -> NewAction?
  ) -> DispatchedAction<NewAction>? {
    transform(action).map { DispatchedAction<NewAction>($0, dispatcher: dispatcher) }
  }
}

extension DispatchedAction {
  public init(_ action: Action, file: String = #file, function: String = #function, line: UInt = #line, info: String? = nil) {
    self.init(
      action,
      dispatcher: ActionSource(file: file, function: function, line: line, info: info)
    )
  }
}

extension DispatchedAction: Decodable where Action: Decodable { }

extension DispatchedAction: Encodable where Action: Encodable { }

extension DispatchedAction: Equatable where Action: Equatable { }

extension DispatchedAction: Hashable where Action: Hashable { }
