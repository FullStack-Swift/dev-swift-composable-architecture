import Foundation

// MARK: Storage cache data
extension Storage {

  struct TodoStorageKey: StorageKey {
    public typealias Value = IdentifiedArrayOf<TodoModel>
  }

  var todoModels: IdentifiedArrayOf<TodoModel> {
    get {
      self[TodoStorageKey.self, default: .init()]
    }
    set {
      self[TodoStorageKey.self] = newValue
    }
  }

  struct CountStorageKey: StorageKey {
    public typealias Value = Int
  }

  var count: Int {
    get {
      self[CountStorageKey.self, default: 0]
    }
    set {
      self[CountStorageKey.self] = newValue
    }
  }
}

extension SharedStateReducer.State {

  struct CountStorageKey: SharedStorageKey {
    public typealias Value = Int
  }

  var count: Int {
    get {
      self[CountStorageKey.self] ?? 0
    }
    set {
      self[CountStorageKey.self] = newValue
    }
  }
}
