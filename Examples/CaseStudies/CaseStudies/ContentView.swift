import SwiftUI
import ComposableArchitecture

private extension DateFormatter {
  static let time: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
  }()
}

struct ContentView: View {
  
  @Dependency(\.navigationPath) var navigationPath
  
  @ViewContext
  var context
  
  var body: some View {
    _NavigationView {
      Form {
        Section(header: Text("Test")) {
          HookScope {
            if let date = useDate() {
              HStack {
                Text(DateFormatter.time.string(from: date))
                Spacer()
              }
              .background(Color.white.opacity(0.0001))
              .clipShape(Rectangle())
              .onTapGesture {
                navigationPath.commit {
                  $0.path.append(.init(id: "APIRequestPage", state: "APIRequestPage"))
                }
              }
            }
          }
        }
        
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
          HStack {
            Text("Riverpod-CaseStudies")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Riverpod-CaseStudies", state: "Riverpod_NavigationView"))
            }
          }
        }
        
        Section(header: Text("Todo - Architecture")) {
          HStack {
            Text("TCA-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "TCA-Todos", state: "TCA-Todos"))
            }
          }
          
          HStack {
            Text("MVVM-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "MVVM-Todos", state: "MVVM-Todos"))
            }
          }
          
          HStack {
            Text("MVC-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "MVC-Todos", state: "MVC-Todos"))
            }
          }
        }
        
        Section(header: Text("Todos - Components")) {
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
          HStack {
            Text("Recoil-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Recoil-Todos", state: "Recoil-Todos"))
            }
          }
          HStack {
            Text("Jotail-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Jotail-Todos", state: "Jotail-Todos"))
            }
          }
          HStack {
            Text("Riverpod-Todos")
            Spacer()
          }
          .background(Color.white.opacity(0.0001))
          .clipShape(Rectangle())
          .onTapGesture {
            navigationPath.commit {
              $0.path.append(.init(id: "Riverpod-Todos", state: "Riverpod-Todos"))
            }
          }
        }
      }
      .navigationTitle(Text("CaseStudies"))
      ._navigationDestination(for: _Destination.self) { destination in
        switch destination.id {
          case "TCA-CaseStudies":
            TCACaseStudiesView()
          case "Hooks-CaseStudies":
            HookCaseStudiesView()
          case "Atoms-CaseStudies":
            AtomCaseStudiesView()
          case "Recoil-CaseStudies":
            RecoilUseCaseStudiesView()
          case "Riverpod-CaseStudies":
            RiverpodCaseStudiesView()
            // MARK: - Todo Architectures
          case "TCA-Todos":
            TCATodoView()
          case "MVVM-Todos":
            MVVMTodoView()
          case "MVC-Todos":
            MVCTodoView()
            // MARK: - Todo Components
          case "Hooks-Todos":
            HookTodoView()
          case "Atoms-Todos":
            AtomTodoView()
          case "Recoil-Todos":
            RecoilTodoView()
          case "Jotail-Todos":
            JotailTodoView()
          case "Riverpod-Todos":
            RiverpodTodoView()
            // MARK: Other Test
          case "APIRequestPage":
            APIRequestPage()
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
