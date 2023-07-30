import SwiftUI
import ComposableArchitecture


public func recoilTaskFamilyTest<S,T>(
  _ param: S,
  _ initialState: @escaping (S) -> T
) -> RecoilParamNode<S, MTaskAtom<T>> {
  RecoilParamNode(
    param: param,
    node: MTaskAtom<T>(
      id: sourceId(),
      { context in
        initialState(param)
      }
    )
  )
}

struct ContentView: View {
  
  let id = sourceId()
  
//  let test = recoilTaskFamilyTest<String, Int>("AAA") { params in
//    return params.count
//  }
  
  var body: some View {
    HookScope {
      let node = useRecoilCallback { context in
        return MTaskAtom(id: sourceId()) { con_text async -> String in
          let count = context.watch(MStateAtom(id: id, initialState: 0))
          return count.description
        }
      }
      let count = useRecoilState(MStateAtom(id: id, initialState: 0))
      let phase = useRecoilTask(updateStrategy: .preserved(by: count.wrappedValue), node())
//      let phase = taskFamily<Int, String> { param in
//        return param.description
//      }(count.wrappedValue)
      let callback = useCallback {
        count.wrappedValue += 1
      }
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        AsyncPhaseView(phase: phase) { value in
          Text(value)
        } suspending: {
          ProgressView()
        }
      }
      .padding()
      .onTapGesture {
        callback()
      }
    }
  }
}

#Preview {
  ContentView()
}

@MainActor
public func taskFamily<Param: Equatable, R>(
  _ fn: @escaping (Param) async -> R
) -> (Param) -> AsyncPhase<R,Never> {
  return { param in
    useRecoilTask(updateStrategy: .preserved(by: param)) {
      MTaskAtom(id: sourceId()) { context in
        await fn(param)
      }
    }
  }
}
