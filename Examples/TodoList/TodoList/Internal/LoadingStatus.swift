import Foundation

enum LoadingStatus: Equatable {
  case loadFirst
  case loadMore
  case loading
  case result(TaskResult<Data>)
}
