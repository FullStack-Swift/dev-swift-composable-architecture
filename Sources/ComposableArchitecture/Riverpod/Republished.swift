import SwiftUI
import Combine
import Foundation
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
  ) -> Republishing where Instance.ObjectWillChangePublisher == ObservableObjectPublisher {
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
