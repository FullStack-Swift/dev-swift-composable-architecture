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
