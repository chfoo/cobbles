package cobbles.font;

import haxe.io.Bytes;

/**
 * Information for drawing a glyph.
 */
@:structInit
class GlyphInfo {
    /**
     * Width of bitmap in pixels.
     */
    public var bitmapWidth(default, null):Int;

    /**
     * Height of bitmap in pixels.
     */
    public var bitmapHeight(default, null):Int;

    /**
     * Alpha channel, 8-bit pixel bitmap.
     */
    public var bitmap(default, null):Bytes;

    /**
     * Bearing X in pixels.
     *
     * (Distance from the origin to the leftmost of the ink.)
     */
    public var bitmapLeft(default, null):Int;

    /**
     * Bearing Y in pixels.
     *
     * Y is positive upwards.
     *
     * (Distance from the baseline to the topmost of the ink.)
     */
    public var bitmapTop(default, null):Int;
}
