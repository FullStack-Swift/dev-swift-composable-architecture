import SwiftUI
import SwiftExt

// MARK: LifeCycle
public extension View {
  
  /// Description
  /// - Parameter action: action description
  /// - Returns: description
  func onLastDisappear(perform action: MCallBack? = nil) -> some View {
    modifier(OnLastDisappearViewModifier(action: action))
  }
  
  /// Description
  /// - Parameter action: action description
  /// - Returns: description
  func onFirstAppear(perform action: MCallBack? = nil) -> some View {
    modifier(OnFirstAppearViewModifier(action: action))
  }
}

// MARK: Alignment
public extension View {
  /// Aligns the content based on the given alignment by wrapping the content
  /// in an `HStack`.
  func alignment(horizontal alignment: HorizontalAlignment) -> some View {
    modifier(HorizontalAlignmentViewModifier(alignment))
  }
  
  /// Aligns the content based on the given alignment by wrapping the content
  /// in a `VStack`.
  func alignment(vertical alignment: VerticalAlignment) -> some View {
    modifier(VerticalAlignmentViewModifier(alignment))
  }
  
  /// Aligns the content based on the given alignment by wrapping the content
  /// in a `ZStack`.
  func alignment(_ alignment: Alignment) -> some View {
    modifier(AlignmentViewModifier(alignment))
  }
}

public extension View {
  
  /// AnyModifier View
  /// - Parameter mutation: mutation description
  /// - Returns: description
  @ViewBuilder
  func anyModifier(
    _ mutation: @escaping (inout AnyViewModifier.Content) -> Void
  ) -> some View {
    modifier(
      AnyViewModifier { content in
        content.with(mutation)
      }
    )
    .eraseToAnyView()
  }
 
  /// Description
  /// - Parameters:
  ///   - valueTrue: valueTrue description
  ///   - caseTrue: caseTrue description
  /// - Returns: description
  @ViewBuilder
  func withModifier<T: ViewModifier>(
    ifTrue valueTrue: Bool,
    modifier caseTrue: T
  ) -> some View {
    IfTrue(valueTrue) {
      modifier(caseTrue)
    }
  }
  
  /// Description
  /// - Parameters:
  ///   - valueFalse: valueFalse description
  ///   - caseFalse: caseFalse description
  /// - Returns: description
  @ViewBuilder
  func withModifier<T: ViewModifier>(
    ifFalse valueFalse: Bool,
    modifier caseFalse: T
  ) -> some View {
    IfFalse(valueFalse) {
      modifier(caseFalse)
    }
  }
  
  /// Description
  /// - Parameters:
  ///   - valueTrue: valueTrue description
  ///   - caseTrue: caseTrue description
  ///   - valueFalse: valueFalse description
  ///   - caseFalse: caseFalse description
  /// - Returns: description
  @ViewBuilder
  func withModifier<T1: ViewModifier, T2: ViewModifier>(
    ifTrue valueTrue: Bool,
    modifier caseTrue: T1,
    ifFalse valueFalse: Bool,
    modifier caseFalse: T2
  ) -> some View {
    if valueTrue == true {
      modifier(caseTrue)
    }
    if valueFalse == false {
      modifier(caseFalse)
    }
  }
  
  /// Description
  /// - Parameters:
  ///   - value: value description
  ///   - caseTrue: caseTrue description
  ///   - caseFalse: caseFalse description
  /// - Returns: description
  
  @ViewBuilder
  func withModifier<T1: ViewModifier, T2: ViewModifier>(
    bool value: Bool,
    modifierIfTrue caseTrue: T1,
    modifierIfFalse caseFalse: T2
  ) -> some View {
    If(value) {
      modifier(caseTrue)
    } false: {
      modifier(caseFalse)
    }
  }
}

// MARK: DebugFrame

public extension View {
  func debugFrame() -> some View {
    return modifier(PreviewFrameViewModifier())
  }
}

public struct OnFirstAppearViewModifier: ViewModifier {
  
  private let action: MCallBack?
  
  @State private var hasAppeared = false
  
  public init(action: MCallBack? = nil) {
    self.action = action
  }
  
