import SwiftUI
import ComposableArchitecture

struct ContentView: View {

  @Dependency(\.navigationPath) var store

  var body: some View {
    _NavigationView {
      Form {
        Section(header: Text("Getting started")) {
          NavigationLink(
            "Hooks",
            destination: HookCaseStudiesView()
          )
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
