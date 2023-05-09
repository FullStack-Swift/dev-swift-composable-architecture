import ComposableArchitecture
import SwiftUI

@main
struct CaseStudiesApp: App {

  let store = Store(
    initialState: Counter.State(),
    reducer: Counter()
  )
    .withMiddleware(CounterMiddleware())
  
  var body: some Scene {
    WindowGroup {
//      RootView(
//        store: Store(
//          initialState: Root.State(),
//          reducer: Root()
//            .signpost()
//            ._printChanges()
//        )
//      )
      CounterDemoView(store: store)
    }
  }
}
