# HookLoadMore

The hook function to load more items with Array or IdentifiedArrayOf.

## Overview


### The example for using load more items with Array

```swift

     let loadmore: LoadMoreIdentifiedArray<Todo> = useLoadMoreIdentifiedArray(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        let request = MRequest {
          RUrl("http://127.0.0.1:8080")
            .withPath("todos")
            .withPath("paginate")
          RQueryItems(["page": page, "per": 5])
          RMethod(.get)
        }
          .printCURLRequest()
        let data = try await request.data
        log.json(data)
        let pageModel = data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
        let pagedResponse: PagedIdentifiedArray<Todo> = PagedIdentifiedArray(page: page, totalPages: pageModel.metadata.totalPages, results: pageModel.items.toIdentifiedArray())
        return pagedResponse
      }
```
### The example for using load more items with IdentifiedArrayOf.

```swift

      let loadmore: LoadMoreIdentifiedArray<Todo> = useLoadMoreIdentifiedArray(firstPage: 1) { page in
        try await Task.sleep(seconds: 1)
        let request = MRequest {
          RUrl("http://127.0.0.1:8080")
            .withPath("todos")
            .withPath("paginate")
          RQueryItems(["page": page, "per": 5])
          RMethod(.get)
        }
          .printCURLRequest()
        let data = try await request.data
        log.json(data)
        let pageModel = data.toModel(Page<Todo>.self) ?? Page(items: [], metadata: .init(page: 0, per: 0, total: 0))
        let pagedResponse: PagedIdentifiedArray<Todo> = PagedIdentifiedArray(page: page, totalPages: pageModel.metadata.totalPages, results: pageModel.items.toIdentifiedArray())
        return pagedResponse
      }
```
