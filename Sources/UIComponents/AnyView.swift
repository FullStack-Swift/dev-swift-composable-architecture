#if canImport(UIKit)
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
  func didAppear(perform action: (() -> Void)? = nil ) -> some View {
    self.overlay(ViewController(action: action).disabled(true))
  }
}

fileprivate struct ViewController: UIViewControllerRepresentable {
  let action: (() -> Void)?
  
  func makeUIViewController(context: Context) -> Controller {
    let vc = Controller()
    vc.action = action
    return vc
  }
  
  func updateUIViewController(_ controller: Controller, context: Context) {}
  
  class Controller: UIViewController {
    var action: (() -> Void)? = nil
    
    override func viewDidLoad() {
      view.addSubview(UILabel())
    }
    
    override func viewDidAppear(_ animated: Bool) {
      action?()
    }
  }
}

#endif
