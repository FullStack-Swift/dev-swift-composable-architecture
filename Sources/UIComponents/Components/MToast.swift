import SwiftUI

// MARK: Toast/ Snackbar
/// A toast-like message that provides simple feedback about an operation in a small popup.
public struct FToast: View {
  
  @Binding var data: FToast.ViewState?
  
  var tapGesture: MTapGesture?
  
  @State var cacheData: FToast.ViewState?
  
  init(data: Binding<FToast.ViewState?>, tapGesture: MTapGesture? = nil) {
    self._data = data
    self._cacheData = State(initialValue: data.wrappedValue)
    self.tapGesture = tapGesture
  }
  
  public var body: some View {
    let data = cacheData
    HStack(spacing: 0) {
      if let image = data?.image {
        Image(systemName: image)
          .foregroundColor(.white)
          .frame(width: 24, height: 24, alignment: .center)
          .cornerRadius(5)
        Spacer()
          .frame(width: 16)
      }
      if let title = data?.title {
        Text(title)
          .foregroundColor(.white)
      }
      Spacer(minLength: 0) /// fixed will button hidden, it can show fullscreen content.
      if let buttonTitle = data?.buttonTitle {
        HStack(spacing: 0) {
          Spacer(minLength: 16)
          Divider()
            .background(Color.white)
          Spacer()
            .frame(width: 16)
          Button {
            tapGesture?()
          } label: {
            Text(buttonTitle)
              .foregroundColor(.white)
              .background(Color.clear)
          }
        }
        .fixedSize(horizontal: true, vertical: false)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background("#182537".toColor())
    .cornerRadius(8)
    .onChange(of: self.data) { newValue in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        if let data = newValue {
          cacheData = data
        }
      }
    }
  }
  
  public func onTapButton(tapGesture: MTapGesture?) -> Self {
    with {
      $0.tapGesture = tapGesture
    }
  }
}

extension FToast {
  /// Model Data for Toast Message.
  public struct ViewState: MViewStateProtocol {
    
    public var title: String?
    
    public var buttonTitle: String?
    
    public var image: String?
    
    public var foregroundColor: Color?
    
    public var backgroundColor: Color?
    
    public var durationValue: Double {
      duration.duration
    }
    
    public var duration: FToastDuration = .short
    
    public init() {
      
    }
  }
  
  public enum FToastDuration: Equatable, Hashable {
    case short
    case long
    case custom(Double)
    
    var duration: Double {
      switch self {
        case .short:
          return 1.5
        case .long:
          return 2.75
        case .custom(let value):
          return value
      }
    }
  }
}

public struct FToastViewModifier: ViewModifier {
  
  @Binding var data: FToast.ViewState?
  private var tapGesture: MTapGesture?
  @State private var timer: Timer?
  
  public init(data: Binding<FToast.ViewState?>, tapGesture: MTapGesture?) {
    self._data = data
    self.tapGesture = tapGesture
  }
  
  public func body(content: Content) -> some View {
    ZStack {
      content
        .onChange(of: data) { newValue in
          withAnimation(.linear(duration: 1)) {
            self.timer?.invalidate()
            self.timer = nil
            let duration = newValue?.durationValue ?? 2
            self.timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
              close()
            }
          }
        }
      if $data.isPresent().wrappedValue {
        VStack {
          Spacer()
          FToast(data: $data)
            .onTapButton {
              tapGesture?()
              close()
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
        }
        .transition(
          .asymmetric(
            insertion: AnyTransition.opacity
              .combined(with: AnyTransition.move(edge: .bottom)),
            removal: AnyTransition.opacity
              .combined(with: AnyTransition.move(edge: .bottom))
          )
        )
      }
    }
  }
  
  private func close() {
    self.timer?.invalidate()
    self.timer = nil
    withAnimation(.linear(duration: 3/2)) {
      self.data = nil
    }
  }
}

extension View {
  public func fSnackBar(data: Binding<FToast.ViewState?>, tapGesture: MTapGesture?) -> some View {
    modifier(FToastViewModifier(data: data, tapGesture: tapGesture))
  }
  
  public func fToast(data: Binding<FToast.ViewState?>, tapGesture: MTapGesture?) -> some View {
    modifier(FToastViewModifier(data: data, tapGesture: tapGesture))
  }
}
