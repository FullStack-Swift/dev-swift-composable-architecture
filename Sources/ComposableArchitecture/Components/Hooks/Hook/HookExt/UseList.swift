import SwiftUI
import Combine

// MARK: Hook Content View.

public func useToggle(_ title: String = "") -> some View {
  @HState var isOn = false
  return Toggle(title, isOn: $isOn)
}

public func useInput(
  _ title: String = "",
  text: String = "",
  onChange: @escaping (String) -> Void
) -> some View {
  @HState var hText = ""
  useLayoutEffect(.preserved(by: text)) {
    hText = text
  }
  return TextField(title, text: $hText)
    .backport.onChange(of: hText) { newValue in
      onChange(newValue)
    }
}


public func hOnAppear(perform action: (() -> Void)? = nil) -> some View {
  useMemo(.once) {
    Color.black
      .opacity(1.toNano())
      .onAppear(perform: action)
      .frame(width: 1.toNano(), height: 1.toNano(), alignment: .center)
      .hidden()
  }
}

public func hOnDisAppear(perform action: (() -> Void)? = nil) -> some View {
  useMemo(.once) {
    Color.black
      .opacity(1.toNano())
      .onDisappear(perform: action)
      .frame(width: 1.toNano(), height: 1.toNano(), alignment: .center)
      .hidden()
  }
}
