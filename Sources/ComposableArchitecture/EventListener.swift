import Foundation
import Combine

// MARK: - ActionListener
@propertyWrapper
public struct ActionListener<Action> {
  
  private let viewModel = ActionListenerViewModel<Action>()
  
  public init() {
    
  }
  
  public var wrappedValue: Self {
    self
  }
  
  public var projectedValue: ActionSubject<Action> {
    viewModel.actionSubject
  }
  
  /// the publisher ActionListener
  public var publisher: ActionSubject<Action> {
    viewModel.actionSubject
  }
  
  /// send action to IOAction
  /// - Parameter action: the action send to ActionListener
  public func send(_ action: Action) {
    viewModel.send(action)
  }
  
  /// Sink action from send(_ action: Action)
  /// - Parameter receiveValue: callback Action
  public func sink(_ receiveValue: @escaping (Action) -> Void) {
    viewModel.actionSubject.sink(receiveValue: receiveValue)
      .store(in: &viewModel.cancellables)
  }
  
  public func sink(_ receiveValue: @escaping (Action) async throws -> Void) {
    viewModel.actionSubject.sink { action in
      withTask {
        try await receiveValue(action)
      }
    }
    .store(in: &viewModel.cancellables)
  }
  
  /// Sink action from send(_ action: Action)
  /// - Parameter onAction: callback Action
  public func onAction(_ onAction: @escaping (Action) -> Void) {
    sink(onAction)
  }
  
  public func onAction(_ onAction: @escaping (Action)  async throws -> Void) {
    sink(onAction)
  }
}

fileprivate final class ActionListenerViewModel<Action> {
  
  fileprivate let actionSubject = ActionSubject<Action>()
  
  fileprivate var cancellables = SetCancellables()
  
  fileprivate init() {
    
  }
  
  deinit {
    for cancellable in cancellables {
      cancellable.cancel()
    }
  }
  
  fileprivate func send(_ action: Action) {
    actionSubject.send(action)
  }
}

// MARK: - StateListener
@propertyWrapper
public struct StateListener<State> {
  
  private let viewModel: StateListenerViewModel<State>
  
  public init(_ initialValue: State) {
    viewModel = StateListenerViewModel(initialValue)
  }
  
  public var wrappedValue: Self {
    self
  }
  
  public var projectedValue: StateSubject<State> {
    viewModel.stateSubject
  }
  
  /// the publisher State
  public var publisher: StateSubject<State> {
    viewModel.stateSubject
  }
  
  /// send state to StateListener
  /// - Parameter action: the state send to StateListener
  public func send(_ state: State) {
    viewModel.send(state)
  }
  
  /// Sink action from send(_ state: State)
  /// - Parameter receiveValue: callback State
  public func sink(_ receiveValue: @escaping (State) -> Void) {
    viewModel.stateSubject.sink(receiveValue: receiveValue)
      .store(in: &viewModel.cancellables)
  }
  
  /// Sink state from send(_ state: State)
  /// - Parameter onState: callback State
  public func onState(_ onState: @escaping (State) -> Void) {
    sink(onState)
  }
}

fileprivate final class StateListenerViewModel<State> {
  
  fileprivate let stateSubject: StateSubject<State>
  
  fileprivate var cancellables = SetCancellables()
  
  fileprivate init(_ initialValue: State) {
    stateSubject = StateSubject(initialValue)
  }
  
  deinit {
    for cancellable in cancellables {
      cancellable.cancel()
    }
  }
  
  fileprivate func send(_ state: State) {
    stateSubject.send(state)
  }
}
