import SwiftUI
import Combine

// MARK: SwiftUI

public func useColor(color: Color) -> some View {
  HookScope {
    color
  }
}

public func useToggle() -> some View {
  HookScope {
    
  }
}

public func useText() -> some View {
  HookScope {
    
  }
}

public func useInput(onChange: @escaping (String) -> Void) -> some View {
  HookScope {
    let text = useState("")
    TextField("", text: text)
      .backport.onChange(of: text.wrappedValue) { newValue in
        onChange(newValue)
      }
  }
}

public func useNavigationTitle() {
  
}

public func useLongPress() {
  
}

public func useTapPress() {
  
}

public func usePreferredLanguage() {

}

public func useTheme() {
  
}

public func hOnAppear(perform action: (() -> Void)? = nil) -> some View {
  useMemo(.once) {
    Color.black
//      .opacity(1.toNano())
      .onAppear(perform: action)
      .frame(width: 1.toNano(), height: 1.toNano(), alignment: .center)
      .hidden()
  }
}

public func hOnDisAppear(perform action: (() -> Void)? = nil) -> some View {
  useMemo(.once) {
    Color.black
//      .opacity(1.toNano())
      .onDisappear(perform: action)
      .frame(width: 1.toNano(), height: 1.toNano(), alignment: .center)
      .hidden()
  }
}


public func useIOnlineStatus() {
  
}

func useLocalStorage() {
  
}


public func useTimeout() {
  
}

public func useEventListener() {
  
}

func useFetch() {
  
}

func useRequest() {
  
}

func useContinuousRetry() {
  
}

func useHistoryState() {
  
}

func useOjbectState() {
  
}

