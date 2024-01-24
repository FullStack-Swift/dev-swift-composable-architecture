import Foundation


class RiverpodSubscribe {
  
  var observableId: String
  var watchProvider: any ProviderProtocol
  
  init(observableId: String, watchProvider: any ProviderProtocol) {
    self.observableId = observableId
    self.watchProvider = watchProvider
  }
  
}
