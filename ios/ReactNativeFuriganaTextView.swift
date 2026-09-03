import ExpoModulesCore
import UIKit
import CoreText

class ReactNativeFuriganaTextView: ExpoView {
  var text: String = "" {
    didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
  }

  var furigana: [String: String] = [:] {
    didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
  }

  var fontSize: CGFloat = 16 {
    didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
  }

  var textColor: UIColor = .black {
    didSet { setNeedsDisplay() }
  }

  var furiganaFontSize: CGFloat = 8 {
    didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
  }

  var furiganaColor: UIColor = .gray {
    didSet { setNeedsDisplay() }
  }

  var fontFamily: String? = nil {
    didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
  }

  var fontWeight: String? = nil {
    didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
  }

  var fontStyleValue: String? = nil {
    didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
  }

  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    isOpaque = false
    backgroundColor = .clear
    contentMode = .redraw
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let attributed = createAttributedText()
    let framesetter = CTFramesetterCreateWithAttributedString(attributed)
    let constrainSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
    let fittedSize = CTFramesetterSuggestFrameSizeWithConstraints(
      framesetter,
      CFRange(location: 0, length: attributed.length),
      nil,
      constrainSize,
      nil
    )
    let height = ceil(fittedSize.height)
    if height > 0 && bounds.width > 0 {
      setViewSize(CGSize(width: CGFloat.nan, height: height))
    }
  }

  override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    let attributed = createAttributedText()

    context.textMatrix = .identity
    context.translateBy(x: 0, y: bounds.height)
    context.scaleBy(x: 1.0, y: -1.0)

    let path = CGMutablePath()
    path.addRect(bounds)

    let frameSetter = CTFramesetterCreateWithAttributedString(attributed)
    let frame = CTFramesetterCreateFrame(
      frameSetter, CFRangeMake(0, attributed.length), path, nil)

    CTFrameDraw(frame, context)
  }

  private func resolveFont(size: CGFloat) -> UIFont {
    // Map string weight to UIFont.Weight
    let weight: UIFont.Weight
    switch fontWeight?.lowercased() {
    case "bold", "700":
        weight = .bold
    case "800":
        weight = .heavy
    case "900":
        weight = .black
    case "600":
        weight = .semibold
    case "500":
        weight = .medium
    case "400", "normal", nil:
        weight = .regular
    case "300":
        weight = .light
    case "200":
        weight = .thin
    case "100":
        weight = .ultraLight
    default:
        weight = .regular
    }

    // Build traits dictionary with explicit weight
    var traits: [UIFontDescriptor.TraitKey: Any] = [
        .weight: weight
    ]

    // Add italic if requested
    if fontStyleValue?.lowercased() == "italic" {
        traits[.symbolic] = UIFontDescriptor.SymbolicTraits.traitItalic.rawValue
    }

    // If a font family is specified, use it; otherwise use system font
    if let family = fontFamily, !family.isEmpty {
        let attributes: [UIFontDescriptor.AttributeName: Any] = [
            .family: family,
            .traits: traits
        ]
        let descriptor = UIFontDescriptor(fontAttributes: attributes)
        return UIFont(descriptor: descriptor, size: size)
    } else {
        // Use system font with weight (most reliable path).
        // NOTE: do NOT use withSymbolicTraits(.traitItalic) on a weighted system
        // font here — on iOS 26 that round-trip drops the weight trait and
        // silently yields the regular face (e.g. '.SFUI-RegularItalic').
        // Instead build the descriptor in one shot with both weight + italic.
        let wantsItalic = fontStyleValue?.lowercased() == "italic"

        var attributes: [UIFontDescriptor.AttributeName: Any] = [:]
        if wantsItalic {
            attributes[.family] = UIFont.systemFont(ofSize: size, weight: weight).familyName
            attributes[.traits] = [
                UIFontDescriptor.TraitKey.weight: weight,
                UIFontDescriptor.TraitKey.symbolic: UIFontDescriptor.SymbolicTraits.traitItalic.rawValue
            ]
        }

        if wantsItalic, let descriptor = UIFontDescriptor(fontAttributes: attributes).withDesign(.default) {
            let font = UIFont(descriptor: descriptor, size: size)
            if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                return font
            }
            return UIFont.systemFont(ofSize: size, weight: weight)
        }

        return UIFont.systemFont(ofSize: size, weight: weight)
    }
  }

  private func createAttributedText() -> NSAttributedString {
    let attributed = NSMutableAttributedString(string: text)
    let fullRange = NSRange(location: 0, length: attributed.length)

    let baseFont = resolveFont(size: fontSize)
    let furiganaFont = resolveFont(size: furiganaFontSize)
    attributed.addAttribute(.font, value: baseFont, range: fullRange)
    attributed.addAttribute(.foregroundColor, value: textColor, range: fullRange)

    let sizeFactor = furiganaFontSize / fontSize
    let nsText = text as NSString

    for (kanji, reading) in furigana {
      var searchRange = NSRange(location: 0, length: nsText.length)
      while searchRange.location < nsText.length {
        let foundRange = nsText.range(of: kanji, options: [], range: searchRange)
        if foundRange.location == NSNotFound {
          break
        }

        let rubyAttributes: [CFString: Any] = [
          kCTRubyAnnotationSizeFactorAttributeName: sizeFactor,
          kCTForegroundColorAttributeName: furiganaColor.cgColor,
          kCTFontAttributeName: furiganaFont,
        ]
        let rubyAnnotation = CTRubyAnnotationCreateWithAttributes(
          .auto, .auto, .before, reading as CFString, rubyAttributes as CFDictionary
        )

        attributed.addAttribute(
          kCTRubyAnnotationAttributeName as NSAttributedString.Key,
          value: rubyAnnotation,
          range: foundRange
        )

        searchRange.location = foundRange.location + foundRange.length
        searchRange.length = nsText.length - searchRange.location
      }
    }

    let lineHeight = fontSize + furiganaFontSize + 2
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.minimumLineHeight = lineHeight
    attributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)

    return attributed
  }
}