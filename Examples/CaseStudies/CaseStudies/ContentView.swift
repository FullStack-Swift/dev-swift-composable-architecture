import SwiftUI
import ComposableArchitecture

struct ContentView: View {

  @Dependency(\.navigationPath) var navigationPath

  @ViewContext
  var context

  var body: some View {
    _NavigationView {
      Form {
        Section(header: Text("Getting started")) {
          HStack {
            Text("TCA-CaseStudies")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "TCA-CaseStudies", state: "TCA_NavigationView"))
            }
          }
          HStack {
            Text("Hooks-CaseStudies")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
            .onTapGesture {
              navigationPath.commit {
                $0.path.append(.init(id: "Hooks-CaseStudies", state: "Hooks_NavigationView"))
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
              $0.path.append(.init(id: "Atoms-CaseStudies", state: "Atoms_NavigationView"))
            }
          }
          HStack {
            Text("Recoil-CaseStudies")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Recoil-CaseStudies", state: "Recoil_NavigationView"))
            }
          }
        }
        Section(header: Text("Todos")) {
          HStack {
            Text("Hooks-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Hooks-Todos", state: "Hooks-Todos"))
            }
          }
          HStack {
            Text("Atoms-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Atoms-Todos", state: "Atoms-Todos"))
            }
          }
        }
      }
      .navigationTitle(Text("CaseStudies"))
      ._navigationDestination(for: _Destination.self) { destination in
        switch destination.id {
          case "TCA-CaseStudies":
            TCACaseStudiesView()
              .onAppear {
                print(destination.state as Any)
              }
          case "Hooks-CaseStudies":
            HookCaseStudiesView()
              .onAppear {
                print(destination.state as Any)
              }
          case "Atoms-CaseStudies":
            AtomRoot {
              AtomCaseStudiesView()
            }
            .onAppear {
              print(destination.state as Any)
            }
          case "Recoil-CaseStudies":
            AtomRoot {
              RecoilUseCaseStudiesView()
            }
          case "Hooks-Todos":
            HookScope {
              HookTodoView()
            }
          case "Atoms-Todos":
            AtomRoot {
              AtomTodoView()
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
