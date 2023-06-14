import SwiftUI

@main
struct TodoListApp: App {

  @Dependency(\.sharedStatePublisher) var sharedStatePublisher

  @State
  fileprivate var isExample: Bool = true

  var body: some Scene {
    WindowGroup {
      if isExample {
//        ExampleView()
        AsyncPhaseView(MRequest {
          RUrl(urlString: "https://api.publicapis.org/categories")
        })
      } else {
        RootView()
          .onReceive(sharedStatePublisher) { value in
            log.info(value.count)
          }
      }
    }
  }
}
