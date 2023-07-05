import SwiftUI
import Combine

@MainActor
public protocol ConsumerView: View {

  associatedtype RiverBody: View
  
  typealias Context = RiverpodStore
  typealias ViewRef = ConsumerViewModel
  
  @ViewBuilder
  func build(context: Context, ref: ViewRef) -> RiverBody
  
}

extension ConsumerView {
  public var body:  some View {
    ProviderScope { store, viewModel in
      build(context: store, ref: viewModel)
    }
  }
}

private struct ProviderScope<Content: View>: View {
  @StateObject
  private var viewModel = ConsumerViewModel()
  
  @Environment(\.self)
  private var environment
  
  private let content: (RiverpodStore, ConsumerViewModel) -> Content
  
  init(@ViewBuilder _ content: @escaping (RiverpodStore, ConsumerViewModel) -> Content) {
    self.content = content
  }
  
  var body: some View {
    content(viewModel.rivepodStore, viewModel)
  }
}

public class ConsumerViewModel: ObservableObject {
  
  var items: [any ProviderProtocol] = []
  
  private var cancellables = Set<AnyCancellable>()
  
  @Dependency(\.rivepodStore) var rivepodStore
  
  @discardableResult
  public func watch<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    subscribe(publisher: node)
      .store(in: &cancellables)
    return node.value
  }
  
  @discardableResult
  public func watch<Value, Node: StateNotifierProvider<Value>>(_ node: Node) -> Value.Value {
    subscribe(publisher: node)
      .store(in: &cancellables)
    subscribe(publisher: node.state)
      .store(in: &cancellables)
    return node.value
  }
  
  @discardableResult
  public func binding<Node: ProviderProtocol>(_ node: Node) -> Binding<Node.Value> {
    subscribe(publisher: node)
      .store(in: &cancellables)
    return Binding {
      node.value
    } set: { newValue in
      node.value = newValue
    }

  }
  
  @discardableResult
  public func read<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func set<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func modify<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func refresh<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }

  @discardableResult
  public func reset<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
  
  @discardableResult
  public func pull<Node: ProviderProtocol>(_ node: Node) -> Node.Value {
    return node.value
  }
}
/// ====================================================================================================================

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
  public var body: some View {
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
