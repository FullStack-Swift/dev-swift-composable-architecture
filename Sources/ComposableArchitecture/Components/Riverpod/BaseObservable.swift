import SwiftUI
import Combine

open class BaseObservable: ObservableObject {
  
  public private(set) lazy var objectWillChange = ObservableObjectPublisher()
  
  public var cancellables = Set<AnyCancellable>()
  
  public init() {
    
  }
  
  public func willChange() {
    withMainTask {
      self.objectWillChange.send()
    }
  }
  
  public func refresh() {
    withMainAsync {
      self.objectWillChange.send()
    }
  }
}
