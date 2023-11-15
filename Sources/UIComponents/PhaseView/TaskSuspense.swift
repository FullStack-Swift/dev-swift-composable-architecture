import SwiftUI
import SwiftExt

public struct TaskSuspense<
  Success,
  Pending: View,
  Running: View,
  SuccessContent: View,
  FailureContent: View
>: View {
  private let task: Task<Success, Error>
  private let pending: () -> Pending
  private let running: () -> Running
  private let content: (Success) -> SuccessContent
  private let failure: (Error) -> FailureContent
  
  @StateObject
  private var state = State()
  
  public init(
    _ task: Task<Success, Error>,
    @ViewBuilder pending: @escaping () -> Pending,
    @ViewBuilder running: @escaping () -> Running,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
  ) {
    self.task = task
    self.pending = pending
    self.running = running
    self.content = content
    self.failure = failure
  }
  
  public init(
    _ task: Task<Success, Error>,
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
    _ task: Task<Success, Error>,
    @ViewBuilder pending: @escaping () -> Pending,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder failure: @escaping (Error) -> FailureContent
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
    _ task: Task<Success, Error>,
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
    _ task: Task<Success, Error>,
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
    return TaskAsyncPhaseView(state.phase) {
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
    _ task: Task<Success, Error>,
    @ViewBuilder content: @escaping (Success) -> SuccessContent,
    @ViewBuilder loading: @escaping () -> Running,
    @ViewBuilder catch: @escaping (Error) -> FailureContent
  ) where Pending == Running {
    self.task = task
    self.pending = loading
    self.running = loading
    self.content = content
    self.failure = `catch`
  }
  
  public init(
    _ task: Task<Success, Error>,
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

private extension TaskSuspense {
  @MainActor
  final class State: ObservableObject {
    @Published
    private(set) var phase = TaskAsyncPhase<Success>.pending
    
    private var suspensionTask: Task<Void, Never>? {
      didSet { oldValue?.cancel() }
    }
    
    var task: Task<Success, Error>? {
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
            self?.phase = TaskAsyncPhase(result)
          }
        }
      }
    }
    
    deinit {
      suspensionTask?.cancel()
    }
  }
}
