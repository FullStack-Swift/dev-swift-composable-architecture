import SwiftUI
@_exported import ComposableArchitecture
@_exported import SwiftExt

@main
struct TheMovieApp: App {
  var body: some Scene {
    WindowGroup {
      AtomRoot {
        TheMovieView()
          .onFirstAppear {
            log.debug("App Already")
          }
      }
    }
  }
}
