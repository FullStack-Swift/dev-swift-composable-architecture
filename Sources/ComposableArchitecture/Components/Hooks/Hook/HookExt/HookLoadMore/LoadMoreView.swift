import SwiftUI

public struct LoadMoreView<
  LoadingContent: View,
  MoreContent: View,
  EndContent: View
>: MView {
  
  var loadmore: (any LoadMoreProtocol)?
  
  let loadingContent: () -> LoadingContent
  let moreContent: () -> MoreContent
  let endContent: () -> EndContent
  
  private var onTap: MCallBack?
  
  public init(
    loadmore: (any LoadMoreProtocol)? = nil,
    loadingContent: @escaping () -> LoadingContent,
    moreContent: @escaping () -> MoreContent,
    endContent: @escaping () -> EndContent
  ) {
    self.loadingContent = loadingContent
    self.moreContent = moreContent
    self.endContent = endContent
    self.loadmore = loadmore
  }
  
  public var anyBody: any View {
    IfLet(loadmore) { loadmore in
      HStack {
        If(loadmore.isLoading) {
          loadingContent()
            .alignment(horizontal: .center)
        } false: {
          Button {
            
          } label: {
            If(loadmore.hasNextPage) {
              moreContent()
            } false: {
              endContent()
            }
          }
          .disabled(!loadmore.hasNextPage)
          .onAppear {
            Task {
              if loadmore.hasNextPage {
                try await loadmore.loadNext()
              }
            }
          }
          .alignment(horizontal: .center)
        }
      }
    }
    .ifLet(onTap) { value, view in
      view.onTap {
        value?()
      }
    }
  }
  
  public func withLoadMore(loadmore: (any LoadMoreProtocol)? = nil) -> Self {
    with {
      $0.loadmore = loadmore
    }
  }
  
  public func onTap(_ onTap: @escaping MCallBack) -> Self {
    with {
      $0.onTap = onTap
    }
  }
}
