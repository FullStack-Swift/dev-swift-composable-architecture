import SwiftUI
import Combine

// MARK: SwiftUI

public func useColor(color: Color) -> some View {
  HookScope {
    color
  }
}

public func useToggle() {
  
}

public func useText() {
  
}

public func useInput() {
  
}

public func useNavigationTitle() {
  
}

public func useLongPress() {
  
}

public func useTapPress() {
  
}

public func usePreferredLanguage() {
  
}

public func useTheme() {
  
}

public func onAppear() {
  
}

public func onDisAppear() {
  
}

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

public func useIOnlineStatus() {
  
}

func useLocalStoreage() {
  
}


public func useTimeout() {
  
}

public func useEventListener() {
  
}

func useNetworkingState() {
  
}

func useFetch() {
  
}

func useRequest() {
  
}

func useContinuousRetry() {
  
}

func useHistoryState() {
  
}

func useOjbectState() {
  
}

func useCounter() {
  
}


/// Throttle computationally expensive operations with useThrottle.
/// 
/// DESCRIPTION:
/// The useThrottle hook offers a controlled way to manage execution frequency in a React application. By accepting a value and an optional interval, it ensures that the value is updated at most every interval milliseconds. This is particularly helpful for limiting API calls, reducing UI updates, or mitigating performance issues by throttling computationally expensive operations.
/// - Parameters:
///   - value: The value to throttle.
///   - delay: (Optional) The interval in milliseconds. Default: 500ms.
/// - Returns: The throttled value that is updated at most once per interval.
public func useThrottle<V>(value: V, delay: Double) -> V {
  let binding = useState(value)
  return binding.wrappedValue
}

/// Delay the execution of function or state update with useDebounce.

/// The useDebounce hook is useful for delaying the execution of functions or state updates until a specified time period has passed without any further changes to the input value. This is especially useful in scenarios such as handling user input or triggering network requests, where it effectively reduces unnecessary computations and ensures that resource-intensive operations are only performed after a pause in the input activity.
///
/// - Parameters:
///   - value: The value that you want to debounce. This can be of any type.
///   - delay: The delay time in milliseconds. After this amount of time, the latest value is used.
/// - Returns: The debounced value. After the delay time has passed without the value changing, this will be updated to the latest value.
public func useDebounce<V>(value: V, delay: Double) -> V {
  let binding = useState(value)
  return binding.wrappedValue
}


