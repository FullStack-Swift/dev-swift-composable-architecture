import Combine
import Foundation

@propertyWrapper
open class FutureProvider<P: Publisher>: ProviderProtocol {
  public var wrappedValue: AsyncPhase<P.Output, P.Failure> {
    value
  }
  /// Returns a Future of any type
  /// A result from an API call
  
  @Published
  public var value: AsyncPhase<P.Output, P.Failure>
  
  private var cancellable: AnyCancellable?
  
  let makePublisher: () -> P
  
  public let id = UUID()
  
  public init(_ initialState: @escaping () -> P) {
    self.value = .suspending
    self.makePublisher = initialState
    refresh()
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
          self?.value = .failure(error)
      }
    } receiveValue: { [weak self] output in
      self?.value = .success(output)
    }
  }
}
