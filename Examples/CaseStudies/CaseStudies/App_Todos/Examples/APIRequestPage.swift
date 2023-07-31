import SwiftUI
import Combine
import ComposableArchitecture

struct Post: Codable {
  let id: Int
  let title: String
  let body: String
}

struct APIRequestPage: View {
  typealias Mtask = MTaskAtom<Int>
  
  var body: some View {
    HookScope {
      let atomFamily = RecoilParamNode<Int, MTaskAtom<String>>(param: 1, node: MTaskAtom(id: sourceId(), { context in
        return Int.random(in: 1..<1000).description
      }))
//      let atomFamily = MTaskAtom<String>(id: "") {
//        try! await Task.sleep(for: .seconds(2))
//        return Int.random(in: 1..<1000).description
//      }
      let phase = useRecoilTask(atomFamily)
      switch phase {
        case .success(let value):
          Text(value)
        case .failure(let error):
          Text(error.localizedDescription)
        default:
          ProgressView()
      }
    }
  }
}

//class PostStreamProvider: StreamProvider<[Post]> {
//
//  init() {
//    super.init {
//      let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
//      let decoder = JSONDecoder()
//      let (data, _) = try await URLSession.shared.data(from: url)
//      return try decoder.decode([Post].self, from: data)
//    }
//  }
//}
//
//class PostFutureProvider: FutureProvider<AnyPublisher<[Post], any Error>> {
//
//  init() {
//    super.init {
//      let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
//      let decoder = JSONDecoder()
//      return URLSession.shared.dataTaskPublisher(for: url)
//        .tryMap({ try decoder.decode([Post].self, from: $0.data)})
//        .eraseToAnyPublisher()
//    }
//  }
//}
//
//
//struct APIRequestPage: RiverpodView {
//
//  //  let stream = PostStreamProvider()
//  let stream = PostFutureProvider()
//
//  func build(context: Context, ref: ViewRef) -> some View {
////        let phase = ref.watch(stream)
//
//    let state = StateProvider<AsyncPhase<[Post], Error>> { context in
//      context.watch(stream)
//    }
//    let phase = state.value
//    ScrollView {
//      VStack {
//        switch phase {
//          case .suspending:
//            ProgressView()
//
//          case .success(let posts):
//            postRows(posts)
//
//          case .failure(let error):
//            errorRow(error, retry: {
//              stream.refresh()
//            })
//        }
//      }
//      .padding(.vertical, 16)
//      .padding(.horizontal, 24)
//    }
//    .onAppear {
//      stream.refresh()
//    }
//    .navigationTitle("API Request")
//    .background(Color(.systemBackground).ignoresSafeArea())
//  }
//
//  func postRows(_ posts: [Post]) -> some View {
//    ForEach(posts, id: \.id) { post in
//      VStack(alignment: .leading) {
//        Text(post.title).bold()
//        Text(post.body).padding(.vertical, 16)
//        Divider()
//      }
//      .frame(maxWidth: .infinity)
//    }
//  }
//
//  func errorRow(_ error: Error, retry: @escaping () async -> Void) -> some View {
//    VStack {
//      Text("Error: \(error.localizedDescription)")
//        .fixedSize(horizontal: false, vertical: true)
//
//      Divider()
//
//      Button("Refresh") {
//        Task {
//          await retry()
//        }
//      }
//    }
//  }
//}


struct TestViewexample: View {
  var body: some View {
    NavigationLink(destination: ExampleActionStateListenerView()) {
      Text("Tap")
    }
  }
}

class Test_Observable: ObservableObject {
  
  enum Action {
    case increment
    case decrement
  }
  
  @ActionListener<Action>
  var action
  
  var Test_action = ActionListener<Action>()
  
}

struct ExampleActionStateListenerView: View {
  
  @ObservedObject var viewModel = Test_Observable()
  
  init() {
    viewModel.action.sink { action in
      print(action)
    }
  }
  
  var body: some View {
    HookScope {
      HStack {
        Button("-") {
          viewModel.action.send(.decrement)
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
          viewModel.action.send(.increment)
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
    viewModel.action.sink { action in
      if action == .decrement {
        ref.current = UUID().uuidString
        subscribe()
      }
    }
    
    let sendAction = useCallback {
      viewModel.action.send(.decrement)
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
    
    viewModel.action.sink { action in
      if action == .increment {
        ref.current = UUID().uuidString
        subscribe()
      }
    }
    
    let sendAction = useCallback {
      viewModel.action.send(.increment)
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
      viewModel.action.send(.decrement)
      viewModel.action.send(.increment)
      return Int.random(in: 1..<1000)
    }
    
    return Text(ref.current.description)
      .onTapGesture {
        ref.current = callback()
      }
  }
}
