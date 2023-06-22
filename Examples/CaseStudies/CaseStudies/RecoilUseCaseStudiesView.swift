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

private struct _StateAtomView: HookView {

  @ViewContext
  private var context

  var hookBody: some View {
    RecoilScope { context in
      VStack {
        headerView
          .padding()
        HStack {
          let state = useRecoilState(_StateAtom(id: "1"))
          AtomRowTextValue(state.wrappedValue)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
        HStack {
          let state = useRecoilState(_StateAtom(id: "2"))
          AtomRowTextValue(state.wrappedValue)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
        HStack {
          let state = useRecoilState(_StateAtom(id: "3"))
          AtomRowTextValue(state.wrappedValue)
          Stepper("Count: \(state.wrappedValue)", value: state)
            .labelsHidden()
        }
      }
    }
    .navigationTitle("Recoil")
  }

  var headerView: some View {
    let state1 = useRecoilValue(_StateAtom(id: "1"))
    let state2 = useRecoilValue(_StateAtom(id: "2"))
    let state3 = useRecoilValue(_StateAtom(id: "3"))
    return Text(state1.description + " + ")
      .foregroundColor(.red)
    + Text(state2.description + " + ")
      .foregroundColor(.green)
    + Text(state3.description + " = ")
      .foregroundColor(.blue)
    + Text((state1 + state2 + state3).description)
      .foregroundColor(.cyan)
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

struct RecoilUseCaseStudiesView: View {

  var body: some View {
    HookScope {
      ScrollView {
        VStack {
          _StateAtomView()
        }
        .padding()
      }
    }
  }
}
