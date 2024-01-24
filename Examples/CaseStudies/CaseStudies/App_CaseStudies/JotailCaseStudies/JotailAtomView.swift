import SwiftUI

@MainActor
let atom = atomState { context in
  0
}

struct JotailAtomView: HookView {
  @MainActor
  var hookBody: some View {
    let state = useAtomState { context in
      0
    }
    Stepper(value: state) {
      Text(state.wrappedValue.description)
    }
  }
}

#Preview {
  JotailAtomView()
}
