import SwiftUI

/// A view that hosts the state of hooks.
/// All hooks should be called within the evaluation of this view's body.
/// The state of hooks are hosted by this view, and changes in state will cause re-evaluation the body of this view.
/// It is possible to limit the scope of re-evaluation by wrapping the views that use hooks in a `HookScope`.
///
///     struct HookRoot: View {
///         var body: some View {
///             HookRoot {
///                 let count = useState(0)
///
///                 Button("\(count.wrappedValue)") {
///                     count.wrappedValue += 1
///                 }
///             }
///         }
///     }
public struct HookRoot<Content: View>: View {
  private let content: () -> Content
  
  /// Creates a `HookScope` that hosts the state of hooks.
  /// - Parameter content: A content view that uses the hooks.
  public init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }
  
  /// The content and behavior of the hook scoped view.
  public var body: some View {
    if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
      HookScopeBody(content)
    }
    else {
      HookScopeCompatBody(content)
    }
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct HookScopeBody<Content: View>: View {
  @StateObject
  private var hookObservable = HookObservable()
  
  @Environment(\.self)
  private var environment
  
  private let content: () -> Content
  
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }
  
  var body: some View {
    hookObservable.scoped(environment: environment, content)
  }
}

@available(iOS, deprecated: 14.0)
@available(macOS, deprecated: 11.0)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
private struct HookScopeCompatBody<Content: View>: View {
  struct Body: View {
    @ObservedObject
    private var hookObservable: HookObservable
    
    @Environment(\.self)
    private var environment
    
    private let content: () -> Content
    
    init(hookObservable: HookObservable, @ViewBuilder _ content: @escaping () -> Content) {
      self.hookObservable = hookObservable
      self.content = content
    }
    
    var body: some View {
      hookObservable.scoped(environment: environment, content)
    }
  }
  
  @State
  private var hookObservable = HookObservable()
  private let content: () -> Content
  
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }
  
  var body: Body {
    Body(hookObservable: hookObservable, content)
  }
}
