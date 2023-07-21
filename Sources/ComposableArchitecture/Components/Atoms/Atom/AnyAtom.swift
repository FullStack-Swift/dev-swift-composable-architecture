import Foundation

public struct AnyAtom<Node: Atom>: Atom {
  
  public typealias Loader = Node.Loader
  
  public typealias Coordinator = Node.Coordinator

  public typealias ID = Node.ID

  public var atom: Node
  
  public init(atom: Node) {
    self.atom = atom
  }

  /// A unique value used to identify the atom internally.
  public var key: Key {
    Key(atomKey: atom.key)
  }

  public var id: ID {
    atom.id
  }
  
  public func makeCoordinator() -> Node.Coordinator {
    atom.makeCoordinator()
  }

  /// A loader that represents an actual implementation of this atom.
  @MainActor
  public var _loader: Loader {
    atom._loader
  }
}

extension AnyAtom {
  /// A type representing the stable identity of this atom.
  public struct Key: Hashable {
    private let atomKey: Node.Key
    
    fileprivate init(
      atomKey: Node.Key
    ) {
      self.atomKey = atomKey
    }
  }
}

extension Atom {
  public func eraseToAnyAtom() -> AnyAtom<Self> {
    AnyAtom(atom: self)
  }
}
