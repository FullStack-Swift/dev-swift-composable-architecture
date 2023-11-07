import SwiftUI

struct HookUseAsyncView: View {
  var body: some View {
    HookScope {
      @HState var state = false
      
      @HUseAsync(.preserved(by: state))
      var phase = blockBuilder { () -> Int in
        try? await Task.sleep(seconds: 2)
        return Int.random(in: 1...1000)
      }
      
      //      let phase = useAsync(.preserved(by: state)) { () -> Int in
      //        try? await Task.sleep(seconds: 2)
      //        return Int.random(in: 1...1000)
      //      }
      VStack {
        Toggle("Use HAsyncPhase", isOn: $state.value)
        viewBuilder {
          switch $phase.value {
            case .success(let value):
              Text(value.description)
            case .running:
              ProgressView()
            default:
              ProgressView()
          }
        }
        .frame(height: 50)
      }
      .padding()
      .alignment(.center)
    }
    .navigationBarTitle(Text("Hook Async"), displayMode: .inline)
  }
}
#Preview {
  HookUseAsyncView()
}
