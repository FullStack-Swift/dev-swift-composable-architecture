import Combine
import Foundation

class RiverpodStore: Equatable {
  
  /// Description
  /// - Parameters:
  ///   - lhs: lhs description
  ///   - rhs: rhs description
  /// - Returns: description
  static func == (lhs: RiverpodStore, rhs: RiverpodStore) -> Bool {
    lhs.id == rhs.id
  }
  
  let id = UUID()
  private var observableCancellable: AnyCancellable?
  
  static let identity = RiverpodStore()
  
  var state: StateSubject<IdentifiedArrayOf<AnyProvider>>
  
//  @ObservableListener
//  var observable
  
  init() {
    state = StateSubject([])
//    observableCancellable = state.eraseToAnyPublisher()
//      .onReceiveValue(observable.send)
  }
}
