import SwiftUI

struct HookUseValueChangedView: View {
  var body: some View {
    HookScope {
      
      @HState
      var state = 0
      
      let newValue = useValueChanged(state) { old, new in
        log.info("oldValue: \(old)")
        log.info("newValue: \(new)")
      }
      
      VStack {
        useToggle()
        useInput("task", text: newValue.description) { value in
          log.info(value)
          if let value = value.toInt() {
            state = value
          }
        }
        
        Stepper(value: $state) {
          Text(newValue.description)
        }
      }
      .padding()
      .font(.largeTitle)
    }
  }
}

#Preview {
  HookUseValueChangedView()
}
