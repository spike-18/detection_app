package com.ultralytics.yolo

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import java.util.Arrays
import kotlin.math.max
import kotlin.math.min

/**
 * Adjusts a list of standard Android Color Ints (ARGB) to a fixed brightness/value.
 * @param colors List of standard Android Color Integers (e.g., from Color.rgb(r,g,b))
 * @param fixedValue 0-255 (default 200). Matches Python logic.
 */
fun normalizeBrightness(colors: List<Int>, fixedValue: Int = 200): List<Int> {
    val hsv = FloatArray(3)
    // Python's logic: new_v = fixed_value / 255.0
    // Android HSV Value is range [0.0, 1.0]
    val targetValue = fixedValue / 255f

    return colors.map { color ->
        // Convert RGB to HSV
        Color.colorToHSV(color, hsv)

        // hsv[0] = Hue, hsv[1] = Saturation, hsv[2] = Value
        hsv[2] = targetValue

        // Convert back to Color Int
        Color.HSVToColor(hsv)
    }
}

/**
 * Overload: If your input is explicitly a List of [R, G, B] arrays like Python
 */
fun normalizeBrightnessRaw(colors: List<IntArray>, fixedValue: Int = 200): List<IntArray> {
    val hsv = FloatArray(3)
    val targetValue = fixedValue / 255f
    val result = ArrayList<IntArray>()

    for (rgb in colors) {
        val r = rgb[0]
        val g = rgb[1]
        val b = rgb[2]

        // Convert to HSV (using Android Color helper)
        Color.RGBToHSV(r, g, b, hsv)

        // Set fixed value
        hsv[2] = targetValue

        // Convert back to Color Int
        val colorInt = Color.HSVToColor(hsv)

        // Extract RGB components back into an array
        val newR = Color.red(colorInt)
        val newG = Color.green(colorInt)
        val newB = Color.blue(colorInt)

        result.add(intArrayOf(newR, newG, newB))
    }
    return result
}


fun getTomatoColor(bitmap: Bitmap): IntArray {
    val width = bitmap.width
    val height = bitmap.height
    val pixelCount = width * height
    val pixels = IntArray(pixelCount)

    // Load pixels into array for faster access than getPixel()
    bitmap.getPixels(pixels, 0, width, 0, 0, width, height)

    // Lists to hold the components of valid pixels
    // We use standard arrays and counters to avoid overhead of ArrayLists if possible,
    // but dynamic lists are cleaner for filtering.
    val validPixels = ArrayList<Int>()
    val ratios = ArrayList<Float>()

    var greenCount = 0
    var otherCount = 0

    // 1. Filter [0,0,0] and Calculate Ratios
    for (pixel in pixels) {
        val r = (pixel shr 16) and 0xFF
        val g = (pixel shr 8) and 0xFF
        val b = pixel and 0xFF

        // drop [0,0,0] pixels
        if (r == 0 && g == 0 && b == 0) continue

        // Logic matches Python: denominator = R + B + epsilon
        val denominator = r + b + 1e-6f
        val ratio = g / denominator

        validPixels.add(pixel)
        ratios.add(ratio)

        if (ratio > 0.5) {
            greenCount++
        } else {
            otherCount++
        }
    }

    if (validPixels.isEmpty()) return intArrayOf(0, 0, 0)

    // 2. Apply Heuristic Logic
    // Python: if others >= 0.1 * greens -> Keep ONLY others (ratio < 0.5)
    // Else -> Keep EVERYTHING (do not filter)
//    val useOnlyOthers = otherCount >= 0.1 * greenCount
    val useOnlyOthers = false

    val finalReds = ArrayList<Int>()
    val finalGreens = ArrayList<Int>()
    val finalBlues = ArrayList<Int>()

    for (i in validPixels.indices) {
        val ratio = ratios[i]

        // If we are filtering, skip items that don't match criteria
        if (useOnlyOthers && ratio >= 0.5) continue

        val px = validPixels[i]
        finalReds.add((px shr 16) and 0xFF)
        finalGreens.add((px shr 8) and 0xFF)
        finalBlues.add(px and 0xFF)
    }

    // Handle edge case where filtering removed everything
    if (finalReds.isEmpty()) return intArrayOf(0, 0, 0)

    // 3. Calculate Median per channel
    // Python's np.median calculates median for each column independently
    return intArrayOf(
        calculateMedian(finalReds),
        calculateMedian(finalGreens),
        calculateMedian(finalBlues)
    )
}

// Helper function to replicate np.median behavior
fun calculateMedian(list: ArrayList<Int>): Int {
    list.sort()
    val size = list.size
    return if (size % 2 == 1) {
        list[size / 2]
    } else {
        // Average of two middle elements
        (list[size / 2 - 1] + list[size / 2]) / 2
    }
}

/**
 * @param img The cropped image patch (Bitmap)
 * @param box The absolute coordinates of the cropped area (Rect)
 * @param boxes List of other detection objects (List<Rect>)
 */
fun removeOverlapping(img: Bitmap, box: Rect, boxes: List<Rect>): Bitmap {
    // 1. Ensure the bitmap is mutable so we can draw on it.
    // If your pipeline already gives a mutable bitmap, you can skip the .copy()
    val mutableBitmap = if (img.isMutable) img else img.copy(Bitmap.Config.ARGB_8888, true)

    // Canvas is the standard Android way to modify Bitmaps efficiently
    val canvas = Canvas(mutableBitmap)
    val paint = Paint().apply {
        color = Color.BLACK
        style = Paint.Style.FILL
    }

    val imgW = mutableBitmap.width
    val imgH = mutableBitmap.height

    // 1. Get Absolute Coordinates of the main box
    // acting as the "Origin"
    val X1 = box.left
    val Y1 = box.top
    val X2 = box.right
    val Y2 = box.bottom

    // 2. Iterate through other boxes
    // (Replacing NumPy vectorization with a fast loop)
    for (other in boxes) {

        // 3. Calculate Absolute Intersection
        // logic: max(start), min(end)
        val ix1 = max(X1, other.left)
        val iy1 = max(Y1, other.top)
        val ix2 = min(X2, other.right)
        val iy2 = min(Y2, other.bottom)

        // 4. Validate Intersection
        // equivalent to: (ix1 < ix2) & (iy1 < iy2)
        if (ix1 < ix2 && iy1 < iy2) {

            // 5. Translate Absolute -> Relative (Crop Space)
            val relX1 = ix1 - X1
            val relY1 = iy1 - Y1
            val relX2 = ix2 - X1
            val relY2 = iy2 - Y1

            // 6. Safety Check: Ignore self-overlap
            // If the intersection covers the exact dimensions of the crop, it's the box itself
            if (relX1 == 0 && relY1 == 0 && relX2 == imgW && relY2 == imgH) {
                continue
            }

            // 7. Apply Blackout
            // Draw a black rectangle on the relative coordinates
            canvas.drawRect(
                relX1.toFloat(),
                relY1.toFloat(),
                relX2.toFloat(),
                relY2.toFloat(),
                paint
            )
        }
    }

    return mutableBitmap
}