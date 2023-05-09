import _Concurrency
import Foundation

#if compiler(>=5.7)
public class AsyncMiddleware<State, Action>: MiddlewareProtocol {
  @usableFromInline
  let handle: (Action, ActionSource, @escaping GetState<State>) async throws -> Action?

  @usableFromInline
  init(
    internal handle: @escaping (Action, ActionSource, @escaping GetState<State>) async throws -> Action?
  ) {
    self.handle = handle
  }

  @inlinable
  public convenience init(_ handle: @escaping (Action, ActionSource, @escaping GetState<State>) async throws -> Action?) {
    self.init(internal: handle)
  }

  public func handle(action: Action, from dispatcher: ActionSource, state: @escaping GetState<State>) -> IO<Action> {
    let io = IO<Action> { [weak self] output in
      guard let self else { return }
      Task { @MainActor in
        if let outputAction = try? await self.handle(action, dispatcher, state) {
          output.dispatch(outputAction)
        }
      }
    }
    return io
  }
}

#else
//open class AsyncMiddleware<InputActionType, OutputActionType, StateType>: MiddlewareProtocol {
//
//    public init() {}
//
//    public func handle(
//        action: InputActionType,
//        from dispatcher: ActionSource,
//        state: @escaping GetState<StateType>
//    ) -> IO<OutputActionType> {
//        let io = IO<OutputActionType> { [weak self] output in
//            guard let self else { return }
//            Task { @MainActor in
//                if let outputAction = try? await self.asyncHandle(action: action, state: state) {
//                    output.dispatch(outputAction)
//                }
//            }
//        }
//        return io
//    }
//
//    @MainActor
//    open func asyncHandle(
//        action:InputActionType,
//        state: @escaping GetState<StateType>
//    ) async throws -> OutputActionType? {
//        return nil
//    }
//}

#endif
