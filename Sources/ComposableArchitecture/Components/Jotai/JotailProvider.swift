import Foundation
import SwiftUI

/// A type of context that to identify the context values.
public enum JotailContext<T>: EnvironmentKey {
  ///  The default value for the context.
  public static var defaultValue: T? { nil }
}

extension JotailContext {
  /// A view that provides the context values through view tree.
  struct JotailProvider<Content: View>: View {
    private let value: T
    private let content: () -> Content
    
    @Environment(\.self)
    private var environment
    
    /// Creates a `Provider` that provides the passed value.
    /// - Parameters:
    ///   - value: A value that to be provided to child views.
    ///   - content: A content view where the passed value will be provided.
    public init(value: T, @ViewBuilder content: @escaping () -> Content) {
      self.value = value
      self.content = content
    }
    
    var contextEnvironments: EnvironmentValues {
      var environment = self.environment
      environment[JotailContext.self] = value
      return environment
    }
    
    /// The content and behavior of the view.
    public var body: some View {
      AtomScope {
        HookScope(content).environment(\.self, contextEnvironments)
      }
    }
  }

}

