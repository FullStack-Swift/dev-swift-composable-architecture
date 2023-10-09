import SwiftUI
import ComposableArchitecture

@MainActor
let _recoilValueFamily = recoilThrowingTaskFamily { (param: Int, context) async throws -> String in
  try? await Task.sleep(nanoseconds: 1_000_000_000)
  return (param * 10).description
}

struct ContentView: View {
  
  let id = sourceId()
  let taskID = sourceId()
  
  @State private var testUnit: Int = 0
  
  var body: some View {
    content
    content
  }
  
  @MainActor
  var content: some View {
    HookScope {
      let _ = useOnLastAppear {
        print("useOnLastAppear")
      }
      let count = useRecoilState(MStateAtom(id: id, 0))
      
      let callback = useCallback {
        count.wrappedValue += 1
      }
      
      let phase = useRecoilThrowingTask(_recoilValueFamily(count.wrappedValue))
      
      VStack {
        LogChangesView()
        Text(testUnit.description)
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
          .onTapGesture {
            testUnit += 1
          }
        
        AsyncPhaseView(phase: phase) { value in
          Text(value)
        } suspending: {
          ProgressView()
        } failureContent: { error in
          Text(error.localizedDescription)
        }
        .frame(height: 100)
        Button(count.wrappedValue.description) {
          callback()
        }
      }
      .padding()
    }
  }
}

#Preview {
  ContentView()
}

