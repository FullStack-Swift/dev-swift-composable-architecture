import SwiftUI
import ComposableArchitecture

@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      HookRoot {
        AtomRoot {
          ContentView()
        }
      }
    }
  }
}
