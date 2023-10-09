import SwiftUI

extension EnvironmentValues {
#if DEBUG
  @EnvironmentValue
  var hooksRulesAssertionDisabled: Bool = false
#else
  var hooksRulesAssertionDisabled: Bool = false
#endif
}
