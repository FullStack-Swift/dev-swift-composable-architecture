import Observation
import SwiftUI

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, *)
public struct ObservationView<Content: View>: View {
  
  @State private var count: Int = 0
  
  private let content: () -> Content
  
  public init(@ViewBuilder _ content: @escaping () -> Content) {
    self.content = content
  }
  
  public var body: some View {
    _ = count
    Self._printChanges()
    return withObservationTracking {
      content()
    } onChange: {
      count += 1
      print(Date(), count)
    }
  }
}
