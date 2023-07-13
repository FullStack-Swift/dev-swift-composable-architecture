import Combine

class RiverpodStore {
  
  static let shared = RiverpodStore()
  
  var state = CurrentValueSubject<IdentifiedArrayOf<AnyProvider>, Never>(IdentifiedArrayOf<AnyProvider>())
}
