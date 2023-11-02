import SwiftUI
import Combine

@_exported import ComposableArchitecture


@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      AtomRoot {
        HookRoot {
          ContentView()
        }
      }
      .observe { snapShot in
        log.info(snapShot)
      }
    }
  }
}
