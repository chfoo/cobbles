package cobbles.render;

import haxe.io.Bytes;

/**
 * Interface for drawing glyphs to bitmaps.
 */
interface Bitmap {
    /**
     * Returns the width of the bitmap in pixels.
     */
    public function getWidth():Int;

    /**
     * Returns the height of the bitmap in pixels.
     */
    public function getHeight():Int;

    /**
     * Draws to the bitmap using the given bitmap.
     *
     * @param x Position on x-axis in pixels.
     * @param y Position on y-axis in pixels.
     * @param width Width of the given bitmap in pixels.
     * @param height Height of the given bitmap in pixels.
     * @param bytes The greyscale, 8 bits per pixel, bitmap to be drawn.
     */
    public function drawBytes(x:Int, y:Int, width:Int, height:Int, bytes:Bytes):Void;

    /**
     * Draw rectangle used for debugging.
     *
     * @param x Position on x-axis in pixels.
     * @param y Position on y-axis in pixels.
     * @param width Width of the rectangle in pixels.
     * @param height Height of the rectangle in pixels.
     * @param filled Whether to draw something in the middle to distinguish
     *  the rectangle from a glyph of a square. Such examples include an "X" or
     *  "?" symbol. It does not mean to flood fill.
     */
    public function drawDebugBox(x:Int, y:Int, width:Int, height:Int, filled:Bool):Void;
}
