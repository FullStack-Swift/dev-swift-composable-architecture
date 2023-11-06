import Combine
import Foundation

/// Returns a Future of any type
/// A result from an API call
open class FutureProvider<P: Publisher>: ProviderProtocol {
  
  public var observable: ObservableListener = ObservableListener()

  public var value: AsyncPhase<P.Output, P.Failure>
  
  private var cancellable: AnyCancellable?
  
  let makePublisher: () -> P
  
  public let id = UUID()
  
  public init(_ initialState: @escaping () -> P) {
    self.value = .pending
    self.makePublisher = initialState
//    refresh()
  }
  
  public convenience init(_ initialState: P) {
    self.init({initialState})
  }
  
  public convenience init(
    _ initialState: @escaping (RiverpodContext) -> P
  ) {
    @Dependency(\.riverpodContext) var riverpodContext
    self.init(initialState(riverpodContext))
  }
  
  open func refresh() {
    cancellable = makePublisher().sink { [weak self] completion in
      switch completion {
        case .finished:
          break
        case .failure(let error):
          self?.observable.send()
          self?.value = .failure(error)
      }
    } receiveValue: { [weak self] output in
      self?.observable.send()
      self?.value = .success(output)
    }
  }
}
