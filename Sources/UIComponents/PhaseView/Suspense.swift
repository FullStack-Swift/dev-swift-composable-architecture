import SwiftUI
import SwiftExt

/// ``Suspense`` lets you display a ``Task`` status in a `View`.

public struct Suspense<
  Success, Failure: Error,
  Pending: View,
  Running: View,
  SuccessContent: View,
  FailureContent: View
>: View {
  /// The Task represent for async await programming.
  private let task: Task<Success, Failure>
  /// The view for pending status
  private let pending: () -> Pending
  /// The view for running status
  private let running: () -> Running
  /// The view for success status
  private let content: (Success) -> SuccessContent
  /// The view for failure status
  private let failure: (Failure) -> FailureContent
  
  @StateObject
  private var state = State()
  
  public init(
    _ task: Task<Success, Failure>,
    @ViewBuilder pending: @escaping () -> Pending,
    @ViewBuilder running: @escaping () -> Running,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Failure) -> FailureContent
  ) {
    self.task = task
    self.pending = pending
    self.running = running
    self.content = content
    self.failure = failure
  }
  
  public init(
    _ task: Task<Success, Failure>,
    @ViewBuilder running: @escaping () -> Running,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
  ) where Pending == EmptyView {
    self.init(task) {
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
    _ task: Task<Success, Failure>,
    @ViewBuilder pending: @escaping () -> Pending,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Failure) -> FailureContent
  ) where Running == EmptyView {
    self.init(task) {
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
    _ task: Task<Success, Failure>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
  ) where Pending == EmptyView, Running == EmptyView {
    self.init(task) {
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
    _ task: Task<Success, Failure>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent
  ) where Pending == EmptyView, Running == EmptyView, FailureContent == EmptyView {
    self.init(task) {
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
    state.task = task
    return AsyncPhaseView(state.phase) {
      pending()
    } running: {
      running()
    } content: { success in
      content(success)
    } failure: { error in
      failure(error)
    }
  }
  
  public init(
    _ task: Task<Success, Failure>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder loading: @escaping () -> Running,
    @ViewBuilder catch: @escaping (Failure) -> FailureContent
  ) where Pending == Running {
    self.task = task
    self.pending = loading
    self.running = loading
    self.content = content
    self.failure = `catch`
  }
  
  public init(
    _ task: Task<Success, Failure>,
    @ViewBuilder _ content: @escaping (Success) -> SuccessContent,
    @ViewBuilder loading: @escaping () -> Running
  ) where Pending == Running, FailureContent == EmptyView {
    self.init(
      task,
      content: content,
      loading: loading
    ) { _ in
      EmptyView()
    }
  }
}

private extension Suspense {
  @MainActor
  final class State: ObservableObject {
    @Published
    private(set) var phase = AsyncPhase<Success, Failure>.pending
    
    private var suspensionTask: Task<Void, Never>? {
      didSet { oldValue?.cancel() }
    }
    
    var task: Task<Success, Failure>? {
      didSet {
        guard task != oldValue else {
          return
        }
        
        guard let task else {
          phase = .pending
          return suspensionTask = nil
        }
        
        suspensionTask = Task { [weak self] in
          self?.phase = .running
          let result = await task.result
          if !Task.isCancelled {
            self?.phase = AsyncPhase(result)
          }
        }
      }
    }
    
    deinit {
      suspensionTask?.cancel()
    }
  }
}
