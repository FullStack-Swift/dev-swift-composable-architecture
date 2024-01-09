# Building Your OwnHooks

A SwiftUI implementation of React Hooks. Enhances reusability of stateful logic and gives state and lifecycle to function view.

@Metadata {
  @PageImage(purpose: card, source: "gettingStarted-card", alt: "The profile images for a regular sloth and an ice sloth.")
}

## Overview

### Hook PropertyWrapper

<!--@START_MENU_TOKEN@-->Text<!--@END_MENU_TOKEN@-->


``HState``

```swift
@HState var state = 0
```


``HRef``

```swift
@HRef var state = 0
```

``HContext``

```swift
@HContext
var todos = TodoContext.self
```

``HMemo``

```swift

@HState var state = 0

@HMemo(.preserved(by: state))
var randomColor = Color(hue: .random(in: 0...1), saturation: 1, brightness: 1)

```
``HEnvironment``

```swift
@HEnvironment(\.dismiss)
var dismiss
```
