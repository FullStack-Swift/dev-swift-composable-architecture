import SwiftUI

struct HookUseStateView: View {
  
  var body: some View {
    HookScope {
      @HState var state = 0
      Stepper(value: $state.value) {
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
