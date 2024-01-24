import SwiftUI
import Combine

@MainActor
public protocol ConsumerWidget: View {
  /// A Context
  typealias Context = RiverpodContext
  
  /// An Observable
  typealias ViewRef = RiverpodObservable
  
  @ViewBuilder
  func build(context: Context, ref: ViewRef) -> any View
}

extension ConsumerWidget {
  public var body:  some View {
    ConsumerScope { store, viewModel in
      build(context: store, ref: viewModel)
    }
  }
}

private struct ConsumerScope: View {
  @StateObject
  private var viewModel = RiverpodObservable()
  
  @Environment(\.self)
  private var environment
  
  private let content: (RiverpodContext, RiverpodObservable) -> any View
  
  init(
    @ViewBuilder _ content: @escaping (RiverpodContext, RiverpodObservable) -> any View
  ) {
    self.content = content
  }
  
  var body: some View {
    content(viewModel.context, viewModel)
      .onAppear {
        viewModel.onAppear()
      }
      .onDisappear {
        viewModel.onDisappear()
      }
      .onFirstAppear {
        viewModel.onFirstAppear()
      }
      .onLastDisappear {
        viewModel.onLastDisappear()
      }
      .eraseToAnyView()
  }
}
