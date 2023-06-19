import SwiftUI

/// ```swift
/// let phase: AsyncPhase<UIImage, Error> == ...
/// AsyncPhaseView(phase: phase) { uiImage in
///  Image(uiImage: uiImage)
/// } suspending: {
///  ProgressView()
///} failureContent: { error in
///  Text(error.localizedDescription)
///}
///```

public struct AsyncPhaseView<
  Value,
  Failure: Error,
  Content: View,
  Suspending: View,
  FailureContent: View
>: View {
  private let phase: AsyncPhase<Value, Failure>
  private let content: (Value) -> Content
  private let suspending: () -> Suspending
  private let failureContent: (Failure) -> FailureContent
  
  public init(
    phase: AsyncPhase<Value, Failure>,
    content: @escaping (Value) -> Content,
    suspending: @escaping () -> Suspending,
    failureContent: @escaping (Failure) -> FailureContent
  ) {
    self.phase = phase
    self.content = content
    self.suspending = suspending
    self.failureContent = failureContent
  }
  
  public var body: some View {
    switch phase {
      case .suspending:
        suspending()
      case .success(let value):
        content(value)
      case .failure(let error):
        failureContent(error)
    }
  }
}


