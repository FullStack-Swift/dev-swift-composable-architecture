import SwiftUI
import Combine
import ComposableArchitecture

typealias ColorSchemeContext = HookContext<Binding<ColorScheme>>

struct HookCaseStudiesView: View {
  var body: some View {
    HookScope {
      
      let colorScheme = useState(useEnvironment(\.colorScheme))
      ColorSchemeContext.Provider(value: colorScheme) {
        ScrollView {
          VStack {
            Group {
              HookTitleView(title: "useState UseCase")
              useStateView
              useSetStateView
              useBindingStateView
            }
            Group {
              HookTitleView(title: "useReducer UseCase")
              useReducerReduxView
              useReducerTCAView
              useReducerProtocolView
            }
            
            Group {
              HookTitleView(title: "usePublisher UseCase")
              usePublisherView
              usePublisherSubscribeView
            }
            
            Group {
              HookTitleView(title: "useAsync UseCase")
              useAsyncView
              useAsyncPerformView
            }
            
            Group {
              HookTitleView(title: "useRef UseCase")
              useRefView
              HookTitleView(title: "useMemo UseCase")
              useMemoView
              HookTitleView(title: "useEffect UseCase")
              useEffectView
              HookTitleView(title: "useContext UseCase")
              useContextView
              HookTitleView(title: "useEnvironment UseCase")
              useEnvironmentView
            }
          }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
      }
      .colorScheme(colorScheme.wrappedValue)
    }
    //    .disableHooksRulesAssertion(true)
  }
  
  var useStateView: some View {
    let count = useState(0)
    return HookRowView("useState") {
      Stepper(value: count) {
        Text(count.wrappedValue.description)
      }
    }
  }
  
  var useSetStateView: some View {
    let (count, setCount) = useSetState(0)
    return HookRowView("useSetState") {
      Stepper(value: Binding(get: {count}, set: { value, _ in
        setCount(value)
      })) {
        Text(count.description)
      }
    }
  }
  
  var useBindingStateView: some View {
    let count = useBindingState(0)
    return HookRowView("useBindingState") {
      Stepper(value: count) {
        Text(count.wrappedValue.description)
      }
    }
  }
  
  var useReducerReduxView: some View {
    enum Action {
      case increment
      case decrement
    }
    
    typealias State = Int
    
    func reducer(state: State, action: Action) -> State {
      switch action {
        case .increment:
          return state + 1
        case .decrement:
          return state - 1
      }
    }
    
    let (state, dispatch) = useReducer(reducer, initialState: 0)
    
    return HookRowView("useReducer redux") {
      Text(state.description)
        .bold()
        .font(.largeTitle)
        .foregroundColor(.green)
      Spacer()
      Button {
        dispatch(.decrement)
      } label: {
        Image(systemName: "minus")
          .bold()
          .font(.title)
          .foregroundColor(.green)
      }
      Button {
        dispatch(.increment)
      } label: {
        Image(systemName: "plus")
          .bold()
          .font(.title)
          .foregroundColor(.green)
      }
    }
  }
  
  var useReducerTCAView: some View {
    
    enum Action {
      case increment
      case decrement
    }
    
    typealias State = Int
    
    func reducer(state: inout State, action: Action) {
      switch action {
        case .increment:
          state += 1
        case .decrement:
          state -= 1
      }
    }
    
    let (state, dispatch) = useReducer(reducer, initialState: 0)
    
    return HookRowView("useReducer tca") {
      Text(state.description)
        .bold()
        .font(.largeTitle)
        .foregroundColor(.green)
      Spacer()
      Button {
        dispatch(.decrement)
      } label: {
        Image(systemName: "minus")
          .bold()
          .font(.title)
          .foregroundColor(.green)
      }
      Button {
        dispatch(.increment)
      } label: {
        Image(systemName: "plus")
          .bold()
          .font(.title)
          .foregroundColor(.green)
      }
      
    }
  }
  
  var useReducerProtocolView: some View {
    
    struct CountReducer: ReducerProtocol {
      
      enum Action {
        case increment
        case decrement
      }
      
      typealias State = Int
      
      var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
          switch action {
            case .decrement:
              state -= 1
              return .fireAndForget {
                print("decrement")
              }
            case .increment:
              state += 1
              return .fireAndForget {
                print("increment")
              }
          }
        }
      }
    }
    
