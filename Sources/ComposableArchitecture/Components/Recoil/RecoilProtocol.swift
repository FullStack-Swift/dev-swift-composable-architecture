import SwiftUI
import Combine

public protocol RecoilProtocol {
  
  associatedtype Context: AtomWatchableContext
  
  var context: Context { get }
}

extension GlobalViewContext: RecoilProtocol {
  public var context: Self {
    self
  }
}

extension RecoilProtocol {
  // MARK: useRecoilState
  public func useRecoilState<Node: StateAtom>(
    _ initialState: Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture.useRecoilState(context, initialState)
  }
  
  // MARK: useRecoilState
  public func useRecoilState<Node: StateAtom>(
    _ initialState: @escaping() -> Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture.useRecoilState(context, initialState)
  }
  
  // MARK: useRecoilValue
  public func useRecoilValue<Node: ValueAtom>(
    _ initialState: Node
  ) -> Node.Loader.Value {
    ComposableArchitecture.useRecoilValue(context, initialState)
  }
  
  // MARK: useRecoilValue
  public func useRecoilValue<Node: ValueAtom>(
    _ initialState: @escaping() -> Node
  ) -> Node.Loader.Value {
    ComposableArchitecture.useRecoilValue(context, initialState)
  }
  
  // MARK: useRecoilPublihser
  public func useRecoilPublisher<Node: PublisherAtom>(
    _ initialState: Node
  ) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilPublisher(context, initialState)
  }
  
  // MARK: useRecoilPublihser
  public func useRecoilPublisher<Node: PublisherAtom>(
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilPublisher(context, initialState)
  }
  
  // MARK: useRecoilTask
  public func useRecoilTask<Node: TaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilTask(updateStrategy, context, initialState)
  }
  
  // MARK: useRecoilTask
  public func useRecoilTask<Node: TaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilTask(updateStrategy, context, initialState)
  }
  
  // MARK: useRecoilThrowingTask
  public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilThrowingTask(updateStrategy, context, initialState)
  }
  
  // MARK: useRecoilThrowingTask
  public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
    _ updateStrategy: HookUpdateStrategy,
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilThrowingTask(updateStrategy, context, initialState)
  }
  
  // MARK: useRecoilRefresher + Publisher
  public func useRecoilRefresher<Node: PublisherAtom>(
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilRefresher(nil, context, initialState)
  }
  
  // MARK: useRecoilRefresher + Publisher
  public func useRecoilRefresher<Node: PublisherAtom>(
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture.useRecoilRefresher(nil, context, initialState)
  }
  
  // MARK: useRecoilRefresher + Task
  public func useRecoilRefresher<Node: TaskAtom>(
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(nil, context, initialState)
  }
  
  // MARK: useRecoilRefresher + Task
  public func useRecoilRefresher<Node: TaskAtom>(
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(nil, context, initialState)
  }
  
  // MARK: useRecoilRefresher + ThrowingTask
  public func useRecoilRefresher<Node: ThrowingTaskAtom>(
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(nil, context, initialState)
  }
  
  // MARK: useRecoilRefresher + ThrowingTask
  public func useRecoilRefresher<Node: ThrowingTaskAtom>(
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture.useRecoilRefresher(nil, context, initialState)
  }
}

// MARK: Func Hook ==============================================================================

// MARK: useRecoilValue
public func useRecoilValue<Node: ValueAtom, Context: AtomWatchableContext>(
  _ context: Context,
  _ initialState: Node
) -> Node.Loader.Value {
  useRecoilValue(context) {
    initialState
  }
}

// MARK: useRecoilValue
public func useRecoilValue<Node: ValueAtom, Context: AtomWatchableContext>(
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(RecoilValueHook<Node, Context>(initialState: initialState, context: context))
}

// MARK: useRecoilState + Context
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  _ context: Context,
  _ initialState: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState(context) {
    initialState
  }
}

// MARK: useRecoilState + Context
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> Binding<Node.Loader.Value> {
  useHook(RecoilStateHook<Node, Context>(initialState: initialState, context: context))
}

// MARK: useRecoilPublisher + Publisher
public func useRecoilPublisher<Node: PublisherAtom, Context: AtomWatchableContext>(
  _ context: Context,
  _ initialState: Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilPublisher(context) {
    initialState
  }
}

// MARK: useRecoilPublisher + Publisher
public func useRecoilPublisher<Node: PublisherAtom, Context: AtomWatchableContext>(
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> where Node.Loader == PublisherAtomLoader<Node> {
  useHook(RecoilPublisherHook<Node, Context>(initialState: initialState, context: context))
}

// MARK: useRecoilTask
public func useRecoilTask<Node: TaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy,
  _ context: Context,
  _ initialState: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(updateStrategy,context) {
    initialState
  }
}

// MARK: useRecoilTask
public func useRecoilTask<Node: TaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy,
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(RecoilTaskHook(initialState: initialState, context: context, updateStrategy: updateStrategy))
}

