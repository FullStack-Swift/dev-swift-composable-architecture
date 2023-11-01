import SwiftUI

extension DateFormatter {
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
            Text("Test New Feature")
              .alignment(horizontal: .leading)
              .onTap {
                navigationPath.commit {
                  $0.path.append(.init(id: "APIRequestPage", state: "APIRequestPage"))
                }
              }
          }
        }
        
        Section(header: Text("UIComponents")) {
          HookScope {
            Text("UIComponents")
              .alignment(horizontal: .leading)
              .onTap {
                navigationPath.commit {
                  $0.path.append(.init(id: "UIComponents", state: "UIComponents"))
                }
              }
          }
        }
        
        Section(header: Text("Getting started")) {
          
          CaseStudyCell("TCA-CaseStudies")
            .onTap {
              navigationPath.commit {
                $0.path.append(.init(id: "TCA-CaseStudies", state: "TCA_NavigationView"))
              }
            }
          
          CaseStudyCell("Hooks-CaseStudies")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Hooks-CaseStudies", state: "Hooks_NavigationView"))
            }
          }

          CaseStudyCell("Atoms-CaseStudies")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Atoms-CaseStudies", state: "Atoms_NavigationView"))
            }
          }

          CaseStudyCell("Recoil-CaseStudies")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Recoil-CaseStudies", state: "Recoil_NavigationView"))
            }
          }

          CaseStudyCell("Jotail-CaseStudies")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Jotail-CaseStudies", state: "Jotail_NavigationView"))
            }
          }

          CaseStudyCell("Riverpod-CaseStudies")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Riverpod-CaseStudies", state: "Riverpod_NavigationView"))
            }
          }
        }
        
        Section(header: Text("Todo - Architecture")) {
          
          CaseStudyCell("Redux-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Redux-Todos", state: "Redux-Todos"))
            }
          }

          CaseStudyCell("VIP-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "VIP-Todos", state: "VIP-Todos"))
            }
          }

          CaseStudyCell("TCA-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "TCA-Todos", state: "TCA-Todos"))
            }
          }

          CaseStudyCell("MVVM-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "MVVM-Todos", state: "MVVM-Todos"))
            }
          }
          
          CaseStudyCell("MVC-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "MVC-Todos", state: "MVC-Todos"))
            }
          }
        }
        
        Section(header: Text("Todos - Components")) {

          CaseStudyCell("Hooks-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Hooks-Todos", state: "Hooks-Todos"))
            }
          }

          CaseStudyCell("Atoms-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Atoms-Todos", state: "Atoms-Todos"))
            }
          }

          CaseStudyCell("Recoil-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Recoil-Todos", state: "Recoil-Todos"))
            }
          }
          
          CaseStudyCell("Jotail-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Jotail-Todos", state: "Jotail-Todos"))
            }
          }

          CaseStudyCell("Riverpod-Todos")
          .onTap {
            navigationPath.commit {
              $0.path.append(.init(id: "Riverpod-Todos", state: "Riverpod-Todos"))
            }
          }
        }
      }
      .navigationTitle(Text("CaseStudies"))
      ._navigationDestination(for: _Destination.self) { destination in
        switch destination.id {
          case "UIComponents":
            UIComponentView()
            // MARK: - CaseStudies
          case "TCA-CaseStudies":
            TCACaseStudiesView()
          case "Hooks-CaseStudies":
            HookCaseStudiesView()
          case "Atoms-CaseStudies":
            AtomCaseStudiesView()
          case "Recoil-CaseStudies":
            RecoilUseCaseStudiesView()
          case "Jotail-CaseStudies":
            JotaiCaseStudiesView()
          case "Riverpod-CaseStudies":
            RiverpodCaseStudiesView()
            // MARK: - Todo Architectures
          case "TCA-Todos":
            TCATodoView()
          case "Redux-Todos":
            ReduxTodoView()
          case "VIP-Todos":
            VIPTodoView()
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

#Preview {
  ContentView()
}

struct CaseStudyCell: View {
  
  let title: String
  
  var onTap: MTapGesture?
  
  
  init(title: String, onTap: MTapGesture? = nil) {
    self.title = title
    self.onTap = onTap
  }
  
  init(_ title: String, onTap: MTapGesture? = nil) {
    self.title = title
    self.onTap = onTap
  }
  
  var body: some View {
    Text(title)
      .alignment(.leading)
      .if(onTap != nil) {
        $0.onTap {
          onTap?()
        }
      }
  }
  
  func onTap( _ onTap: MTapGesture?) -> some View {
    with {
      $0.onTap = onTap
    }
  }
}
