import SwiftUI

struct HookUseEnvironmentView: View {
  
  var body: some View {
    HookScope {
      @HEnvironment(\.locale)
      var locale
      
      @HEnvironment(\.presentationMode)
      var presentation
      
      Text("Current Locale = \(locale.identifier)")
        .frame(height: 60)
      Button {
        presentation.wrappedValue.dismiss()
      } label: {
        Text("Dismiss")
      }
    }
    .navigationBarTitle(Text("Hook Enviroment"), displayMode: .inline)
  }
}

#Preview {
    HookUseEnvironmentView()
}
