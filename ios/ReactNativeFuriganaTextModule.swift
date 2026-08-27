import ExpoModulesCore
import CoreText
import UIKit

extension UIColor {
  convenience init?(hex: String) {
    var hexString = hex
    if hexString.hasPrefix("#") {
      hexString.removeFirst()
    }
    var rgba: UInt64 = 0
    Scanner(string: hexString).scanHexInt64(&rgba)
    let r, g, b, a: CGFloat
    switch hexString.count {
    case 8:
      r = CGFloat((rgba >> 24) & 0xFF) / 255.0
      g = CGFloat((rgba >> 16) & 0xFF) / 255.0
      b = CGFloat((rgba >> 8) & 0xFF) / 255.0
      a = CGFloat(rgba & 0xFF) / 255.0
    case 6:
      r = CGFloat((rgba >> 16) & 0xFF) / 255.0
      g = CGFloat((rgba >> 8) & 0xFF) / 255.0
      b = CGFloat(rgba & 0xFF) / 255.0
      a = 1.0
    default:
      return nil
    }
    self.init(red: r, green: g, blue: b, alpha: a)
  }
}

public class ReactNativeFuriganaText: Module {
  public func definition() -> ModuleDefinition {
    Name("ReactNativeFuriganaText")

    View(ReactNativeFuriganaTextView.self) {
      Prop("text") { (view: ReactNativeFuriganaTextView, text: String) in
        view.text = text
      }

      Prop("furigana") { (view: ReactNativeFuriganaTextView, furigana: [String: String]) in
        view.furigana = furigana
      }

      Prop("fontSize") { (view: ReactNativeFuriganaTextView, fontSize: Double) in
        view.fontSize = CGFloat(fontSize)
      }

      Prop("color") { (view: ReactNativeFuriganaTextView, color: String) in
        view.textColor = UIColor(hex: color) ?? .black
      }

      Prop("furiganaFontSize") { (view: ReactNativeFuriganaTextView, fontSize: Double) in
        view.furiganaFontSize = CGFloat(fontSize)
      }

      Prop("furiganaColor") { (view: ReactNativeFuriganaTextView, color: String) in
        view.furiganaColor = UIColor(hex: color) ?? .gray
      }

      Prop("fontFamily") { (view: ReactNativeFuriganaTextView, fontFamily: String) in
        view.fontFamily = fontFamily
      }

      Prop("fontWeight") { (view: ReactNativeFuriganaTextView, fontWeight: String) in
        view.fontWeight = fontWeight
      }

      Prop("fontStyleValue") { (view: ReactNativeFuriganaTextView, fontStyle: String) in
        view.fontStyleValue = fontStyle
      }
    }
  }
}