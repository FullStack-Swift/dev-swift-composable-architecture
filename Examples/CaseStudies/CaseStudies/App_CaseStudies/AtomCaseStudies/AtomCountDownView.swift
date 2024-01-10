import SwiftUI
import ComposableArchitecture

struct AtomCountDownView: View {
  
  @WatchStateObject(
    MObservableObjectAtom(
      id: sourceId(),
      CountDownAtom(countdow: 100, withTimeInterval: 0.1, isAutoCountdown: false)
    )
  )
  var countdown
  
  var body: some View {
    VStack {
      let phase = countdown.phase
      let value = countdown.value
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
