import SwiftUI
import ComposableArchitecture

struct TCACaseStudiesView: View {
  var body: some View {
    Form {
      Text("TCA")
    }
#if os(iOS)
    .navigationBarTitle(Text("TCA"), displayMode: .inline)
#endif
  }
}

#Preview {
  TCACaseStudiesView()
}
