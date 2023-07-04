import Foundation
import Combine
import SwiftUI

public class Ref {
  
}

let ref = ConsumerViewModel()

public protocol ProviderProtocol: ObservableObject {
  
  associatedtype Value
  
  var value: Value { get set }
}


open class Provider<T>: ProviderProtocol {
  /// Returns any type
  /// A service class / computed property (filtered list)
  
  public var value: T
  
  public init(_ initialState: T) {
    self.value = initialState
  }
  
  public convenience init(_ ref: Ref,_ initialState: () -> T) {
    self.init(initialState())
  }
}

open class StateProvider<T>: ProviderProtocol {
  /// Returns any type
  /// A filter condition / simple state object
  
  @Published public var value: T
  
  public init(_ initialState: T) {
    self.value = initialState
  }
  
  public convenience init(_ initialState: () -> T) {
    self.init(initialState())
  }
}

open class FutureProvider<P: Publisher>: ProviderProtocol {
  /// Returns a Future of any type
  /// A result from an API call
  
  @Published
  public var value: AsyncPhase<P.Output, P.Failure>
  
  private var cancellable: AnyCancellable?
  
  public init(_ initialState: P) {
    self.value = .suspending
    cancellable = initialState.sink { completion in
      switch completion {
        case .finished:
          break
        case .failure(let error):
          self.value = .failure(error)
      }
    } receiveValue: { output in
      self.value = .success(output)
    }
  }
  
  public convenience init(_ initialState: () -> P) {
    self.init(initialState())
  }
}

open class StreamProvider<T>: ProviderProtocol {
  /// Returns a Stream of any type
  /// A stream of results from an API
  
  public var value: AsyncPhase<T, Error>
  
  var task: Task<Void, Never>? {
    didSet {
      oldValue?.cancel()
    }
  }

  public init(_ initialState: @escaping () async throws -> T) {
    self.value = .suspending
    task = Task { @MainActor in
      let phase: AsyncPhase<T, Error>
      do {
        let output = try await initialState()
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

open class StateNotifierProvider<V,S: StateProvider<V>>: ProviderProtocol {
  /// Returns a subclass of StateNotifier
  /// A complex state object that is immutable except through an interface
  @Republished
  public var state: S
  
  public var value: V {
    get {
      state.value
    } set {
      state.value = newValue
    }
  }
  
  public init(_ initialState: S) {
    self._state = Republished(wrappedValue: initialState)
  }
  
  public convenience init(_ initialState: () -> S) {
    self.init(initialState())
  }
}

open class ChangeNotifierProvider<V,S: StateProvider<V>>: ProviderProtocol {
  /// Returns a subclass of ChangeNotifier
  /// A complex state object that requires mutability

  @Republished
  public var state: S
  
  public var value: V {
    get {
      state.value
    } set {
      state.value = newValue
    }
  }
  
  public init(_ initialState: S) {
    self._state = Republished(wrappedValue: initialState)
  }
  
  public convenience init(_ initialState: () -> S) {
    self.init(initialState())
  }}
