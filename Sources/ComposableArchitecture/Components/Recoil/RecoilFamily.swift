import Foundation
import IdentifiedCollections
import SwiftUI
import Combine

public typealias AtomFamily<P: Hashable, Node: Atom> = (P) -> RecoilParamNode<P, Node>

public struct RecoilParamNode<P, Node: Atom> {
  public let param: P
  public let node: Node
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func recoilValueFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (P) -> T
) -> AtomFamily<P, MValueAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atomFamily: AtomFamily = { (param: P) -> RecoilParamNode<P, MValueAtom<T>> in
    RecoilParamNode(param: param, node: MValueAtom(id: id) { context in
      initialState(param)
    })
  }
  return atomFamily
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func recoilStateFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (P) -> T
) -> AtomFamily<P, MStateAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atomFamily: AtomFamily<P, MStateAtom<T>> = { (param: P) -> RecoilParamNode<P, MStateAtom<T>> in
    RecoilParamNode(param: param, node: MStateAtom(id: id) { context in
      initialState(param)
    })
  }
  return atomFamily
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func recoilTaskFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (P) -> T
) -> AtomFamily<P, MStateAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atomFamily: AtomFamily<P, MStateAtom<T>> = { (param: P) -> RecoilParamNode<P, MStateAtom<T>> in
    RecoilParamNode(param: param, node: MStateAtom(id: id) { context in
      initialState(param)
    })
  }
  return atomFamily
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func recoilThrowingTaskFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (P) -> T
) -> AtomFamily<P, MThrowingTaskAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atomFamily: AtomFamily<P, MThrowingTaskAtom<T>> = { (param: P) -> RecoilParamNode<P, MThrowingTaskAtom<T>> in
    RecoilParamNode(param: param, node: MThrowingTaskAtom(id: id) { context in
      initialState(param)
    })
  }
  return atomFamily
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func recoilPublisherFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialState: @escaping (P) -> T
) -> AtomFamily<P, MPublisherAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atomFamily: AtomFamily<P, MPublisherAtom<T>> = { (param: P) -> RecoilParamNode<P, MPublisherAtom<T>> in
    RecoilParamNode(param: param, node: MPublisherAtom(id: id) { context in
      initialState(param)
    })
  }
  return atomFamily
}

// MARK: Recoil Hook Function.

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilValue<P: Equatable, Node: Atom>(
  _ value: RecoilParamNode<P, Node>
) -> Node.Loader.Value {
  useRecoilValue(updateStrategy: .preserved(by: value.param), value.node)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilState<P: Equatable, Node: StateAtom>(
  _ value: RecoilParamNode<P, Node>
) -> Binding<Node.Loader.Value> {
  useRecoilState(updateStrategy: .preserved(by: value.param), value.node)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilTask<P: Equatable, Node: TaskAtom>(
  _ value: RecoilParamNode<P, Node>
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(updateStrategy: .preserved(by: value.param), value.node)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilThrowingTask<P: Equatable, Node: ThrowingTaskAtom>(
  _ value: RecoilParamNode<P, Node>
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilThrowingTask(updateStrategy: .preserved(by: value.param), value.node)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilPublisher<P: Equatable, Node: PublisherAtom>(
  _ value: RecoilParamNode<P, Node>
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilPublisher(updateStrategy: .preserved(by: value.param), value.node)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<P: Equatable, Node: PublisherAtom>(
  _ value: RecoilParamNode<P, Node>
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher(updateStrategy: .preserved(by: value.param), value.node)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<P: Equatable, Node: TaskAtom>(
  _ value: RecoilParamNode<P, Node>
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(updateStrategy: .preserved(by: value.param), value.node)
}

/// Description:A hook will subscribe to the component atom to re-render if there are any changes in the Recoil state.
/// - Parameters:
///   - fileID: the path to the file it appears in.
///   - line: the line number on which it appears.
///   - updateStrategy: the Strategy update state.
///   - initialNode: the any Atom value.
/// - Returns: Hook Value.
@MainActor
public func useRecoilRefresher<P: Equatable, Node: ThrowingTaskAtom>(
  _ value: RecoilParamNode<P, Node>
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(updateStrategy: .preserved(by: value.param), value.node)
}
