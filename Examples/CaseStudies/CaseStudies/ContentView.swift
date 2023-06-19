import SwiftUI
import ComposableArchitecture

struct ContentView: View {

  @Dependency(\.navigationPath) var navigationPath

  var body: some View {
    _NavigationView {
      Form {
        Section(header: Text("Getting started")) {
          HStack {
            Text("Hooks")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
            .onTapGesture {
              navigationPath.commit {
                $0.path.append(.init(id: "Hooks", state: "Hooks_NavigationView"))
              }
            }
          HStack {
            Text("Atoms")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Atoms", state: "Atoms_NavigationView"))
            }
          }
        }
        Section(header: Text("Getting started")) {
          HStack {
            Text("Hooks-CaseStudies")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Hooks-CaseStudies", state: "Hooks-CaseStudies"))
            }
          }
          HStack {
            Text("Atoms-CaseStudies")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Atoms-CaseStudies", state: "Atoms-CaseStudies"))
            }
          }
        }
      }
      .navigationTitle(Text("CaseStudies"))
      ._navigationDestination(for: _Destination.self) { destination in
        switch destination.id {
          case "Hooks":
            HookCaseStudiesView()
              .onAppear {
                print(destination.state as Any)
              }
          case "Atoms":
            AtomRoot {
              AtomCaseStudiesView()
            }
            .onAppear {
              print(destination.state as Any)
            }
          case "Atoms-CaseStudies":
            AtomRoot {
              AtomView()
            }
          case "Hooks-CaseStudies":
            AtomRoot {
              AtomView()
            }
          default:
            EmptyView()
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
