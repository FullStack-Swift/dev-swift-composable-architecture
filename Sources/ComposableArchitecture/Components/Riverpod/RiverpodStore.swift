import Combine

class RiverpodStore {
  
  static let identity = RiverpodStore()
  
  var state = CurrentValueSubject<IdentifiedArrayOf<AnyProvider>, Never>(IdentifiedArrayOf<AnyProvider>())
}
