precedencegroup MonoidAppend {
  associativity: left
  higherThan: MultiplicationPrecedence
  lowerThan: BitwiseShiftPrecedence
}

infix operator <>: MonoidAppend
