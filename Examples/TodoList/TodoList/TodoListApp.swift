import SwiftUI

@main
struct TodoListApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

public extension DependencyValues {
  var urlString: String {
    "http://0.0.0.0:8080/todos"
  }
}
