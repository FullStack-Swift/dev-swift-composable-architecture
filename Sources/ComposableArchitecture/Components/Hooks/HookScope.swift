import SwiftUI

/// A view that hosts the state of hooks.
/// All hooks should be called within the evaluation of this view's body.
/// The state of hooks are hosted by this view, and changes in state will cause re-evaluation the body of this view.
/// It is possible to limit the scope of re-evaluation by wrapping the views that use hooks in a `HookScope`.
///
///     struct ContentView: View {
///         var body: some View {
///             HookScope {
///                 let count = useState(0)
///
///                 Button("\(count.wrappedValue)") {
///                     count.wrappedValue += 1
///                 }
///             }
///         }
///     }
public struct HookScope<Content: View>: View {
  private let content: () -> Content
  
  /// Creates a `HookScope` that hosts the state of hooks.
  /// - Parameter content: A content view that uses the hooks.
  public init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }
  
  public init(_ content: Content) {
    self.content = { content }
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
  private var viewModel: ViewModelObservable
  
  @StateObject
  private var hookObservable: HookObservable
  
  @Environment(\.self)
  private var environment
  
  private let content: () -> Content
  
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
    let viewModel = ViewModelObservable()
    let hookObservable = HookObservable()
    viewModel.disposeAll = hookObservable.disposeAll
    _viewModel = StateObject(wrappedValue: viewModel)
    _hookObservable = StateObject(wrappedValue: hookObservable)
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
    private var viewModel: ViewModelObservable
    
    @ObservedObject
    private var hookObservable: HookObservable
    
    @Environment(\.self)
    private var environment
    
    private let content: () -> Content
    
    init(
      viewModel: ViewModelObservable,
      hookObservable: HookObservable,
      @ViewBuilder _ content: @escaping () -> Content
    ) {
      self.viewModel = viewModel
      self.hookObservable = hookObservable
      self.content = content
    }
    
    var body: some View {
      hookObservable.scoped(environment: environment, content)
    }
  }
  
  @State
  private var viewModel = ViewModelObservable()
  
  @State
  private var hookObservable = HookObservable()
  private let content: () -> Content
  
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
    self.viewModel.disposeAll = hookObservable.disposeAll
  }
  
  var body: Body {
    Body(viewModel: viewModel, hookObservable: hookObservable, content)
  }
}
