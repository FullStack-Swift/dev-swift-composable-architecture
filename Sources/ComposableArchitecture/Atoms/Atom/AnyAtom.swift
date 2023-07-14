import Foundation


//public struct AnyAtom<Node: Atom>: Atom {
//  public typealias Loader = Node.Loader
//
//  public typealias ID = UUID
//
//  /// A type representing the stable identity of this atom.
//  public struct Key: Hashable {
//    private let atomKey: Node.Key
//
//    fileprivate init(
//      atomKey: Node.Key
//    ) {
//      self.atomKey = atomKey
//    }
//  }
//
//  public var atom: Node
//
//  /// A unique value used to identify the atom internally.
//  public var key: Key {
//    Key(atomKey: atom.key)
//  }
//
//  public var id: UUID {
//    UUID()
//  }
//
//  /// A loader that represents an actual implementation of this atom.
//  @MainActor
//  public var _loader: Loader {
//    atom._loader
//  }
//}
