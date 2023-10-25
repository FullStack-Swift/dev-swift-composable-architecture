import SwiftUI
import SwiftExt

// MARK: OnFirstAppearViewModifier
public struct OnFirstAppearViewModifier: ViewModifier {
  
  private let action: (() -> Void)?
  
  @State private var hasAppeared = false
  
  public init(action: (() -> Void)? = nil) {
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

// MARK: OnLastDisappearViewModifier
public struct OnLastDisappearViewModifier: ViewModifier {
  
  fileprivate final class OnLastDisappearViewModel: ObservableObject {
    
    fileprivate var action: (() -> Void)?
    
    fileprivate init(action: (() -> Void)? = nil) {
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

extension View {
  public func onLastDisappear(perform action: (() -> Void)? = nil) -> some View {
    modifier(OnLastDisappearViewModifier(action: action))
  }
}

public extension View {
  func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
    modifier(OnFirstAppearViewModifier(action: action))
  }
}

extension View {
  /// Aligns the content based on the given alignment by wrapping the content
  /// in an `HStack`.
  public func alignment(horizontal alignment: HorizontalAlignment) -> some View {
    modifier(HorizontalAlignmentViewModifier(alignment))
  }
  
  /// Aligns the content based on the given alignment by wrapping the content
  /// in a `VStack`.
  public func alignment(vertical alignment: VerticalAlignment) -> some View {
    modifier(VerticalAlignmentViewModifier(alignment))
  }
  
  /// Aligns the content based on the given alignment by wrapping the content
  /// in a `ZStack`.
  public func alignment(_ alignment: Alignment) -> some View {
    modifier(AlignmentViewModifier(alignment))
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
