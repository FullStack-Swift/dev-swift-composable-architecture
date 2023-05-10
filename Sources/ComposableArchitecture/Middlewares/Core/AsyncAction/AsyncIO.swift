import Dependencies

public struct AsyncIO<Action> {
  private let runIO: (AsyncAnyActionHandler<Action>) async throws -> Void

  public init(_ run: @escaping ((AsyncAnyActionHandler<Action>) async throws -> Void)) {
    self.runIO = withEscapedDependencies { continuation in
      return { anyAction in
        try await continuation.yield { try await run(anyAction) }
      }
    }
  }
  
  public func run(_ output: AsyncAnyActionHandler<Action>) async throws {
    try await runIO(output)
  }
  
  public func run(_ output: @escaping (DispatchedAction<Action>) async throws -> Void) async throws {
    try await runIO(.init(output))
  }
}

extension AsyncIO {
  public static func none() -> AsyncIO {
    AsyncIO { _ in }
  }
}

public func <> <Action>(lhs: AsyncIO<Action>, rhs: AsyncIO<Action>) async throws -> AsyncIO<Action> {
  .init { handler in
    try await lhs.run(handler)
    try await rhs.run(handler)
  }
}

extension AsyncIO {
  public func map<NewAction>(
    _ transform: @escaping(Action) -> NewAction
  ) async throws -> AsyncIO<NewAction> {
    AsyncIO<NewAction> { newAction in
      try await self.run(newAction.map(transform))
    }
  }
}

extension AsyncIO {
  public func flatMap<NewAction>(
    _ transform: @escaping (DispatchedAction<Action>) async throws -> AsyncIO<NewAction>
  ) -> AsyncIO<NewAction> {
    AsyncIO<NewAction> { newAction in
      try await self.run(.init { action in
        try await transform(action).run(newAction)
      })
    }
  }
}
