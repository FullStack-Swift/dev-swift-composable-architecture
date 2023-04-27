import Dependencies
import Dependencies

public struct AsyncIO<Action> {
  private let runIO: (AnyActionHandler<Action>) async -> Void
  
  public init(_ run: @escaping ((AnyActionHandler<Action>) async -> Void)) {
    self.runIO = withEscapedDependencies { continuation in
      return { anyAction in
        await continuation.yield { await run(anyAction) }
      }
    }
  }
  
  public static func pure() -> AsyncIO {
    AsyncIO {_ in }
  }
  
  public func run(_ output: AnyActionHandler<Action>) async {
    await runIO(output)
  }
  
  public func run(_ output: @escaping (DispatchedAction<Action>) -> Void) async {
    await runIO(.init(output))
  }
  
  public func performAsync(_ output: AnyActionHandler<Action>) async -> () {
    await self.runIO(output)
  }
}

extension AsyncIO {
  public static var identity: AsyncIO { .pure() }
}

public func <> <Action>(lhs: AsyncIO<Action>, rhs: AsyncIO<Action>) async -> AsyncIO<Action> {
  .init { handler in
    await lhs.run(handler)
    await rhs.run(handler)
  }
}

extension AsyncIO {
  public func map<NewAction>(_ transform: @escaping(Action) -> NewAction) async -> AsyncIO<NewAction> {
    AsyncIO<NewAction> { newAction in
      await self.run(newAction.contramap(transform))
    }
  }
}

extension AsyncIO {
  public func flatMap<NewAction>(
    _ transform: @escaping (DispatchedAction<Action>) async -> AsyncIO<NewAction>
  ) -> AsyncIO<NewAction> {
    AsyncIO<NewAction> { newAction in
      await self.run(.init { action in
        Task {
          await transform(action).run(newAction)
        }
      })
    }
  }
}
