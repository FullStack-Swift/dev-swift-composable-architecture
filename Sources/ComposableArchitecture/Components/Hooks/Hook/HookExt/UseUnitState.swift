import SwiftUI

// MARK: Foundation

public func useBool(
  _ initialNode: @escaping () -> Bool
) -> Binding<Bool> {
  useState(initialNode())
}

public func useBool(
  _ initialNode: Bool = false
) -> Binding<Bool> {
  useState(initialNode)
}

public func useString(
  _ initialNode: @escaping () -> String
) -> Binding<String> {
  useState(initialNode())
}

public func useString(
  _ initialNode: String
) -> Binding<String> {
  useState(initialNode)
}

public func useNumber<N: Numeric>(
  _ initialNode: @escaping () -> N
) -> Binding<N> {
  useState(initialNode)
}


public func useNumber<N: Numeric>(
  _ initialNode: N
) -> Binding<N> {
  useState(initialNode)
}

public func useSet<Node: Hashable>(
  _ node: Set<Node>
) -> Binding<Set<Node>> {
  useState(node)
}

public func useArray<Node>(
  _ node: Array<Node>
) -> Binding<Array<Node>> {
  useState(node)
}

public func useDictionaray<K, V>(
  _ node: Dictionary<K, V>
) -> Binding<Dictionary<K, V>> {
  useState(node)
}

public func useIdentifiedArrayOf<Node>(
  _ node: IdentifiedArrayOf<Node> = []
) -> Binding<IdentifiedArrayOf<Node>> {
  useState(node)
}

func useQueue<Node>(
  _ node: Queue<Node>
) -> Binding<Queue<Node>> {
  useState(node)
}

func useStack<Node>(
  _ node: Stack<Node>
) -> Binding<Stack<Node>> {
  useState(node)
}

func useTree<Node>(
  _ node: TreeNode<Node>
) -> Binding<TreeNode<Node>> {
  useState(node)
}

func useId(
  _ updateStrategy: HookUpdateStrategy = .once
) -> UUID {
  useMemo(updateStrategy) {
    UUID()
  }
}
