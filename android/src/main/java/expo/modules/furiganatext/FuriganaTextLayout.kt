package expo.modules.furiganatext

import android.graphics.Paint
import android.text.SpannableStringBuilder
import android.text.StaticLayout
import android.text.TextPaint
import android.text.style.LineHeightSpan
import android.text.style.ReplacementSpan

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

    val furiganaHeight = furiganaPaint.fontMetricsInt.descent - furiganaPaint.fontMetricsInt.ascent
    spannable.setSpan(
      UniformLineHeightSpan(textPaint, furiganaHeight),
      0,
      spannable.length,
      SpannableStringBuilder.SPAN_EXCLUSIVE_EXCLUSIVE
    )

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

  /**
   * Sets every line's ascent/top to include the furigana height, so all lines
   * have the same total height. The RubySpan no longer modifies font metrics,
   * so this span is the sole source of line height.
   */
  class UniformLineHeightSpan(
    private val textPaint: TextPaint,
    private val furiganaHeight: Int
  ) : LineHeightSpan {

    override fun chooseHeight(
      text: CharSequence,
      start: Int,
      end: Int,
      spanstartv: Int,
      lineHeight: Int,
      fm: Paint.FontMetricsInt
    ) {
      // Only adjust the first line (spanstartv == 0) and subsequent lines.
      // For the first line, also extend top upward.
      val baseFm = textPaint.fontMetricsInt
      fm.ascent = baseFm.ascent - furiganaHeight
      fm.top = baseFm.top - furiganaHeight
    }
  }
}