import SwiftUI
import Foundation
import MCombineRequest
import SwiftLogger

public struct AsyncPhaseView: HookView {

  let request: MRequest?

  init(_ request: MRequest?) {
    self.request = request
  }

  public var hookBody: some View {
    ZStack {
      let (phase, perform) = useAsyncPerform { () -> Data? in
        guard let request = request else {
          return nil
        }
        let data = try await request.data
        try await Task.sleep(for: .seconds(2))
        log.info(Json(data))
        return data
      }
      ScrollView {
        Color.white.opacity(0.0001)
        VStack(alignment: .center) {
          switch phase {
            case .running:
              ProgressView()
            case .success(let data):
              HStack(alignment: .center) {
                Text(data?.toJson().description ?? "Nil")
                  .lineLimit(nil)
                  .multilineTextAlignment(.leading)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                Spacer()
              }
              .onTapGesture {
                Task {
                  await perform()
                }
              }
            case .failure(let error):
              Text(error.localizedDescription)
                .padding()
                .bold()
                .foregroundColor(.red)
                .onTapGesture {
                  Task {
                    await perform()
                  }
                }
            case .pending:
              ProgressView()
          }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .task {
        await perform()
      }
    }
  }
}
