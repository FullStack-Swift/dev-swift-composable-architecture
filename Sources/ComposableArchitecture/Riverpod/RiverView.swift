import SwiftUI

@MainActor
public protocol RiverView: View {
  // The type of view representing the body of this view that can use river.
  associatedtype RiverBody: View
  
  typealias Context = AtomRecoilContext
  typealias ViewRef = AtomRecoilContext
  
  @ViewBuilder
  func build(context: Context, ref: ViewRef) -> RiverBody
  
}

extension RiverView {
  public var body:  some View {
    HookScope {
      build(context: context, ref: context)
    }
  }
  
  @MainActor
  var context: AtomRecoilContext {
    @RecoilViewContext
    var context
    return context
  }
}
