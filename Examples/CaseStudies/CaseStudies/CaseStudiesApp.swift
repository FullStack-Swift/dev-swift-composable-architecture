import SwiftUI
import Combine
import ComposableArchitecture

@main
struct CaseStudiesApp: App {
  var body: some Scene {
    WindowGroup {
      HookRoot {
        AtomRoot {
//          ContentView()
          ExampleActionStateListenerView()
        }
      }
    }
  }
}

struct ExampleActionStateListenerView: View {
  
  enum Action {
    case increment
    case decrement
  }
  
  @ActionListener<Action>
  private var action
  
  init() {
    action.sink { action in
      print(action)
    }
  }
  
  var body: some View {
    HookScope {
      HStack {
        Button("-") {
          action.send(.decrement)
        }
        .font(.largeTitle)
        .padding()
        Spacer()
        VStack {
          AnyView(contentDecrement)
            .frame(height: 100)
          callBackView
          AnyView(contentIncrement)
            .frame(height: 100)
        }
        Spacer()
        Button("+") {
          action.send(.increment)
        }
        .font(.largeTitle)
        .padding()
      }
      .padding()
    }
  }
  
  var contentDecrement: any View {
    let ref = useRef("")
    let (phase, subscribe) = usePublisherSubscribe {
      Just(ref.current)
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
    }
    action.sink { action in
      if action == .decrement {
        ref.current = UUID().uuidString
        subscribe()
      }
    }
    
    let sendAction = useCallback {
      action.send(.decrement)
    }
    switch phase {
      case .running:
        return ProgressView {
          Text("decrement")
        }
      case .success(let uuid):
        return VStack {
          Text(uuid)
            .frame(height: 60)
          Button("Random decrement") {
            sendAction()
          }
        }
      case .pending:
        return EmptyView()
    }
    
  }
  
  var contentIncrement: any View {
    let ref = useRef("")
    let (phase, subscribe) = usePublisherSubscribe {
      Just(ref.current)
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
    }
    
    action.sink { action in
      if action == .increment {
        ref.current = UUID().uuidString
        subscribe()
      }
    }
    
    let sendAction = useCallback {
      action.send(.increment)
    }
    
    switch phase {
      case .running:
        return ProgressView {
          Text("increment")
        }
      case .success(let uuid):
        return VStack {
          Text(uuid)
            .frame(height: 60)
          Button("Random increment") {
            sendAction()
          }
        }
      case .pending:
        return EmptyView()
    }
  }
  
  var callBackView: some View {
    let ref = useRef(0)
    let callback = useCallback {
      print(ref.current.description)
      action.send(.decrement)
      action.send(.increment)
      return Int.random(in: 1..<1000)
    }
    
    return Text(ref.current.description)
      .onTapGesture {
        ref.current = callback()
      }
  }
}
