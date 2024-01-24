import SwiftUI

struct JotaiCaseStudiesView: View {
  var body: some View {
    Form {
      NavigationLink("atom") {
        JotailAtomView()
      }
    }
  }
}

#Preview {
  JotaiCaseStudiesView()
}
