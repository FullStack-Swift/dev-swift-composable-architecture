import SwiftUI

struct HookUseDateView: View {
  var body: some View {
    HookScope {
      List {
        if let date = useDate() {
          Text(DateFormatter.time.string(from: date))
            .font(.largeTitle)
        }

        if let date = useDate(date: Date()) {
          Text(DateFormatter.time.string(from: date))
            .font(.largeTitle)
        }
        
        let datePhase = usePhaseDate()
        switch datePhase {
          case .success(let date):
            Text(DateFormatter.time.string(from: date))
              .font(.largeTitle)
          case .failure:
            Text("Failure")
          default:
            EmptyView()
        }
      }
    }
    .navigationBarTitle(Text("Hook Date"), displayMode: .inline)
  }
}

#Preview {
  HookUseDateView()
}
