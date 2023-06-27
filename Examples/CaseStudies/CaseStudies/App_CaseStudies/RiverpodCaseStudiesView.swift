import SwiftUI
import ComposableArchitecture

struct RiverpodCaseStudiesView: View {
  var body: some View {
    Text("Riverpod")
      .navigationBarTitle(Text("Riverpod"), displayMode: .inline)
  }
}

struct RiverpodCaseStudiesView_Previews: PreviewProvider {
  static var previews: some View {
    RiverpodCaseStudiesView()
  }
}
