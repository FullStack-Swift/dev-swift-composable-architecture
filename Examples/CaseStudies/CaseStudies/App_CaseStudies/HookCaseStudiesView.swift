import SwiftUI
import Combine

typealias ColorSchemeContext = HookContext<Binding<ColorScheme>>

struct HookCaseStudiesView: View {
  var body: some View {
    Form {
      Section(header: Text("Use Case")) {
        NavigationLink("Hook-Lifecycle") {
          HookLifecycleView()
        }
        
        NavigationLink("Hook-UseCountDown") {
          HookUseCountDownView()
        }
        
        NavigationLink("Hook-UseInitalAndDispose") {
          HookUseInitalAndDisposeView()
        }
        
        NavigationLink("Hook-UseLoadMore") {
          HookLoadMoreView()
        }
        
        NavigationLink("Hook-UseDate") {
          HookUseDateView()
        }
        
        NavigationLink("Hook-UseMemo") {
          HookUseMemoView()
        }
        
        NavigationLink("Hook-UseAsync") {
          HookUseAsyncView()
        }
               
        NavigationLink("Hook-UseEnvironment") {
          HookUseEnvironmentView()
        }
        
        NavigationLink("Hook-UseState") {
          HookUseStateView()
        }
      }
    }
    .navigationTitle("Hook")
//    HookScope {
//      let _ = useOnFistAppear {
//        print("useOnFistAppear")
//      }
//      
//      let _ = useOnLastAppear {
//        print("useOnLastAppear")
//      }
//      let colorScheme = useState(useEnvironment(\.colorScheme))
//      ColorSchemeContext.Provider(value: colorScheme) {
//        ScrollView {
//          VStack {
//            Group {
//              HookTitleView(title: "useState UseCase")
//              useStateView
//              useSetStateView
//              useBindingStateView
//            }
//            Group {
//              HookTitleView(title: "useReducer UseCase")
//              useReducerReduxView
//              useReducerTCAView
//              useReducerProtocolView
//            }
//            
//            Group {
//              HookTitleView(title: "usePublisher UseCase")
//              usePublisherView
//              usePublisherSubscribeView
//            }
//            
//            Group {
//              HookTitleView(title: "useAsync UseCase")
//              useAsyncView
//              useAsyncPerformView
//            }
//            
//            Group {
//              Group {
//                HookTitleView(title: "useRef UseCase")
//                useRefView
//                HookTitleView(title: "useMemo UseCase")
//                useMemoView
//              }
//              Group {
//                HookTitleView(title: "useEffect UseCase")
//                useEffectView
//                HookTitleView(title: "useLayoutEffect UseCase")
//                useLayoutEffectView
//              }
//              HookTitleView(title: "useEnvironment UseCase")
//              useEnvironmentView
//              HookTitleView(title: "useContext UseCase")
//              useContextView
//              HookTitleView(title: "userTimerView UseCase")
//              userTimerView
//            }
//          }
//        }
//#if os(iOS)
//        .background(Color(.systemBackground).ignoresSafeArea())
//        .navigationBarTitle(Text("Hook"), displayMode: .inline)
//#endif
//      }
//      .colorScheme(colorScheme.wrappedValue)
//    }
    //    .disableHooksRulesAssertion(true)
  }
  
//  private var useStateView: some View {
//    let state = useState(0)
//    return HookRowView("useState") {
//      Stepper(value: state) {
//        HookRowTextValue(state.wrappedValue)
//      }
//    }
//  }
  
  private var useBindingStateView: some View {
    let state = useBindingState(0)
    return HookRowView("useBindingState") {
      Stepper(value: state) {
        HookRowTextValue(state.wrappedValue)
      }
    }
  }
  
  private var useSetStateView: some View {
    let (state, setState) = useSetState(0)
    return HookRowView("useSetState") {
      Stepper(value: Binding(get: {state}, set: { value, _ in
        setState(value)
      })) {
        HookRowTextValue(state)
      }
    }
  }
  
