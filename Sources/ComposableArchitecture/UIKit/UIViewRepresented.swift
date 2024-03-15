#if canImport(UIKit) && !os(watchOS)
import UIKit
import SwiftUI

public struct UIViewRepresented<UIViewType>: UIViewRepresentable where UIViewType: UIView {
  public let makeUIView: (Context) -> UIViewType
  public let updateUIView: (UIViewType, Context) -> Void = { _, _ in }
  
  public init(makeUIView: @escaping (Context) -> UIViewType) {
    self.makeUIView = makeUIView
  }
  
  public func makeUIView(context: Context) -> UIViewType {
    self.makeUIView(context)
  }
  
  public func updateUIView(_ uiView: UIViewType, context: Context) {
    self.updateUIView(uiView, context)
  }
}

extension UIViewController {
  public func toSwiftUI() -> some View {
    UIViewRepresented(makeUIView: { _ in self.view })
  }
}

extension UIView {
  public func toSwiftUI() -> some View {
    UIViewRepresented(makeUIView: { _ in self })
  }
}

extension UIView {
  func addConstrained(subview: UIView) {
    addSubview(subview)
    subview.translatesAutoresizingMaskIntoConstraints = false
    subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
    subview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    subview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }
}

  /// https://sarunw.com/posts/swiftui-view-as-uiview/
open class SwiftUIView: UIView {

  private var swiftuiView = UIView(frame: .zero)
  
  private var viewModel: MVVMObservable = MVVMObservable()
  
  public var observable: ObservableListener {
    viewModel.observable
  }
  
  open override class func awakeFromNib() {
    super.awakeFromNib()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configurationUI()
  }
  
  public init() {
    super.init(frame: .zero)
    configurationUI()
  }
  
  private func configurationUI() {
    let rootView = self.content.eraseToAnyView()
    let vc = UIHostingController(rootView: rootView)
    swiftuiView = vc.view!
    addConstrained(subview: swiftuiView)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @ViewBuilder
  open var body: any View {
#if DEBUG
    fatalError("please override this property")
#else
    Text("")
#endif
  }
  
  
  @ViewBuilder
  private var content: some View {
    ScopeViewController(viewModel: viewModel) {
      self.body
    }
  }
}

fileprivate extension SwiftUIView {
 
  struct ScopeViewController: View {
    
    @ObservedObject
    var viewModel: MVVMObservable
    
    var content: () -> any View
    
    init(viewModel: MVVMObservable, content: @escaping () -> any View) {
      self.viewModel = viewModel
      self.content = content
    }
    
    var body: some View {
      content().eraseToAnyView()
    }
  }
}

  /// https://sarunw.com/posts/swiftui-view-as-uiview/
open class SwiftUIViewController: UIViewController {
  
  private var swiftuiView = UIView(frame: .zero)
    
  private var viewModel: MVVMObservable = MVVMObservable()
  
  public var observable: ObservableListener {
    viewModel.observable
  }
  
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    let rootView = self.content.eraseToAnyView()
    let vc = UIHostingController(rootView: rootView)
    swiftuiView = vc.view!
    swiftuiView.translatesAutoresizingMaskIntoConstraints = false
    addChild(vc)
    view.addConstrained(subview: swiftuiView)
    vc.didMove(toParent: self)
  }
    
  @ViewBuilder
  open var body: any View {
#if DEBUG
    fatalError("please override this property")
#else
    Text("")
#endif
  }
  
  @ViewBuilder
  private var content: some View {
    ScopeViewController(viewModel: viewModel) {
      self.body
    }
  }
}

fileprivate extension SwiftUIViewController {
 
  struct ScopeViewController: View {
    
    @ObservedObject
    var viewModel: MVVMObservable
    
    var content: () -> any View
    
    init(viewModel: MVVMObservable, content: @escaping () -> any View) {
      self.viewModel = viewModel
      self.content = content
    }
    
    var body: some View {
      content().eraseToAnyView()
    }
  }
}

#if canImport(Combine)
import Combine

open class BaseSwiftUIView: SwiftUIView {
  open var cancellable = Set<AnyCancellable>()
}

open class BaseSwiftUIViewController: SwiftUIViewController {
  open var cancellable = Set<AnyCancellable>()
}
#endif

#endif
