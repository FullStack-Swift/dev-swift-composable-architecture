import SwiftUI

public struct FAlert: View {
  
  @Binding var data: FAlert.ViewState?
  
  var tapGesture: MTapGesture?
  
  @State var cacheData: FAlert.ViewState?
  
  init(data: Binding<FAlert.ViewState?>, tapGesture: MTapGesture? = nil) {
    self._data = data
    self._cacheData = State(initialValue: data.wrappedValue)
    self.tapGesture = tapGesture
  }
  
  public var body: some View {
    let data = cacheData
    ZStack {
      VStack(spacing: 0) {
        if let color = data?.backgroundColor {
          color
            .frame(height: 44)
            .frame(maxWidth: .infinity)
        }
        HStack(spacing: 0) {
          if let image = data?.image {
            VStack {
              Image(systemName: image)
                .foregroundColor(.white)
                .frame(width: 24, height: 24, alignment: .center)
              Spacer()
            }
          }
          Spacer()
            .frame(width: 8)
          if let title = data?.title {
            Text(title)
              .foregroundColor(.white)
          }
          if let buttonTitle = data?.buttonTitle, !buttonTitle.isEmpty {
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
          } else {
            Spacer()
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
          IfLet(data?.backgroundColor, content: { color in
            color
          })
        )
      }
    }
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

extension FAlert {
  /// Model Data for Toast Message.
  public struct ViewState: MViewStateProtocol {
    
    public var id: String = UUID().uuidString
    
    public var title: String?
    
    public var buttonTitle: String?
    
    public var image: String?
    
    public var foregroundColor: Color?
    
    public var backgroundColor: Color?
    
    public var tapToDismiss: Bool = true
    
    public var durationValue: Double {
      duration.duration
    }
    
    public var duration: FAlertDuration = .short
    
    public init() {
      
    }
    
    public static func warning(title: String) -> Self {
      .init()
      .with {
        $0.image = "exclamationmark.circle.fill"
        $0.title = title
        $0.buttonTitle = ""
        $0.backgroundColor = "#FFAA38".toColor()
      }
    }
    
    public static func fail(title: String) -> Self {
      .init()
      .with {
        $0.image = "exclamationmark.triangle.fill"
        $0.title = title
        $0.buttonTitle = ""
        $0.backgroundColor = "#FF4D4D".toColor()
      }
    }
    
    
    public static func success(title: String) -> Self {
      .init()
      .with {
        $0.image = "checkmark.circle.fill"
        $0.title = title
        $0.buttonTitle = ""
        $0.backgroundColor = "#0FD186".toColor()
      }
    }
  }
  
  public enum FAlertDuration: Equatable, Hashable {
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

public struct FAlertViewModifier: ViewModifier {
  
  @Binding var data: FAlert.ViewState?
  private var tapGesture: MTapGesture?
  @State private var timer: Timer?
  
  public init(data: Binding<FAlert.ViewState?>, tapGesture: MTapGesture?) {
    self._data = data
    self.tapGesture = tapGesture
  }
  
  public func body(content: Content) -> some View {
    ZStack(alignment: .top) {
      content
        .zIndex(-1)
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
        VStack(spacing: 0) {
          FAlert(data: $data)
            .onTapButton {
              tapGesture?()
              close()
            }
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
              if data?.tapToDismiss == true {
                close()
              }
            }
          Spacer(minLength: 0)
        }
        .zIndex(1)
        .transition(
          .asymmetric(insertion: AnyTransition.opacity
            .combined(with: AnyTransition.move(edge: .top)),
                      removal: AnyTransition.identity
            .combined(with: AnyTransition.move(edge: .top)))
        )
      }
    }
    .clipped()
    .ignoresSafeArea()
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
  public func fAlert(
    data: Binding<FAlert.ViewState?>,
    tapGesture: MTapGesture?,
    completion: MCompletion<String?>?
  ) -> some View {
    modifier(
      FAlertViewModifier(data: data) {
        tapGesture?()
        completion?(data.wrappedValue?.id)
      }
    )
  }
}
