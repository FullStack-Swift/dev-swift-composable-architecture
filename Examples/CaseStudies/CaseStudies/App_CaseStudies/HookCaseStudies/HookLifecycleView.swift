import SwiftUI

struct UserModel: Codable, Equatable , Identifiable {
  var id: UUID = UUID()
  var email: String
  var phonenumber: String
}

private let readMe = """
This screen demostrates how to use useOnFirstAppear, useOnLastAppear.
"""

struct HookLifecycleView: View {

    var body: some View {
      HookScope {
        
        let users = useMemo {
          arrayBuilder {
            UserModel(email: "A", phonenumber: "0")
            UserModel(email: "B", phonenumber: "1")
          }
        }
        
        let _ = hOnAppear {
          print("hOnAppear")
        }
        
        let _ = hOnDisAppear {
          print("hOnDisAppear")
        }
        
        let _ = useOnFistAppear {
          print("useOnFistAppear")
          let data = users.toData()
          log.info(Json(data as Any))
        }
        
        let _ = useOnLastAppear {
          print("useOnLastAppear")
        }
        Form {
          Section {
            AboutView(readMe: readMe)
          }
          NavigationLink {
            Text(users.toData(options: .prettyPrinted).toString() ?? "")
          } label: {
            Text("HookLifecycle")
          }
        }
      }
      .navigationBarTitle(Text("Hook Lifecycle"), displayMode: .inline)
    }
}

#Preview {
  HookLifecycleView()
}
