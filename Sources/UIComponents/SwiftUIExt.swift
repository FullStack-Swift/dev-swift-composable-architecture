import SwiftUI
import Combine

public typealias FTapGesture = () -> Void

public typealias FCompletion<T> = (T) -> Void

public protocol FView: View {
  
  @ViewBuilder var anyBody: any View { get }
}

extension FView where Body: View {
  var body: some View {
    AnyView(anyBody)
  }
}

extension View {
  
  /// Description
  /// - Parameter mutation: mutation your view
  /// - Returns: Self
  public func with(_ mutation: (inout Self) -> Void) -> Self {
    var view = self
    mutation(&view)
    return view
  }
}

extension View {
  public func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

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
    } else {
      self
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
    } else {
      `else`(self)
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
    } else {
      self
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
    } else {
      `else`(self)
    }
  }
  
  /// Applies given transform to the view.
  /// - Parameters:
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Original `View`.
  @ViewBuilder
  public func extractView<Content: View>(transform: (Self) -> Content) -> some View {
    transform(self)
  }
}

extension View {
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

extension View {
  
  @ViewBuilder
  public func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
    if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
      self.onChange(of: value, perform: onChange)
    } else {
      self.onReceive(Just(value)) { value in
        onChange(value)
      }
    }
  }
}

extension Task where Success == Never, Failure == Never {
  public static func sleep(seconds: Double) async throws {
    let duration = UInt64(seconds * 1_000_000_000)
    try await Task.sleep(nanoseconds: duration)
  }
}

public struct If<TrueContent: View, FalseContent: View>: View {
  
  var value: Bool
  let trueContent: () -> TrueContent
  let falseContent: () -> FalseContent
  
  public init(
    value: Bool,
    @ViewBuilder trueContent: @escaping () -> TrueContent,
    @ViewBuilder falseContent: @escaping () -> FalseContent
  ) {
    self.value = value
    self.trueContent = trueContent
    self.falseContent = falseContent
  }
  
  @ViewBuilder
  public var body: some View {
    if value {
      trueContent()
    } else {
      falseContent()
    }
  }
}

public struct IfLet<T, Content: View>: View {
  let value: T?
  let content: (T) -> Content
  
  public init(_ value: T?, @ViewBuilder content: @escaping (T) -> Content) {
    self.value = value
    self.content = content
  }
  
  public var body: some View {
    if let value = value {
      content(value)
    }
  }
}

public struct IfLetTrue<Content: View>: View {
  let value: Bool?
  let content: () -> Content
  
  public init(_ value: Bool?, @ViewBuilder content: @escaping () -> Content) {
    self.value = value
    self.content = content
  }
  
  public var body: some View {
    IfLet(value) { element in
      if element == true {
        content()
      }
    }
  }
}

public struct IfLetFalse<Content: View>: View {
  let value: Bool?
  let content: () -> Content
  
  public init(_ value: Bool?, @ViewBuilder content: @escaping () -> Content) {
    self.value = value
    self.content = content
  }
  
  public var body: some View {
    IfLet(value) { element in
      if element == false {
        content()
      }
    }
  }
}

public struct IfTrue<Content: View>: View {
  var value: Bool
  let content: () -> Content
  
  public init(value: Bool = true, @ViewBuilder content: @escaping () -> Content) {
    self.value = value
    self.content = content
  }
  
  public var body: some View {
    if value == true {
      content()
    }
  }
}

public struct IfFalse<Content: View>: View {
  var value: Bool
  let content: () -> Content
  
  public init(value: Bool = false, @ViewBuilder content: @escaping () -> Content) {
    self.value = value
    self.content = content
  }
  
  public var body: some View {
    if value == false {
      content()
    }
  }
}

public struct IfLetPhone<Content: View>: View {
  let content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
#if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .phone {
      content()
    } else {
      EmptyView()
        .hidden()
    }
#else
    EmptyView()
      .hidden()
#endif
  }
}

public struct IfLetPad<Content: View>: View {
  let content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
#if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .pad {
      content()
    } else {
      EmptyView()
        .hidden()
    }
#else
    EmptyView()
      .hidden()
#endif
  }
}

public struct IfLetIOS<Content: View>: View {
  let content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
#if os(iOS)
    content()
#else
    EmptyView()
      .hidden()
#endif
  }
}

public struct IfLetMacOS<Content: View>: View {
  let content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
#if os(macOS)
    content()
#else
    EmptyView()
      .hidden()
#endif
  }
}

public struct IfLetTVOS<Content: View>: View {
  let content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
#if os(tvOS)
    content()
#else
    EmptyView()
      .hidden()
#endif
  }
}

public struct IfLetWatchOS<Content: View>: View {
  let content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
#if os(watchOS)
    content()
#else
    EmptyView()
      .hidden()
#endif
  }
}

public struct IFLetVisionOS<Content: View>: View {
  let content: () -> Content
  
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
#if os(visionOS)
    content()
#else
    EmptyView()
      .hidden()
#endif
  }
}

@propertyWrapper
public struct LazyView<Content: View>: View {
  private let builder: () -> Content
  
  public init(_ builder: @autoclosure @escaping () -> Content) {
    self.builder = builder
  }
  public var body: Content {
    builder()
  }
  
  public var wrappedValue: Content {
    body
  }
}
