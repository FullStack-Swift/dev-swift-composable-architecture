import Combine
import SwiftUI
import Foundation

@dynamicCallable
@dynamicMemberLookup
@propertyWrapper
public struct ViewModel<ViewState, ViewAction>: DynamicProperty {

  fileprivate var store: Store<ViewState, ViewAction>

  @StateObject
  fileprivate var viewStore: ViewStore<ViewState, ViewAction>

  public init<State, Action>(
    _ keyPath: KeyPath<DependencyValues, Store<State, Action>>,
    observe toViewState: @escaping (State) -> ViewState,
    send fromViewAction: @escaping (ViewAction) -> Action,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    @Dependency(keyPath) var store: Store<State, Action>
    self.store = store.scope(state: toViewState, action: fromViewAction)
    let viewStore = ViewStore(store, observe: toViewState, send: fromViewAction, removeDuplicates: isDuplicate)
    self._viewStore = StateObject(wrappedValue: viewStore)
  }

  public init<State>(
    _ store: Store<State, ViewAction>,
    observe toViewState: @escaping (State) -> ViewState,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    self.store = store.scope(state: toViewState)
    let viewStore = ViewStore(store, observe: toViewState, removeDuplicates: isDuplicate)
    self._viewStore = StateObject(wrappedValue: viewStore)
  }

  public init<State, Action>(
    _ store: Store<State, Action>,
    observe toViewState: @escaping (State) -> ViewState,
    send fromViewAction: @escaping (ViewAction) -> Action,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    self.store = store.scope(state: toViewState, action: fromViewAction)
    let viewStore = ViewStore(store, observe: toViewState, send: fromViewAction, removeDuplicates: isDuplicate)
    self._viewStore = StateObject(wrappedValue: viewStore)
  }

  public init(
    _ store: Store<ViewState, ViewAction>,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) {
    self.store = store
    let viewStore = ViewStore(store, removeDuplicates: isDuplicate)
    self._viewStore = StateObject(wrappedValue: viewStore)
  }

  public init(_ viewModel: ViewModel<ViewState, ViewAction>) {
    self.store = viewModel.store
    let viewStore = viewModel.viewStore
    self._viewStore = StateObject(wrappedValue: viewStore)
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
  
  public subscript<Value>(dynamicMember keyPath: KeyPath<ViewStore<ViewState, ViewAction>, Value>) -> Value {
    self.viewStore[keyPath: keyPath]
  }
  
  public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, ViewAction>) {
    for (key, value) in args {
      switch key {
        case "send":
          viewStore.send(value)
        case "dispatch":
          viewStore.dispatch(value)
        default:
          break
      }
    }
  }

  @discardableResult
  public func send(_ action: ViewAction) -> ViewStoreTask {
    viewStore.send(action)
  }

  @discardableResult
  public func send(_ action: ViewAction, animation: Animation?) -> ViewStoreTask {
    send(action, transaction: Transaction(animation: animation))
  }

  @discardableResult
  public func send(_ action: ViewAction, transaction: Transaction) -> ViewStoreTask {
    withTransaction(transaction) {
      self.send(action)
    }
  }

  @MainActor
  public func send(_ action: ViewAction, while predicate: @escaping (ViewState) -> Bool) async {
    let task = self.send(action)
    await withTaskCancellationHandler {
      await self.yield(while: predicate)
    } onCancel: {
      task.getValue?.cancel()
    }
  }

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
      task.getValue?.cancel()
    }
  }

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

extension ViewModel: ActionHandler {
  public func dispatch(_ dispatchedAction: DispatchedAction<ViewAction>) {
    store.dispatch(dispatchedAction)
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

extension ViewModel where ViewAction == Void {
  public func send() {
    self.send(())
  }
}
