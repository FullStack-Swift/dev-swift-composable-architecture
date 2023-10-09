import Foundation

internal func assertMainThread(file: StaticString = #file, line: UInt = #line) {
#if DEBUG
  assert(Thread.isMainThread, "This API must be called only on the main thread.", file: file, line: line)
#endif
}

internal func fatalErrorHooksRules(file: StaticString = #file, line: UInt = #line) -> Never {
#if DEBUG
  fatalError(
        """
        Hooks must be called at the function top level within scope of the HookScope or the HookView.hookBody`.
        
        - SeeAlso: https://reactjs.org/docs/hooks-rules.html
        """,
        file: file,
        line: line
  )
#endif
}

internal func debugAssertionFailure(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) {
#if DEBUG
  assertionFailure(
    message()
  )
#endif
}
