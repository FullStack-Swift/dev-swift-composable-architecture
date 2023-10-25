import SwiftUI
import Combine

public extension View {
  var mbackport: MBackport<Self> { MBackport(self) }
}

// MARK: MBackport + View
public extension MBackport where Content: View {
  
  /// Generates a badge for the view from an integer value.
  ///
  /// Use a badge to convey optional, supplementary information about a
  /// view. Keep the contents of the badge as short as possible. Badges
  /// appear only in list rows, tab bars, and menus.
  ///
  /// The following example shows a ``List`` with the value of `recentItems.count`
  /// represented by a badge on one of the rows:
  ///
  ///     List {
  ///         Text("Recents")
  ///             .backport.badge(recentItems.count)
  ///         Text("Favorites")
  ///     }
  ///
  /// ![A table with two rows, titled Recents and Favorites. The first row
  /// shows the number 10 at the trailing side of the row
  ///  cell.](View-badge-1)
  ///
  /// - Parameter count: An integer value to display in the badge.
  ///   Set the value to zero to hide the badge.
  @ViewBuilder
  func badge(_ count: Int) -> some View {
    if #available(iOS 15,  macOS 12.0, *) {
      content.badge(count)
    } else {
      content
    }
  }
  
  /// Attach an async task to this view, which will be performed
  /// when the view first appears, and cancelled if the view
  /// disappears (or is removed from the view hierarchy).
  /// - parameter priority: Any explicit priority that the async
  ///   task should have.
  /// - parameter action: The async action that the task should run.
  func task(
    priority: TaskPriority = .userInitiated,
    _ action: @escaping () async -> Void
  ) -> some View {
    content.modifier(
      TaskModifier(
        priority: priority,
        action: action
      )
    )
  }
  
  @ViewBuilder
  func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
    if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
      content.onChange(of: value, perform: onChange)
    } else {
      content.onReceive(Just(value)) { value in
        onChange(value)
      }
    }
  }
}

// MARK: - Private Code
private struct TaskModifier: ViewModifier {
  var priority: TaskPriority
  var action: () async -> Void
  
  @State private var task: Task<Void, Never>?
  
  func body(content: Content) -> some View {
    content
      .onAppear {
        task = Task(priority: priority) {
          await action()
        }
      }
      .onDisappear {
        task?.cancel()
        task = nil
      }
  }
}
