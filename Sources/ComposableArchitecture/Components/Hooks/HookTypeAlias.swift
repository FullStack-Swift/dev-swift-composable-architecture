import Foundation

// Return
public typealias AsyncReturn<Output> = @MainActor () async -> Output

public func blockBuilder<V>(_ block: @escaping AsyncReturn<V>) -> AsyncReturn<V> {
  block
}


public typealias ThrowingAsyncReturn<Output> = @MainActor () async throws -> Output

public func blockBuilder<V>(_ block: @escaping ThrowingAsyncReturn<V>) -> ThrowingAsyncReturn<V> {
  block
}


// Completion
public typealias AsyncCompletion = AsyncReturn<Void>

public func blockBuilder(_ block: @escaping AsyncCompletion) -> AsyncCompletion {
  block
}


public typealias ThrowingAsyncCompletion = ThrowingAsyncReturn<Void>

public func blockBuilder(_ block: @escaping ThrowingAsyncCompletion) -> ThrowingAsyncCompletion {
  block
}

// Callback
public typealias Callback<R> = () -> R

public func blockBuilder<V>(_ block: @escaping Callback<V>) -> Callback<V> {
  block
}


public typealias AsyncCallback<R> = () async -> R

public typealias ThrowingAsyncCallback<R> = () async throws -> R

// Param
public typealias ParamCallback<Param, R> = (Param) -> R

public func blockBuilder<Param, R>(_ block: @escaping ParamCallback<Param, R>) -> ParamCallback<Param, R> {
  block
}

public typealias ParamAsyncCallback<Param, R> = (Param) async -> R

public func blockBuilder<Param, R>(_ block: @escaping ParamAsyncCallback<Param, R>) -> ParamAsyncCallback<Param, R> {
  block
}

public typealias ParamThrowingAsyncCallback<Param, R> = (Param) async throws -> R

public func blockBuilder<Param, R>(_ block: @escaping ParamThrowingAsyncCallback<Param, R>) -> ParamThrowingAsyncCallback<Param, R> {
  block
}
