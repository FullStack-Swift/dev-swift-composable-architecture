import SwiftUI
import Combine

public typealias MCallBack = () -> Void

public typealias MCompletion<T> = (T) -> Void

// MARK: Function Builder SwiftUI

/// Description: A custom parameter attribute that constructs views from closures.
/// - Parameter _: _ view content
/// - Returns: You typically use ViewBuilder as a parameter attribute for child view-producing closure parameters, allowing those closures to provide multiple child views. For example, the following contextMenu function accepts a closure that produces one or more views via the view builder.

public func viewBuilder<Content: View>( @ViewBuilder _ builder: () -> Content) -> some View {
  builder()
    .eraseToAnyView()
}

public protocol MView: View {
  
  @ViewBuilder var anyBody: any View { get }
}

extension MView where Body: View {
  public var body: some View {
    AnyView(anyBody)
  }
}

// MARK: View Changed view
extension View {
  
  /// AnyView allows changing the type of view used in a given view hierarchy. Whenever the type of view used with AnyView changes, SwiftUI destroys old hierarchy and creates a new hierarchy the new type.
  /// - Returns: AnyView
  public func eraseToAnyView() -> AnyView {
    AnyView(self)
  }
  
  /// Description
  /// - Parameter mutation: mutation your view
  /// - Returns: Self
  public func with(_ mutation: (inout Self) -> Void) -> Self {
    var view = self
    mutation(&view)
    return view
  }
}

// MARK: Condition View function.
extension View {
  /// Applies the given transform if the given condition evaluates to `true`.
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
  @ViewBuilder
  public func `if`<Transform: View>(
    _ condition: Bool,
    @ViewBuilder transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
        .eraseToAnyView()
    } else {
      self
        .eraseToAnyView()
    }
  }
  
  
  /// Applies the given transform `transform` or `else`.
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  ///   - else: The transform that applies if `condition` is false
  /// - Returns: Either the original `View` or the modified `View` based on the condition`.
  @ViewBuilder
  public func `if`<Content: View>(
    _ condition: Bool,
    transform: (Self) -> Content,
    @ViewBuilder else: (Self) -> Content
  ) -> some View {
    if condition {
      transform(self)
        .eraseToAnyView()
    } else {
      `else`(self)
        .eraseToAnyView()
    }
  }
  
  /// Unwraps the given `value` and applies the given `transform`.
  /// - Parameters:
  ///   - value: The value to unwrap.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original `View` or the modified `View` with unwrapped `value` if the `value` is not nil`.
  @ViewBuilder
  public func ifLet<Value, Content: View>(
    _ value: Value?,
    @ViewBuilder transform: (Value, Self) -> Content
  ) -> some View {
    if let value = value {
      transform(value, self)
        .eraseToAnyView()
    } else {
      self
        .eraseToAnyView()
    }
  }
  
  /// Unwraps the given `value` and applies the given `transform`.
  /// - Parameters:
  ///   - value: The value to unwrap.
  ///   - transform: The transform to apply to the source `View`.
  ///   - else:The transform that applies if `value` is nil
  /// - Returns: Either the `else` transform or the modified `View` with unwrapped `value` if the `value` is not nil`.
  @ViewBuilder
  public func ifLet<Value, Content: View>(
    _ value: Value?,
    @ViewBuilder transform: (Value, Self) -> Content,
    @ViewBuilder else: (Self) -> Content
  ) -> some View {
    if let value = value {
      transform(value, self)
        .eraseToAnyView()
    } else {
      `else`(self)
        .eraseToAnyView()
    }
  }
}

// MARK: extractView
extension View {
  /// Applies given transform to the view.
  /// - Parameters:
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Original `View`.
  @ViewBuilder
  public func extractView<Content: View>(transform: (Self) -> Content) -> some View {
    transform(self)
  }
}

// MARK: View onTap
extension View {
  
