import SwiftUI
import Combine

open class BaseObservable: ObservableObject {
  
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  public var cancellables = SetCancellables()
  
  private var numberRefresh: Int = 0
  
  @ObservableListener
  private var observable
  
  public init() {
    observable.sink { [ weak self] in
      guard let self else { return }
      self.numberRefresh += 1
      log.warning("numberRefresh: \(numberRefresh)")
    }
  }
  
  public func willChange() {
    withMainTask {
      self.objectWillChange.send()
      self.observable.send()
    }
  }
  
  public func refresh() {
    withMainAsync {
      self.objectWillChange.send()
      self.observable.send()
    }
  }
}