  private var useReducerReduxView: some View {
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
      HookRowTextValue(state)
        .frame(height: 60)
      Button {
        dispatch(.decrement)
      } label: {
        ImageMinus()
      }
      Button {
        dispatch(.increment)
      } label: {
        ImagePlus()
      }
    }
  }
  
  private var useReducerTCAView: some View {
    
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
      HookRowTextValue(state)
        .frame(height: 60)
      Button {
        dispatch(.decrement)
      } label: {
        ImageMinus()
      }
      Button {
        dispatch(.increment)
      } label: {
        ImagePlus()
      }
    }
  }
  
  private var useReducerProtocolView: some View {
    
    struct CountReducer: Reducer {
      
      enum Action {
        case increment
        case decrement
      }
      
      typealias State = Int
      
      @Dependency(\.fireAndForget)
      var fireAndForget
      
      var body: some ReducerOf<Self> {
        Reduce { state, action in
          switch action {
            case .decrement:
              state -= 1
              return .run { send in
                await fireAndForget {
                  print("decrement")
                }
              }
            case .increment:
              state += 1
              return .run { send in
                await fireAndForget {
                  print("increment")
                }
              }
          }
        }
      }
    }
    
    let store = useReducer(initialState: 0, CountReducer())
    
    let viewStore = ViewStore(store)
    
    return VStack {
      HookRowView("useReducerProtocol store.commit") {
        HookRowTextValue(viewStore.state)
          .frame(height: 60)
        Button {
          store.commit {
            $0 -= 1
          }
        } label: {
          ImageMinus()
        }
        Button {
          store.commit {
            $0 += 1
          }
        } label: {
          ImagePlus()
        }
      }
      HookRowView("useReducerProtocol viewstore.send") {
        HookRowTextValue(viewStore.state)
          .frame(height: 60)
        Button {
          viewStore.send(.decrement)
        } label: {
          ImageMinus()
        }
        Button {
          viewStore.send(.increment)
        } label: {
          ImagePlus()
        }
      }
    }
  }
  
  private var useRefView: some View {
    let state = useRef(0)
    return HookRowView("userRef") {
      HookRowTextValue(state.current)
        .frame(height: 60)
      Button {
        state.current -= 1
      } label: {
        ImageMinus()
      }
      Button {
        state.current += 1
      } label: {
        ImagePlus()
      }
    }
  }
  
  private var useMemoView: some View {
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
        TextValue(uuid)
          .frame(height: 60)
      }
      HookRowView("useMemo") {
        TextValue(state)
          .frame(height: 60)
      }
      HookRowView("useMemo") {
        HStack {
          Circle()
            .foregroundColor(randomColor)
            .frame(width: 60, height: 60, alignment: .center)
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
  
  private var useEffectView: some View {
    return HookScope {
      let state = useState(999999999)
      let isAutoIncrement = useState(false)
      
      //    useEffect(.preserved(by: isAutoIncrement.wrappedValue)) {
      //      guard isAutoIncrement.wrappedValue else { return nil }
      //      print("Timer.scheduledTimer")
      //      let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
      //        state.wrappedValue += 1
      //      }
      //
      //      return timer.invalidate
      //    }
      
      useEffect(.preserved(by: isAutoIncrement.wrappedValue)) {
        guard isAutoIncrement.wrappedValue else { return nil }
        print("Timer.scheduledTimer")
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
          state.wrappedValue += 1
        }
        
        return timer.invalidate
      }
      
      return HookRowView("useEffect") {
        HookRowTextValue(state.wrappedValue)
        Spacer()
        Stepper(value: state, in: 0...(.max), label: EmptyView.init).fixedSize()
        Toggle("Auto +", isOn: isAutoIncrement).fixedSize()
      }
    }
  }
  
  private var useLayoutEffectView: some View {
    let state = useState(999999999)
    let isAutoIncrement = useState(false)
    
    //    useLayoutEffect(.preserved(by: isAutoIncrement.wrappedValue)) {
    //      guard isAutoIncrement.wrappedValue else { return nil }
    //      print("Timer.scheduledTimer")
    //      let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
    //        state.wrappedValue += 1
    //      }
    //
    //      return timer.invalidate
    //    }
    
    useLayoutEffect(.preserved(by: isAutoIncrement.wrappedValue)) {
      guard isAutoIncrement.wrappedValue else { return nil }
      print("Timer.scheduledTimer")
      let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        state.wrappedValue += 1
      }
      
      return timer.invalidate
    }
    
    return HookRowView("useEffect") {
      HookRowTextValue(state.wrappedValue)
      Spacer()
      Stepper(value: state, in: 0...(.max), label: EmptyView.init).fixedSize()
      Toggle("Auto +", isOn: isAutoIncrement).fixedSize()
    }
  }
  
  private var useContextView: some View {
    let colorScheme = useContext(ColorSchemeContext.self)
    return HookRowView("useContext") {
      VStack(alignment: .center) {
        HStack {
          Spacer()
          Text("\(colorScheme.wrappedValue)".description)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .font(.system(size: 16, weight: .heavy, design: .monospaced))
            .padding(8)
            .background(Color.secondary.opacity(1/3))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .foregroundColor(.primary)
            .frame(height: 60, alignment: .center)
          Spacer()
        }
        .frame(maxWidth: .infinity)
        Picker("Color Scheme", selection: colorScheme) {
          ForEach(ColorScheme.allCases, id: \.self) { scheme in
            Text("\(scheme)".description)
          }
        }
        .pickerStyle(SegmentedPickerStyle())
      }
    }
  }
  
