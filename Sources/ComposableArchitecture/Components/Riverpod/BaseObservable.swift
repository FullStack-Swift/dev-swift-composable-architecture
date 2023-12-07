import SwiftUI
import Combine

open class BaseObservable: ObservableObject {
  
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  public var cancellables = SetCancellables()
  
  private var count: Int = 0
  
  public let id: UUID = UUID()
  
  @ObservableListener
  private var observable
  
  public init() {
    observable.sink { [ weak self] in
      guard let self else { return }
      self.count += 1
      print(Date())
      print("\(objectId): printChanges: \(count) id: \(id)")
    }
  }
  
  public func willChange() {
    Task { @MainActor in
      self.objectWillChange.send()
      self.observable.send()
    }
  }
  
  public func refresh() {
    DispatchQueue.main.async {
      self.objectWillChange.send()
      self.observable.send()
    }
  }
  
  public var objectId: String {
    ObjectIdentifier(self).debugDescription
  }
}
