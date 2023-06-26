import SwiftUI

/// https://recoiljs.org/

public struct RecoilRoot<Content: View>: View {

  private let content: (AtomRecoilContext) -> Content

  @RecoilViewContext
  private var context

  public init(@ViewBuilder _ content: @escaping (AtomRecoilContext) -> Content) {
    self.content = content
  }

  public var body: some View {
    HookScope {
      content(context)
    }
  }
}

public struct RecoilScope<Content: View>: View {

  private let content: (AtomRecoilContext) -> Content

  @RecoilViewContext
  var context

  public init(@ViewBuilder _ content: @escaping (AtomRecoilContext) -> Content) {
    self.content = content
  }

  public var body: some View {
    HookScope {
      content(context)
    }
  }
}

@propertyWrapper
@MainActor struct RecoilViewContext {

  @Dependency(\.storeContext)
  private var _store

  private let location: SourceLocation

  public init(fileID: String = #fileID, line: UInt = #line) {
    location = SourceLocation(fileID: fileID, line: line)
  }

  public var wrappedValue: AtomRecoilContext {
    AtomRecoilContext(fileID: location.fileID, line: location.line)
  }
}

@propertyWrapper
struct RecoilWatch<Node: Atom> {
  private let atom: Node

  @RecoilViewContext
  private var context

  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilViewContext(fileID: fileID, line: line)
  }

  public var wrappedValue: Node.Loader.Value {
    context.watch(atom)
  }
}


@propertyWrapper
struct RecoilWatchState<Node: StateAtom> {
  private let atom: Node

  @RecoilViewContext
  private var context

  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilViewContext(fileID: fileID, line: line)
  }

  public var wrappedValue: Node.Loader.Value {
    get { context.watch(atom) }
    nonmutating set { context.set(newValue, for: atom) }
  }

  public var projectedValue: Binding<Node.Loader.Value> {
    context.state(atom)
  }
}

@propertyWrapper
struct RecoilWatchStateObject<Node: ObservableObjectAtom> {

  @dynamicMemberLookup
  public struct Wrapper {
    private let object: Node.Loader.Value

    public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Node.Loader.Value, T>) -> Binding<T> {
      Binding(
        get: { object[keyPath: keyPath] },
        set: { object[keyPath: keyPath] = $0 }
      )
    }

    fileprivate init(_ object: Node.Loader.Value) {
      self.object = object
    }
  }

  private let atom: Node

  @RecoilViewContext
  private var context

  public init(_ atom: Node, fileID: String = #fileID, line: UInt = #line) {
    self.atom = atom
    self._context = RecoilViewContext(fileID: fileID, line: line)
  }

  public var wrappedValue: Node.Loader.Value {
    context.watch(atom)
  }

  public var projectedValue: Wrapper {
    Wrapper(wrappedValue)
  }
}
