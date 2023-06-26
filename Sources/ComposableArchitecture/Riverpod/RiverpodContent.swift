import Foundation

protocol ProviderProtocol {
  // Returns any type
}

open class Provider<T>: ProviderProtocol {
  // Returns any type
  // A service class / computed property (filtered list)
  
  let value: T
  
  init(_ value: T) {
    self.value = value
  }
}

open class StateProvider<T>: ProviderProtocol {
  // Returns any type
  // A filter condition / simple state object
  
  let value: T
  
  init(_ value: T) {
    self.value = value
  }
}

open class FutureProvider<T>: ProviderProtocol {
  // Returns a Future of any type
  // A result from an API call
  
  let value: T
  
  init(_ value: T) {
    self.value = value
  }
}

open class StreamProvider<T>: ProviderProtocol {
  // Returns a Stream of any type
  // A stream of results from an API
  
  let value: T
  
  init(_ value: T) {
    self.value = value
  }
}

open class StateNotifierProvider<T>: ProviderProtocol {
  // Returns a subclass of StateNotifier
  // A complex state object that is immutable except through an interface
  let value: T
  
  init(_ value: T) {
    self.value = value
  }
}

open class ChangeNotifierProvider<T>: ProviderProtocol {
  // Returns a subclass of ChangeNotifier
  // A complex state object that requires mutability
  
  let value: T
  
  init(_ value: T) {
    self.value = value
  }
}
