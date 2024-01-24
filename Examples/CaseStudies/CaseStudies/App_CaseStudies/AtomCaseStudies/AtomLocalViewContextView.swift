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
  
  var body: some View {
    List {
      ForEach(1..<100) { _ in
        ContentLocalView()
      }
    }
    .navigationBarItems(
      leading: EmptyView(),
      trailing: viewBuilder {
        NavigationLink {
          AtomLocalViewContextView()
        } label: {
          Text("Push")
        }
      }
    )
  }
}

private struct ContentLocalView: View {
  
  @LocalViewContext
  var context
  
  var readValueLocal: String {
    context.read(readValue.select(\.description))
  }
  
  var body: some View {
    
    let localWathState = context.binding(value)
    HStack {
      Text(localWathState.wrappedValue.description)
        .alignment(horizontal: .center)
        .onTap {
          localWathState.wrappedValue += 1
        }
      Text(context.watch(readValue).description)
        .alignment(horizontal: .center)
        .onTap {
          localWathState.wrappedValue += 1
        }
      Text(readValueLocal)
        .alignment(horizontal: .center)
      Text(readValueLocal)
        .alignment(horizontal: .center)
    }
    .font(.largeTitle)
    .padding()
  }
}

#Preview {
  AtomLocalViewContextView()
}
