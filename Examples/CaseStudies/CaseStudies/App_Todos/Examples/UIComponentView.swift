import SwiftUI

struct UIComponentView: View {
  
  var body: some View {
    List {
      NavigationLink("MVVMDemo1") {
        MVVMDemo1()
      }
      NavigationLink("MVVMDemo2") {
        MVVMDemo2()
      }
      NavigationLink("MVVMDemo3") {
        MVVMDemo3()
      }
    }
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
#endif
  }
}

#Preview {
  UIComponentView()
}
