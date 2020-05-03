package cobbles;

import haxe.io.Bytes;

/**
 * Glyph properties
 */
@:structInit
class GlyphInfo {
    /**
     * ID for this glyph.
     */
    public var id:GlyphID;

    /**
     * Coverage map of the glyph.
     *
     * 0 is transparent, 255 is opaque.
     */
    public var image:Bytes;

    /**
     * Width of the coverage map.
     *
     * - Value is 0 if no `image`
     */
    public var imageWidth:Int;

    /**
     * Height of the coverage map.
     *
     * - Value is 0 if no `image`
     */
    public var imageHeight:Int;

    /**
     * Horizontal offset when drawing the image.
     *
     * Additive to your pen position.
     */
    public var imageOffsetX:Int;

    /**
     * Vertical offset when drawing the image.
     *
     * Additive to your pen position.
     */
    public var imageOffsetY:Int;
}
