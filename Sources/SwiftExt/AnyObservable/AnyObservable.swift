import SwiftUI
import Combine

// MARK: DisposeObservable
open class DisposeObservable: ObservableObject {
  
  open var disposeAll: (() -> ())?
  
  open var objectId: String {
    ObjectIdentifier(self).debugDescription
  }
  
  public init() {
    
  }
  
  deinit {
    let clone = disposeAll
    disposeAll = nil
    Task { @MainActor in
      try await Task.sleep(seconds: 0.03)
      clone?()
    }
  }
}

  // MARK: MVVMObservable
open class MVVMObservable: ObservableObject {
  
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  public var cancellables = SetCancellables()
  
  @ObservableListener
  public var observable
  
  public let id: UUID = UUID()
  
  public init() {
    observable.publisher
      .sink(receiveValue: objectWillChange.send)
      .store(in: &cancellables)
  }
}

// MARK: BaseObservable
open class BaseObservable: ObservableObject {
  
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  public var cancellables = SetCancellables()
  
  private var count: Int = 0
  
  public let id: UUID = UUID()
  
  @ObservableListener
  private var observable
  
  public init() {
    objectWillChange
      .eraseToAnyPublisher()
      .sink(receiveValue: observable.send)
      .store(in: &cancellables)
    observable.sink { [ weak self] in
      guard let self else { return }
      self.count += 1
      print(Date())
      print("\(objectId): printChanges: \(count) id: \(id)")
    }
  }
  
  open func willChange() {
    Task { @MainActor in
      self.objectWillChange.send()
    }
  }
  
  open func refresh() {
    DispatchQueue.main.async {
      self.objectWillChange.send()
    }
  }
  
  public var objectId: String {
    ObjectIdentifier(self).debugDescription
  }
}
