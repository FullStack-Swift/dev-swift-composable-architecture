import Combine
import Foundation

open class FutureProvider<P: Publisher>: ProviderProtocol {
  /// Returns a Future of any type
  /// A result from an API call
  
  @Published
  public var value: AsyncPhase<P.Output, P.Failure>
  
  private var cancellable: AnyCancellable?
  
  let makePublisher: () -> P
  
  public let id = UUID()
  
  public convenience init(_ initialState: P) {
    self.init({initialState})
  }
  
  public init(_ initialState: @escaping () -> P) {
    self.value = .suspending
    self.makePublisher = initialState
    refresh()
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
