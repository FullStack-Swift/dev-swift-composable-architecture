import Foundation

public struct IO<Action> {
  private let runIO: (AnyActionHandler<Action>) -> Void

  public init(_ run: @escaping (AnyActionHandler<Action>) -> Void) {
    self.runIO = run
  }

  public static func pure() -> IO {
    IO { _ in }
  }

  public func run(_ output: AnyActionHandler<Action>) {
    runIO(output)
  }

  public func run (_ output: @escaping (DispatchedAction<Action>) -> Void) {
    runIO(.init(output))
  }
}

extension IO {
  public static var identity: IO { .pure() }
}

public func <> <Action>(lhs: IO<Action>, rhs: IO<Action>) -> IO<Action> {
  .init { handler in
    lhs.run(handler)
    rhs.run(handler)
  }
}

extension IO {
  public func map<NewAction>(
    _ transform: @escaping (Action) -> NewAction
  ) -> IO<NewAction> {
    IO<NewAction> { output in
      self.run(output.contramap(transform))
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
