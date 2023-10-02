import SwiftUI
import ComposableArchitecture

struct AsyncFunctions {
  
  @AddAsync
  func test(arg1: String, completion: (String) -> Void) {

  }
}

struct ContentView: View {
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hello, world!")
    }
    .padding()
    .onAppear {
      let x = 1
      let y = 2
      
      // "Stringify" macro turns the expression into a string.
      print(#stringify(x + y))
      
      let url = #URL("1")
      print(url)
    }
    .task {
      #mWarning("Add Completion in AsycFunction")
//      let result = await AsyncFunctions().test(arg1: "Async")
      #mTodo("Todo")
    }
  }
}

#Preview {
  ContentView()
}
