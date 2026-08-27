package expo.modules.furiganatext

import android.graphics.Paint
import android.text.SpannableStringBuilder
import android.text.StaticLayout
import android.text.TextPaint

object FuriganaTextLayout {
  fun build(
    text: String,
    furigana: Map<String, String>,
    textPaint: TextPaint,
    furiganaPaint: TextPaint,
    widthPx: Int
  ): StaticLayout {
    val spannable = SpannableStringBuilder(text)
    for ((kanji, reading) in furigana) {
      var searchStart = 0
      while (searchStart < text.length) {
        val start = text.indexOf(kanji, searchStart)
        if (start == -1) break
        val end = start + kanji.length
        spannable.setSpan(
          ReactNativeFuriganaTextView.RubySpan(kanji, reading, textPaint, furiganaPaint),
          start, end, SpannableStringBuilder.SPAN_EXCLUSIVE_EXCLUSIVE
        )
        searchStart = end
      }
    }
    return StaticLayout.Builder.obtain(spannable, 0, spannable.length, textPaint, widthPx)
      .setIncludePad(false)
      .setLineSpacing(0f, 1f)
      .build()
  }

  fun paints(fontSizeDp: Float, furiganaFontSizeDp: Float, density: Float): Pair<TextPaint, TextPaint> {
    val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply { textSize = fontSizeDp * density }
    val furiganaPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply { textSize = furiganaFontSizeDp * density }
    return textPaint to furiganaPaint
  }
}