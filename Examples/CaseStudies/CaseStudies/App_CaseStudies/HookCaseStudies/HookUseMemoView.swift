import SwiftUI

struct HookUseMemoView: View {
  var body: some View {
    HookScope {
      
      @HState var state = 0
      
      @HMemo(.preserved(by: state))
      //      @HMemo(.once)
      var randomColor = Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
      
      @HMemo<Color>(.preserved(by: state))
      //      @HMemo<Color>(.once)
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
    .navigationBarTitle(Text("Hook Memo"), displayMode: .inline)
  }
}

#Preview {
    HookUseMemoView()
}
