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
    var traits: UIFontDescriptor.SymbolicTraits = []
    if fontWeight?.lowercased() == "bold" || fontWeight == "700" || fontWeight == "800" || fontWeight == "900" {
      traits.insert(.traitBold)
    }
    if fontStyleValue?.lowercased() == "italic" {
      traits.insert(.traitItalic)
    }

    let baseDescriptor = UIFontDescriptor(fontAttributes: [
      .name: fontFamily as Any
    ])
    if let combined = baseDescriptor.withSymbolicTraits(traits) {
      return UIFont(descriptor: combined, size: size)
    }
    return UIFont.systemFont(ofSize: size)
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