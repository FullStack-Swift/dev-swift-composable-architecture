import Foundation
import Combine
import SwiftUI

/// @Republished is a property wrapper which allows an `ObservableObject` nested
/// within another `ObservableObject` to notify SwiftUI of changes.
///
/// The outer `ObservableObject` should hold the inner one in a var annotated
/// with this property wrapper.
///
/// ```swift
/// @Republished private var state: StateProvider
///
/// > Note: The outer `ObservableObject` will only republish notifications
/// > of inner `ObservableObjects` that it actually accesses.
@propertyWrapper
public final class Republished<Republishing: ObservableObject>
where Republishing.ObjectWillChangePublisher == ObservableObjectPublisher {
  
  private var republished: Republishing
  private var cancellable: AnyCancellable?
  
  public init(wrappedValue republished: Republishing) {
    self.republished = republished
  }
  
  public var wrappedValue: Republishing {
    republished
  }
  
  public var projectedValue: Binding<Republishing> {
    Binding {
      self.republished
    } set: { newValue in
      self.republished = newValue
    }
  }
  
  public static subscript<Instance: ObservableObject>(
    _enclosingInstance instance: Instance,
    wrapped _: KeyPath<Instance, Republishing>,
    storage storageKeyPath: KeyPath<Instance, Republished>
  )
  -> Republishing where Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
    let storage = instance[keyPath: storageKeyPath]
    storage.cancellable = instance.subscribe(publisher: storage.wrappedValue)
    return storage.wrappedValue
  }
}

public extension ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {
  func subscribe<T: ObservableObject>(publisher: T) -> AnyCancellable {
    publisher
      .objectWillChange
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { [weak self] _ in
          DispatchQueue.main.async {
            self?.objectWillChange.send()
          }
        }
      )
  }
}

public struct RiverpodStore {
  
}

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
  
  let makePublisher: () -> P
  
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

open class StateNotifierProvider<P: ProviderProtocol>: ProviderProtocol where P.ObjectWillChangePublisher == ObservableObjectPublisher {
  /// Returns a subclass of StateNotifier
  /// A complex state object that is immutable except through an interface
  @Republished
  public var state: P
  
  public var value: P.Value {
    get {
      state.value
    } set {
      state.value = newValue
    }
  }
  
  public init(_ initialState: P) {
    self._state = Republished(wrappedValue: initialState)
  }
  
  public convenience init(_ initialState: () -> P) {
    self.init(initialState())
  }
}

open class ChangeNotifierProvide<P: ProviderProtocol>: ProviderProtocol where P.ObjectWillChangePublisher == ObservableObjectPublisher {
  /// Returns a subclass of ChangeNotifier
  /// A complex state object that requires mutability

  @Republished
  public var state: P
  
  public var value: P.Value {
    get {
      state.value
    } set {
      state.value = newValue
    }
  }
  
  public init(_ initialState: P) {
    self._state = Republished(wrappedValue: initialState)
  }
  
  public convenience init(_ initialState: () -> P) {
    self.init(initialState())
  }}
