#if canImport(ComposableArchitecture)
import ComposableArchitecture

// MARK: Store to ViewStore

public extension Store {
  
  /// Transform a Store to ViewStore
  ///
  ///      let store: StoreOf<AppReducer> = ...
  ///
  ///      let viewStore = store.toViewStore()
  ///
  /// - Returns: ViewStore
  func toViewStore() -> ViewStore<State, Action> where State: Equatable {
    ViewStore(self)
  }
  
  /// Transform a Store to ViewStore
  ///
  ///     let store: StoreOf<AppReducer> = ...
  ///
  ///     let viewStore = store.toViewStore()
  ///     
  /// - Returns: ViewStore
  func toViewStore() -> ViewStore<State, Action> where State == Void {
    ViewStore(self)
  }
  
  /// Transform a Store to ViewStore
  /// - Parameter isDuplicate: isDuplicate description
  /// - Returns: description
  func toViewStore(
    removeDuplicates isDuplicate: @escaping (State, State) -> Bool
  ) -> ViewStore<State, Action> {
    ViewStore(
      self,
      removeDuplicates: isDuplicate
    )
  }
  
  /// Transform a Store to ViewStore
  ///
  ///     let store: StoreOf<AppReducer> = ...
  ///
  ///     let viewStore = store.toViewStore(...)
  ///
  /// - Parameters:
  ///   - toViewState: toViewState description
  ///   - isDuplicate: isDuplicate description
  /// - Returns: ViewStore
  func toViewStore<ViewState>(
    observe toViewState: @escaping (State) -> ViewState,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) -> ViewStore<ViewState, Action> {
    ViewStore(
      self,
      observe: toViewState,
      removeDuplicates: isDuplicate
    )
  }
  
  /// Transform a Store to ViewStore
  ///
  ///     let store: StoreOf<AppReducer> = ...
  ///
  ///     let viewStore = store.toViewStore(...)
  ///
  /// - Parameters:
  ///   - toViewState: toViewState description
  ///   - isDuplicate: isDuplicate description
  /// - Returns: ViewStore
  func toViewStore<ViewState, ViewAction>(
    observe toViewState: @escaping (State) -> ViewState,
    send fromViewAction: @escaping (ViewAction) -> Action,
    removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
  ) -> ViewStore<ViewState, ViewAction> {
    ViewStore(
      self,
      observe: toViewState,
      send: fromViewAction,
      removeDuplicates: isDuplicate
    )
  }
}

#endif
