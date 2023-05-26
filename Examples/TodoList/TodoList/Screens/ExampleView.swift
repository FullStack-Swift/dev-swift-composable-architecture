import SwiftUI

struct ExampleView: View {
  var body: some View {
    ScrollView {
      VStack {
        ExampleHookView()
      }
    }
  }
}

struct ExampleHookView: HookView {
  var hookBody: some View {
    VStack {
      counterUseState
      counterUseSetState
    }
  }

  var counterUseState: some View {
    let count = useState(0)
    let newCount = useState(0)
    return VStack {
      HStack {
        Button("+") {
          count.wrappedValue += 1
        }
        Text(count.wrappedValue.description)
        Button("-") {
          count.wrappedValue -= 1
        }
      }
      HStack {
        Button("+") {
          newCount.wrappedValue += 1
        }
        Text(newCount.wrappedValue.description)
        Button("-") {
          newCount.wrappedValue -= 1
        }
      }
    }
  }

  var counterUseSetState: some View {
    let (count, setCount) = useSetState(0)
    let (newCount, newSetCount) = useSetState(0)
    return VStack {
      HStack {
        Button("+") {
          setCount(count + 1)
        }
        Text(count.description)
        Button("-") {
          setCount(count - 1)
        }
      }

      HStack {
        Button("+") {
          newSetCount(newCount + 1)
        }
        Text(newCount.description)
        Button("-") {
          newSetCount(newCount - 1)
        }
      }
    }
  }
}
