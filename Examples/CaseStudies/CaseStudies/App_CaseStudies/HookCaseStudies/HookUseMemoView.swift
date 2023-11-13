import SwiftUI

struct HookUseMemoView: View {
  var body: some View {
    VStack {
      content
      contentOther
    }
    .padding()
    .font(.largeTitle)
    .navigationBarTitle(Text("Hook Memo"), displayMode: .inline)
  }
  
  var content: some View {
    HookScope {
      
      @HState var state = 0
      
      /// @HMemo(.once)
      @HMemo(.preserved(by: state))
      var randomColor = Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
      
      /// @HMemo<Color>(.once)
      @HMemo<Color>(.preserved(by: state))
      var randomColor2 = {
        Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
      }
      
      VStack {
        Stepper(value: $state) {
          Text(state.description)
        }
        randomColor
        randomColor2
      }
      
    }
  }
  
  var contentOther: some View {
    HookScope {
      
      let state = useState(0)
      
      let randomColor = useMemo(.preserved(by: state.wrappedValue)) {
        Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
      }
      
      let randomColor2 = useMemo(.preserved(by: state.wrappedValue)) {
        Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
      }
      
      VStack {
        Stepper(value: state) {
          Text(state.wrappedValue.description)
        }
        randomColor
        randomColor2
      }
    }
  }
  
}

#Preview {
  HookUseMemoView()
}
