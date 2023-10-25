import SwiftUI
import Combine
import SwiftLogger

@_exported import ComposableArchitecture
@_exported import SwiftLogger
@_exported import Json

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
