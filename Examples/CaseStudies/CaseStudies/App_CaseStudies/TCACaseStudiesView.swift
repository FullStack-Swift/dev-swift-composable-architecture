import SwiftUI


struct TCACaseStudiesView: View {
  var body: some View {
    AtomLoadMoreView()
#if os(iOS)
    .navigationBarTitle(Text("TCA"), displayMode: .inline)
#endif
  }
}

#Preview {
  TCACaseStudiesView()
}
