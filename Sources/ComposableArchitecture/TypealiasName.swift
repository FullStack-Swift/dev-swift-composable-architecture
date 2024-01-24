import Foundation
import Combine

// MARK: Function

public typealias CallBackFunction = () -> Void

public typealias CompletionFunction<C> = (C) -> Void

// Return
public typealias AsyncReturn<Output> = () async -> Output

public typealias ThrowingAsyncReturn<Output> = () async throws -> Output

public typealias MainAsyncReturn<Output> = @MainActor () async -> Output

public typealias MainThrowingAsyncReturn<Output> = @MainActor () async throws -> Output

public typealias Callback<R> = () -> R

//public typealias AsyncReturn<R> = () async -> R

//public typealias ThrowingAsyncCallback<R> = () async throws -> R

public typealias ThrowingAsyncCompletion = ThrowingAsyncReturn<Void>

// Param
public typealias ParamCallback<Param, R> = (Param) -> R

public typealias ParamAsyncCallback<Param, R> = (Param) async -> R

public typealias ParamThrowingAsyncCallback<Param, R> = (Param) async throws -> R

public func blockBuilder<V>(
  _ block: @escaping AsyncReturn<V>
) -> AsyncReturn<V> {
  block
}

public func blockBuilder<V>(
  _ block: @escaping ThrowingAsyncReturn<V>
) -> ThrowingAsyncReturn<V> {
  block
}

// Completion
public typealias AsyncCompletion = AsyncReturn<Void>

public func blockBuilder(
  _ block: @escaping AsyncCompletion
) -> AsyncCompletion {
  block
}



public func blockBuilder(
  _ block: @escaping ThrowingAsyncCompletion
) -> ThrowingAsyncCompletion {
  block
}

public func blockBuilder<V>(
  _ block: @escaping Callback<V>
) -> Callback<V> {
  block
}

public func blockBuilder<Param, R>(
  _ block: @escaping ParamCallback<Param, R>
) -> ParamCallback<Param, R> {
  block
}


public func blockBuilder<Param, R>(
  _ block: @escaping ParamAsyncCallback<Param, R>
) -> ParamAsyncCallback<Param, R> {
  block
}

public func blockBuilder<Param, R>(
  _ block: @escaping ParamThrowingAsyncCallback<Param, R>
) -> ParamThrowingAsyncCallback<Param, R> {
  block
}

public func blockReturn<Return>(
  _ return: Return
) -> Return {
  `return`
}
