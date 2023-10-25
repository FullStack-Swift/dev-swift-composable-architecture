import SwiftUI

struct HookUseCountDownView: View {
    var body: some View {
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
      .navigationBarTitle(Text("Hook Countdown"), displayMode: .inline)
    }
}

#Preview {
  HookUseCountDownView()
}
