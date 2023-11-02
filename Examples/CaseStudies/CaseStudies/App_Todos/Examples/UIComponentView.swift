import SwiftUI

struct UIComponentView: View {
  
  var body: some View {
    ZStack {
      List {
        ForEach(0 ..< 30) { item in
          Text("Mask and Transparency")
            .font(.title3).bold()
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .background(Color.white)
      .mask(
        LinearGradient(
          gradient: Gradient(colors: [Color.black, Color.black, Color.black, Color.black.opacity(0)]),
          startPoint: .top,
          endPoint: .bottom
        )
      )
    }
  }
  
}

#Preview {
  UIComponentView()
}
