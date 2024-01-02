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
      
      @RecoilWatchState(selectorState(id: id,0))
      var count
      
      let callback = useCallback {
        count += 1
      }
      
      let phase = useRecoilThrowingTask(_recoilValueFamily(count))
      
      VStack {
        LogChangesView()
        Text(testUnit.description)
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
          .onTapGesture {
            testUnit += 1
          }
        
        AsyncPhaseView(phase) { value in
          Text(value)
        } loading: {
          ProgressView()
        } catch: { error in
          Text(error.localizedDescription)
        }
        .frame(height: 100)
        Button(count.description) {
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

