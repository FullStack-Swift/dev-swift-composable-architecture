import SwiftUI

/// A view that lets the content wait for the given task to provide a resulting value
/// or an error.
///
/// ``Suspense`` manages the given task internally until the task instance is changed.
/// While the specified task is in process to provide a resulting value, it displays the
/// `suspending` content that is empty by default.
/// When the task eventually provides a resulting value, it updates the view to display
/// the given content. If the task fails, it falls back to show the `catch` content that
/// is also empty as default.
///
/// ## Example
///
/// ```swift
/// let phase: AsyncPhase<UIImage, Error> == ...
///
/// AsyncPhaseView(phase) { uiImage in
///     // Displays content when the task successfully provides a value.
///     Image(uiImage: uiImage)
/// } suspending: {
///     // Optionally displays a suspending content.
///     ProgressView()
/// } catch: { error in
///     // Optionally displays a failure content.
///     Text(error.localizedDescription)
/// }
/// ```
///
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

  /// Waits for the given task to provide a resulting value and display the content
  /// accordingly.
  ///
  /// ```swift
  /// let phase: AsyncPhase<UIImage, Error> == ...
  ///
  /// AsyncPhaseView(phase) { uiImage in
  ///     Image(uiImage: uiImage)
  /// } suspending: {
  ///     ProgressView()
  /// } catch: { error in
  ///     Text(error.localizedDescription)
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - task: A task that provides a resulting value to be displayed.
  ///   - content: A content that displays when the task successfully provides a value.
  ///   - suspending: A suspending content that displays while the task is in process.
  ///   - catch: A failure content that displays if the task fails.
  public init(
    phase: AsyncPhase<Value, Failure>,
    @ViewBuilder content: @escaping (Value) -> Content,
    @ViewBuilder suspending: @escaping () -> Suspending,
    @ViewBuilder failureContent: @escaping (Failure) -> FailureContent
  ) {
    self.phase = phase
    self.content = content
    self.suspending = suspending
    self.failureContent = failureContent
  }

  /// Waits for the given task to provide a resulting value and display the content
  /// accordingly.
  ///
  /// ```swift
  /// let phase: AsyncPhase<UIImage, Error> == ...
  ///
  /// AsyncPhaseView(phase) { uiImage in
  ///     Image(uiImage: uiImage)
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - task: A task that provides a resulting value to be displayed.
  ///   - content: A content that displays when the task successfully provides a value.
  public init(
    phase: AsyncPhase<Value, Failure>,
    @ViewBuilder content: @escaping (Value) -> Content
  ) where Suspending == EmptyView, FailureContent == EmptyView {
    self.init(
      phase: phase,
      content: content,
      suspending: EmptyView.init,
      failureContent: { _ in EmptyView()}
    )
  }

  /// Waits for the given task to provide a resulting value and display the content
  /// accordingly.
  ///
  /// ```swift
  /// let phase: AsyncPhase<UIImage, Error> == ...
  ///
  /// AsyncPhaseView(phase) { uiImage in
  ///     Image(uiImage: uiImage)
  /// } suspending: {
  ///     ProgressView()
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - task: A task that provides a resulting value to be displayed.
  ///   - content: A content that displays when the task successfully provides a value.
  ///   - suspending: A suspending content that displays while the task is in process.
  public init(
    phase: AsyncPhase<Value, Failure>,
    @ViewBuilder content: @escaping (Value) -> Content,
    @ViewBuilder suspending: @escaping () -> Suspending
  ) where FailureContent == EmptyView {
    self.init(
      phase: phase,
      content: content,
      suspending: suspending,
      failureContent: { _ in EmptyView() }
    )
  }

  /// Waits for the given task to provide a resulting value and display the content
  /// accordingly.
  ///
  /// ```swift
  /// let phase: AsyncPhase<UIImage, Error> == ...
  ///
  /// AsyncPhaseView(phase) { uiImage in
  ///     Image(uiImage: uiImage)
  /// } catch: { error in
  ///     Text(error.localizedDescription)
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - task: A task that provides a resulting value to be displayed.
  ///   - content: A content that displays when the task successfully provides a value.
  ///   - catch: A failure content that displays if the task fails.
  public init(
    phase: AsyncPhase<Value, Failure>,
    @ViewBuilder content: @escaping (Value) -> Content,
    @ViewBuilder failureContent: @escaping (Failure) -> FailureContent
  ) where Suspending == EmptyView {
    self.init(
      phase: phase,
      content: content,
      suspending: EmptyView.init,
      failureContent: failureContent
    )
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
