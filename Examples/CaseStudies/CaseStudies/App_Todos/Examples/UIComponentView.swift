import SwiftUI

struct UIComponentView: View {
  
  var body: some View {
    VScrollView {
      ForEach(1..<100) { _ in
        HScrollView {
          ForEach(1..<100) { _ in
            Color.orange
              .frame(length: 100)
          }
        }
      }
    }
    .frame(maxHeight: .infinity)
  }
}

#Preview {
  UIComponentView()
}
