import SwiftUI

struct UserModel: Codable, Equatable , Identifiable {
  var id: UUID = UUID()
  var email: String
  var phonenumber: String
}

private let readMe = """
This screen demostrates how to use `useOnFirstAppear`, `useOnLastAppear`.
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
        
        let _ = useLayoutEffect {
          let data = users.toData()
          log.json(data as Any)
          return nil
        }
        
        let _ = hOnAppear {
          log.debug("hOnAppear")
        }
        
        let _ = hOnDisAppear {
          log.debug("hOnDisAppear")
        }
        
        let _ = useOnFistAppear {
          log.debug("useOnFistAppear")
        }
        
        let _ = useOnLastAppear {
          log.debug("useOnLastAppear")
        }
        
        @HOnFirstAppear
        var onFirstAppear = {
          log.debug("HOnFirstAppear")
        }

        
        @HOnLastAppear
        var onLastAppear = {
          log.debug("HOnLastAppear")
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
