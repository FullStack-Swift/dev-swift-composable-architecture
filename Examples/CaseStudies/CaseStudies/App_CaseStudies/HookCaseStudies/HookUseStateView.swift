import SwiftUI

struct HookUseStateView: View {
  
  var body: some View {
    VStack {
      content
        .frame(maxHeight: .infinity)
      contentOther
        .frame(maxHeight: .infinity)
    }
    .padding()
    .font(.largeTitle)
    .navigationBarTitle(Text("Hook HState"), displayMode: .inline)
    
  }
  
  var content: some View {
    HookScope {
      
      @HState var state = 0
      
      @HState<Int> var otherState = {
        0
      }
      
      VStack {
        Stepper(value: $state) {
          Text(state.description)
        }
        
        Stepper(value: $otherState) {
          Text(otherState.description)
        }
      }
    }
  }
  
  var contentOther: some View {
    HookScope {
      
      let state = useState(0)
      
      let otherState = useState {
        0
      }
      
      VStack {
        Stepper(value: state) {
          Text(state.wrappedValue.description)
        }
        
        Stepper(value: otherState) {
          Text(otherState.wrappedValue.description)
        }
      }
    }
  }
}

#Preview {
  HookUseStateView()
}
