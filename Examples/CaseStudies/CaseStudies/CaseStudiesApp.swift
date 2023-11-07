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
            .onAppear {
              let a = 1 == "AAAA"
              print(a)
            }
        }
      }
      .observe { snapShot in
        log.info(snapShot)
      }
    }
  }
}
