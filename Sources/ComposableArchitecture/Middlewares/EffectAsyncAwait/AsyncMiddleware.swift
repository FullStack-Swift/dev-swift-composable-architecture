import _Concurrency
import Foundation

open class AsyncMiddleware<InputActionType, OutputActionType, StateType>: MiddlewareProtocol {

  public init() {}

  public func handle(
    action: InputActionType,
    from dispatcher: ActionSource,
    state: @escaping GetState<StateType>
  ) -> IO<OutputActionType> {
    let io = IO<OutputActionType> { [weak self] output in
      guard let self else { return }
      Task { @MainActor in
        if let outputAction = try? await self.asyncHandle(action: action, state: state) {
          output.dispatch(outputAction)
        }
      }
    }
    return io
  }

  @MainActor
  open func asyncHandle(
    action:InputActionType,
    state: @escaping GetState<StateType>
  ) async throws -> OutputActionType? {
    return nil
  }
}