    let store = useReducerProtocol(initialState: 0, CountReducer())
    
    let viewStore = ViewStore(store)
    
    return VStack {
      HookRowView("useReducerProtocol store.commit") {
        Text(viewStore.state.description)
          .bold()
          .font(.largeTitle)
          .foregroundColor(.green)
        Spacer()
        Button {
          store.commit {
            $0 -= 1
          }
        } label: {
          Image(systemName: "minus")
            .bold()
            .font(.title)
            .foregroundColor(.green)
        }
        Button {
          store.commit {
            $0 += 1
          }
        } label: {
          Image(systemName: "plus")
            .bold()
            .font(.title)
            .foregroundColor(.green)
        }
      }
      HookRowView("useReducerProtocol viewstore.send") {
        Text(viewStore.state.description)
          .bold()
          .font(.largeTitle)
          .foregroundColor(.green)
        Spacer()
        Button {
          viewStore.send(.decrement)
        } label: {
          Image(systemName: "minus")
            .bold()
            .font(.title)
            .foregroundColor(.green)
        }
        Button {
          viewStore.send(.increment)
        } label: {
          Image(systemName: "plus")
            .bold()
            .font(.title)
            .foregroundColor(.green)
        }
      }
    }
  }
  
  var useRefView: some View {
    let state = useRef(0)
    return HookRowView("userRef") {
      Text(state.current.description)
        .bold()
        .font(.largeTitle)
        .foregroundColor(.green)
      Spacer()
      Button {
        state.current -= 1
      } label: {
        Image(systemName: "minus")
          .bold()
          .font(.title)
          .foregroundColor(.green)
      }
      Button {
        state.current += 1
      } label: {
        Image(systemName: "plus")
          .bold()
          .font(.title)
          .foregroundColor(.green)
      }
    }
  }
  
  var useMemoView: some View {
    let state = useMemo(.once) {
      UUID().uuidString
    }
    let uuid = UUID().uuidString
    let flag = useState(false)
    let randomColor = useMemo(.preserved(by: flag.wrappedValue)) {
      Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)
    }
    return VStack {
      HookRowView("no useMemo") {
        Text(uuid)
      }
      HookRowView("useMemo") {
        Text(state)
      }
      HookRowView("useMemo") {
        HStack {
          Circle()
            .foregroundColor(randomColor)
            .frame(width: 100, height: 100, alignment: .center)
          Spacer()
          Button {
            flag.wrappedValue.toggle()
          } label: {
            Text("Random")
          }
        }
      }
    }
  }
  
  var useEffectView: some View {
    let count = useState(0)
    let isAutoIncrement = useState(false)
    
    useEffect(.preserved(by: isAutoIncrement.wrappedValue)) {
      guard isAutoIncrement.wrappedValue else { return nil }
      
      let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        count.wrappedValue += 1
      }
      
      return timer.invalidate
    }
    
    return HookRowView("useEffect") {
      VStack(alignment: .center,spacing: 50) {
        HStack {
          Spacer()
        }
        Text(String(format: "%02d", count.wrappedValue))
          .lineLimit(1)
          .minimumScaleFactor(0.1)
          .font(.system(size: 100, weight: .heavy, design: .monospaced))
          .padding(30)
          .frame(width: 200, height: 200)
          .background(Color(.secondarySystemBackground))
          .clipShape(Circle())
        
        Stepper(value: count, in: 0...(.max), label: EmptyView.init).fixedSize()
        
        Toggle("Auto +", isOn: isAutoIncrement).fixedSize()
      }
      
    }
  }
  
  var useContextView: some View {
    let colorScheme = useContext(ColorSchemeContext.self)
    return HookRowView("useContext") {
      Picker("Color Scheme", selection: colorScheme) {
        ForEach(ColorScheme.allCases, id: \.self) { scheme in
          Text("\(scheme)".description)
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }
  
  var useEnvironmentView: some View {
    let locale = useEnvironment(\.locale)
    return HookRowView("useEnvironment") {
      Text("Current Locale = \(locale.identifier)")
    }
  }
  
  //  var usePublisherView: some View {
  //    let phase = usePublisher(.once) {
  //      Timer.publish(every: 1, on: .main, in: .common)
  //        .autoconnect()
  //        .prepend(Date())
  //    }
  //
  //    let formatter = DateFormatter()
  //    formatter.dateStyle = .none
  //    formatter.timeStyle = .medium
  //
  //    return HookRowView("usePublisher") {
  //      if case .success(let date) = phase {
  //        Text(formatter.string(from: date))
  //      }
  //    }
  //  }
  
  var usePublisherView: some View {
    let phase = usePublisher(.once) {
      Just(UUID())
        .map(\.uuidString)
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
    }
    return HookRowView("usePublisher") {
      HStack {
        switch phase {
          case .running:
            ProgressView()
          case .success(let uuid):
            Text(uuid)
          case .pending:
            EmptyView()
        }
      }
      .frame(height: 68)
    }
  }
  
  var usePublisherSubscribeView: some View {
    let (phase, subscribe) = usePublisherSubscribe {
      Just(UUID())
        .map(\.uuidString)
        .delay(for: .seconds(1), scheduler: DispatchQueue.main)
    }
    return HookRowView("usePublisherSubscribe") {
      HStack {
        switch phase {
          case .running:
            ProgressView()
          case .success(let uuid):
            Text(uuid)
          case .pending:
            EmptyView()
        }
        Spacer()
        switch phase {
          case .success:
            Button("Random", action: subscribe)
          default:
            ProgressView()
        }
      }
      .frame(height: 68)
      .task { @MainActor in
        subscribe()
      }
    }
  }
  
  var useAsyncView: some View {
    
    struct ErrorCode: Error {
      var title: String
      var code: Int
    }
    
    let phase = useAsync(.once) { () -> Int in
      try await Task.sleep(for: .seconds(2))
      if Bool.random() {
        return 999
      } else {
        throw ErrorCode(title: "-ErrorCode", code: -999)
      }
    }
    
    return HookRowView("") {
      switch phase {
        case .pending, .running:
          ProgressView()
        case .failure(let error):
          Text((error as? ErrorCode)?.title ?? "Error")
        case .success(let data):
          Text(data.description)
      }
    }
  }
  
  var useAsyncPerformView: some View {
    struct ErrorCode: Error {
      var title: String
      var code: Int
    }
    
    let phase = useAsyncPerform { () -> String in
      try await Task.sleep(for: .seconds(2))
      if Bool.random() {
        return "Success"
      } else {
        throw ErrorCode(title: "ErrorCode", code: -999)
      }
    }
    
    return HookRowView("") {
      VStack {
        switch phase.phase {
          case .pending, .running:
            ProgressView()
          case .failure(let error):
            HStack {
              Text((error as? ErrorCode)?.title ?? "Error")
              Spacer()
              Button("Random") {
                Task {
                  await phase.perform()
                }
              }
            }
          case .success(let data):
            HStack {
              Text(data)
              Spacer()
              Button("Random") {
                Task {
                  await phase.perform()
                }
              }
            }
        }
      }
      .frame(height: 68)
      .task {
        await phase.perform()
      }
    }
  }
}

struct HookCaseStudiesView_Previews: PreviewProvider {
  static var previews: some View {
    HookCaseStudiesView()
  }
}

private struct HookTitleView: View {
  var title: String
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .bold()
        .font(.body)
        .foregroundColor(.blue)
      Divider()
    }
    .padding(.horizontal, 24)
  }
}


private struct HookRowView<Content: View>: View {
  let title: String
  let content: Content
  
  init(_ title: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.content = content()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title).bold()
      HStack { content }.padding(.vertical, 16)
      Divider()
    }
    .padding(.horizontal, 24)
  }
}
