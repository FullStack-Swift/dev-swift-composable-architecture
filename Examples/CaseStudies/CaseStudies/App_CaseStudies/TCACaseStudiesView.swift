import SwiftUI
import ComposableArchitecture

struct TCACaseStudiesView: View {
  var body: some View {
    Form {
      Text("TCA")
    }
    .navigationBarTitle(Text("TCA"), displayMode: .inline)
  }
}

struct TCACaseStudiesView_Previews: PreviewProvider {
  static var previews: some View {
    TCACaseStudiesView()
  }
}
