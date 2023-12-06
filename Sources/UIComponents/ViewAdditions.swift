import SwiftUI

// MARK: View Container
public protocol ContainerView: View {
  associatedtype Content
  init(content: @escaping () -> Content)
}

public extension ContainerView {
  init(@ViewBuilder _ content: @escaping () -> Content) {
    self.init(content: content)
  }
}

public struct HScrollView<Content: View>: ContainerView {
  var content: () -> Content
  
  public init(content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    ScrollView(.horizontal) {
      HStack(content: content).padding()
    }
  }
}

public struct VScrollView<Content: View>: ContainerView {
  var content: () -> Content
  
  public init(content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    ScrollView(.vertical) {
      HStack(content: content).padding()
    }
  }
}

public struct If<TrueContent: View, FalseContent: View>: View {
  
  var value: Bool
  let trueContent: () -> TrueContent
  let falseContent: () -> FalseContent
  
  public init(
    _ value: Bool,
    @ViewBuilder `true`: @escaping () -> TrueContent,
    @ViewBuilder `false`: @escaping () -> FalseContent
  ) {
    self.value = value
    self.trueContent = `true`
    self.falseContent = `false`
  }
  
  public init(
    _ value: Bool,
    @ViewBuilder `true`: @escaping () -> TrueContent
  ) where FalseContent == EmptyView {
    self.init(value, true: `true`) {
      EmptyView()
    }
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

public struct IfLet<T, Content: View, ElseContent: View>: View {
  
  let value: T?
  let content: (T) -> Content
  let elseContent: () -> ElseContent
  
  public init(
    _ value: T?,
    @ViewBuilder content: @escaping (T) -> Content,
    @ViewBuilder `else`: @escaping () -> ElseContent
  ) {
    self.value = value
    self.content = content
    self.elseContent = `else`
  }
  
  public init(
    _ value: T?,
    @ViewBuilder content: @escaping (T) -> Content
  ) where ElseContent == EmptyView {
    self.init(value, content: content) {
      EmptyView()
    }
  }

  
  public var body: some View {
    if let value = value {
      content(value)
    } else {
      elseContent()
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
  
  public init(_ value: Bool = true, @ViewBuilder content: @escaping () -> Content) {
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
  
  public init(_ value: Bool = false, @ViewBuilder content: @escaping () -> Content) {
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
