import Foundation

open class StreamProvider<T>: ProviderProtocol {
  /// Returns a Stream of any type
  /// A stream of results from an API
  
  @Published
  public var value: AsyncPhase<T, Error>
  
  let operation: () async throws -> T
  
  var task: Task<Void, Never>? {
    didSet {
      oldValue?.cancel()
    }
  }
  
  public init(_ initialState: @escaping () async throws -> T) {
    self.value = .suspending
    self.operation = initialState
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
      
      if !Task.isCancelled {
        value = phase
      }
    }
  }
}