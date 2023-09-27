import Foundation

public struct IO<Action> {
  private let runIO: (AnyActionHandler<Action>) -> Void

  public init(_ run: @escaping (AnyActionHandler<Action>) -> Void) {
    self.runIO = run
  }

  public func run(_ output: AnyActionHandler<Action>) {
    runIO(output)
  }

  public func run (_ output: @escaping (DispatchedAction<Action>) -> Void) {
    runIO(.init(output))
  }
}

public func <> <Action>(lhs: IO<Action>, rhs: IO<Action>) -> IO<Action> {
  .init { handler in
    lhs.run(handler)
    rhs.run(handler)
  }
}

extension IO {
  public static var none: IO {
    IO { _ in }
  }
}

extension IO {
  public func map<NewAction>(
    _ transform: @escaping (Action) -> NewAction
  ) -> IO<NewAction> {
    IO<NewAction> { output in
      self.run(output.map(transform))
    }
  }
}

extension IO {
  public func flatMap<NewAction>(
    _ transform: @escaping (DispatchedAction<Action>) -> IO<NewAction>
  ) -> IO<NewAction> {
    IO<NewAction> { newAction in
      self.run(.init { action in
        transform(action).run(newAction)
      })
    }
  }
}

extension IO {
  
  /// Listening Action
  /// - Parameter output: callback Action
  public func on(_ output: @escaping (DispatchedAction<Action>) -> Void) {
    runIO(.init(output))
  }
  
}
