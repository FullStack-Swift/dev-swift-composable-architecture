import SwiftUI
import Observation
import SwiftObservation
import ComposableArchitecture

struct TheMovieView: View {
  var body: some View {
    AuthView()
  }
}

//
//struct AsyncFunctions {
//  
//  @AddAsync
//  func test(arg1: String, completion: (String) -> Void) {
//
//  }
//}
//
//@Observable 
//final class Person {
//  var name: String
//  var age: Int
//  
//  init(name: String, age: Int) {
//    self.name = name
//    self.age = age
//  }
//}
//
//struct ContentView: View {
//  private var person = Person(name: "Tom", age: 12)
//  var body: some View {
//    VStack {
//      Image(systemName: "globe")
//        .imageScale(.large)
//        .foregroundColor(.accentColor)
//      Text("Hello, world!")
//      observationView
//    }
//    .padding()
//    .onAppear {
//      let x = 1
//      let y = 2
//      
//      // "Stringify" macro turns the expression into a string.
//      print(#stringify(x + y))
//      
//      let url = #URL("1")
//      print(url)
//    }
//    .task {
//      #mWarning("Add Completion in AsycFunction")
////      let result = await AsyncFunctions().test(arg1: "Async")
////      #mTodo("Todo")
//    }
//  }
//  
//  var observationView: some View {
//    ObservationView {
//      VStack {
//        Text(person.name)
//        Text("\(person.age)")
//        HStack {
//          Button("+") { person.age += 1 }
//          Button("-") { person.age -= 1 }
//        }
//      }
//      .padding()
//    }
//  }
//  
//}
//
//#Preview {
//  ContentView()
//}
