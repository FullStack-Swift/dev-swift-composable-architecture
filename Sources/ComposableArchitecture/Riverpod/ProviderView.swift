import SwiftUI

@MainActor
public protocol ProviderGlobalView: View {
  // The type of view representing the body of this view that can use river.
  associatedtype RiverBody: View
  
  typealias Context = RecoilGlobalContext
  typealias ViewRef = RecoilGlobalContext
  
  @ViewBuilder
  func build(context: Context, ref: ViewRef) -> RiverBody
  
}

extension ProviderGlobalView {
  public var body:  some View {
    HookScope {
      build(context: context, ref: context)
    }
  }
  
  @MainActor
  var context: RecoilGlobalContext {
    @RecoilGlobalViewContext
    var context
    return context
  }
}

@MainActor
public protocol ProviderLocalView: View {
  // The type of view representing the body of this view that can use river.
  associatedtype RiverBody: View
  
  typealias Context = RecoilLocalContext
  typealias ViewRef = RecoilLocalContext
  
  @ViewBuilder
  func build(context: Context, ref: ViewRef) -> RiverBody
  
}

extension ProviderLocalView {
  public var body:  some View {
    HookScope {
      build(context: context, ref: context)
    }
  }
  
  @MainActor
  var context: RecoilLocalContext {
    @RecoilLocalViewContext
    var context
    return context
  }
}
