import Combine

// MARK: Combine
public typealias SetCancellables = Set<AnyCancellable>

public typealias ActionSubject<Action> = PassthroughSubject<Action, Never>

public typealias StateSubject<State> = CurrentValueSubject<State, Never>

public typealias ObservableEvent = PassthroughSubject<(), Never>

extension Set where Element: AnyCancellable {
  public func dispose() {
    for item in self {
      item.cancel()
    }
  }
}

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
  public func onReceiveValue(_ receiveValue: @escaping () -> ()) -> AnyCancellable {
    sink { completion in }
  receiveValue: { _ in
    receiveValue()
  }
  }
  
  public func onCompletion(_ receiveCompletion: @escaping () -> ()) -> AnyCancellable {
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

// MARK: @propertyWrapper - ValueSubject for CurrentValueSubject in Combine.
@propertyWrapper
public struct ValueSubject<Value> {

  private let cvs: CurrentValueSubject<Value, any Error>

  public init(wrappedValue: Value) {
    cvs = CurrentValueSubject(wrappedValue)
  }

  public var wrappedValue: Value {
    get {
      cvs.value
    }
    set {
      cvs.value = newValue
    }
  }
}

// MARK: @propertyWrapper - ActionListener
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

fileprivate final class ActionListenerViewModel<Action> {
  
  fileprivate let actionSubject = ActionSubject<Action>()
  
  fileprivate var cancellables = SetCancellables()
  
  var observableEvent: AnyPublisher<Void, Never> {
    actionSubject.map { _ in }.eraseToAnyPublisher()
  }
  
  fileprivate init() {
    
  }
  
  deinit {
    cancellables.dispose()
  }
  
  fileprivate func send(_ action: Action) {
    actionSubject.send(action)
  }
}

// MARK: @propertyWrapper - StateListener
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

open class ViewModelObservable: ObservableObject {
  
  open var disposeAll: (() -> ())?
  
  open var objectId: String {
    ObjectIdentifier(self).debugDescription
  }
  
  public init() {
    
  }
  
  deinit {
    let clone = disposeAll
    disposeAll = nil
    Task { @MainActor in
      try await Task.sleep(seconds: 0.03)
      clone?()
    }
  }
}
