import Combine
import SwiftUI
import Foundation

@propertyWrapper
public struct ViewModel<ViewState, ViewAction>: DynamicProperty {

  fileprivate var store: Store<ViewState, ViewAction>

  @ObservedObject
  fileprivate var viewStore: ViewStore<ViewState, ViewAction>

  public init<State, Action>(
    _ keyPath: KeyPath<DependencyValues, Store<State, Action>>,
    observe toViewState: @escaping (State) -> ViewState,
    send fromViewAction: @escaping (ViewAction) -> Action,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    @Dependency(keyPath) var store : Store<State, Action>
    self.store = store.scope(state: toViewState, action: fromViewAction)
    self.viewStore = ViewStore(store, observe: toViewState, send: fromViewAction, removeDuplicates: isDuplicate)
  }

  public init<State>(
    _ store: Store<State, ViewAction>,
    observe toViewState: @escaping (State) -> ViewState,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    self.store = store.scope(state: toViewState)
    self.viewStore = ViewStore(store, observe: toViewState, removeDuplicates: isDuplicate)
  }

  public init<State, Action>(
    _ store: Store<State, Action>,
    observe toViewState: @escaping (State) -> ViewState,
    send fromViewAction: @escaping (ViewAction) -> Action,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    self.store = store.scope(state: toViewState, action: fromViewAction)
    self.viewStore = ViewStore(store, observe: toViewState, send: fromViewAction, removeDuplicates: isDuplicate)
  }

  public init(
    _ store: Store<ViewState, ViewAction>,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    self.store = store
    self.viewStore = ViewStore(store, removeDuplicates: isDuplicate)
  }

  public init(_ viewModel: ViewModel<ViewState, ViewAction>) {
    self.store = viewModel.store
    self.viewStore = viewModel.viewStore
  }

  public var wrappedValue: ViewState {
    get {
      store.state.value
    }
    nonmutating set {
      store.applyState({$0 = newValue})
    }
  }

  public var projectedValue: ViewModel {
    self
  }

  public var publisher: StorePublisher<ViewState> {
    viewStore.publisher
  }

  public var state: ViewState {
    wrappedValue
  }

  /// Sends an action to the store.
  ///
  /// This method returns a ``ViewStoreTask``, which represents the lifecycle of the effect started
  /// from sending an action. You can use this value to tie the effect's lifecycle _and_
  /// cancellation to an asynchronous context, such as SwiftUI's `task` view modifier:
  ///
  /// ```swift
  /// .task { await viewStore.send(.task).finish() }
  /// ```
  ///
  /// > Important: ``ViewStore`` is not thread safe and you should only send actions to it from the
  /// > main thread. If you want to send actions on background threads due to the fact that the
  /// > reducer is performing computationally expensive work, then a better way to handle this is to
  /// > wrap that work in an ``EffectTask`` that is performed on a background thread so that the
  /// > result can be fed back into the store.
  ///
  /// - Parameter action: An action.
  /// - Returns: A ``ViewStoreTask`` that represents the lifecycle of the effect executed when
  ///   sending the action.

  @discardableResult
  public func send(_ action: ViewAction) -> ViewModelTask {
    let task = viewStore.send(action)
    return ViewModelTask(rawValue: task.getValue)
  }

  /// Sends an action to the store with a given animation.
  ///
  /// See ``ViewStore/send(_:)`` for more info.
  ///
  /// - Parameters:
  ///   - action: An action.
  ///   - animation: An animation.
  @discardableResult
  public func send(_ action: ViewAction, animation: Animation?) -> ViewModelTask {
    send(action, transaction: Transaction(animation: animation))
  }

  /// Sends an action to the store with a given transaction.
  ///
  /// See ``ViewStore/send(_:)`` for more info.
  ///
  /// - Parameters:
  ///   - action: An action.
  ///   - transaction: A transaction.

  @discardableResult
  public func send(_ action: ViewAction, transaction: Transaction) -> ViewModelTask {
    withTransaction(transaction) {
      self.send(action)
    }
  }

  /// Sends an action into the store and then suspends while a piece of state is `true`.
  ///
  /// This method can be used to interact with async/await code, allowing you to suspend while work
  /// is being performed in an effect. One common example of this is using SwiftUI's `.refreshable`
  /// method, which shows a loading indicator on the screen while work is being performed.
  ///
  /// For example, suppose we wanted to load some data from the network when a pull-to-refresh
  /// gesture is performed on a list. The domain and logic for this feature can be modeled like so:
  ///
  /// ```swift
  /// struct Feature: ReducerProtocol {
  ///   struct State: Equatable {
  ///     var isLoading = false
  ///     var response: String?
  ///   }
  ///   enum Action {
  ///     case pulledToRefresh
  ///     case receivedResponse(TaskResult<String>)
  ///   }
  ///   @Dependency(\.fetch) var fetch
  ///
  ///   func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
  ///     switch action {
  ///     case .pulledToRefresh:
  ///       state.isLoading = true
  ///       return .task {
  ///         await .receivedResponse(TaskResult { try await self.fetch() })
  ///       }
  ///
  ///     case let .receivedResponse(result):
  ///       state.isLoading = false
  ///       state.response = try? result.value
  ///       return .none
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Note that we keep track of an `isLoading` boolean in our state so that we know exactly when
  /// the network response is being performed.
  ///
  /// The view can show the fact in a `List`, if it's present, and we can use the `.refreshable`
  /// view modifier to enhance the list with pull-to-refresh capabilities:
  ///
  /// ```swift
  /// struct MyView: View {
  ///   let store: Store<State, Action>
  ///
  ///   var body: some View {
  ///     WithViewStore(self.store, observe: { $0 }) { viewStore in
  ///       List {
  ///         if let response = viewStore.response {
  ///           Text(response)
  ///         }
  ///       }
  ///       .refreshable {
  ///         await viewStore.send(.pulledToRefresh, while: \.isLoading)
  ///       }
  ///     }
  ///   }
  /// }
  /// ```
  ///
  /// Here we've used the ``send(_:while:)`` method to suspend while the `isLoading` state is
  /// `true`. Once that piece of state flips back to `false` the method will resume, signaling to
  /// `.refreshable` that the work has finished which will cause the loading indicator to disappear.
  ///
  /// - Parameters:
  ///   - action: An action.
  ///   - predicate: A predicate on `ViewState` that determines for how long this method should
  ///     suspend.
  @MainActor
  public func send(_ action: ViewAction, while predicate: @escaping (ViewState) -> Bool) async {
    let task = self.send(action)
    await withTaskCancellationHandler {
      await self.yield(while: predicate)
    } onCancel: {
      task.rawValue?.cancel()
    }
  }

