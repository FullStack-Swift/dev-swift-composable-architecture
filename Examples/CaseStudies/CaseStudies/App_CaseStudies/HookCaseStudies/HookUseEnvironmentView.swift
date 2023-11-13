import SwiftUI

struct HookUseEnvironmentView: View {
  
  var body: some View {
    VStack {
      content
        .frame(maxHeight: .infinity)
      contentOther
        .frame(maxHeight: .infinity)
    }
    .navigationBarTitle(Text("Hook Enviroment"), displayMode: .inline)
  }
  
  var content: some View {
    HookScope {
      @HEnvironment(\.locale)
      var locale
      
      @HEnvironment(\.presentationMode)
      var presentation
      
      @HEnvironment(\.dismiss)
      var dismiss
      
      VStack(spacing: 48) {
        Text("Current Locale = \(locale.identifier)")
        Button {
          presentation.wrappedValue.dismiss()
        } label: {
          Text("presentationMode")
        }
        Button {
          dismiss()
        } label: {
          Text("Dismiss")
        }
      }
    }
  }
  
  var contentOther: some View {
    HookScope {
      @HEnvironment(\.locale)
      var locale
      
      @HEnvironment(\.presentationMode)
      var presentation
      
      @HEnvironment(\.dismiss)
      var dismiss
      
      VStack(spacing: 48) {
        Text("Current Locale = \(locale.identifier)")
        Button {
          presentation.wrappedValue.dismiss()
        } label: {
          Text("presentationMode")
        }
        Button {
          dismiss()
        } label: {
          Text("Dismiss")
        }
      }
    }
  }
}

#Preview {
    HookUseEnvironmentView()
}
