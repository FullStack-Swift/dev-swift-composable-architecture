import SwiftUI
import Combine

public extension View {
  var backport: Backport<Self> { Backport(self) }
}

// MARK: Backport + View
public extension Backport where Base: View {
  
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
      base.badge(count)
    } else {
      base
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
    base.modifier(
      TaskModifier(
        priority: priority,
        action: action
      )
    )
  }
  
  @ViewBuilder
  func focused() -> some View {
    if #available(iOS 15.0, macOS 12.0, *) {
      base.modifier(TextFieldFocused())
    } else {
      base
    }
  }
  
  @ViewBuilder
  func onChange<V>(of value: V, perform: @escaping (V) -> Void) -> some View where V: Equatable {
    if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
      base.onChange(of: value, perform: perform)
    } else {
      base.onReceive(Just(value)) { value in
        perform(value)
      }
    }
  }

  
  @ViewBuilder
  func onChange<V>(of value: V, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View where V: Equatable {
    base.modifier(ChangeModifier(value: value, action: action))
  }
}

// MARK: Private Components

extension Backport where Base: View {
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
  
  @available(macOS 12.0, *)
  @available(iOS 15.0, *)
  private struct TextFieldFocused: ViewModifier {
    
    @FocusState private var focused: Bool
    
    init() {
      self.focused = false
    }
    
    func body(content: Content) -> some View {
      content
        .focused($focused)
        .onAppear {
          focused = true
        }
    }
  }
  
  private struct ChangeModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let action: (Value, Value) -> Void
    
    @State var oldValue: Value?
    
    init(value: Value, action: @escaping (Value, Value) -> Void) {
      self.value = value
      self.action = action
      _oldValue = .init(initialValue: value)
    }
    
    func body(content: Content) -> some View {
      content
        .onReceive(Just(value)) { newValue in
          guard newValue != oldValue else { return }
          action(oldValue ?? newValue, newValue)
          oldValue = newValue
        }
    }
  }

}

// MARK: Public Components

extension Backport where Base: View {
  
  public struct NavigationStack<V: View>: View {
    private let content: () -> V
    
    public init(@ViewBuilder builder: @escaping () -> V) {
      self.content = builder
    }
    
    public var body: some View {
      if #available(iOS 16.0, macOS 13, *) {
        SwiftUI.NavigationStack(root: content)
      } else {
        SwiftUI.NavigationView(content: content)
      }
    }
  }
}

extension Backport where Base: View {
  
  /// Masks this view using the alpha channel of the given view.
  ///
  /// Use `mask(_:)` when you want to apply the alpha (opacity) value of
  /// another view to the current view.
  ///
  /// This example shows an image masked by rectangle with a 10% opacity:
  ///
  ///     Image(systemName: "envelope.badge.fill")
  ///         .foregroundColor(Color.blue)
  ///         .font(.system(size: 128, weight: .regular))
  ///         .mask {
  ///             Rectangle().opacity(0.1)
  ///         }
  ///
  /// ![A screenshot of a view masked by a rectangle with 10%
  /// opacity.](SwiftUI-View-mask.png)
  ///
  /// - Parameters:
  ///     - alignment: The alignment for `mask` in relation to this view.
  ///     - mask: The view whose alpha the rendering system applies to
  ///       the specified view.
  @ViewBuilder
  public func mask<Mask>(
    alignment: Alignment = .center,
    @ViewBuilder _ mask: () -> Mask
  ) -> some View where Mask : View {
    if #available(iOS 15.0, *) {
      base.mask(alignment: alignment, mask)
    } else {
      // Fallback on earlier versions
      // #mTodo("Write code for fallback")
    }
  }
  
  /// Layers the given view behind this view.
  ///
  /// Use `background(_:alignment:)` when you need to place one view behind
  /// another, with the background view optionally aligned with a specified
  /// edge of the frontmost view.
  ///
  /// The example below creates two views: the `Frontmost` view, and the
  /// `DiamondBackground` view. The `Frontmost` view uses the
  /// `DiamondBackground` view for the background of the image element inside
  /// the `Frontmost` view's ``VStack``.
  ///
  ///     struct DiamondBackground: View {
  ///         var body: some View {
  ///             VStack {
  ///                 Rectangle()
  ///                     .fill(.gray)
  ///                     .frame(width: 250, height: 250, alignment: .center)
  ///                     .rotationEffect(.degrees(45.0))
  ///             }
  ///         }
  ///     }
  ///
  ///     struct Frontmost: View {
  ///         var body: some View {
  ///             VStack {
  ///                 Image(systemName: "folder")
  ///                     .font(.system(size: 128, weight: .ultraLight))
  ///                     .background(DiamondBackground())
  ///             }
  ///         }
  ///     }
  ///
  /// ![A view showing a large folder image with a gray diamond placed behind
  /// it as its background view.](View-background-1)
  ///
  /// - Parameters:
  ///   - background: The view to draw behind this view.
  ///   - alignment: The alignment with a default value of
  ///     ``Alignment/center`` that you use to position the background view.
  @ViewBuilder
  public func background<Background: View>(
    @ViewBuilder _ builder: () -> Background,
    alignment: Alignment = .center
  ) -> some View {
    base.background(builder(), alignment: alignment)
  }
}
