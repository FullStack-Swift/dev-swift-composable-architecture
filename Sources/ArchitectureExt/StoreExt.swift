#if canImport(ComposableArchitecture)
import ComposableArchitecture

// MARK: Store to ViewStore
public extension Store {
  
  /// Description
  /// - Returns: description
  func toViewStore() -> ViewStore<State, Action> where State: Equatable {
    ViewStore(self)
  }
  
  /// Description
  /// - Returns: description
  func toViewStore() -> ViewStore<State, Action> where State == Void {
    ViewStore(self)
  }
  
  /// Description
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
  
  /// Description
  /// - Parameters:
  ///   - toViewState: toViewState description
  ///   - isDuplicate: isDuplicate description
  /// - Returns: description
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
  
  /// Description
  /// - Parameters:
  ///   - toViewState: toViewState description
  ///   - fromViewAction: fromViewAction description
  ///   - isDuplicate: isDuplicate description
  /// - Returns: description
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
