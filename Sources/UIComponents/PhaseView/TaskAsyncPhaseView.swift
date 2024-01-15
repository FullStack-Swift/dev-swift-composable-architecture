import SwiftUI
import SwiftExt

/// ``TaskAsyncPhaseView`` lets you display an ``TaskAsyncPhase`` status in a `View`.

public struct TaskAsyncPhaseView<
  Success,
  Pending: View,
  Running: View,
  FailureContent: View,
  SuccessContent: View
>: View {
  /// The TaskAsyncPhase represented.
  private let phase: TaskAsyncPhase<Success>
  /// The view for pending status.
  private let pending: () -> Pending
  /// The view for running status.
  private let running: () -> Running
  /// The view for success status.
  private let content: (Success) -> SuccessContent
  /// The view for failure status.
  private let failure: (Error) -> FailureContent
  
  public init(
    _ phase: TaskAsyncPhase<Success>,
    @ViewBuilder pending: @escaping () -> Pending,
    @ViewBuilder running: @escaping () -> Running,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
  ) {
    self.phase = phase
    self.pending = pending
    self.running = running
    self.content = content
    self.failure = failure
  }
  
  public init(
    _ phase: TaskAsyncPhase<Success>,
    @ViewBuilder running: @escaping () -> Running,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
  ) where Pending == EmptyView {
    self.init(phase) {
      EmptyView()
    } running: {
      running()
    } content: { success in
      content(success)
    } failure: { error in
      failure(error)
    }
  }
  
  public init(
    _ phase: TaskAsyncPhase<Success>,
    @ViewBuilder pending: @escaping () -> Pending,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
  ) where Running == EmptyView {
    self.init(phase) {
      pending()
    } running: {
      EmptyView()
    } content: { success in
      content(success)
    } failure: { error in
      failure(error)
    }
  }
  
  public init(
    _ phase: TaskAsyncPhase<Success>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
  ) where Pending == EmptyView, Running == EmptyView {
    self.init(phase) {
      EmptyView()
    } running: {
      EmptyView()
    } content: { success in
      content(success)
    } failure: { error in
      failure(error)
    }
  }
  
  public init(
    _ phase: TaskAsyncPhase<Success>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent
  ) where Pending == EmptyView, Running == EmptyView, FailureContent == EmptyView {
    self.init(phase) {
      EmptyView()
    } running: {
      EmptyView()
    } content: { success in
      content(success)
    } failure: { _ in
      EmptyView()
    }
  }
  
  public var body: some View {
    switch phase {
      case .pending:
        pending()
      case .running:
        running()
      case .success(let value):
        content(value)
      case .failure(let error):
        failure(error)
    }
  }
  
  public init(
    _ phase: TaskAsyncPhase<Success>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder loading: @escaping () -> Running,
    @ViewBuilder catch: @escaping (Error) -> FailureContent
  ) where Pending == Running {
    self.phase = phase
    self.pending = loading
    self.running = loading
    self.content = content
    self.failure = `catch`
  }
  
  public init(
    _ phase: TaskAsyncPhase<Success>,
    @ViewBuilder _ content: @escaping (Success) -> SuccessContent,
    @ViewBuilder loading: @escaping () -> Running
  ) where Pending == Running, FailureContent == EmptyView {
    self.init(
      phase,
      content: content,
      loading: loading
    ) { _ in
      EmptyView()
    }
  }
  
  public init(
    _ result: Result<Success, Error>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder catch: @escaping (Error) -> FailureContent
  ) where Pending == EmptyView, Running == EmptyView {
    self.init(result.toTaskAsyncPhase(), content: content, failure: `catch`)
  }
  
  public init(
    _ taskResult: TaskResult<Success>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder catch: @escaping (Error) -> FailureContent
  ) where Pending == EmptyView, Running == EmptyView {
    self.init(taskResult.toTaskAsyncPhase(), content: content, failure: `catch`)
  }
}
