package cobbles.font;

import haxe.io.Bytes;

/**
 * Information for drawing a glyph.
 */
@:structInit
class GlyphBitmap {
    /**
     * Width of bitmap in pixels.
     */
    public var width(default, null):Int;

    /**
     * Height of bitmap in pixels.
     */
    public var height(default, null):Int;

    /**
     * Alpha channel, 8-bit pixel bitmap.
     */
    public var data(default, null):Bytes;

    /**
     * Bearing X in pixels.
     *
     * (Distance from the origin to the leftmost of the ink.)
     */
    public var left(default, null):Int;

    /**
     * Bearing Y in pixels.
     *
     * Y is positive upwards.
     *
     * (Distance from the baseline to the topmost of the ink.)
     */
    public var top(default, null):Int;
}
