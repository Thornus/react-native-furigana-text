package expo.modules.furiganatext

import android.graphics.Color
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

private fun parseColorString(color: String): Int {
  return try {
    Color.parseColor(color)
  } catch (e: IllegalArgumentException) {
    val hex = if (color.startsWith("#")) color.substring(1) else color
    when (hex.length) {
      3 -> {
        val r = hex[0].toString().repeat(2)
        val g = hex[1].toString().repeat(2)
        val b = hex[2].toString().repeat(2)
        Color.parseColor("#$r$g$b")
      }
      4 -> {
        val r = hex[0].toString().repeat(2)
        val g = hex[1].toString().repeat(2)
        val b = hex[2].toString().repeat(2)
        val a = hex[3].toString().repeat(2)
        Color.parseColor("#$a$r$g$b")
      }
      else -> Color.BLACK
    }
  }
}

class ReactNativeFuriganaTextModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("ReactNativeFuriganaText")

    Function("measureHeight") { text: String, furigana: Map<String, String>, width: Double, fontSize: Double, furiganaFontSize: Double ->
      val density = appContext.reactContext?.resources?.displayMetrics?.density ?: 1f
      val (textPaint, furiganaPaint) =
        FuriganaTextLayout.paints(fontSize.toFloat(), furiganaFontSize.toFloat(), density)
      val layout = FuriganaTextLayout.build(
        text, furigana, textPaint, furiganaPaint,
        (width * density).toInt()
      )
      layout.height / density.toDouble()
    }

    View(ReactNativeFuriganaTextView::class) {
      Prop("text") { view: ReactNativeFuriganaTextView, text: String ->
        view.setText(text)
      }

      Prop("furigana") { view: ReactNativeFuriganaTextView, furigana: Map<String, String> ->
        view.setFurigana(furigana)
      }

      Prop("fontSize") { view: ReactNativeFuriganaTextView, fontSize: Double ->
        view.setTextSize(fontSize.toFloat())
      }

      Prop("color") { view: ReactNativeFuriganaTextView, color: String ->
        view.setTextColor(parseColorString(color))
      }

      Prop("furiganaFontSize") { view: ReactNativeFuriganaTextView, fontSize: Double ->
        view.setFuriganaTextSize(fontSize.toFloat())
      }

      Prop("furiganaColor") { view: ReactNativeFuriganaTextView, color: String ->
        view.setFuriganaTextColor(parseColorString(color))
      }

      Prop("fontFamily") { view: ReactNativeFuriganaTextView, fontFamily: String? ->
        view.setFontFamily(fontFamily)
      }

      Prop("fontWeight") { view: ReactNativeFuriganaTextView, fontWeight: String? ->
        view.setFontWeight(fontWeight)
      }

      Prop("fontStyleValue") { view: ReactNativeFuriganaTextView, fontStyle: String? ->
        view.setFontStyleValue(fontStyle)
      }
    }
  }
}