public typealias GetState<StateType> = () -> StateType

public typealias MutableReduceFunction<ActionType, StateType> = (ActionType, inout StateType) -> Void
