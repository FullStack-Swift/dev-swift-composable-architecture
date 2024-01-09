# Introduction

A SwiftUI implementation of React Hooks. Enhances reusability of stateful logic and gives state and lifecycle to function view.

@Metadata {
  @PageImage(purpose: card, source: "gettingStarted-card", alt: "The profile images for a regular sloth and an ice sloth.")
}


## Overview

SwiftUI Hooks is a SwiftUI implementation of React Hooks. Brings the state and lifecycle into the function view, without depending on elements that are only allowed to be used in struct views such as @State or @ObservedObject.
It allows you to reuse stateful logic between views by building custom hooks composed with multiple hooks.
Furthermore, hooks such as useEffect also solve the problem of lack of lifecycles in SwiftUI.

The API and behavioral specs of SwiftUI Hooks are entirely based on React Hooks, so you can leverage your knowledge of web applications to your advantage.

### Examples

Basic Hooks

```swift

func timer() -> some View {
  HookScope {

    let time = useState(Date())

    useEffect(.once) {
      let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
        time.wrappedValue = $0.fireDate
      }

      return {
        timer.invalidate()
      }
    }

    return Text("Time: \(time.wrappedValue)")
  }
}
```

```swift
var contentOther: some View {
  HookScope {

    let state = useState(0)

    let otherState = useState {
      0
    }

    let toggle = useState(false)

    let _ = useLogger(nil, toggle.wrappedValue)

    let _ = useLogger(.preserved(by: toggle.wrappedValue), toggle.wrappedValue)

    VStack {
      Stepper(value: state) {
        Text(state.wrappedValue.description)
      }

      Stepper(value: otherState) {
        Text(otherState.wrappedValue.description)
      }

      Toggle("", isOn: toggle)
        .toggleStyle(.switch)
    }
  }
}

```

Advance Hooks

```swift

var content: some View {
  HookScope {

    @HState var state = 0

    @HState<Int> var otherState = {
      0
    }

    @HState var toggle = false

    @HLogger
    var log = toggle

    @HLogger(.preserved(by: toggle))
    var otherLog = toggle

    VStack {
      Stepper(value: $state) {
        Text(state.description)
      }

      Stepper(value: $otherState) {
        Text(otherState.description)
      }

      Toggle("", isOn: $toggle)
        .toggleStyle(.switch)
      }
  }
}

```
