import Foundation

open class AnyLocationBase {}

open class AnyLocation<Value>: AnyLocationBase {
  
  private let _value = UnsafeMutablePointer<Value>.allocate(capacity: 1)
  
  public init(value: Value) {
    self._value.pointee = value
  }
  
  open var value: Value {
    get {
      _value.pointee
    }
    set {
      _value.pointee = newValue
    }
  }
}
