import SwiftUI
import Combine

struct HookUseOnChangedExtView: View {
  var body: some View {
    HookScope {
      
      @HState
      var state = 0
      
      let _ = useLayoutEffect(.once) {
        let bounces:[(Int,TimeInterval)] = [
          (0, 0),
          (1, 0.25),  // 0.25s interval since last index
          (2, 1),     // 0.75s interval since last index
          (3, 1.25),  // 0.25s interval since last index
          (4, 1.5),   // 0.25s interval since last index
          (5, 2.1)      // 0.5s interval since last index
        ]
        
        
        let subject = PassthroughSubject<Int, Never>()
        let cancellable = subject
          .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
          .sink { index in
            print ("Received index \(index)")
            state = index
          }
        
        
        for bounce in bounces {
          DispatchQueue.main.asyncAfter(deadline: .now() + bounce.1) {
            subject.send(bounce.0)
//            state = bounce.0
          }
        }
        
        return {
          cancellable.cancel()
        }
      }
      
      let _ = useOnChangedDebounce(state) {
        print("Received state: \(state)")
      }

      Stepper(value: $state) {
        Text(state.description)
      }
      .padding()
      .font(.largeTitle)
      .navigationBarTitle(Text("Hook OnChangedExt"), displayMode: .inline)
    }
  }
}

#Preview {
  HookUseOnChangedExtView()
}
