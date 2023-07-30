import SwiftUI
import ComposableArchitecture

@main
struct CaseStudiesAppApp: App {
  var body: some Scene {
    WindowGroup {
      AtomRoot {
        HookScope {
          ContentView()
        }
      }
    }
  }
}
