import SwiftUI
import ComposableArchitecture

@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      HookScope {
        AtomRoot {
          ContentView()
        }
      }
    }
  }
}
