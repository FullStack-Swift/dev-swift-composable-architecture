import SwiftUI

@MainActor
private let value = selectorState { context in
  return 0
}

@MainActor
private let readValue = selectorValue { context in
  return context.watch(value)
}


struct AtomLocalViewContextView: View {
  
  @LocalViewContext
  var context
  
  var body: some View {
    
    let localWathState = context.binding(value)
    
    return VStack {
      NavigationLink {
        AtomLocalViewContextView()
      } label: {
        Text("Push")
      }
      Text(localWathState.wrappedValue.description)
        .onTap {
          localWathState.wrappedValue += 1
        }
      Text(context.watch(readValue).description)
        .onTap {
          localWathState.wrappedValue += 1
        }
      Text(context.read(readValue).description)
    }
  }
}

#Preview {
  AtomLocalViewContextView()
}
