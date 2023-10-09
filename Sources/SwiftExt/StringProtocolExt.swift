import Foundation

extension StringProtocol {
  
  public var firstUppercased: String {
    uppercased(1)
  }
  
  public func uppercased(_ maxLength: Int = 1) -> String {
    prefix(maxLength).uppercased() + dropFirst()
  }
  
  public var capitalizedSentence: String {
    // 1
    let firstLetter = self.prefix(1).capitalized
    // 2
    let remainingLetters = self.dropFirst().lowercased()
    // 3
    return firstLetter + remainingLetters
  }
}