  public func body(content: Content) -> some View {
    content
      .onAppear {
        if !hasAppeared {
          hasAppeared = true
          action?()
        }
      }
      .onDisappear()
  }
}

public struct OnLastDisappearViewModifier: ViewModifier {
  
  fileprivate final class OnLastDisappearViewModel: ObservableObject {
    
    fileprivate var action: MCallBack?
    
    fileprivate init(action: MCallBack? = nil) {
      self.action = action
    }
    
    deinit {
      let clone = action
      action = nil
      Task.init { @MainActor in
        try await Task.sleep(seconds:0.03)
        clone?()
      }
    }
  }
  
  @StateObject
  private var viewModel: OnLastDisappearViewModel
  
  public init(action: (() -> Void)? = nil) {
    _viewModel = StateObject(wrappedValue: OnLastDisappearViewModel(action: action))
  }
  
  public func body(content: Content) -> some View {
    content
      .onAppear {}
      .onDisappear {}
  }
}

// MARK: - HorizontalAlignment
private struct HorizontalAlignmentViewModifier: ViewModifier {
  
  private let alignment: HorizontalAlignment
  
  init(_ alignment: HorizontalAlignment) {
    self.alignment = alignment
  }
  
  func body(content: Content) -> some View {
    HStack(spacing: 0) {
      switch alignment {
        case .leading:
          content
          Spacer(minLength: 0)
        case .center:
          Spacer(minLength: 0)
          content
          Spacer(minLength: 0)
        case .trailing:
          Spacer(minLength: 0)
          content
        default:
          content
      }
    }
  }
}

// MARK: - VerticalAlignment
private struct VerticalAlignmentViewModifier: ViewModifier {
  
  private let alignment: VerticalAlignment
  
  init(_ alignment: VerticalAlignment) {
    self.alignment = alignment
  }
  
  func body(content: Content) -> some View {
    VStack(spacing: 0) {
      switch alignment {
        case .top:
          content
          Spacer(minLength: 0)
        case .center:
          Spacer(minLength: 0)
          content
          Spacer(minLength: 0)
        case .bottom:
          Spacer(minLength: 0)
          content
        default:
          content
      }
    }
  }
}

// MARK: - Alignment
private struct AlignmentViewModifier: ViewModifier {
  
  private let alignment: Alignment
  
  init(_ alignment: Alignment) {
    self.alignment = alignment
  }
  
  func body(content: Content) -> some View {
    ZStack(alignment: alignment) {
      Color.clear
      content
    }
  }
}

// MARK: AnyViewModifier
public struct AnyViewModifier: ViewModifier {
  
  private let makeBody: ( inout Content) -> any View
  
  public init<T: ViewModifier>(_ modifier: T) {
    self.makeBody = { $0.modifier(modifier) }
  }
  
  public init(
    _ makeBody: @escaping (inout Content) -> any View
  ) {
    self.makeBody = { makeBody(&$0) }
  }
  
  public func body(content: Content) -> some View {
    var result = content
    return AnyView(makeBody(&result))
  }
}

public struct PreviewFrameViewModifier: ViewModifier {
  
  @State private var isPresentedBackground: Bool = false
  
  public func body(content: Content) -> some View {
#if !DEBUG
    return content
#endif
    content
      .overlay(
        GeometryReader { geometry in
          let globalOrigin: CGPoint = geometry.frame(in: .global).origin
          let origin: String = "(x: \(rounded(globalOrigin.x)), y: \(rounded(globalOrigin.y)))"
          let size: String = "(w: \(rounded(geometry.size.width)), h: \(rounded(geometry.size.height)))"
          ZStack(alignment: .bottom) {
            if isPresentedBackground {
#if iOS
              Color(.systemBackground)
#endif
            }
            Rectangle()
              .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [5]))
              .foregroundColor(Color.red)
            Text("\(origin) | \(size)")
              .fontWeight(.bold)
              .foregroundColor(Color.red)
#if iOS
              .font(.caption2)
#endif
              .zIndex(9999)
              .onTapGesture {
                isPresentedBackground.toggle()
              }
          }
        }
      )
  }
  
  private func rounded(_ value: CGFloat) -> Float {
    return Float(round(100 * value) / 100)
  }
}