// MARK: useRecoilThrowingTask
public func useRecoilThrowingTask<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy,
  _ context: Context,
  _ initialState: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilThrowingTask(updateStrategy, context) {
    initialState
  }
}

// MARK: useRecoilThrowingTask
public func useRecoilThrowingTask<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy,
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(RecoilThrowingTaskHook(initialState: initialState, context: context, updateStrategy: updateStrategy))
}


// MARK: useRecoilRefresher + Publisher
public func useRecoilRefresher<Node: PublisherAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ context: Context,
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher(updateStrategy, context) {
    initialState
  }
}

// MARK: useRecoilRefresher + Publisher
public func useRecoilRefresher<Node: PublisherAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(RecoilPublisherRefresherHook(initialState: initialState, context: context, updateStrategy: updateStrategy))
}

// MARK: useRecoilRefresher + Task
public func useRecoilRefresher<Node: TaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ context: Context,
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(updateStrategy, context) {
    initialState
  }
}

// MARK: useRecoilRefresher + Task
public func useRecoilRefresher<Node: TaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(RecoilTaskRefresherHook(initialState: initialState, context: context, updateStrategy: updateStrategy))
}

// MARK: useRecoilRefresher + ThrowingTask
public func useRecoilRefresher<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ context: Context,
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(updateStrategy, context) {
    initialState
  }
}

// MARK: useRecoilRefresher + ThrowingTask
public func useRecoilRefresher<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  _ updateStrategy: HookUpdateStrategy? = nil,
  _ context: Context,
  _ initialState: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(RecoilThrowingTaskRefresherHook(initialState: initialState, context: context, updateStrategy: updateStrategy))
}

// MARK: Context Hook ============================================================================


// MARK: Value
private struct RecoilValueHook<Node: ValueAtom, Context: AtomWatchableContext>: Hook {
  
  typealias Value = Node.Loader.Value
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy? = .once
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.context.objectWillChange
      .sink(receiveValue: coordinator.updateView)
      .store(in: &coordinator.state.cancellables)
    return coordinator.state.value
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
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

private extension RecoilValueHook {
  
  final class State {
    
    let context: Context
    var state: Node
    var cancellables: SetCancellables = []
    var isDisposed = false
    
    init(initialState: Node, context: Context) {
      self.state = initialState
      self.context = context
    }
    
    /// Get  value from context
    @MainActor
    var value: Value {
      context.watch(state)
    }
  }
}

// MARK: State
private struct RecoilStateHook<Node: StateAtom, Context: AtomWatchableContext>: Hook {
  
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
    coordinator.state.context.objectWillChange
      .sink(receiveValue: coordinator.updateView)
      .store(in: &coordinator.state.cancellables)
    return Binding(
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
    for cancellable in state.cancellables {
      cancellable.cancel()
    }
  }
}

private extension RecoilStateHook {
  // MARK: State
  final class State {
    
    let context: Context
    var state: Node
    var cancellables: SetCancellables = []
    var isDisposed = false
    
    init(initialState: Node, context: Context) {
      self.state = initialState
      self.context = context
    }
  }
}

// MARK: Publisher
private struct RecoilPublisherHook<Node: PublisherAtom, Context: AtomWatchableContext>: Hook
where Node.Loader == PublisherAtomLoader<Node> {
  
  typealias Value = AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy? = .once
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.phase = coordinator.state.value
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }
}

extension RecoilPublisherHook {
  // MARK: State
  final class State {
    
    var context: Context
    
    var node: Node
    var phase = Value.suspending
    var isDisposed = false
    
    init(initialState: Node, context: Context) {
      self.context = context
      self.node = initialState
    }
    
    /// Get  value from context
    @MainActor
    var value: Value {
      context.watch(node)
    }
  }
}

// MARK: Task
private struct RecoilTaskHook<Node: TaskAtom, Context: AtomWatchableContext>: Hook where Node.Loader: AsyncAtomLoader {
  
  typealias Value = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy?
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    coordinator.state.phase = .suspending
    coordinator.state.task = Task { @MainActor in
      let value = await coordinator.state.value
      if !Task.isCancelled {
        coordinator.state.phase = value
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.task = nil
  }
}

extension RecoilTaskHook {
  // MARK: State
  final class State {
    
    var context: Context
    
    var node: Node
    var phase = Value.suspending
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    init(initialState: Node, context: Context) {
      self.context = context
      self.node = initialState
    }
    