  /// Adds an action to perform when this view recognizes a tap gesture.
  ///
  /// Use this method to perform the specified `action` when the user clicks
  /// or taps on the view or container `count` times.
  ///
  /// > Note: If you create a control that's functionally equivalent
  /// to a ``Button``, use ``ButtonStyle`` to create a customized button
  /// instead.
  ///
  /// In the example below, the color of the heart images changes to a random
  /// color from the `colors` array whenever the user clicks or taps on the
  /// view twice:
  ///
  ///     struct TapGestureExample: View {
  ///         let colors: [Color] = [.gray, .red, .orange, .yellow,
  ///                                .green, .blue, .purple, .pink]
  ///         @State private var fgColor: Color = .gray
  ///
  ///         var body: some View {
  ///             Image(systemName: "heart.fill")
  ///                 .resizable()
  ///                 .frame(width: 200, height: 200)
  ///                 .foregroundColor(fgColor)
  ///                 .onTap(count: 2) {
  ///                     fgColor = colors.randomElement()!
  ///                 }
  ///         }
  ///     }
  ///
  /// ![A screenshot of a view of a heart.](SwiftUI-View-TapGesture.png)
  ///
  /// - Parameters:
  ///    - count: The number of taps or clicks required to trigger the action
  ///      closure provided in `action`. Defaults to `1`.
  ///    - action: The action to perform.
  public func onTap(count: Int = 1, perform: @escaping MCallBack) -> some View {
    contentShape(Rectangle())
      .onTapGesture(count: count, perform: perform)
  }
}

// MARK: View - Hidden
extension View {
  /// Hide or show the view based on a boolean value.
  ///
  /// - Parameters:
  ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
  @ViewBuilder
  public func isHidden(_ isHidden: Bool) -> some View {
    if isHidden {
      hidden()
    } else {
      self
    }
  }
  /// Hide or show the view based on a boolean value.
  ///
  /// - Parameters:
  ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
  ///   - remove: Boolean value indicating whether or not to remove the view.
  @ViewBuilder
  public func hidden(_ hidden: Bool, remove: Bool = false) -> some View {
    if hidden {
      if !remove {
        self.hidden()
      }
    } else {
      self
    }
  }

  @ViewBuilder
  public func hideListRowSeperator() -> some View {
#if os(iOS)
    if #available(iOS 15, *) {
      listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(.zero))
    } else {
      frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .listRowInsets(EdgeInsets(top: -1, leading: -1, bottom: -1, trailing: -1))
    }
#endif
    
#if os(macOS)
    if #available(macOS 13, *) {
      listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    } else {
      frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets())
        .listRowInsets(EdgeInsets(top: -1, leading: -1, bottom: -1, trailing: -1))
    }
#endif
  }
}