  /// Sends an action into the store and then suspends while a piece of state is `true`.
  ///
  /// See the documentation of ``send(_:while:)`` for more information.
  ///
  /// - Parameters:
  ///   - action: An action.
  ///   - animation: The animation to perform when the action is sent.
  ///   - predicate: A predicate on `ViewState` that determines for how long this method should
  ///     suspend.
  @MainActor
  public func send(
    _ action: ViewAction,
    animation: Animation?,
    while predicate: @escaping (ViewState) -> Bool
  ) async {
    let task = withAnimation(animation) { self.send(action) }
    await withTaskCancellationHandler {
      await self.yield(while: predicate)
    } onCancel: {
      task.rawValue?.cancel()
    }
  }

  /// Suspends the current task while a predicate on state is `true`.
  ///
  /// If you want to suspend at the same time you send an action to the view store, use
  /// ``send(_:while:)``.
  ///
  /// - Parameter predicate: A predicate on `ViewState` that determines for how long this method
  ///   should suspend.
  @MainActor
  public func yield(while predicate: @escaping (ViewState) -> Bool) async {
    if #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) {
      _ = await self.publisher
        .values
        .first(where: { !predicate($0) })
    } else {
      let cancellable = Box<AnyCancellable?>(wrappedValue: nil)
      try? await withTaskCancellationHandler {
        try Task.checkCancellation()
        try await withUnsafeThrowingContinuation {
          (continuation: UnsafeContinuation<Void, Error>) in
          guard !Task.isCancelled else {
            continuation.resume(throwing: CancellationError())
            return
          }
          cancellable.wrappedValue = self.publisher
            .filter { !predicate($0) }
            .prefix(1)
            .sink { _ in
              continuation.resume()
              _ = cancellable
            }
        }
      } onCancel: {
        cancellable.wrappedValue?.cancel()
      }
    }
  }
}

public typealias ViewModelOf<R: ReducerProtocol> = ViewModel<R.State, R.Action>

extension ViewModel where ViewState: Equatable {

  public init(
    _ keyPath: KeyPath<DependencyValues, Store<ViewState, ViewAction>>
  ) {
    @Dependency(keyPath) var store: Store
    self.init(store)
  }

  public init<State>(
    _ store: Store<State, ViewAction>,
    observe toViewState: @escaping (State) -> ViewState
  ) {
    self.init(store, observe: toViewState, removeDuplicates: ==)
  }

  public init<State, Action>(
    _ store: Store<State, Action>,
    observe toViewState: @escaping (State) -> ViewState,
    send fromViewAction: @escaping (ViewAction) -> Action
  ) {
    self.init(store, observe: toViewState, send: fromViewAction, removeDuplicates: ==)
  }

  public init(
    _ store: Store<ViewState, ViewAction>
  ) {
    self.init(store, removeDuplicates: ==)
  }
}

extension ViewModel where ViewState == Void {
  public init(_ store: Store<Void, ViewAction>) {
    self.init(store, removeDuplicates: ==)
  }
}

/// The type returned from ``ViewStore/send(_:)`` that represents the lifecycle of the effect
/// started from sending an action.
///
/// You can use this value to tie the effect's lifecycle _and_ cancellation to an asynchronous
/// context, such as the `task` view modifier.
///
/// ```swift
/// .task { await viewStore.send(.task).finish() }
/// ```
///
/// > Note: Unlike Swift's `Task` type, ``ViewStoreTask`` automatically sets up a cancellation
/// > handler between the current async context and the task.
///
/// See ``TestStoreTask`` for the analog returned from ``TestStore``.
public struct ViewModelTask: Hashable, Sendable {
  fileprivate let rawValue: Task<Void, Never>?

  /// Cancels the underlying task and waits for it to finish.
  public func cancel() async {
    self.rawValue?.cancel()
    await self.finish()
  }

  /// Waits for the task to finish.
  public func finish() async {
    await self.rawValue?.cancellableValue
  }

  /// A Boolean value that indicates whether the task should stop executing.
  ///
  /// After the value of this property becomes `true`, it remains `true` indefinitely. There is no
  /// way to uncancel a task.
  public var isCancelled: Bool {
    self.rawValue?.isCancelled ?? true
  }
}
