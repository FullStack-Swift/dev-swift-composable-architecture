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
    "https://todolistappproj.herokuapp.com/todos"
  }
}
