import Foundation

// Return
public typealias AsyncReturn<Output> = @MainActor () async -> Output

public typealias ThrowingAsyncReturn<Output> = @MainActor () async throws -> Output

// Completion
public typealias AsyncCompletion = AsyncReturn<Void>

public typealias ThrowingAsyncCompletion = ThrowingAsyncReturn<Void>

// Callback
public typealias Callback<R> = () -> R

public typealias AsyncCallback<R> = () async -> R

public typealias ThrowingAsyncCallback<R> = () async throws -> R

// Param
public typealias ParamCallback<Param, R> = (Param) -> R

public typealias ParamAsyncCallback<Param, R> = (Param) async -> R

public typealias ParamThrowingAsyncCallback<Param, R> = (Param) async throws -> R
