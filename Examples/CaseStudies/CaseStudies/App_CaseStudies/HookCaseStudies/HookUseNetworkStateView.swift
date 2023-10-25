import SwiftUI

struct HookUseNetworkStateView: View {
  var body: some View {
    HookScope {
      let isConnected = useNetworkState()
      if isConnected {
        NavigationLink {
          Color.green
        } label: {
          Color.green
        }
      } else {
        NavigationLink {
          Color.red
        } label: {
          Color.red
        }
      }
    }
    .navigationBarTitle(Text("Hook NetworkState"), displayMode: .inline)
  }
}

#Preview {
  HookUseNetworkStateView()
}
