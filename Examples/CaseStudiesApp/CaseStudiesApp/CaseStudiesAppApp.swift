import SwiftUI
import ComposableArchitecture
import ComposeMacros

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
