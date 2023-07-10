import SwiftUI

/// https://recoiljs.org/
///
/// A view that wrapper around the `HookScope` to use hooks inside with Recoil.
/// The view that is completion from `init` will be encluded with `Context` and enable to use hooks.
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
///Using `RecoilGlobalScope` when you want something update only in scope, with another scope,  it will update when the view re-redener again.
///
///
//@MainActor
//public struct RecoilGlobalScope<Content: View>: View {
//
//  private let content: (RecoilGlobalContext) -> Content
//
//  @RecoilGlobalViewContext
//  var context
//
//  public init(@ViewBuilder _ content: @escaping (RecoilGlobalContext) -> Content) {
//    self.content = content
//  }
//
//  public var body: some View {
//    HookScope {
//      content(context)
//    }
//  }
//}

/// A view that wrapper around the `HookScope` to use hooks inside with Recoil.
/// The view that is completion from `init` will be encluded with `Context` and enable to use hooks.
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
///Using `RecoilLocalScope` when you want something update only in scope and only in scope there.
///
//@MainActor
//public struct RecoilLocalScope<Content: View>: View {
//
//  private let content: (RecoilLocalContext) -> Content
//
//  @RecoilLocalViewContext
//  var context
//
//  public init(@ViewBuilder _ content: @escaping (RecoilLocalContext) -> Content) {
//    self.content = content
//  }
//
//  public var body: some View {
//    HookScope {
//      content(context)
//    }
//  }
//}
