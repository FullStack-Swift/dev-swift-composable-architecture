# LoadMoreObservableAtom

LoadMore with ObservableObject, It's object for load more data items in a view in SwiftUI.

What you can do with class:
- 1: - LoadFirst function when view visible.
- 2: - LoadMore function when you want load more data items.
- 3: - refreshing UI when you pull refresh in a view.

This is common object for load more items, you can using it like normal of Observable or with the ObservableOjectAtom to cache data item in global state.

## Overview

 This is overview of LoadMore.

  using LoadMoreOservableAtom when you want cache data in `global state`, otherwise you shold using useLoadmore or using as ObservableOject in `local state`.

### How to using LoadMoreObsevableAtom.

```swift
// make loadmore
let loadmore: LoadMoreObservableAtom = ...

// get status loading
let isLoading = loadmore.isLoading

// get status refreshing
let isRefresh = loadmore.isRefresh

// call func loadFirst
try await loadmore.loadFirst()

// call func loadMore
try await loadmore.loadext()

// call function refresh
try await loadmore.refresh()
```

### using as an ObservableObject.

```swift
@StateObject var loadMore = LoadMoreObservableAtom() {
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
