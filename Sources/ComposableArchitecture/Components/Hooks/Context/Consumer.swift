import SwiftUI

public extension HookContext {
  /// A view that consumes the context values that provided by `Provider` through view tree.
  /// If the value is not provided by the `Provider` from upstream of the view tree, the view's update will be asserted.
  struct Consumer<Content: View>: View {
    private let content: (T) -> Content
    
    @Environment(\.self)
    private var environment
    
    /// Creates a `Consumer` that consumes the provided value.
    /// - Parameter content: A content view that be able to use the provided value.
    public init(@ViewBuilder content: @escaping (T) -> Content) {
      self.content = content
    }
    
    /// The content and behavior of the view.
    public var body: some View {
      if let value = environment[HookContext.self] {
        content(value)
      }
      else {
        assertMissingContext()
      }
    }
  }
}

private extension HookContext.Consumer {
  func assertMissingContext() -> some View {
#if DEBUG
    debugAssertionFailure(
            """
            No context value of type \(HookContext.self) found.
            A \(HookContext.self).Provider.init(value:content:) is missing as an ancestor of the consumer.
            
            - SeeAlso: https://reactjs.org/docs/context.html#contextprovider
            """
    )
#endif
    return EmptyView().hidden()
  }
}