// MARK: - View Frame
extension View {
  /// Positions this view within an invisible frame with the specified size.
  public func frame(size: CGSize, alignment: Alignment = .center) -> some View {
    frame(width: size.width, height: size.height, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame with the specified size.
  public func frame(length: CGFloat, alignment: Alignment = .center) -> some View {
    frame(width: length, height: length, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame having the specified size
  /// constraints.
  public func frame(min: CGFloat, alignment: Alignment = .center) -> some View {
    frame(minWidth: min, minHeight: min, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame having the specified size
  /// constraints.
  public func frame(max: CGFloat, alignment: Alignment = .center) -> some View {
    frame(maxWidth: max, maxHeight: max, alignment: alignment)
  }
}

// MARK: Color Extension
public extension Color {
  static var divider: Color {
    white.opacity(0.5)
  }
  
  static var almostClear: Color {
    Color.black.opacity(0.0001)
  }
  
  static var random: Color {
    Color(
      .sRGBLinear,
      red: .random(in: 0.0...1),
      green: .random(in: 0.0...1),
      blue: .random(in: 0.0...1),
      opacity: 1.0
    )
  }
}

public extension Color {
  /// Creates a `Color` using RGB values.
  init(rgbRed: UInt8, rgbGreen: UInt8, rgbBlue: UInt8) {
    self.init(red: Double(rgbRed) / 255, green: Double(rgbGreen) / 255, blue: Double(rgbBlue) / 255)
  }
}

public extension Color {
  func toHexString() -> String {
    let colorString = "\(self)"
    if let colorHex = colorString.isHex() {
      return colorHex.cleanedHex
    } else {
      var colorArray: [String] = colorString.components(separatedBy: " ")
      if colorArray.count < 3 { colorArray = colorString.components(separatedBy: ", ") }
      if colorArray.count < 3 { colorArray = colorString.components(separatedBy: ",") }
      if colorArray.count < 3 { colorArray = colorString.components(separatedBy: " - ") }
      if colorArray.count < 3 { colorArray = colorString.components(separatedBy: "-") }
      
      colorArray = colorArray.filter { colorElement in
        return (!colorElement.isEmpty) &&
        (String(colorElement)
          .replacingOccurrences(of: ".", with: "")
          .rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil)
      }
      
      if (colorArray.count == 3) || (colorArray.count == 4) { //count == 4 if alpha is set
        var r: CGFloat = CGFloat((Float(colorArray[0]) ?? 1))
        var g: CGFloat = CGFloat((Float(colorArray[1]) ?? 1))
        var b: CGFloat = CGFloat((Float(colorArray[2]) ?? 1))
        
        if (r < 0.0) {r = 0.0}
        if (g < 0.0) {g = 0.0}
        if (b < 0.0) {b = 0.0}
        
        if (r > 1.0) {r = 1.0}
        if (g > 1.0) {g = 1.0}
        if (b > 1.0) {b = 1.0}
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06X", rgb).cleanedHex
      } else {
        return ""
      }
    }
  }
  
}

public extension Color {
  init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
      case 3: // RGB (12-bit)
        (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
      case 6: // RGB (24-bit)
        (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
      case 8: // ARGB (32-bit)
        (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
      default:
        (a, r, g, b) = (1, 1, 1, 0)
    }
    self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
  }
}

fileprivate extension String {
  func isHex() -> Bool {
    if (((self.cleanedHex.count == 6) || (self.cleanedHex.count == 8)) && (self.replacingOccurrences(of: "#", with: "").isAlphanumeric())) {
      return true
    } else {
      return false
    }
  }
  
  func isHex() -> String? {
    if self.isHex() {
      return self.cleanedHex
    } else {
      return nil
    }
  }
  
  func isAlphanumeric() -> Bool {
    return ((!self.isEmpty) && (self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil))
  }
  
  var cleanedHex: String {
    return self.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: CharacterSet.alphanumerics.inverted).cleanedString.uppercased()
  }
  var cleanedString: String {
    var cleanedString = self
    
    cleanedString = cleanedString.replacingOccurrences(of: "á", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "ä", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "â", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "à", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "æ", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "ã", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "å", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "ā", with: "a")
    cleanedString = cleanedString.replacingOccurrences(of: "ç", with: "c")
    cleanedString = cleanedString.replacingOccurrences(of: "é", with: "e")
    cleanedString = cleanedString.replacingOccurrences(of: "ë", with: "e")
    cleanedString = cleanedString.replacingOccurrences(of: "ê", with: "e")
    cleanedString = cleanedString.replacingOccurrences(of: "è", with: "e")
    cleanedString = cleanedString.replacingOccurrences(of: "ę", with: "e")
    cleanedString = cleanedString.replacingOccurrences(of: "ė", with: "e")
    cleanedString = cleanedString.replacingOccurrences(of: "ē", with: "e")
    cleanedString = cleanedString.replacingOccurrences(of: "í", with: "i")
    cleanedString = cleanedString.replacingOccurrences(of: "ï", with: "i")
    cleanedString = cleanedString.replacingOccurrences(of: "ì", with: "i")
    cleanedString = cleanedString.replacingOccurrences(of: "î", with: "i")
    cleanedString = cleanedString.replacingOccurrences(of: "į", with: "i")
    cleanedString = cleanedString.replacingOccurrences(of: "ī", with: "i")
    cleanedString = cleanedString.replacingOccurrences(of: "j́", with: "j")
    cleanedString = cleanedString.replacingOccurrences(of: "ñ", with: "n")
    cleanedString = cleanedString.replacingOccurrences(of: "ń", with: "n")
    cleanedString = cleanedString.replacingOccurrences(of: "ó", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "ö", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "ô", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "ò", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "õ", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "œ", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "ø", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "ō", with: "o")
    cleanedString = cleanedString.replacingOccurrences(of: "ú", with: "u")
    cleanedString = cleanedString.replacingOccurrences(of: "ü", with: "u")
    cleanedString = cleanedString.replacingOccurrences(of: "û", with: "u")
    cleanedString = cleanedString.replacingOccurrences(of: "ù", with: "u")
    cleanedString = cleanedString.replacingOccurrences(of: "ū", with: "u")
    
    return cleanedString
  }
}
#if os(iOS) || os(tvOS)
import UIKit
public typealias AppKitOrUIKitColor = UIColor
#endif
#if os(watchOS)
import UIKit
public typealias AppKitOrUIKitColor = UIColor
#endif

#if os(macOS)
import AppKit
public typealias AppKitOrUIKitColor = NSColor
#endif

extension Color {
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
  public static var lightGray: Color {
    Color(.lightGray)
  }
  
  public static var darkGray: Color {
    Color(.darkGray)
  }
  
  public static var magenta: Color {
    Color(.magenta)
  }
#endif
  
  /// A color for placeholder text in controls or text fields or text views.
  public static var placeholderText: Color {
#if os(iOS) || os(macOS) || os(tvOS)
    Color(.placeholderText)
#else
    return .gray // FIXME
#endif
  }
}

#if os(iOS) || os(macOS) || os(tvOS)
extension Color {
  public static var systemRed: Color {
    Color(.systemRed)
  }
  
  public static var systemGreen: Color {
    Color(.systemGreen)
  }
  
  public static var systemBlue: Color {
    Color(.systemBlue)
  }
  
  public static var systemOrange: Color {
    Color(.systemOrange)
  }
  
  public static var systemYellow: Color {
    Color(.systemYellow)
  }
  
  public static var systemPink: Color {
    Color(.systemPink)
  }
  
  public static var systemPurple: Color {
    Color(.systemPurple)
  }
  
  public static var systemTeal: Color {
    Color(.systemTeal)
  }
  
  public static var systemIndigo: Color {
    Color(.systemIndigo)
  }
  
  public static var systemBrown: Color {
    Color(.systemBrown)
  }
  
  @available(iOS 15.0, tvOS 15.0, *)
  public static var systemMint: Color {
    Color(.systemMint)
  }
  
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
  public static var systemCyan: Color {
    Color(.systemCyan)
  }
  
  public static var systemGray: Color {
    Color(.systemGray)
  }
}
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
extension Color {
  @_disfavoredOverload
  public static var brown: Color {
    Color(.brown)
  }
  
  @_disfavoredOverload
  public static var indigo: Color {
    Color(.systemIndigo)
  }
  
  @_disfavoredOverload
  public static var teal: Color {
    Color(.systemTeal)
  }
}

extension Color {
  public static let systemGray2: Color = Color(.systemGray2)
  public static let systemGray3: Color = Color(.systemGray3)
  public static let systemGray4: Color = Color(.systemGray4)
  public static let systemGray5: Color = Color(.systemGray5)
  public static let systemGray6: Color = Color(.systemGray6)
}
#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension Color {
  /// The color for text labels that contain primary content.
  public static var label: Color {
#if os(macOS)
    Color(.labelColor)
#else
    Color(.label)
#endif
  }
  
  /// The color for text labels that contain secondary content.
  public static var secondaryLabel: Color {
#if os(macOS)
    Color(.secondaryLabelColor)
#else
    Color(.secondaryLabel)
#endif
  }
  
  /// The color for text labels that contain tertiary content.
  public static var tertiaryLabel: Color {
#if os(macOS)
    Color(.tertiaryLabelColor)
#else
    Color(.tertiaryLabel)
#endif
  }
  
  /// The color for text labels that contain quaternary content.
  public static var quaternaryLabel: Color {
#if os(macOS)
    Color(.quaternaryLabelColor)
#else
    Color(.quaternaryLabel)
#endif
  }
}
#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
extension Color {
  /// A foreground color for standard system links.
  public static var link: Color {
    Color(.link)
  }
  
  /// A forground color for separators (thin border or divider lines).
  public static var separator: Color {
    Color(.separator)
  }
  
  /// A forground color intended to look similar to `Color.separated`, but is guaranteed to be opaque, so it will.
  public static var opaqueSeparator: Color {
    Color(.opaqueSeparator)
  }
}
#endif

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
extension Color {
  /// The color for the main background of your interface.
  public static var systemBackground: Color {
#if os(macOS)
    return Color(AppKitOrUIKitColor.windowBackgroundColor)
#else
    return Color(.systemBackground)
#endif
  }
  
  /// The color for content layered on top of the main background.
  public static var secondarySystemBackground: Color {
#if os(macOS)
    return Color(AppKitOrUIKitColor.controlBackgroundColor)
#else
    return Color(AppKitOrUIKitColor.secondarySystemBackground)
#endif
  }
  
  /// The color for content layered on top of secondary backgrounds.
  public static var tertiarySystemBackground: Color {
#if os(macOS)
    return Color(AppKitOrUIKitColor.textBackgroundColor)
#else
    return Color(AppKitOrUIKitColor.tertiarySystemBackground)
#endif
  }
}
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
extension Color {
  /// The color for the main background of your grouped interface.
  public static var systemGroupedBackground: Color {
    Color(AppKitOrUIKitColor.systemGroupedBackground)
  }
  
  /// The color for content layered on top of the main background of your grouped interface.
  public static var secondarySystemGroupedBackground: Color {
    Color(AppKitOrUIKitColor.secondarySystemGroupedBackground)
  }
  
  /// The color for content layered on top of secondary backgrounds of your grouped interface.
  public static var tertiarySystemGroupedBackground: Color {
    Color(AppKitOrUIKitColor.tertiarySystemGroupedBackground)
  }
}
#endif

#if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
extension Color {
  /// A color  appropriate for filling thin and small shapes.
  ///
  /// Example: The track of a slider.
  public static var systemFill: Color {
#if os(macOS)
    return Color(AppKitOrUIKitColor.textBackgroundColor)
#else
    return Color(AppKitOrUIKitColor.systemFill)
#endif
  }
  
  /// A color appropriate for filling medium-size shapes.
  ///
  /// Example: The background of a switch.
  public static var secondarySystemFill: Color {
#if os(macOS)
    return Color(AppKitOrUIKitColor.windowBackgroundColor)
#else
    return Color(AppKitOrUIKitColor.secondarySystemFill)
#endif
  }
  
  /// A color appropriate for filling large shapes.
  ///
  /// Examples: Input fields, search bars, buttons.
  public static var tertiarySystemFill: Color {
#if os(macOS)
    return Color(AppKitOrUIKitColor.underPageBackgroundColor)
#else
    return Color(AppKitOrUIKitColor.tertiarySystemFill)
#endif
  }
  
  /// A color appropriate for filling large areas containing complex content.
  ///
  /// Example: Expanded table cells.
  @available(macOS, unavailable)
  public static var quaternarySystemFill: Color {
#if os(macOS)
    return Color(AppKitOrUIKitColor.scrubberTexturedBackground) // FIXME: This crashes for some reason.
#else
    return Color(AppKitOrUIKitColor.quaternarySystemFill)
#endif
  }
}
#endif

extension Color {
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
  /// A color that adapts to the preferred color scheme.
  ///
  /// - Parameters:
  ///   - light: The preferred color for a light color scheme.
  ///   - dark: The preferred color for a dark color scheme.
  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
  public static func adaptable(
    light: @escaping @autoclosure () -> Color,
    dark: @escaping @autoclosure () -> Color
  ) -> Color {
    Color(
      UIColor.adaptable(
        light: UIColor(light()),
        dark: UIColor(dark())
      )
    )
  }
  
  /// Inverts the color.
  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
  public func colorInvert() -> Color {
    Color(
      AppKitOrUIKitColor { _ in
        AppKitOrUIKitColor(self).invertedColor()
      }
    )
  }
#endif
}

extension Color {
  public init(
    cube256 colorSpace: RGBColorSpace,
    red: Int,
    green: Int,
    blue: Int,
    opacity: Double = 1.0
  ) {
    self.init(
      colorSpace,
      red: Double(red) / 255.0,
      green: Double(green) / 255.0,
      blue: Double(blue) / 255.0,
      opacity: opacity
    )
  }
}

extension Color {
  /// Creates a color from a hexadecimal color code.
  ///
  /// - Parameter hexadecimal: A hexadecimal representation of the color.
  ///
  /// - Returns: A `Color` from the given color code. Returns `nil` if the code is invalid.
  public init!(hexadecimal string: String) {
    var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    
    if string.hasPrefix("#") {
      _ = string.removeFirst()
    }
    
    if !string.count.isMultiple(of: 2), let last = string.last {
      string.append(last)
    }
    
    if string.count > 8 {
      string = String(string.prefix(8))
    }
    
    let scanner = Scanner(string: string)
    
    var color: UInt64 = 0
    
    scanner.scanHexInt64(&color)
    
    if string.count == 2 {
      let mask = 0xFF
      
      let g = Int(color) & mask
      
      let gray = Double(g) / 255.0
      
      self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
    } else if string.count == 4 {
      let mask = 0x00FF
      
      let g = Int(color >> 8) & mask
      let a = Int(color) & mask
      
      let gray = Double(g) / 255.0
      let alpha = Double(a) / 255.0
      
      self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
    } else if string.count == 6 {
      let mask = 0x0000FF
      
      let r = Int(color >> 16) & mask
      let g = Int(color >> 8) & mask
      let b = Int(color) & mask
      
      let red = Double(r) / 255.0
      let green = Double(g) / 255.0
      let blue = Double(b) / 255.0
      
      self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    } else if string.count == 8 {
      let mask = 0x000000FF
      
      let r = Int(color >> 24) & mask
      let g = Int(color >> 16) & mask
      let b = Int(color >> 8) & mask
      let a = Int(color) & mask
      
      let red = Double(r) / 255.0
      let green = Double(g) / 255.0
      let blue = Double(b) / 255.0
      let alpha = Double(a) / 255.0
      
      self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    } else {
      return nil
    }
  }
  
  /// Creates a color from a 6-digit hexadecimal color code.
  public init(hexadecimal6: Int) {
    let red = Double((hexadecimal6 & 0xFF0000) >> 16) / 255.0
    let green = Double((hexadecimal6 & 0x00FF00) >> 8) / 255.0
    let blue = Double(hexadecimal6 & 0x0000FF) / 255.0
    
    self.init(red: red, green: green, blue: blue)
  }
}

// MARK: - Auxiliary

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
fileprivate extension UIColor {
  class func adaptable(
    light: @escaping @autoclosure () -> UIColor,
    dark: @escaping @autoclosure () -> UIColor
  ) -> UIColor {
    UIColor { traitCollection in
      switch traitCollection.userInterfaceStyle {
        case .light:
          return light()
        case .dark:
          return dark()
        default:
          return light()
      }
    }
  }
  
  func invertedColor() -> UIColor {
    var alpha: CGFloat = 1.0
    
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
    
    if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
    }
    
    var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
    
    if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
      return UIColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
    }
    
    var white: CGFloat = 0.0
    
    if self.getWhite(&white, alpha: &alpha) {
      return UIColor(white: 1.0 - white, alpha: alpha)
    }
    
    return self
  }
}
#endif

#if os(macOS)
extension Color {
  /// The color to use for the window background.
  public static let windowBackground = Color(NSColor.windowBackgroundColor)
}
#endif

#if os(macOS)

import AppKit
import Swift
import SwiftUI

extension NSColor {
  public static var placeholderText: NSColor {
    return .placeholderTextColor
  }
  
  convenience init?(hexadecimal: String, alpha: CGFloat = 1.0) {
    var hexSanitized = hexadecimal.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexSanitized.hasPrefix("#") {
      hexSanitized.remove(at: hexSanitized.startIndex)
    }
    
    var rgbValue: UInt64 = 0
    
    Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
    
    let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
    let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
    let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
    
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
}

#endif
