import Foundation
import Combine

// MARK: Combine TypeAlias
public typealias SetCancellables = Set<AnyCancellable>

public typealias ActionSubject<Action> = PassthroughSubject<Action, Never>

public typealias StateSubject<State> = CurrentValueSubject<State, Never>

public typealias ObservableEvent = ActionSubject<()>

///
///```swift
///
///var cancellable = Set<AnyCancellable>()
///
///cancellable.dispose() /// => dispose all element in cancellable
///
///```
///
extension Set where Element: AnyCancellable {
  public func dispose() {
    for item in self {
      item.cancel()
    }
  }
}

// MARK: Combine Extension
extension Publisher where Output == Never, Failure == Never {
  public func start() -> Cancellable {
    return sink(receiveValue: { _ in })
  }
}

extension Publisher where Self.Failure == Never {
  public func assign<Root: AnyObject>(
    to keyPath: WritableKeyPath<Root, Self.Output>,
    weakly object: Root
  ) -> AnyCancellable {
    return self.sink { [weak object] output in
      object?[keyPath: keyPath] = output
    }
  }
}

extension Publisher {
  public func onReceiveValue(
    _ receiveValue: @escaping () -> ()
  ) -> AnyCancellable {
    sink { _ in
    } receiveValue: { _ in
      receiveValue()
    }
  }
  
  public func onCompletion(
    _ receiveCompletion: @escaping () -> ()
  ) -> AnyCancellable {
    sink { _ in
      receiveCompletion()
    } receiveValue: { _ in }
  }
}

extension Publisher {
  public func replaceError(
    replace: @escaping (Failure) -> Self.Output
  ) -> AnyPublisher<Self.Output, Never> {
    return `catch` { error in
      Result.Publisher(replace(error))
    }.eraseToAnyPublisher()
  }
  
  public func ignoreError() -> AnyPublisher<Output, Never> {
    return `catch` { _ in
      Empty()
    }.eraseToAnyPublisher()
  }
  
  public func void() -> AnyPublisher<(), Failure> {
    map { _ in
      return
    }
    .eraseToAnyPublisher()
  }
}

extension AnyPublisher {
  public func bindValue<S: Subject>(
    subject: S
  ) -> AnyCancellable where S.Output == Output?, S.Failure == Failure {
    sink { completion in
      /// don't send completion
      /// subject.send(completion: completion)
    } receiveValue: { ouput in
      subject.send(ouput)
    }
  }
}

public extension AnyPublisher where Failure == Never {
  func start() -> Cancellable {
    return sink(receiveValue: { _ in })
  }
}

extension CurrentValueSubject {
  public func commit(_ block: (inout Output) -> Void) {
    var clone = self.value
    block(&clone)
    self.value = clone
  }
}

// MARK: @propertyWrapper - ActionListener
/// Listtener Action for App.
@propertyWrapper
public struct ActionListener<Action> {
  
  private let viewModel: ViewModel
  
  public init() {
    viewModel = ViewModel()
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
  
  public var objectWillChange: AnyPublisher<Void, Never> {
    viewModel.actionSubject.map{ _ in }.eraseToAnyPublisher()
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

extension ActionListener {
  
  fileprivate final class ViewModel {
    
    fileprivate let actionSubject = ActionSubject<Action>()
    
    fileprivate var cancellables = SetCancellables()
    
    var action: Action?
    
    var observableEvent: AnyPublisher<Void, Never> {
      actionSubject.map { _ in }.eraseToAnyPublisher()
    }
    
    fileprivate init() {
      actionSubject
        .sink {
          self.action = $0
        }
        .store(in: &cancellables)
    }
    
    deinit {
      cancellables.dispose()
    }
    
    fileprivate func send(_ action: Action) {
      actionSubject.send(action)
    }
  }

}

// MARK: @propertyWrapper - StateListener
/// Listener StateChange for State.
@propertyWrapper
public struct StateListener<State> {
  
  private let viewModel: ViewModel
  
  public init(_ initialValue: State) {
    viewModel = ViewModel(initialValue)
  }
  
  public var wrappedValue: State {
    viewModel.stateSubject.value
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

extension StateListener {
  
  fileprivate final class ViewModel {
    
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
}

// MARK: - ObservableListener

/// ```swift
///
/// @ObservableListener
/// var observable
///
/// ```
/// Listerner to updateUI for SwiftUI or UIKit.
///
@propertyWrapper
public struct ObservableListener {
  
  private let viewModel = ViewModel()
  
  public init() {
    
  }
  
  public var wrappedValue: Self {
    self
  }
  
  public var projectedValue: ObservableEvent {
    viewModel.observableEvent
  }
  
  public var publisher: ObservableEvent {
    viewModel.observableEvent
  }
  
  public var objectWillChange: AnyPublisher<Void, Never> {
    viewModel.observableEvent.eraseToAnyPublisher()
  }
  
  public func send() {
    viewModel.send()
  }
  
  public func sink(_ receiveValue: @escaping () -> Void) {
    viewModel.observableEvent.sink(receiveValue: receiveValue)
      .store(in: &viewModel.cancellables)
  }
  
  public func sink(_ receiveValue: @escaping () async -> Void) {
    viewModel.observableEvent.sink { action in
      withTask {
        await receiveValue()
      }
    }
    .store(in: &viewModel.cancellables)
  }
  
  public func sink(_ receiveValue: @escaping () async throws -> Void) {
    viewModel.observableEvent.sink { action in
      withTask {
        try await receiveValue()
      }
    }
    .store(in: &viewModel.cancellables)
  }
  
  public func onAction(_ onAction: @escaping () -> Void) {
    sink(onAction)
  }
  
  public func onAction(_ onAction: @escaping () async -> Void) {
    sink(onAction)
  }
  
  public func onAction(_ onAction: @escaping () async throws -> Void) {
    sink(onAction)
  }
}

extension ObservableListener {
  /// ViewModel
  fileprivate final class ViewModel {
    
    fileprivate let observableEvent = ObservableEvent()
    
    fileprivate var cancellables = SetCancellables()
    
    deinit {
      for cancellable in cancellables {
        cancellable.cancel()
      }
    }
    
    fileprivate func send() {
      observableEvent.send()
    }
  }
}
