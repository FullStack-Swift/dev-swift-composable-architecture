# ``Documentation``

A SwiftUI implementation of React Hooks. Enhances reusability of stateful logic and gives state and lifecycle to function view.

@Metadata {¡
  @PageImage(
             purpose: icon, 
             source: "slothCreator-icon", 
             alt: "A technology icon representing the SlothCreator framework.")
  @PageColor(green)
}

@Options(scope: global) {
  @AutomaticSeeAlso(enabled)
  @AutomaticTitleHeading(enabled)
  @AutomaticArticleSubheading(enabled)
}

## Overview

- [SwiftUI Hooks](https://github.com/ra1028/swiftui-hooks)

SwiftUI Hooks is a SwiftUI implementation of React Hooks. Brings the state and lifecycle into the function view, without depending on elements that are only allowed to be used in struct views such as @State or @ObservedObject.
It allows you to reuse stateful logic between views by building custom hooks composed with multiple hooks.
Furthermore, hooks such as useEffect also solve the problem of lack of lifecycles in SwiftUI.

The API and behavioral specs of SwiftUI Hooks are entirely based on React Hooks, so you can leverage your knowledge of web applications to your advantage.

There're already a bunch of documentations on React Hooks, so you can refer to it and learn more about Hooks.

- [React Hooks Documentation](https://reactjs.org/docs/hooks-intro.html)  
- [Youtube Video](https://www.youtube.com/watch?v=dpw9EHDh2bM)

### Featured

@Links(visualStyle: detailedGrid) {
  - <doc:Introduction>
  - <doc:GettingStarted>
  - <doc:BuildingYourOwnHooks>
  - <doc:RulesHooks>
}


## Topics

### Essentials

- <doc:TodoHookBasic>
- <doc:TodoHookNetwork>
- <doc:TodoHookAdvance>
