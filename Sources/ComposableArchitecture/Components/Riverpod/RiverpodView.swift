import SwiftUI
import Combine

@MainActor
public protocol RiverpodView: View {

  associatedtype RiverBody: View
  
  typealias Context = RiverpodContext
  typealias ViewRef = RiverpodObservable
  
  @ViewBuilder
  func build(context: Context, ref: ViewRef) -> RiverBody
  
}

extension RiverpodView {
  public var body:  some View {
    RiverpodScope { store, viewModel in
      build(context: store, ref: viewModel)
    }
  }
}

private struct RiverpodScope<Content: View>: View {
  @StateObject
  private var viewModel = RiverpodObservable()
  
  @Environment(\.self)
  private var environment
  
  private let content: (RiverpodContext, RiverpodObservable) -> Content
  
  init(
    @ViewBuilder _ content: @escaping (RiverpodContext, RiverpodObservable) -> Content
  ) {
    self.content = content
  }
  
  var body: some View {
    content(viewModel.context, viewModel)
  }
}
