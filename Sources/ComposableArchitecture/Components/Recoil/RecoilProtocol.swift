import SwiftUI
import Combine

// MARK: ContextRecoilHookRef State

/// The Base State for  Recoil Hook.
@MainActor
fileprivate class ContextRecoilHookRef<Node: Atom, Context: AtomWatchableContext> {
  
  /// the context is some AtomWatchableContext, that excute hooks api.
  fileprivate var context: Context
  
  /// the atom value in Hook.
  fileprivate var node: Node
  
  /// task excute action refresh or wath atom.
  fileprivate var task: Task<Void, Never>? {
    didSet {
      oldValue?.cancel()
    }
  }
  
  /// the property in order to check the view is dispose.
  fileprivate var isDisposed = false
  
  /// the store any canncellable from combine.
  fileprivate var cancellables: SetCancellables = []
  
  /// Description: init Hook state.
  /// - Parameters:
  ///   - location: location description
  ///   - initialNode: initialNode description
  ///   - context: context description
  fileprivate init(
    location: SourceLocation,
    initialNode: Node,
    context: Context
  ) {
    self.node = initialNode
    self.context = context
  }
  
  /// release state
  fileprivate func dispose() {
    task = nil
    cancellables.dispose()
    isDisposed = true
  }
}

/// Declares that a type can produce hooks api function that can be accessed from any
/// The value produces by hooks api function is watched from some where, and is imediately update when the atom value changes.
/// Any context from Atoms can conform ``RecoilProtocol`` to provides hooks api function.
public protocol RecoilProtocol {
  
  associatedtype Context: AtomWatchableContext
  
  var context: Context { get }
}

@MainActor
extension RecoilProtocol {
  
