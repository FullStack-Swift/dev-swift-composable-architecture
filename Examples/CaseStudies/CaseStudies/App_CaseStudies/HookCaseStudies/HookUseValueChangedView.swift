import SwiftUI
import Combine

struct HookUseValueChangedView: View {
  
  var body: some View {
    HookScope {
      
      @HState
      var state = 0
      
      @HRef
      var oldState: Int? = nil
      
      @HRef
      var newState: Int = state
      
      let newValue = useOnChanged(state) { old, new in
        oldState = old
        newState = new
      }
            
      VStack {
        Text("oldValue: \(oldState?.description ?? "Nil")")
        Text("newState: \(newState)")
        Stepper(value: $state) {
          Text(newValue.description)
        }
      }
      .padding()
      .font(.largeTitle)
      .navigationBarTitle(Text("Hook OnChanged"), displayMode: .inline)
    }
  }
}

#Preview {
  HookUseValueChangedView()
}
