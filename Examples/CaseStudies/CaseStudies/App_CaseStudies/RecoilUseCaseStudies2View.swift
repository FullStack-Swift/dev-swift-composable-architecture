import SwiftUI

import Combine

// MARK: StateAtom
private struct _StateAtom: StateAtom, Hashable {
  
  var id: String
  
  init(id: String = "") {
    self.id = id
  }
  
  func defaultValue(context: Context) -> Int {
    0
  }
  
  var key: any Hashable {
    id
  }
}

// MARK: ValueAtom
private struct _ValueAtom: ValueAtom, Hashable {
  
  var id: String
  
  func value(context: Context) -> Int {
    context.watch(_StateAtom(id: id))
  }
  
  var key: any Hashable {
    id
  }
}

private struct _RecoilViewContext: View {
  
  var body: some View {
    HookScope {
      VStack {
        HookScope {
          HStack {
            let state = useRecoilState(_StateAtom(id: "1"))
            let value = useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
        HookScope {
          HStack {
            let state = useRecoilState(_StateAtom(id: "1"))
            let value = useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
      }
    }
  }
}

private struct Test_RecoilGlobalView: _RecoilGlobalView {
  
  var _context: RecoilGlobalViewContext = .init()
  
  func build(context: Context) -> some View {
    VStack {
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
    }
  }
}

private struct Test_RecoilLocalView: _RecoilLocalView {
  
  func build(context: Context) -> some View {
    VStack {
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
      HookScope {
        HStack {
          let state = context.useRecoilState(_StateAtom(id: "1"))
          let value = context.useRecoilValue(_ValueAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          AtomRowTextValue(value)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
    }
  }
}

private struct _ViewContext: View {
  
  @ViewContext
  var context
  
  var body: some View {
    HookScope {
      VStack {
        HookScope {
          HStack {
            let state = context.useRecoilState(_StateAtom(id: "1"))
            let value = context.useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
        HookScope {
          HStack {
            let state = context.state(_StateAtom(id: "1"))
            let value = context.watch(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
      }
    }
  }
}

private struct _LocalViewContext: View {
  
  @LocalViewContext
  var context
  
  var body: some View {
    HookScope {
      VStack {
        HookScope {
          HStack {
            let state = context.useRecoilState(_StateAtom(id: "1"))
            let value = context.useRecoilValue(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
        HookScope {
          HStack {
            let state = context.state(_StateAtom(id: "1"))
            let value = context.watch(_ValueAtom(id: "1"))
            AtomRowTextValue(state.wrappedValue)
            AtomRowTextValue(value)
            Stepper("Count: \(state.wrappedValue)", value: state)
              .labelsHidden()
          }
        }
      }
    }
  }
}


private struct AtomRowTextValue: View {
  
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

struct RecoilUseCaseStudies2View: View {
  
  var body: some View {
    ScrollView {
      Group {
        Text("Test_RecoilGlobalView")
        Test_RecoilGlobalView()
        Test_RecoilGlobalView()
        Test_RecoilGlobalView()
        Divider()
      }
      
      Group {
        Text("Test_RecoilLocalView")
        Test_RecoilLocalView()
        Test_RecoilLocalView()
        Test_RecoilLocalView()
        Divider()
      }
      Group {
        Text("Global ViewContext")
        _ViewContext()
        _ViewContext()
        _ViewContext()
        Divider()
      }
      Group {
        Text("Local ViewContext")
        _LocalViewContext()
        _LocalViewContext()
        _LocalViewContext()
        Divider()
      }
      
      Group {
        Text("Recoil")
        _RecoilViewContext()
        _RecoilViewContext()
        _RecoilViewContext()
        Divider()
      }
      
    }
    .padding()
#if os(iOS)
    .navigationBarTitle(Text("Riverpod"), displayMode: .inline)
    .navigationBarItems(leading: leading, trailing: trailing)
#endif
  }
  
  var leading: some View {
    EmptyView()
  }
  
  var trailing: some View {
    EmptyView()
  }
}

#Preview {
  RecoilUseCaseStudies2View()
}
