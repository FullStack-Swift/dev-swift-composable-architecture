import Foundation

/// Returns a Stream of any type
/// A stream of results from an API
open class StreamProvider<T>: ProviderProtocol {
  
  public var observable: ObservableListener = ObservableListener()
  
  public var value: AsyncPhase<T, Error>
  
  let operation: () async throws -> T
  
  var task: Task<Void, Never>? {
    didSet {
      oldValue?.cancel()
    }
  }
  
  public let id = UUID()
  
  public convenience init(_ initialState: () -> (() async throws -> T)) {
    self.init(initialState())
  }
  
  public init(_ initialState: @escaping () async throws -> T) {
    self.value = .pending
    self.operation = initialState
    refresh()
  }
  
  public convenience init(_ initialState: (RiverpodContext) -> ( () async throws -> T)) {
    @Dependency(\.riverpodContext) var riverpodContext
    self.init(initialState(riverpodContext))
  }
  
  public func refresh() {
    task = Task { @MainActor in
      let phase: AsyncPhase<T, Error>
      do {
        let output = try await operation()
        phase = .success(output)
      }
      catch {
        phase = .failure(error)
      }
      observable.send()
      if !Task.isCancelled {
        value = phase
      }
    }
  }
}
