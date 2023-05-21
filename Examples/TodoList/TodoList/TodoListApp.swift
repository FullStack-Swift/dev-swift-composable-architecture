import SwiftUI

@main
struct TodoListApp: App {

  @Dependency(\.sharedStatePublisher) var sharedStatePublisher

  var body: some Scene {
    WindowGroup {
      RootView()
//        .onReceive(sharedStatePublisher) { value in
//          log.info(value.count)
//        }
    }
  }
}
