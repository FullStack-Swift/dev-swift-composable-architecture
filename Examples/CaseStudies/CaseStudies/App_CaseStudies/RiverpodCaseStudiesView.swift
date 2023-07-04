import SwiftUI
import ComposableArchitecture

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
}

struct _ProviderGlobalView: ProviderGlobalView {
  
  @RecoilGlobalViewContext
//  @LocalViewContext
  var context
  
  func build(context: Context, ref: ViewRef) -> some View {
    HStack {
      let state = context.useRecoilState(_StateAtom(id: "1"))
      let value = context.useRecoilValue(_ValueAtom(id: "1"))
//      let state = self.context.state(_StateAtom(id: "1"))
//      let value = self.context.watch(_ValueAtom(id: "1"))
      AtomRowTextValue(state.wrappedValue)
      AtomRowTextValue(value)
      Stepper("Count: \(state.wrappedValue)", value: state)
        .labelsHidden()
    }
  }
}

struct _ProviderLocalView: ProviderLocalView {
  
  func build(context: Context, ref: ViewRef) -> some View {
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

struct _TestView: View {
  
  @ViewContext
  var context
  
  var body: some View {
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

struct RiverpodCaseStudiesView: View {
  
  @State var count = 0
  
  var body: some View {
    ScrollView {
      HStack {
        Button("+") {
          count += 1
        }
        Text(count.description)
          .font(.largeTitle)
        Button("-") {
          count -= 1
        }
      }
      .foregroundColor(.accentColor)
      Group {
        _ProviderGlobalView()
        _ProviderGlobalView()
        _ProviderGlobalView()
        Divider()
      }

      Group {
        _ProviderLocalView()
        _ProviderLocalView()
        _ProviderLocalView()
        Divider()
      }
      Group {
        _TestView()
        _TestView()
        _TestView()
        Divider()
      }
    }
    .padding()
    .navigationBarTitle(Text("Riverpod"), displayMode: .inline)
    .navigationBarItems(leading: leading, trailing: trailing)
  }
  
  var leading: some View {
    EmptyView()
  }
  
  var trailing: some View {
    Button("+") {
      count += 1
    }
  }
}

struct RiverpodCaseStudiesView_Previews: PreviewProvider {
  static var previews: some View {
    RiverpodCaseStudiesView()
  }
}
