import SwiftUI
import ComposableArchitecture

struct ContentView: View {
  
  let id = sourceId()
  var family: (Int) -> MParamTaskAtom<Int, String> {
    return { param in
      var node = {
        MParamTaskAtom(id: UUID().uuidString, param: param) {context, varg in
          let count = await context.watch(MStateAtom(id: id, initialState: 0))
          try? await Task.sleep(nanoseconds: 1_000_000_000)
          let value = count + Int.random(in: 1..<100)
//          print(varg)
          return varg.description
        }
      }
      let ccc = node()
      print(ccc.param)
      return ccc
      ////      let node = MTaskAtom(id: sourceId()) {  [param] context in
      ////        let count = await context.watch(MStateAtom(id: id, initialState: 0))
      ////        try? await Task.sleep(nanoseconds: 1_000_000_000)
      ////        let value = count + Int.random(in: 1..<100)
      ////        print(param)
      ////        return value.description
      ////      }
      //      return RecoilParamNode<Int, MParamTaskAtom<Int, String>>(param: param, node: node)
    }
  }
  
//  let family = recoilTaskFamily<Int, String> { [id] context, param in
////    let count = await context.watch(MStateAtom(id: id, initialState: 0))
////    try? await Task.sleep(nanoseconds: 1_000_000_000)
////    let value = count + Int.random(in: 1..<100)
////    print(param)
////    return value.description
//    return param
//  }
  
  
  
  var body: some View {
    HookScope {
      
      let node = useRecoilCallback { context in
        return MTaskAtom(id: sourceId()) { con_text async -> String in
          let count = await context.watch(MStateAtom(id: id, initialState: 0))
//          try? await Task.sleep(nanoseconds: 1_000_000_000)
//          let value = count + Int.random(in: 1..<100)
//          return value.description
          return count.description
        }
      }
      
      let count = useRecoilState(MStateAtom(id: id, initialState: 0))
      var phase = useRecoilTask(family(count.wrappedValue))
//      let phase = useRecoilTask(updateStrategy: .preserved(by: count.wrappedValue), node())
//      let phase = useRecoilTask(updateStrategy: .preserved(by: count.wrappedValue), MTaskAtom(id: sourceId(), { context -> String in
//        try! await Task.sleep(nanoseconds: 1_000_000_000)
//        let value = count.wrappedValue + Int.random(in: 1..<100)
//        return value.description
//      }))
      let callback = useCallback {
        count.wrappedValue += 1
        phase = useRecoilTask(family(count.wrappedValue))
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
