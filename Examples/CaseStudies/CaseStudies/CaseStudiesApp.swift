import SwiftUI
import Combine
@_exported import ComposableArchitecture
@_exported import SwiftExt

@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      AtomRoot {
        HookRoot {
          ContentView()
            .onFirstAppear {
              log.debug("App Already")
            }
        }
      }
      .observe { snapShot in
//        log.info(snapShot)
      }
    }
  }
}
