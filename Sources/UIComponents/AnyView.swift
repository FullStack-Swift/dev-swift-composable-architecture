#if canImport(UIKit) && !os(watchOS)
import SwiftUI
import UIKit

struct AnyUIView<Wrapper : UIView>: UIViewRepresentable {
  typealias Updater = (Wrapper, Context) -> Void
  
  var makeView: () -> Wrapper
  var update: (Wrapper, Context) -> Void
  
  init(_ makeView: @escaping @autoclosure () -> Wrapper,
       updater update: @escaping (Wrapper) -> Void) {
    self.makeView = makeView
    self.update = { view, _ in update(view) }
  }
  
  func makeUIView(context: Context) -> Wrapper {
    makeView()
  }
  
  func updateUIView(_ view: Wrapper, context: Context) {
    update(view, context)
  }
}

public extension View {
  func didLoad(perform didLoad: (() -> Void)? = nil ) -> some View {
    self.overlay(ViewController(didLoad: didLoad).disabled(true))
  }
  
  func willAppear(perform willAppear: (() -> Void)? = nil ) -> some View {
    self.overlay(ViewController(willAppear: willAppear).disabled(true))
  }
  
  func didAppear(perform didAppear: (() -> Void)? = nil ) -> some View {
    self.overlay(ViewController(didAppear: didAppear).disabled(true))
  }
  
  func willDisappear(perform willDisappear: (() -> Void)? = nil ) -> some View {
    self.overlay(ViewController(willDisappear: willDisappear).disabled(true))
  }
  
  func didDisappear(perform didDisappear: (() -> Void)? = nil ) -> some View {
    self.overlay(ViewController(didDisappear: didDisappear).disabled(true))
  }
}

fileprivate struct ViewController: UIViewControllerRepresentable {
  
  var didLoad: (() -> Void)? = nil
  var willAppear: (() -> Void)? = nil
  var didAppear: (() -> Void)? = nil
  var willDisappear: (() -> Void)? = nil
  var didDisappear: (() -> Void)? = nil
  
  func makeUIViewController(context: Context) -> Controller {
    let vc = Controller()
    vc.didLoad = didLoad
    vc.willAppear = willAppear
    vc.didAppear = didAppear
    vc.willDisappear = willDisappear
    vc.didDisappear = didDisappear
    return vc
  }
  
  func updateUIViewController(_ controller: Controller, context: Context) {}
  
  class Controller: UIViewController {
    
    var didLoad: (() -> Void)? = nil
    var willAppear: (() -> Void)? = nil
    var didAppear: (() -> Void)? = nil
    var willDisappear: (() -> Void)? = nil
    var didDisappear: (() -> Void)? = nil
    
    override func viewDidLoad() {
      view.addSubview(UILabel())
      didLoad?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
      willAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      didAppear?()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      willDisappear?()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      didDisappear?()
    }
  }
}
#endif
