import Combine

// MARK: - ObservableListener

/// ```swift
///
/// @ObservableListener
/// var observable
///
/// ```
@propertyWrapper
public struct ObservableListener {
  
  private let viewModel = ObservableListenerViewModel()
  
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
  
  public func onAction(_ onAction: @escaping ()  async throws -> Void) {
    sink(onAction)
  }
}

/// ViewModel
fileprivate final class ObservableListenerViewModel {
  
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
