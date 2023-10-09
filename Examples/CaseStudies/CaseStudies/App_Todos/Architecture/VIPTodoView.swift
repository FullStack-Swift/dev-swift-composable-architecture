import ComposableArchitecture
import SwiftUI

struct VIPTodoView: View {
  
  var body: some View {
    HookScope {
      let isConnected = useNetworkState()
      if isConnected {
        Color.green
      } else {
        Color.red
      }
    }
  }
}

#Preview {
  VIPTodoView()
}
