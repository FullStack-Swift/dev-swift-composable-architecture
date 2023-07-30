import Foundation
import IdentifiedCollections
import SwiftUI
import Combine

public typealias AtomFamily<P, Node: Atom> = (P) -> RecoilParamNode<P, Node>

public struct RecoilParamNode<P, Node: Atom> {
  public let param: P
  public let node: Node
  
  public init(param: P, node: Node) {
    self.param = param
    self.node = node
  }
}

// MARK: Make MParamValueAtom
public struct MParamValueAtom<P, M>: ValueAtom {
  
  public typealias Value = M
  
  public let param: P
  
  var initialState: (Self.Context, P) -> M
  
  public var id: String
  
  public init(id: String, param: P,_ initialState: @escaping (Self.Context, P) -> M) {
    self.id = id
    self.param = param
    self.initialState = initialState
  }
  
  public init(id: String, param: P, initialState: M) {
    self.init(id: id, param: param) { _,_  in
      initialState
    }
  }
  
  public func value(context: Self.Context) -> M {
    initialState(context, param)
  }
  
  public var key: String {
    self.id
  }
}

// MARK: Make MParamTaskAtom
public struct MParamTaskAtom<P: Hashable, M>: TaskAtom {
  
  public typealias Value = M
  
  public var id: String
  
  public var initialState: (Self.Context, P) async -> M
  
  public let param: P
  
  public init(id: String, param: P,_ initialState: @escaping (Self.Context, P) async -> M) {
    self.id = id
    self.param = param
    self.initialState = initialState
  }
  
  public init(id: String, param: P, _ initialState: @escaping() async -> M) {
    self.init(id: id, param: param) { _,_ in
      await initialState()
    }
  }
  
  public init(id: String, param: P, _ initialState: M) {
    self.init(id: id, param: param) { _,_  in
      initialState
    }
  }
  
  @MainActor
  public func value(context: Self.Context) async -> Value {
    await initialState(context, param)
  }
  
  public var key: some Hashable {
    self.id + param.hashValue.description
  }
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
  _ initialState: @escaping (MParamValueAtom<P, T>.Context, P) -> T
) -> AtomFamily<P, MParamValueAtom<P, T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atomFamily: AtomFamily = { (param: P) -> RecoilParamNode<P, MParamValueAtom<P, T>> in
    RecoilParamNode(param: param, node: MParamValueAtom<P,T>(id: id, param: param, initialState))
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
  _ initialState: @escaping (MParamTaskAtom<P, T>.Context, P) async -> T
) -> AtomFamily<P, MParamTaskAtom<P, T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let atomFamily: AtomFamily<P, MParamTaskAtom<P, T>> = { (param: P) -> RecoilParamNode<P, MParamTaskAtom<P, T>> in
    RecoilParamNode(param: param, node: MParamTaskAtom<P, T>(id: id, param: param, initialState))
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> Node.Loader.Value {
  useRecoilValue(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> Binding<Node.Loader.Value> {
  useRecoilState(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilTask(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> AsyncPhase<Node.Loader.Success, Node.Loader.Failure>
where Node.Loader: AsyncAtomLoader {
  useRecoilThrowingTask(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilPublisher(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> (phase: AsyncPhase<Node.Publisher.Output, Node.Publisher.Failure>, refresher: () -> ())
where Node.Loader == PublisherAtomLoader<Node> {
  useRecoilRefresher(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
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
  fileID: String = #fileID,
  line: UInt = #line,
  _ value: RecoilParamNode<P, Node>
) -> (phase: AsyncPhase<Node.Loader.Success, Node.Loader.Failure>, refresher: () -> ())
where Node.Loader: AsyncAtomLoader {
  useRecoilRefresher(
    fileID: fileID,
    line: line,
    updateStrategy: .preserved(by: value.param),
    value.node
  )
}
