import SwiftUI

struct HookUseInitalAndDisposeView: View {
  var body: some View {
    HookScope {
      let _ = useInital {
        
      }
      
      let _ = useDispose {
        
      }
      
      Text("Empty")
    }
    .navigationBarTitle(Text("Hook InitalAndDispose"), displayMode: .inline)
  }
}

#Preview {
  HookUseInitalAndDisposeView()
}