//  private var useEnvironmentView: some View {
//    HookScope {
//      let locale = useEnvironment(\.locale)
//      let presentation = useEnvironment(\.presentationMode)
//      return HookRowView("useEnvironment") {
//        TextValue("Current Locale = \(locale.identifier)")
//          .frame(height: 60)
//        Spacer()
//        Button {
//          presentation.wrappedValue.dismiss()
//        } label: {
//          Text("Dismiss")
//        }
//      }
//    }
//  }
  
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
  
  private var usePublisherView: some View {
    let phase = usePublisher(.once) {
      Just(UUID())
        .map(\.uuidString)
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
    }
    return HookRowView("usePublisher") {
      VStack(alignment: .center) {
        HStack {
          Spacer()
        }
        switch phase {
          case .running:
            ProgressView()
          case .success(let uuid):
            VStack {
              TextValue(uuid)
                .frame(height: 60)
            }
          case .pending:
            EmptyView()
        }
      }
      .frame(height: 60)
    }
  }
  
  private var usePublisherSubscribeView: some View {
    let (phase, subscribe) = usePublisherSubscribe {
      Just(UUID())
        .map(\.uuidString)
        .delay(for: .seconds(3), scheduler: DispatchQueue.main)
    }
    return HookRowView("usePublisherSubscribe") {
      VStack(alignment: .center) {
        HStack {
          Spacer()
        }
        switch phase {
          case .running:
            ProgressView()
          case .success(let uuid):
            VStack {
              TextValue(uuid)
                .frame(height: 60)
              Button("Random", action: subscribe)
            }
          case .pending:
            EmptyView()
        }
      }
      .frame(height: 100)
      .task { @MainActor in
        subscribe()
      }
    }
  }
  
  private var useAsyncView: some View {
    
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
    
    return HookRowView("useAsync") {
      switch phase {
        case .pending, .running:
          ProgressView()
        case .failure(let error):
          TextValue((error as? ErrorCode)?.title ?? "Error")
            .frame(height: 60)
        case .success(let data):
          TextValue(data.description)
            .frame(height: 60)
      }
    }
  }
  
  private var useAsyncPerformView: some View {
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
    
    return HookRowView("useAsyncPerform") {
      VStack {
        switch phase.phase {
          case .pending, .running:
            ProgressView()
          case .failure(let error):
            HStack {
              TextValue((error as? ErrorCode)?.title ?? "Error")
              Spacer()
              Button("Random") {
                withMainTask { try await phase.perform() }
              }
            }
          case .success(let data):
            HStack {
              TextValue(data)
              Spacer()
              Button("Random") {
                withMainTask { try await phase.perform() }
              }
            }
        }
      }
      .frame(height: 68)
      .task {
        withMainTask { try await phase.perform() }
      }
    }
  }
//  private var userTimerView: some View {
//    let timer = useCountdown(countdown: 10, withTimeInterval: 1)
//    return HStack {
//      switch timer.phase.wrappedValue {
//        case .pending:
//          Text("Pending")
//        case .start(let value):
//          Text(Int(value).description)
//        case .stop:
//          Text("Stop")
//        case .cancel:
//          Text("Cancel")
//        case .process(let value):
//          Text(Int(value).description)
//        case .completion:
//          Text("Completion")
//          
//      }
//      Spacer()
//      Button("Start") {
//        timer.start()
//      }
//      Button("Stop") {
//        timer.stop()
//      }
//      Button("Play") {
//        timer.play()
//      }
//      Button("Canncel") {
//        timer.cancel()
//      }
//    }
//    .padding()
//  }
}



private struct HookTitleView: View {
  var title: String
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .foregroundColor(.accentColor)
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
      Text(title)
        .font(.system(size: 16, weight: .regular, design: .serif))
      HStack(alignment: .center) {
        content
      }
      .padding(.vertical, 16)
      Divider()
    }
    .padding(.horizontal, 24)
  }
}

private struct HookRowTextValue: View {
  
  private let content: Int
  
  init(_ content: Int) {
    self.content = content
  }
  
  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .center) {
        Color.white.opacity(0.0001)
        HStack {
          Text(String(format: "%02d", content))
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .font(.system(size: 16, weight: .heavy, design: .monospaced))
            .padding(8)
            .background(Color.secondary.opacity(1/3))
            .clipShape(RoundedRectangle(cornerRadius: proxy.size.height))
            .foregroundColor(.primary)
          Spacer()
        }
      }
    }
  }
}

private struct TextValue: View {
  
  private let content: String
  
  init(_ content: String) {
    self.content = content
  }
  
  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .center) {
        Color.white.opacity(0.0001)
        HStack {
          Text(content)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .font(.system(size: 16, weight: .heavy, design: .monospaced))
            .padding(8)
            .background(Color.secondary.opacity(1/3))
            .clipShape(RoundedRectangle(cornerRadius: proxy.size.height))
            .foregroundColor(.primary)
          Spacer()
        }
      }
    }
  }
}

private struct ImagePlus: View {
  var body: some View {
    Image(systemName: "plus")
      .bold()
      .foregroundColor(.accentColor)
  }
}

private struct ImageMinus: View {
  var body: some View {
    Image(systemName: "minus")
      .bold()
      .foregroundColor(.accentColor)
  }
}

#Preview {
  HookScope {
    HookCaseStudiesView()
  }
}
