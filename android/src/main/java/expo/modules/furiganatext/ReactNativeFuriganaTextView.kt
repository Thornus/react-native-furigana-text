package expo.modules.furiganatext

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.text.StaticLayout
import android.text.TextPaint
import android.text.style.ReplacementSpan
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.views.ExpoView

class ReactNativeFuriganaTextView(
  context: Context,
  appContext: AppContext
) : ExpoView(context, appContext) {

  override val shouldUseAndroidLayout: Boolean = true

  init {
    setWillNotDraw(false)
  }

  private val density = resources.displayMetrics.density

  private var text: String = ""
  private var furigana: Map<String, String> = emptyMap()
  private val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
    color = Color.BLACK
    textSize = 16f * density
  }
  private val furiganaPaint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
    color = Color.GRAY
    textSize = 8f * density
  }
  private var cachedLayout: StaticLayout? = null
  private var needsLayoutRebuild = true

  private fun rebuild() {
    needsLayoutRebuild = true
    requestLayout()
    invalidate()
  }

  fun setText(text: String) {
    this.text = text
    rebuild()
  }

  fun setFurigana(furigana: Map<String, String>) {
    this.furigana = furigana
    rebuild()
  }

  fun setTextSize(size: Float) {
    textPaint.textSize = size * density
    rebuild()
  }

  fun setTextColor(color: Int) {
    textPaint.color = color
    invalidate()
  }

  fun setFuriganaTextSize(size: Float) {
    furiganaPaint.textSize = size * density
    rebuild()
  }

  fun setFuriganaTextColor(color: Int) {
    furiganaPaint.color = color
    invalidate()
  }

  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    val specWidth = MeasureSpec.getSize(widthMeasureSpec)
    val width = when (MeasureSpec.getMode(widthMeasureSpec)) {
      MeasureSpec.AT_MOST -> minOf(getLayout(specWidth).width, specWidth)
      else -> specWidth.takeIf { it > 0 }
        ?: (parent as? android.view.View)?.width
        ?: resources.displayMetrics.widthPixels
    }
    val layout = getLayout(width)
    val height = when (MeasureSpec.getMode(heightMeasureSpec)) {
      MeasureSpec.EXACTLY -> MeasureSpec.getSize(heightMeasureSpec)
      MeasureSpec.AT_MOST -> minOf(layout.height, MeasureSpec.getSize(heightMeasureSpec))
      else -> layout.height
    }
    setMeasuredDimension(layout.width, height)
  }

  override fun onDraw(canvas: Canvas) {
    super.onDraw(canvas)
    if (text.isEmpty()) return

    val layout = getLayout(width)
    layout.draw(canvas)
  }

  private fun getLayout(width: Int): StaticLayout {
    if (!needsLayoutRebuild && cachedLayout != null && cachedLayout!!.width == width) {
      return cachedLayout!!
    }
    val layout = FuriganaTextLayout.build(text, furigana, textPaint, furiganaPaint, width)
    cachedLayout = layout
    needsLayoutRebuild = false
    return layout
  }

  class RubySpan(
    private val kanji: String,
    private val reading: String,
    private val textPaint: TextPaint,
    private val furiganaPaint: TextPaint
  ) : ReplacementSpan() {

    private fun getSegmentWidth(): Float {
      val textWidth = textPaint.measureText(kanji)
      val furiganaWidth = furiganaPaint.measureText(reading)
      return maxOf(textWidth, furiganaWidth)
    }

    override fun getSize(
      paint: Paint,
      text: CharSequence,
      start: Int,
      end: Int,
      fm: Paint.FontMetricsInt?
    ): Int {
      val width = getSegmentWidth()

      if (fm != null) {
        val textFm = textPaint.fontMetricsInt
        val furiganaHeight = furiganaPaint.fontMetricsInt.descent - furiganaPaint.fontMetricsInt.ascent
        fm.ascent = textFm.ascent - furiganaHeight
        fm.descent = textFm.descent
        fm.top = textFm.top - furiganaHeight
        fm.bottom = textFm.bottom
      }

      return width.toInt()
    }

    override fun draw(
      canvas: Canvas,
      text: CharSequence,
      start: Int,
      end: Int,
      x: Float,
      top: Int,
      y: Int,
      bottom: Int,
      paint: Paint
    ) {
      val segmentWidth = getSegmentWidth()
      val textWidth = textPaint.measureText(kanji)
      val furiganaWidth = furiganaPaint.measureText(reading)

      val textX = x + (segmentWidth - textWidth) / 2f
      canvas.drawText(kanji, textX, y.toFloat(), textPaint)

      val baseAscent = textPaint.fontMetrics.ascent
      val furiganaDescent = furiganaPaint.fontMetrics.descent
      val furiganaBaseline = y.toFloat() + baseAscent - furiganaDescent - 2f
      val furiganaX = x + (segmentWidth - furiganaWidth) / 2f
      canvas.drawText(reading, furiganaX, furiganaBaseline, furiganaPaint)
    }
  }
}