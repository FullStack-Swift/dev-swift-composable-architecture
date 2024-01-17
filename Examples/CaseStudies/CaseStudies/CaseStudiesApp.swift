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
              try await Task.sleep(seconds: 1/3)
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
