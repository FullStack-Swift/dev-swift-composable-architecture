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
      EmptyView()
    }
  }
}
