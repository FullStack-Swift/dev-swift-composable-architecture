# LoadMoreObservableAtom

LoadMore with ObservableObject, It's object for load more data items in a view in SwiftUI.


What you can do with class:
- 1: - LoadFirst function when view visible.
- 2: - LoadMore function when you want load more data items.
- 3: - refreshing UI when you pull refresh in a view.


This i common object for load more items, you can using it like normal of Observable or with the ObservableOjectAtom to cache data item in global state.
## Overview

 This is overview of LoadMore.

### How to using ``LoadMoreObsevableAtom``.

### using as an ObservableObject.

```swift
let loadMore = LoadMoreObservableAtom() {
  /// to do
}
```

### using as an Atom.
```swift
fileprivate let loadMoreAtom = MObservableObjectAtom(id: sourceId()) { context in
  LoadMoreObservableAtom<Todo>(firstPage: 1) { page in
    try? await Task.sleep(seconds: 1)
    var todos = IdentifiedArrayOf<Todo>.mock.toArray()
    if testNoContent {
      todos = []
      testNoContent.toggle()
    }
//    var todos = IdentifiedArrayOf<Todo>().toArray()
    return PagedResponse(page: page, totalPages: 10, results: todos)
  }
}
```
