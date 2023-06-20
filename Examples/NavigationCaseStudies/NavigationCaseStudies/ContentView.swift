import SwiftUI
import ComposableArchitecture

struct ContentView: View {

  @Dependency(\.navigationPath)
  private var navigationPath

  var body: some View {
    _NavigationView {
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundColor(.accentColor)
        Text("Hello, world!")
      }
      .padding()
      .onTapGesture {
        navigationPath.commit {
          $0.path.append(.init(id:"Test"))
        }
      }
      ._navigationDestination(for: _Destination.self) { destination in
        switch destination.id {
          case "Test":
            Text("Test Demo")
          default:
            Text("Empty")
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
