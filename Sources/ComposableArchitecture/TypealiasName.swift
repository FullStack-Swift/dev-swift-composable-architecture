import Foundation
import Combine

// MARK: Combine
public typealias SetCancellables = Set<AnyCancellable>

public typealias ActionSubject<Action> = PassthroughSubject<Action, Never>

public typealias StateSubject<State> = CurrentValueSubject<State, Never>

public typealias ObservableEvent = PassthroughSubject<(), Never>

// MARK: Function

public typealias CallBackFunction = () -> Void

public typealias CompletionFunction<C> = (C) -> Void

// Return
public typealias AsyncReturn<Output> = () async -> Output

public typealias MainAsyncReturn<Output> = @MainActor () async -> Output

public func blockBuilder<V>(_ block: @escaping AsyncReturn<V>) -> AsyncReturn<V> {
  block
}

public typealias ThrowingAsyncReturn<Output> = () async throws -> Output

public typealias MainThrowingAsyncReturn<Output> = @MainActor () async throws -> Output

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

public func blockReturn<Return>(_ return: Return) -> Return {
  `return`
}
