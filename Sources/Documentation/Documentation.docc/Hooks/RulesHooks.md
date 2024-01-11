# RulesHooks

A SwiftUI implementation of React Hooks. Enhances reusability of stateful logic and gives state and lifecycle to function view.

@Metadata {
  @PageImage(purpose: card, source: "gettingStarted-card", alt: "The profile images for a regular sloth and an ice sloth.")
}

## Overview

In order to take advantage of the wonderful interface of Hooks, the same rules that React hooks has must also be followed by SwiftUI Hooks.

[Disclaimer]: These rules are not technical constraints specific to SwiftUI Hooks, but are necessary based on the design of the Hooks itself. You can see here to know more about the rules defined for React Hooks.

* In -Onone builds, if a violation against this rules is detected, it asserts by an internal sanity check to help the developer notice the mistake in the use of hooks. However, hooks also has disableHooksRulesAssertion modifier in case you want to disable the assertions.

### Only Call Hooks at the Function Top Level
Do not call Hooks inside conditions or loops. The order in which hook is called is important since Hooks uses LinkedList to keep track of its state.

```swift
@ViewBuilder
func counterButton() -> some View {
  let count = useState(0)  // 🟢 Uses hook at the top level

  Button("You clicked \(count.wrappedValue) times") {
    count.wrappedValue += 1
  }
}
```

```swift
@ViewBuilder
func counterButton() -> some View {
  if condition {
    let count = useState(0)  // 🔴 Uses hook inside condition.

    Button("You clicked \(count.wrappedValue) times") {
      count.wrappedValue += 1
    }
  }
}
```

### Only Call Hooks from HookScope or HookView.hookBody

In order to preserve the state, hooks must be called inside a HookScope.
A view that conforms to the HookView protocol will automatically be enclosed in a HookScope.

```swift
struct CounterButton: HookView {  // 🟢 `HookView` is used.
  var hookBody: some View {
    let count = useState(0)

    Button("You clicked \(count.wrappedValue) times") {
      count.wrappedValue += 1
    }
  }
}

```

```swift
func counterButton() -> some View {
  HookScope {  // 🟢 `HookScope` is used.
    let count = useState(0)

    Button("You clicked \(count.wrappedValue) times") {
      count.wrappedValue += 1
    }
  }
}
```

```swift
struct ContentView: HookView {
  var hookBody: some View {
    counterButton()
  }

// 🟢 Called from `HookView.hookBody` or `HookScope`.
  @ViewBuilder
  var counterButton: some View {
    let count = useState(0)

    Button("You clicked \(count.wrappedValue) times") {
      count.wrappedValue += 1
    }
  }
}
```

```swift
// 🔴 Neither `HookScope` nor `HookView` is used, and is not called from them.
@ViewBuilder
func counterButton() -> some View {
  let count = useState(0)

  Button("You clicked \(count.wrappedValue) times") {
    count.wrappedValue += 1
  }
}
```
