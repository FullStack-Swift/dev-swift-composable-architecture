import Foundation

// MARK: useSelectorRecoil
@MainActor func useSelectorRecoil<Node: StateAtom>(
  _ initialState: Node,
  context: GlobalViewContext
) {
  fatalError()
}

private struct SelectorRecoilHook<Node: Atom>: Hook {

  var updateStrategy: HookUpdateStrategy?

}
