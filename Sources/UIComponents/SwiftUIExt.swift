import SwiftUI
import Combine

public typealias MCallBack = () -> Void

public typealias MCompletion<T> = (T) -> Void

/// Description: A custom parameter attribute that constructs views from closures.
/// - Parameter _: _ view content
/// - Returns: You typically use ViewBuilder as a parameter attribute for child view-producing closure parameters, allowing those closures to provide multiple child views. For example, the following contextMenu function accepts a closure that produces one or more views via the view builder.

public func viewBuilder<Content: View>( @ViewBuilder _ builder: () -> Content) -> some View {
  builder()
    .eraseToAnyView()
}

public protocol MView: View {
  
  @ViewBuilder var anyBody: any View { get }
}

extension MView where Body: View {
  public var body: some View {
    AnyView(anyBody)
  }
}

// MARK: Changed view
extension View {
  
  /// AnyView allows changing the type of view used in a given view hierarchy. Whenever the type of view used with AnyView changes, SwiftUI destroys old hierarchy and creates a new hierarchy the new type.
  /// - Returns: AnyView
  public func eraseToAnyView() -> AnyView {
    AnyView(self)
  }
  
  /// Description
  /// - Parameter mutation: mutation your view
  /// - Returns: Self
  public func with(_ mutation: (inout Self) -> Void) -> Self {
    var view = self
    mutation(&view)
    return view
  }
}

// MARK: Condition View function.
extension View {
  /// Applies the given transform if the given condition evaluates to `true`.
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
  @ViewBuilder
  public func `if`<Transform: View>(
    _ condition: Bool, @ViewBuilder transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
        .eraseToAnyView()
    } else {
      self
        .eraseToAnyView()
    }
  }
  
  
  /// Applies the given transform `transform` or `else`.
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  ///   - else: The transform that applies if `condition` is false
  /// - Returns: Either the original `View` or the modified `View` based on the condition`.
  @ViewBuilder
  public func `if`<Content: View>(
    _ condition: Bool, transform: (Self) -> Content,
    @ViewBuilder else: (Self) -> Content
  ) -> some View {
    if condition {
      transform(self)
        .eraseToAnyView()
    } else {
      `else`(self)
        .eraseToAnyView()
    }
  }
  
  /// Unwraps the given `value` and applies the given `transform`.
  /// - Parameters:
  ///   - value: The value to unwrap.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original `View` or the modified `View` with unwrapped `value` if the `value` is not nil`.
  @ViewBuilder
  public func ifLet<Value, Content: View>(
    _ value: Value?,
    @ViewBuilder transform: (Value, Self) -> Content
  ) -> some View {
    if let value = value {
      transform(value, self)
        .eraseToAnyView()
    } else {
      self
        .eraseToAnyView()
    }
  }
  
  /// Unwraps the given `value` and applies the given `transform`.
  /// - Parameters:
  ///   - value: The value to unwrap.
  ///   - transform: The transform to apply to the source `View`.
  ///   - else:The transform that applies if `value` is nil
  /// - Returns: Either the `else` transform or the modified `View` with unwrapped `value` if the `value` is not nil`.
  @ViewBuilder
  public func ifLet<Value, Content: View>(
    _ value: Value?,
    @ViewBuilder transform: (Value, Self) -> Content,
    @ViewBuilder else: (Self) -> Content
  ) -> some View {
    if let value = value {
      transform(value, self)
        .eraseToAnyView()
    } else {
      `else`(self)
        .eraseToAnyView()
    }
  }
}

// MARK: extractView
extension View {
  /// Applies given transform to the view.
  /// - Parameters:
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Original `View`.
  @ViewBuilder
  public func extractView<Content: View>(transform: (Self) -> Content) -> some View {
    transform(self)
  }
}

// MARK: onTap
extension View {
  
  /// Adds an action to perform when this view recognizes a tap gesture.
  ///
  /// Use this method to perform the specified `action` when the user clicks
  /// or taps on the view or container `count` times.
  ///
  /// > Note: If you create a control that's functionally equivalent
  /// to a ``Button``, use ``ButtonStyle`` to create a customized button
  /// instead.
  ///
  /// In the example below, the color of the heart images changes to a random
  /// color from the `colors` array whenever the user clicks or taps on the
  /// view twice:
  ///
  ///     struct TapGestureExample: View {
  ///         let colors: [Color] = [.gray, .red, .orange, .yellow,
  ///                                .green, .blue, .purple, .pink]
  ///         @State private var fgColor: Color = .gray
  ///
  ///         var body: some View {
  ///             Image(systemName: "heart.fill")
  ///                 .resizable()
  ///                 .frame(width: 200, height: 200)
  ///                 .foregroundColor(fgColor)
  ///                 .onTap(count: 2) {
  ///                     fgColor = colors.randomElement()!
  ///                 }
  ///         }
  ///     }
  ///
  /// ![A screenshot of a view of a heart.](SwiftUI-View-TapGesture.png)
  ///
  /// - Parameters:
  ///    - count: The number of taps or clicks required to trigger the action
  ///      closure provided in `action`. Defaults to `1`.
  ///    - action: The action to perform.
  public func onTap(count: Int = 1, perform: @escaping MCallBack) -> some View {
    contentShape(Rectangle())
      .onTapGesture(count: count, perform: perform)
  }
}

// MARK: - Hidden
extension View {
  /// Hide or show the view based on a boolean value.
  ///
  /// - Parameters:
  ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
  @ViewBuilder
  public func isHidden(_ isHidden: Bool) -> some View {
    if isHidden {
      hidden()
    } else {
      self
    }
  }
  /// Hide or show the view based on a boolean value.
  ///
  /// - Parameters:
  ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
  ///   - remove: Boolean value indicating whether or not to remove the view.
  @ViewBuilder
  public func hidden(_ hidden: Bool, remove: Bool = false) -> some View {
    if hidden {
      if !remove {
        self.hidden()
      }
    } else {
      self
    }
  }

  @ViewBuilder
  public func hideListRowSeperator() -> some View {
#if os(iOS)
    if #available(iOS 15, *) {
      listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(.zero))
    } else {
      frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .listRowInsets(EdgeInsets(top: -1, leading: -1, bottom: -1, trailing: -1))
    }
#endif
    
#if os(macOS)
    if #available(macOS 13, *) {
      listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    } else {
      frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .listRowInsets(EdgeInsets(top: -1, leading: -1, bottom: -1, trailing: -1))
    }
#endif
  }
}

// MARK: - Frame
extension View {
  /// Positions this view within an invisible frame with the specified size.
  public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
    frame(width: size.width, height: size.height, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame with the specified size.
  public func frame(length: CGFloat, alignment: Alignment = .center) -> some View {
    frame(width: length, height: length, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame having the specified size
  /// constraints.
  public func frame(min: CGFloat, alignment: Alignment = .center) -> some View {
    frame(minWidth: min, minHeight: min, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame having the specified size
  /// constraints.
  public func frame(max: CGFloat, alignment: Alignment = .center) -> some View {
    frame(maxWidth: max, maxHeight: max, alignment: alignment)
  }
}
