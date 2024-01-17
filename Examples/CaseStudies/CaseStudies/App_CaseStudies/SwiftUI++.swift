import ArchitectureExt
import SwiftUI

#if os(iOS)
import NavigationStackBackport
public typealias MNavigationStack = NavigationStackBackport.NavigationStack

#else
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias NavigationStack = NavigationStack
#endif

public typealias MDestination = MNavigationReducer.Destination

extension DependencyValues {
  
  @DependencyValue
  public var navigationPath: StoreOf<MNavigationReducer> = Store(initialState: .init()) {
    MNavigationReducer()
  }
  
  public var pathViewStore: ViewStoreOf<MNavigationReducer> {
    ViewStore(navigationPath)
  }
}

extension View {
  @available(macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @ViewBuilder
  public func mNavigationDestination<D: Hashable, C: View>(
    for data: D.Type,
    @ViewBuilder destination: @escaping (D) -> C
  ) -> some View {
#if os(iOS)
    backport.navigationDestination(for: data, destination: destination)
#else
    navigationDestination(for: data, destination: destination)
#endif
  }
}
@available(macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct MNavigationView<Root: View>: View {
  
  @StateObject
  var viewStore: ViewStoreOf<MNavigationReducer>
  
  let rootView: () -> Root
  
  public init(@ViewBuilder rootView: @escaping () -> Root) {
    @Dependency(\.navigationPath) var store
    self._viewStore = StateObject(wrappedValue: ViewStoreOf<MNavigationReducer>(store))
    self.rootView = rootView
    
  }
  
  public var body: some View {
    MNavigationStack(
      path: viewStore.binding(
        get: {$0.path},
        send: MNavigationReducer.Action.set
      )
    ) {
      rootView()
    }
  }
}

public struct MNavigationReducer: Reducer {
  
  public struct State: BaseState {
    public var path: IdentifiedArrayOf<Destination> = []
  }
  
  public enum Action: Equatable {
    case push(IdentifiedArrayOf<Destination>)
    case set(IdentifiedArrayOf<Destination>)
    case pop
    case popTo(Destination.ID)
    case popToRoot
    case shuffle
    case none
  }
  /// Destination
  public struct Destination: Identifiable, Equatable, Hashable {
    public static func == (lhs: MNavigationReducer.Destination, rhs: MNavigationReducer.Destination) -> Bool {
      return lhs.id == rhs.id && ((lhs.state?.isEqual(rhs.state)) != nil)
    }
    
    public var id: String = UUID().uuidString
    
    public var state: (any Equatable)?
    
    public init(id: String, state: (any Equatable)? = nil) {
      self.id = id
      self.state = state
    }
    
    public init(id: Int, state: (any Equatable)? = nil) {
      self.init(id: String(id), state: state)
    }
    
    public init(id: UUID, state: (any Equatable)? = nil) {
      self.init(id: id.uuidString, state: state)
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        case .set(let stack):
          state.path = stack
        case .push(let stack):
          state.path.append(contentsOf: stack)
        case .pop:
          _ = state.path.popLast()
        case .popTo(let id):
          state.path.remove(id: id)
        case .popToRoot:
          state.path.removeAll()
        case .shuffle:
          state.path.shuffle()
        default:
          break
      }
      return .none
    }
  }
}
