import SwiftUI

extension EnvironmentValues {
#if DEBUG
  @EnvironmentValue
  var hooksRulesAssertionDisabled: Bool = true
#else
  var hooksRulesAssertionDisabled: Bool = false
#endif
}
