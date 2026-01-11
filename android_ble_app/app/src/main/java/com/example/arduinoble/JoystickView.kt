package com.example.arduinoble

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt

class JoystickView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0
) : View(context, attrs, defStyleAttr) {

    // Joystick position listener
    interface OnJoystickMoveListener {
        fun onJoystickMove(x: Float, y: Float)
    }

    private var listener: OnJoystickMoveListener? = null

    // Paint objects for drawing
    private val outerCirclePaint = Paint().apply {
        color = Color.GRAY
        style = Paint.Style.FILL
        alpha = 100
    }

    private val innerCirclePaint = Paint().apply {
        color = Color.DKGRAY
        style = Paint.Style.FILL
    }

    // Joystick dimensions
    private var centerX = 0f
    private var centerY = 0f
    private var outerRadius = 0f
    private var innerRadius = 0f

    // Current joystick position (-1.0 to 1.0)
    private var joystickX = 0f
    private var joystickY = 0f

    // Current knob position (pixels)
    private var knobX = 0f
    private var knobY = 0f

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)

        // Calculate the center and radius
        centerX = w / 2f
        centerY = h / 2f
        outerRadius = min(w, h) / 2f * 0.8f
        innerRadius = outerRadius * 0.3f

        // Initialize knob at center
        knobX = centerX
        knobY = centerY
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)

        // Draw outer circle (base)
        canvas.drawCircle(centerX, centerY, outerRadius, outerCirclePaint)

        // Draw inner circle (knob)
        canvas.drawCircle(knobX, knobY, innerRadius, innerCirclePaint)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_MOVE -> {
                handleTouchMove(event.x, event.y)
                return true
            }
            MotionEvent.ACTION_UP -> {
                resetJoystick()
                return true
            }
        }
        return super.onTouchEvent(event)
    }

    private fun handleTouchMove(touchX: Float, touchY: Float) {
        // Calculate distance from center
        val dx = touchX - centerX
        val dy = touchY - centerY
        val distance = sqrt(dx.pow(2) + dy.pow(2))

        // Limit the knob to stay within the outer circle
        if (distance < outerRadius - innerRadius) {
            knobX = touchX
            knobY = touchY
        } else {
            // Clamp to the edge
            val angle = Math.atan2(dy.toDouble(), dx.toDouble())
            knobX = centerX + ((outerRadius - innerRadius) * Math.cos(angle)).toFloat()
            knobY = centerY + ((outerRadius - innerRadius) * Math.sin(angle)).toFloat()
        }

        // Calculate normalized position (-1.0 to 1.0)
        val maxDistance = outerRadius - innerRadius
        joystickX = (knobX - centerX) / maxDistance
        joystickY = (knobY - centerY) / maxDistance

        // Notify listener
        listener?.onJoystickMove(joystickX, joystickY)

        // Redraw
        invalidate()
    }

    private fun resetJoystick() {
        knobX = centerX
        knobY = centerY
        joystickX = 0f
        joystickY = 0f

        // Notify listener
        listener?.onJoystickMove(0f, 0f)

        // Redraw
        invalidate()
    }

    fun setOnJoystickMoveListener(listener: OnJoystickMoveListener) {
        this.listener = listener
    }
}
