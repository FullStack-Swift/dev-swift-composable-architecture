import SwiftUI
import Combine
import ComposableArchitecture
import SwiftLogger

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
