import SwiftUI

struct HookUseCountDownView: View {
    var body: some View {
      VStack {
        content
          .frame(maxHeight: .infinity)
        contentOther
          .frame(maxHeight: .infinity)
      }
      .navigationBarTitle(Text("Hook Countdown"), displayMode: .inline)
    }
  
  var content: some View {
    HookScope {
      
      @HCountdown(withTimeInterval: 1)
      var hcountdown = 10
      
      let countdown = $hcountdown.value
      
      let value = useMemo(countdown.value.wrappedValue)
      
      let phase = useMemo(countdown.phase.wrappedValue)
      
      VStack {
        viewBuilder {
          switch phase {
            case .pending:
              Text("Pending")
            case .start(let value):
              Text(Int(value).description)
            case .stop:
              Text("Stop")
            case .cancel:
              Text("Cancel")
            case .process(let value):
              Text(Int(value).description)
            case .completion:
              Text("Completion")
          }
        }
        .font(.largeTitle)
        
        Text(Int(value).description)
          .font(.largeTitle)
        
        Spacer()
        
        HStack {
          Button("Start") {
            countdown.start()
          }
          Button("Stop") {
            countdown.stop()
          }
          Button("Play") {
            countdown.play()
          }
          Button("Cancel") {
            countdown.cancel()
          }
        }
        .font(.subheadline)
        
        Spacer()
          .frame(height: 100)
      }
      .padding()
    }
  }
  
  var contentOther: some View {
    HookScope {
      let countdown = useCountdown(countdown: 10, withTimeInterval: 1)
      let value = useMemo(countdown.value.wrappedValue)
      VStack {
        viewBuilder {
          switch countdown.phase.wrappedValue {
            case .pending:
              Text("Pending")
            case .start(let value):
              Text(Int(value).description)
            case .stop:
              Text("Stop")
            case .cancel:
              Text("Cancel")
            case .process(let value):
              Text(Int(value).description)
            case .completion:
              Text("Completion")
          }
        }
        .font(.largeTitle)
        
        Text(Int(value).description)
          .font(.largeTitle)
        
        Spacer()
        
        HStack {
          Button("Start") {
            countdown.start()
          }
          Button("Stop") {
            countdown.stop()
          }
          Button("Play") {
            countdown.play()
          }
          Button("Cancel") {
            countdown.cancel()
          }
        }
        .font(.subheadline)
        
        Spacer()
          .frame(height: 100)
      }
      .padding()
    }
  }
}

#Preview {
  HookUseCountDownView()
}
