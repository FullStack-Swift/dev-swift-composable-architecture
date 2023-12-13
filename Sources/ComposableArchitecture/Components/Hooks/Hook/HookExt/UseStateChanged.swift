import SwiftUI

/// A hook to use a ``MHState`` to updated newState, Triggers a view update when the state has been changed
///
///     let count = useStateChanged {
///       let initialNode = expensiveComputation() // Int
///       return initialNode
///     }                                          // MHState<Int>
///      .onChange { newValue in
///
///       }
///Updated newState without `onChange`
///
///           $count.send(something)
///
/// - Parameter initialNode: A closure creating an initial state. The closure will only be called once, during the initial render.
/// - Returns: A `MHState<Node>` wrapping current state.

public func useStateChanged<Node>(
  _ initialNode: @escaping () -> Node
) -> MHState<Node> {
  useStateChanged(initialNode())
}

/// A hook to use a ``MHState`` to updated newState, Triggers a view update when the state has been changed
///
///     let count = useStateChanged(0)                                  // MHState<Int>
///      .onChange { newValue in
///
///       }
///Updated newState without `onChange`
///
///           $count.send(something)
///
/// - Parameter initialNode: A closure creating an initial state. The closure will only be called once, during the initial render.
/// - Returns: A `MHState<Node>` wrapping current state.
public func useStateChanged<Node>(
  _ initialNode: Node
) -> MHState<Node> {
  MHState(wrappedValue: initialNode)
}
