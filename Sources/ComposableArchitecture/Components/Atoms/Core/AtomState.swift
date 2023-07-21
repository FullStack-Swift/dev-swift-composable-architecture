@MainActor
internal protocol AtomStateProtocol: AnyObject {
  associatedtype Coordinator
  
  var coordinator: Coordinator { get }
  var transaction: AtomTransaction? { get set }
}

internal final class AtomState<Coordinator>: AtomStateProtocol {
  let coordinator: Coordinator
  var transaction: AtomTransaction?
  
  init(coordinator: Coordinator) {
    self.coordinator = coordinator
  }
}
