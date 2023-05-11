import SwiftUI

#if os(macOS)
/// `NavigationStack` driven by `Store`
@available(macOS 13, *)
public struct NavigationStackWithStore<ID: Hashable, Root: View>: View {
  /// Create `NavigationStack` wrapped with `WithViewStore`.
  ///
  /// - State of the store provides navigation path of type `[ID]`.
  /// - Whenever navigation path changes, an action with updated path is sent to the store.
  ///
  /// - Parameters:
  ///   - store: Store with state and action of `[ID]`.
  ///   - root: Creates root view.
  public init(
    _ store: Store<[ID], [ID]>,
    root: @escaping () -> Root
  ) {
    self.store = store
    self.root = root
  }

  let store: Store<[ID], [ID]>
  let root: () -> Root

  public var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStack(
        path: viewStore.binding(send: { $0 }),
        root: root
      )
    }
  }
}
#endif

#if os(iOS)
import NavigationStackBackport

public struct NavigationStackWithStore<ID: Hashable, Root: View>: View {
  /// Create `NavigationStack` wrapped with `WithViewStore`.
  ///
  /// - State of the store provides navigation path of type `[ID]`.
  /// - Whenever navigation path changes, an action with updated path is sent to the store.
  ///
  /// - Parameters:
  ///   - store: Store with state and action of `[ID]`.
  ///   - root: Creates root view.
  public init(
    _ store: Store<[ID], [ID]>,
    root: @escaping () -> Root
  ) {
    self.store = store
    self.root = root
  }

  let store: Store<[ID], [ID]>
  let root: () -> Root

  public var body: some View {
    WithViewStore(store) { viewStore in
      NavigationStackBackport.NavigationStack(
        path: viewStore.binding(send: { $0 }),
        root: root
      )
    }
  }
}
#endif
