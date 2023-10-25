import Foundation
import Combine

// MARK: Combine
public typealias SetCancellables = Set<AnyCancellable>

public typealias ActionSubject<Action> = PassthroughSubject<Action, Never>

public typealias StateSubject<State> = CurrentValueSubject<State, Never>

public typealias ObservableEvent = PassthroughSubject<(), Never>

// MARK: Function
public typealias CompletionFunction<C> = (C) -> ()

public typealias CallBackFunction = () -> ()

struct UniqueKey: Hashable {}

struct Pair<T: Equatable>: Equatable {
  let first: T
  let second: T
}