  // MARK: Recoil Value
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  ///
  ///```swift
  ///let context = ...
  ///
  ///let value = context.useRecoilValue(TextAtom())
  ///
  ///print(value) // Prints the current value associated with ``TextAtom``.
  ///
  ///```
  ///
  public func useRecoilValue<Node: ValueAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy? = .once,
    _ initialState: Node
  ) -> Node.Loader.Value {
    ComposableArchitecture
      .useRecoilValue(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  ///
  ///```swift
  ///let context = ...
  ///
  ///let value = context.useRecoilValue{TextAtom()}
  ///
  ///print(value) // Prints the current value associated with ``TextAtom``.
  ///
  ///```
  ///
  public func useRecoilValue<Node: ValueAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy? = .once,
    _ initialState: @escaping() -> Node
  ) -> Node.Loader.Value {
    ComposableArchitecture
      .useRecoilValue(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  // MARK: Recoil State
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  ///
  ///```swift
  ///let context = ...
  ///
  ///let value = context.useRecoilState(TextAtom())
  ///
  ///print(value.wrappedValue) // Prints the current value associated with ``TextAtom``.
  ///
  ///value.wrappedValue = ... // When the value changes, it will re-render ui.
  ///```
  ///
  public func useRecoilState<Node: StateAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy? = .once,
    _ initialState: Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture
      .useRecoilState(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  ///```swift
  ///let context = ...
  ///
  ///let value = context.useRecoilValue {TextAtom()}
  ///
  ///print(value) // Prints the current value associated with ``TextAtom``.
  ///
  ///value.wrappedValue = ... // When the value changes, it will re-render ui.
  ///```
  ///
  public func useRecoilState<Node: StateAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy? = .once,
    _ initialState: @escaping() -> Node
  ) -> Binding<Node.Loader.Value> {
    ComposableArchitecture
      .useRecoilState(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  // MARK: Recoil Publisher
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilPublisher<Node: PublisherAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy? = .once,
    _ initialState: Node
  ) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture
      .useRecoilPublisher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilPublisher<Node: PublisherAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy? = .once,
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture
      .useRecoilPublisher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  // MARK: Recoil Task
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilTask<Node: TaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilTask(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilTask<Node: TaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilTask(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  // MARK: Recoil ThrowingTask
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilThrowingTask(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilThrowingTask<Node: ThrowingTaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: @escaping() -> Node
  ) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilThrowingTask(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  // MARK: Recoil Publisher Refresher
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilRefresher<Node: PublisherAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture
      .useRecoilRefresher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilRefresher<Node: PublisherAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
  where Node.Loader == PublisherAtomLoader<Node> {
    ComposableArchitecture
      .useRecoilRefresher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  // MARK: Recoil Task Refresher
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
public func useRecoilRefresher<Node: TaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilRefresher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilRefresher<Node: TaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilRefresher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  // MARK: Recoil ThrowingTask Refresher
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilRefresher<Node: ThrowingTaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilRefresher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
  
  /// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
  /// - Parameters:
  ///   - fileID: the path to the file it appears in.
  ///   - line: the line number on which it appears.
  ///   - updateStrategy: the Strategy update state.
  ///   - context: the context's execution hooks.
  ///   - initialNode: the any Atom value.
  /// - Returns: Hook Value.
  public func useRecoilRefresher<Node: ThrowingTaskAtom>(
    fileID: String = #fileID,
    line: UInt = #line,
    updateStrategy: HookUpdateStrategy = .once,
    _ initialState: @escaping() -> Node
  ) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  where Node.Loader: AsyncAtomLoader {
    ComposableArchitecture
      .useRecoilRefresher(
        fileID: fileID,
        line: line,
        updateStrategy: updateStrategy,
        context,
        initialState
      )
  }
}

// MARK: Func Hook
// ==============================================================================

// MARK: Recoil Value

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilValue<Node: ValueAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: Node
) -> Node.Loader.Value {
  useRecoilValue(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilValue<Node: ValueAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> Node.Loader.Value {
  useHook(
    RecoilValueHook(
      updateStrategy: updateStrategy,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil State

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: Node
) -> Binding<Node.Loader.Value> {
  useRecoilState(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilState<Node: StateAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> Binding<Node.Loader.Value> {
  useHook(
    RecoilStateHook(
      updateStrategy: .once,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil Publisher

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilPublisher<Node: PublisherAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilPublisher(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilPublisher<Node: PublisherAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure> where Node.Loader == PublisherAtomLoader<Node> {
  useHook(
    RecoilPublisherHook(
      updateStrategy: updateStrategy,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil Task

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilTask<Node: TaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy = .once,
  _ context: Context,
  _ initialNode: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilTask<Node: TaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy = .once,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilTaskHook(
      updateStrategy: updateStrategy,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil Throwing Task

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilThrowingTask<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy = .once,
  _ context: Context,
  _ initialNode: Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilThrowingTask(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilThrowingTask<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilThrowingTaskHook(
      updateStrategy: updateStrategy,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil Publisher Refresher

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: PublisherAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: PublisherAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useHook(
    RecoilPublisherRefresherHook(
      updateStrategy: updateStrategy,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil Task Refresher

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: TaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialNode
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: TaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilTaskRefresherHook(
      updateStrategy: updateStrategy,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil ThrowingTask Refresher

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialState: Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(fileID: fileID, line: line, updateStrategy: updateStrategy, context) {
    initialState
  }
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - context: the context's execution hooks.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<Node: ThrowingTaskAtom, Context: AtomWatchableContext>(
  fileID: String = #fileID,
  line: UInt = #line,
  updateStrategy: HookUpdateStrategy? = .once,
  _ context: Context,
  _ initialNode: @escaping() -> Node
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useHook(
    RecoilThrowingTaskRefresherHook<Node, Context>(
      updateStrategy: updateStrategy,
      context: context,
      initialNode: initialNode,
      location: SourceLocation(fileID: fileID, line: line)
    )
  )
}

// MARK: Recoil Hooks for any Context.
// ============================================================================

// MARK: RecoilValueHook
private struct RecoilValueHook<
  Node: ValueAtom,
  Context: AtomWatchableContext
>: RecoilHook {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Value = Node.Loader.Value
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func makeState() -> State {
    State(location: location, initialNode: initialNode(), context: context)
  }

  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    return coordinator.state.value
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.updateView()
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilValueHook {
  // MARK: State
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {
    @MainActor
    var value: Node.Loader.Value {
      context.watch(node)
    }
  }
}

// MARK: RecoilStateHook
private struct RecoilStateHook<
  Node: StateAtom,
  Context: AtomWatchableContext
>: RecoilHook {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Value = Binding<Node.Loader.Value>
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func makeState() -> State {
    State(location: location, initialNode: initialNode(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    return Binding(
      get: {
        coordinator.state.value
      },
      set: { newValue, transaction in
        guard !coordinator.state.isDisposed else {
          return
        }
        withTransaction(transaction) {
          coordinator.state.context.set(newValue, for: coordinator.state.node)
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
    coordinator.updateView()
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilStateHook {
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {
    @MainActor
    var value: Node.Loader.Value {
      context.watch(node)
    }
  }
}

// MARK: RecoilPublisherHook
private struct RecoilPublisherHook<
  Node: PublisherAtom,
  Context: AtomWatchableContext
>: RecoilHook where Node.Loader == PublisherAtomLoader<Node> {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Value = AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }

  @MainActor
  func makeState() -> State {
    State(location: location, initialNode: initialNode(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase = coordinator.state.value
    return coordinator.state.phase
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.context.objectWillChange.sink {
      let value = coordinator.state.value
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.phase = value
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilPublisherHook {
  // MARK: State
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {
    
    var phase: Value = .suspending
    
    var value: Value {
      context.watch(node)
    }
    
    var refresh: Value {
      get async {
        await context.refresh(node)
      }
    }
  }
}

// MARK: RecoilTaskHook
private struct RecoilTaskHook<
  Node: TaskAtom,
  Context: AtomWatchableContext
>: RecoilHook where Node.Loader: AsyncAtomLoader {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Value = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }

  @MainActor
  func makeState() -> State {
    State(location: location, initialNode: initialNode(), context: context)
  }
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.context.objectWillChange.sink {
      coordinator.state.task = Task { @MainActor in
        guard !coordinator.state.isDisposed else {
          return
        }
        let value = await coordinator.state.value.result
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = AsyncPhase(value)
          coordinator.updateView()
        }
      }
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilTaskHook {
  // MARK: State
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {
    
    var phase = Value.suspending
    
    var value: Task<Node.Loader.Success, Node.Loader.Failure> {
      context.watch(node)
    }
    
    var refresh: Value {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}

// MARK: RecoilThrowingTaskHook
private struct RecoilThrowingTaskHook<
  Node: ThrowingTaskAtom,
  Context: AtomWatchableContext
>: RecoilHook
where Node.Loader: AsyncAtomLoader {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Value = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func makeState() -> State {
    State(location: location, initialNode: initialNode(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    coordinator.state.phase
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.context.objectWillChange.sink {
      coordinator.state.task = Task { @MainActor in
        guard !coordinator.state.isDisposed else {
          return
        }
        let value = await coordinator.state.value.result
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = AsyncPhase(value)
          coordinator.updateView()
        }
      }
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilThrowingTaskHook {
  // MARK: State
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {
    
    var phase = Value.suspending
    
    var value: Task<Node.Loader.Success, Node.Loader.Failure> {
      context.watch(node)
    }
    
    var refresh: Value {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}

// MARK: RecoilPublisherRefresherHook
private struct RecoilPublisherRefresherHook<
  Node: PublisherAtom,
  Context: AtomWatchableContext
>: RecoilHook
where Node.Loader == PublisherAtomLoader<Node> {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Phase = AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
  
  typealias Value = (Phase, refresher: () -> Void)
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func makeState() -> State {
    State(location: location, initialNode : initialNode(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    (
      coordinator.state.phase,
      refresher: {
        guard !coordinator.state.isDisposed else {
          return
        }
        Task { @MainActor in
          let refresh = await coordinator.state.refresh
          if !Task.isCancelled && !coordinator.state.isDisposed {
            coordinator.state.phase = refresh
            coordinator.updateView()
          }
        }
      }
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.context.objectWillChange.sink {
      guard !coordinator.state.isDisposed else {
        return
      }
      coordinator.state.phase = coordinator.state.value
      coordinator.updateView()
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }

  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilPublisherRefresherHook {
  @MainActor
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {

    var phase: Phase = .suspending
    
    var value: Phase {
      context.watch(node)
    }

    var refresh: Phase {
      get async {
        await context.refresh(node)
      }
    }
  }
}

// MARK: RecoilTaskRefresherHook
private struct RecoilTaskRefresherHook<
  Node: TaskAtom,
  Context: AtomWatchableContext
>: RecoilHook
where Node.Loader: AsyncAtomLoader {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  typealias Value = (AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func makeState() -> State {
    State(location: location, initialNode : initialNode(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    (
      coordinator.state.phase,
      refresher: {
        guard !coordinator.state.isDisposed else {
          return
        }
        Task { @MainActor in
          let refresh = await coordinator.state.refresh
          if !Task.isCancelled && !coordinator.state.isDisposed {
            coordinator.state.phase = refresh
            coordinator.updateView()
          }
        }
      }
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.context.objectWillChange.sink {
      coordinator.state.task = Task { @MainActor in
        guard !coordinator.state.isDisposed else {
          return
        }
        let value = await coordinator.state.value.result
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = AsyncPhase(value)
          coordinator.updateView()
        }
      }
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilTaskRefresherHook {
  // MARK: State
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {
    
    var phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>.suspending
    
    var value: Task<Node.Loader.Success, Node.Loader.Failure> {
      context.watch(node)
    }
    
    var refresh: Phase {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}

// MARK: RecoilThrowingTaskRefresherHook
private struct RecoilThrowingTaskRefresherHook<
  Node: ThrowingTaskAtom,
  Context: AtomWatchableContext
>: RecoilHook
where Node.Loader: AsyncAtomLoader {
  
  typealias State = _ContextRecoilHookRef
  
  typealias Phase = AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
  
  typealias Value = (Phase, refresher: () -> Void)
  
  let updateStrategy: HookUpdateStrategy?
  
  let context: Context
  
  let initialNode: () -> Node
  
  let location: SourceLocation
  
  init(
    updateStrategy: HookUpdateStrategy? = .once,
    context: Context,
    initialNode: @escaping () -> Node,
    location: SourceLocation
  ) {
    self.updateStrategy = updateStrategy
    self.context = context
    self.initialNode = initialNode
    self.location = location
  }
  
  @MainActor
  func makeState() -> State {
    State(location: location, initialNode: initialNode(), context: context)
  }
  
  @MainActor
  func value(coordinator: Coordinator) -> Value {
    return (
      coordinator.state.phase,
      refresher: {
        guard !coordinator.state.isDisposed else {
          return
        }
        Task { @MainActor in
          let refresh = await coordinator.state.refresh
          if !Task.isCancelled && !coordinator.state.isDisposed {
            coordinator.state.phase = refresh
            coordinator.updateView()
          }
        }
      }
    )
  }
  
  @MainActor
  func updateState(coordinator: Coordinator) {
    guard !coordinator.state.isDisposed else {
      return
    }
    coordinator.state.context.objectWillChange.sink {
      coordinator.state.task = Task { @MainActor in
        guard !coordinator.state.isDisposed else {
          return
        }
        let value = await coordinator.state.value.result
        if !Task.isCancelled && !coordinator.state.isDisposed {
          coordinator.state.phase = AsyncPhase(value)
          coordinator.updateView()
        }
      }
    }
    .store(in: &coordinator.state.cancellables)
    coordinator.state.task = Task { @MainActor in
      let refresh = await coordinator.state.refresh
      if !Task.isCancelled && !coordinator.state.isDisposed {
        coordinator.state.phase = refresh
        coordinator.updateView()
      }
    }
  }
  
  @MainActor
  func dispose(state: State) {
    state.dispose()
  }
}

private extension RecoilThrowingTaskRefresherHook {
  // MARK: State
  final class _ContextRecoilHookRef: ContextRecoilHookRef<Node, Context> {

    var phase = Phase.suspending
    
    var value: Task<Node.Loader.Success, Node.Loader.Failure> {
      context.watch(node)
    }
    
    var refresh: Phase {
      get async {
        await AsyncPhase(context.refresh(node).result)
      }
    }
  }
}
