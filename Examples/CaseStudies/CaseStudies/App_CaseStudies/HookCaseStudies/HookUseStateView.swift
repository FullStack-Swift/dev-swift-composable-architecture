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
    .navigationBarTitle(Text("Hook State"), displayMode: .inline)
    
  }
  
  var content: some View {
    HookScope {
      
      @HState var state = 0
      
      @HState<Int> var otherState = {
        0
      }
      
      @HState var toggle = false
      
      @HLogger
      var log = toggle
      
      @HLogger(.preserved(by: toggle))
      var otherLog = toggle
      
      VStack {
        Stepper(value: $state) {
          Text(state.description)
        }
        
        Stepper(value: $otherState) {
          Text(otherState.description)
        }
        
        Toggle("", isOn: $toggle)
          .toggleStyle(.switch)
      }
    }
  }
  
  var contentOther: some View {
    HookScope {
      
      let state = useState(0)
      
      let otherState = useState {
        0
      }
      
      let toggle = useState(false)
      
      let _ = useLogger(nil, toggle.wrappedValue)
      
      let _ = useLogger(.preserved(by: toggle.wrappedValue), toggle.wrappedValue)
      
      VStack {
        Stepper(value: state) {
          Text(state.wrappedValue.description)
        }
        
        Stepper(value: otherState) {
          Text(otherState.wrappedValue.description)
        }
        
        Toggle("", isOn: toggle)
          .toggleStyle(.switch)
      }
    }
  }
}

#Preview {
  HookUseStateView()
}
