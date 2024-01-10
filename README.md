# dev-swift-composable-architecture

This is base project custom from TCA, Hooks, Atoms. See more in:

[swift composable architecture](https://github.com/pointfreeco/swift-composable-architecture)

[swiftui hooks](https://github.com/ra1028/swiftui-hooks)

[swiftui atoms](https://github.com/ra1028/swiftui-atom-properties)


# Overview

basic TCA:

```swift

import ComposableArchitecture
import SwiftUI

// MARK: - Feature domain

@Reducer
struct Counter {
  struct State: Equatable {
    var count = 0
  }

  enum Action {
    case decrementButtonTapped
    case incrementButtonTapped
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .decrementButtonTapped:
        state.count -= 1
        return .none
      case .incrementButtonTapped:
        state.count += 1
        return .none
      }
    }
  }
}

// MARK: - Feature view

struct CounterView: View {
  let store: StoreOf<Counter>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      HStack {
        Button {
          viewStore.send(.decrementButtonTapped)
        } label: {
          Image(systemName: "minus")
        }

        Text("\(viewStore.count)")
          .monospacedDigit()

        Button {
          viewStore.send(.incrementButtonTapped)
        } label: {
          Image(systemName: "plus")
        }
      }
    }
  }
}

struct CounterDemoView: View {
  @State var store = Store(initialState: Counter.State()) {
    Counter()
  }

  var body: some View {
    Form {
      Section {
        CounterView(store: self.store)
          .frame(maxWidth: .infinity)
      }
    }
    .buttonStyle(.borderless)
    .navigationTitle("Counter demo")
  }
}

// MARK: - SwiftUI previews

#Preview {
    NavigationView {
      CounterDemoView(
        store: Store(initialState: Counter.State()) {
          Counter()
        }
      )
    }
}
```

```swift

```

```swift


```

# Documentation

## For Ref:

- [TCA Docnumentation](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture)

- [SwiftUI Hooks](https://ra1028.github.io/swiftui-hooks/documentation/hooks)

- [SwiftUI Atoms](https://ra1028.github.io/swiftui-atom-properties/documentation/atoms)

## For Custom in Project:

- [TCA Docnumentation](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture)

- [SwiftUI Hooks](https://ra1028.github.io/swiftui-hooks/documentation/hooks)

- [SwiftUI Atoms](https://ra1028.github.io/swiftui-atom-properties/documentation/atoms)

# ``DocC``

### Generating Documentation for Extended Types


```
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target Documentation --output-path ./docs
```

```
swift package --disable-sandbox preview-documentation --target Documentation
```

### Publishing to GitHub Pages

```
sudo swift package --allow-writing-to-directory ./docs \
    generate-documentation --target Documentation \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path Documentation \
    --output-path ./docs
```