    /// Get current value from context
    var value: Value {
      get async {
        await AsyncPhase(context.watch(node).result)
      }
    }
  }
}

// MARK: Throwing Task
private struct RecoilThrowingTaskHook<Node: ThrowingTaskAtom, Context: AtomWatchableContext>: Hook
where Node.Loader: AsyncAtomLoader {
  
  typealias Value = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy?
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    coordinator.state.phase = .suspending
    coordinator.state.task = Task { @MainActor in
      let value = await coordinator.state.value
      if !Task.isCancelled {
        coordinator.state.phase = value
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.task = nil
  }
}

extension RecoilThrowingTaskHook {
  // MARK: State
  final class State {
    
    var context: Context
    
    var node: Node
    var phase = Value.suspending
    
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    init(initialState: Node, context: Context) {
      self.node = initialState
      self.context = context
    }
    
    /// Get current value from context
    var value: Value {
      get async {
        await AsyncPhase(context.watch(node).result)
      }
    }
  }
}

private struct RecoilPublisherRefresherHook<Node: PublisherAtom, Context: AtomWatchableContext>: Hook
where Node.Loader == PublisherAtomLoader<Node> {
  
  typealias Value = (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> Void)
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy?
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    (
      coordinator.state.phase,
      refresher: {
        coordinator.state.phase = .suspending
        coordinator.updateView()
        Task { @MainActor in
          let refresh = await coordinator.state.refresh
          guard !coordinator.state.isDisposed else {
            return
          }
          coordinator.state.phase = refresh
          coordinator.updateView()
        }
      }
    )
  }
  
  @MainActor
  func dispose(state: State) {
    state.isDisposed = true
  }
}

extension RecoilPublisherRefresherHook {
  @MainActor
  final class State {
    
    var context: Context
    
    var state: Node
    var phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> = .suspending
    var isDisposed = false
    
    init(initialState: Node, context: Context) {
      self.context = context
      self.state = initialState
    }
    
    /// Get current value from context
    var value: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> {
      context.watch(state)
    }
    
    
    /// Refresh to get newValue from context
    var refresh: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> {
      get async {
        await context.refresh(state)
      }
    }
  }
}

private struct RecoilTaskRefresherHook<Node: TaskAtom, Context: AtomWatchableContext>: Hook
where Node.Loader: AsyncAtomLoader {
  
  typealias Value = (AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy?
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    (
      coordinator.state.phase,
      refresher: {
        coordinator.state.phase = .suspending
        coordinator.updateView()
        Task { @MainActor in
          let refresh = await coordinator.state.refresh
          guard !coordinator.state.isDisposed else {
            return
          }
          coordinator.state.phase = refresh
          coordinator.updateView()
        }
      }
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    coordinator.state.phase = .suspending
    coordinator.state.task = Task { @MainActor in
      let value = await coordinator.state.value
      if !Task.isCancelled {
        coordinator.state.phase = value
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.task = nil
    state.isDisposed = true
  }
}

extension RecoilTaskRefresherHook {
  // MARK: State
  final class State {
    
    var context: Context
    
    var state: Node
    var isDisposed = false
    var phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>.suspending
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    init(initialState: Node, context: Context) {
      self.context = context
      self.state = initialState
    }
    
    /// Get current value from context
    var value: AsyncPhase<Node.Loader.Success, Node.Loader.Failure> {
      get async {
        await AsyncPhase(context.watch(state).result)
      }
    }
    
    /// Refresh to get newValue from context
    var refresh: AsyncPhase<Node.Loader.Success, Node.Loader.Failure> {
      get async  {
        await AsyncPhase(context.refresh(state).result)
      }
    }
  }
}

private struct RecoilThrowingTaskRefresherHook<Node: ThrowingTaskAtom, Context: AtomWatchableContext>: Hook
where Node.Loader: AsyncAtomLoader {
  typealias Value = (AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> Void)
  
  let initialState: () -> Node
  let context: Context
  let updateStrategy: HookUpdateStrategy?
  
  @MainActor
  func makeState() -> State {
    State(initialState: initialState(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    (
      coordinator.state.phase,
      refresher: {
        coordinator.state.phase = .suspending
        coordinator.updateView()
        Task { @MainActor in
          let refresh = await coordinator.state.refresh
          guard !coordinator.state.isDisposed else {
            return
          }
          coordinator.state.phase = refresh
          coordinator.updateView()
        }
      }
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    coordinator.state.phase = .suspending
    coordinator.state.task = Task { @MainActor in
      let value = await coordinator.state.value
      if !Task.isCancelled {
        coordinator.state.phase = value
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.task = nil
    state.isDisposed = true
  }
}

extension RecoilThrowingTaskRefresherHook {
  final class State {
    
    var context: Context
    
    var isDisposed = false
    var state: Node
    var phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>.suspending
    var task: Task<Void, Never>? {
      didSet {
        oldValue?.cancel()
      }
    }
    
    init(initialState: Node, context: Context) {
      self.context = context
      self.state = initialState
    }
    
    /// Get current value from context
    var value: AsyncPhase<Node.Loader.Success, Node.Loader.Failure> {
      get async {
        await AsyncPhase(context.watch(state).result)
      }
    }
    
    /// Refresh to get newValue from context
    var refresh: AsyncPhase<Node.Loader.Success, Node.Loader.Failure> {
      get async {
        await AsyncPhase(context.refresh(state).result)
      }
    }
  }
}
