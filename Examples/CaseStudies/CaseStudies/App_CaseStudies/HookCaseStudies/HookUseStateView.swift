import SwiftUI

struct HookUseStateView: View {
  
  var body: some View {
    HookScope {
      @HState var state = 0
      Stepper(value: $state) {
        Text(state.description)
      }
    }
    .padding()
    .font(.largeTitle)
    .navigationBarTitle(Text("Hook HState"), displayMode: .inline)
    
  }
}

#Preview {
  HookUseStateView()
}
