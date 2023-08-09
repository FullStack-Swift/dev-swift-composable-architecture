import Foundation
import IdentifiedCollections
import SwiftUI
import Combine

public typealias AtomFamily<P, Node: Atom> = (P) -> RecoilParamNode<P, Node>

public typealias TaskAtomFamily<P, Node: TaskAtom> = (P) async -> RecoilParamNode<P, Node>

public typealias ThrowingTaskAtomFamily<P, Node: ThrowingTaskAtom> = (P) async throws -> RecoilParamNode<P, Node>

fileprivate var currentParamFamily: RefObject<Any>? = nil
fileprivate func curryFnRecoilFamily<A, B, C>(
  _ f: @escaping (A, B) -> C
) -> (A) -> (B) ->  C  {
  return { a in
    currentParamFamily = RefObject(a)
    return { b in
      defer {
        currentParamFamily = nil
      }
      if let currentParamFamily = currentParamFamily,
         let current = currentParamFamily.current as? A {
        return f(current, b)
      }
      return f(a, b)
    }
  }
}

fileprivate var currentTaskParamFamily: RefObject<Any>? = nil
fileprivate func curryFnTaskRecoilFamily<A, B, C>(
  _ f: @escaping (A, B) async -> C
) -> (A) -> (B) async ->  C  {
  return { a in
    currentTaskParamFamily = RefObject(a)
    return { b in
      defer {
        currentTaskParamFamily = nil
      }
      if let currentParamFamily = currentTaskParamFamily,
         let current = currentParamFamily.current as? A {
        return await f(current, b)
      }
      return await f(a, b)
    }
  }
}

fileprivate var currentThrowingTaskParamFamily: RefObject<Any>? = nil
fileprivate func curryFnThrowingTaskRecoilFamily<A, B, C>(
  _ f: @escaping (A, B) async throws -> C
) -> (A) -> (B) async throws ->  C  {
  return { a in
    currentThrowingTaskParamFamily = RefObject(a)
    return { b in
      defer {
        currentThrowingTaskParamFamily = nil
      }
      if let currentParamFamily = currentThrowingTaskParamFamily,
         let current = currentParamFamily.current as? A {
        return try await f(current, b)
      }
      return try await f(a, b)
    }
  }
}

public struct RecoilParamNode<P, Node: Atom> {
  public let param: P
  public let node: Node
  
  public init(param: P, node: Node) {
    self.param = param
    self.node = node
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
  _ initialNode: @escaping (P, AtomTransactionContext<Void>) -> T
) -> AtomFamily<P, MValueAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let body = curryFnRecoilFamily(initialNode)
  @RecoilGlobalViewContext
  var _context
  return { (param: P) -> RecoilParamNode<P, MValueAtom<T>> in
    let _body = body(param)
    let node = MValueAtom<T>(id: id) { context -> T in
      return _body(context)
    }
    _context.reset(node)
    return RecoilParamNode(param: param, node: node)
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
public func recoilStateFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: @escaping (P, AtomTransactionContext<Void>) -> T
) -> AtomFamily<P, MStateAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let body = curryFnRecoilFamily(initialNode)
  @RecoilGlobalViewContext
  var _context
  return { (param: P) -> RecoilParamNode<P, MStateAtom<T>> in
    let _body = body(param)
    let node = MStateAtom<T>(id: id) { context -> T in
      return _body(context)
    }
    _context.reset(node)
    return RecoilParamNode(param: param, node: node)
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
public func recoilTaskFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: @escaping (P, RecoilGlobalContext) async -> T
) -> AtomFamily<P, MTaskAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let body = curryFnTaskRecoilFamily(initialNode)
  @RecoilGlobalViewContext
  var _context
  return { (param: P) -> RecoilParamNode<P, MTaskAtom<T>> in
    let _body = body(param)
    let node = MTaskAtom<T>(id: id) { context -> T in
      await _body(_context)
    }
    _context.reset(node)
    return RecoilParamNode(param: param, node: node)
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
public func recoilThrowingTaskFamily<P: Hashable, T>(
  fileID: String = #fileID,
  line: UInt = #line,
  id: String = "",
  _ initialNode: @escaping (P, RecoilGlobalContext) async throws -> T
) -> AtomFamily<P, MThrowingTaskAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let body = curryFnThrowingTaskRecoilFamily(initialNode)
  @RecoilGlobalViewContext
  var _context
  let atomFamily: AtomFamily<P, MThrowingTaskAtom<T>> = { (param: P) -> RecoilParamNode<P, MThrowingTaskAtom<T>> in
    let _body = body(param)
    let node = MThrowingTaskAtom<T>(id: id) { context in
      try await _body(_context)
    }
    _context.reset(node)
    return RecoilParamNode(param: param, node: node)
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
  _ initialNode: @escaping (P, AtomTransactionContext<Void>) -> T
) -> AtomFamily<P, MPublisherAtom<T>> {
  let id = sourceId(id: id, fileID: fileID, line: line)
  let body = curryFnRecoilFamily(initialNode)
  @RecoilGlobalViewContext
  var _context
  return { (param: P) -> RecoilParamNode<P, MPublisherAtom<T>> in
    let _body = body(param)
    let node = MPublisherAtom<T>(id: id) { context in
      return _body(context)
    }
//    _context.reset(node)
    return RecoilParamNode(param: param, node: node)
  }
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
