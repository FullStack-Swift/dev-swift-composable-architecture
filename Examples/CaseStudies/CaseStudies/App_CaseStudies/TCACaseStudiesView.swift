import SwiftUI


struct TCACaseStudiesView: View {
  var body: some View {
    Text("TCA")
#if os(iOS)
    .navigationBarTitle(Text("TCA"), displayMode: .inline)
#endif
  }
}

#Preview {
  TCACaseStudiesView()
}
