import SwiftUI

/// https://recoiljs.org/



/// A view that wrapper around the `HookScope` to use hooks inside with Recoil.
/// The view that is completion from `init` will be encluded with `Context` and e able to use hooks.
///
/// ```swift
///  struct Content: View {
///   var body: some View {
///     RecoilScope { context in
///      // TODO
///     }
///   }
///  }
///
/// ```
public struct RecoilScope<Content: View>: View {

  private let content: (RecoilGlobalContext) -> Content

  @RecoilGlobalViewContext
  var context

  public init(@ViewBuilder _ content: @escaping (RecoilGlobalContext) -> Content) {
    self.content = content
  }

  public var body: some View {
    HookScope {
      content(context)
    }
  }
}

