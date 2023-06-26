import SwiftUI
import Combine

public protocol RecoilProtocol {

  associatedtype Context: AtomWatchableContext

  var context: Context { get }
}

extension RecoilProtocol {
  // MARK: useRecoilState
  public func useRecoilState<Node: StateAtom>(
    _ initialState: Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture.useRecoilState(context: context, initialState)
  }

  // MARK: useRecoilState
  public func useRecoilState<Node: StateAtom>(
    _ initialState: @escaping() -> Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture.useRecoilState(context: context, initialState)
  }

  // MARK: useRecoilValue
  public func useRecoilValue<Node: ValueAtom>(
    _ initialState: Node
  ) -> Node.Loader.Value {
    ComposableArchitecture.useRecoilValue(context: context, initialState)
  }

  // MARK: useRecoilValue
  public func useRecoilValue<Node: ValueAtom>(
    _ initialState: @escaping() -> Node
  ) -> Node.Loader.Value {
    ComposableArchitecture.useRecoilValue(context: context, initialState)
  }

  // MARK: useRecoilPublihser
  public func useRecoilPublisher<Node: PublisherAtom>(
    _ initialState: Node
  ) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilPublisher(initialState)
  }

  // MARK: useRecoilPublihser
  public func useRecoilPublisher<Node: PublisherAtom>(
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilPublisher(initialState)
  }

  // MARK: useRecoilTask
  public func useRecoilTask<Node: TaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilTask(updateStrategy, initialState)
  }

  // MARK: useRecoilTask
  public func useRecoilTask<Node: TaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilTask(updateStrategy, initialState)
  }

  // MARK: useRecoilThrowingTask
  public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilThrowingTask(updateStrategy, initialState)
  }

  // MARK: useRecoilThrowingTask
  public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilThrowingTask(updateStrategy, initialState)
  }

  // MARK: useRecoilRefresher + Publisher
  public func useRecoilRefresher<Node: PublisherAtom>(
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilRefresher(initialState)
  }

  // MARK: useRecoilRefresher + Publisher
  public func useRecoilRefresher<Node: PublisherAtom>(
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilRefresher(initialState)
  }

  // MARK: useRecoilRefresher + Task
  public func useRecoilRefresher<Node: TaskAtom>(
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(initialState)
  }

  // MARK: useRecoilRefresher + Task
  public func useRecoilRefresher<Node: TaskAtom>(
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(initialState)
  }

  // MARK: useRecoilRefresher + ThrowingTask
  public func useRecoilRefresher<Node: ThrowingTaskAtom>(
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(initialState)
  }

  // MARK: useRecoilRefresher + ThrowingTask
  public func useRecoilRefresher<Node: ThrowingTaskAtom>(
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(initialState)
  }
}

// MARK: Func Hook ==============================================================================

// MARK: useRecoilValue
public func useRecoilValue<Node: ValueAtom, Context: AtomContext>(
  context: Context,
  _ initialState: Node
) -> Node.Loader.Value {
  useRecoilValue(context: context) {
    initialState
  }
}

// MARK: useRecoilValue
public func useRecoilValue<Node: ValueAtom, Context: AtomContext>(
  context: Context,
  _ initialState: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(RecoilContextValueHook<Node, Context>(initialState: initialState, context: context))
}

// MARK: useRecoilState + Context
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  context: Context,
  _ initialState: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState(context: context) {
    initialState
  }
}

// MARK: useRecoilState + Context
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  context: Context,
  _ initialState: @escaping() -> Node
) -> Binding<Node.Loader.Value> {
  useHook(RecoilContextStateHook<Node, Context>(initialState: initialState, context: context))
}

// MARK: Context Hook ============================================================================
private struct RecoilContextValueHook<Node: ValueAtom, Context: AtomContext>: Hook {

  typealias Value = Node.Loader.Value

  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy? = .once

  @MainActor
  func makeState() -> State {
    State(initialState: initialState(),context: context)
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.value
  }

  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }

  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }
}

private extension RecoilContextValueHook {

  final class State {
    var state: Node
    let context: Context
    var isDisposed = false
    init(initialState: Node, context: Context) {
      self.state = initialState
      self.context = context
    }

    @MainActor
    var value: Value {
      context.read(state)
    }
  }
}

private struct RecoilContextStateHook<Node: StateAtom, Context: AtomWatchableContext>: Hook {

  typealias Value = Binding<Node.Loader.Value>

  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy? = .once

  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }

  @MainActor
  func value(coordinator: Coordinator) -> Value {
    Binding(
      get: {
        coordinator.state.context.watch(coordinator.state.state)
      },
      set: { newValue, transaction in
        assertMainThread()
        guard !coordinator.state.isDisposed else {
          return
        }
        withTransaction(transaction) {
          coordinator.state.context.set(newValue, for: coordinator.state.state)
          coordinator.updateView()
        }
      }
    )
  }

  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }

  func dispose(state: State) {
    state.isDisposed = true
  }
}

private extension RecoilContextStateHook {
  final class State {

    var state: Node
    let context: Context
    var isDisposed = false

    init(initialState: Node, context: Context) {
      self.state = initialState
      self.context = context
    }
  }
}

