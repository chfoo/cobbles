package cobbles;

/**
 * Representation of a rendered glyph for an `Engine`.
 */
@:structInit
class TileInfo {
    /**
     * The glyph ID represented.
     */
    public var glyphID:GlyphID;

    /**
     * Horizontal offset within a texture atlas.
     *
     * - Value is 0 if tile packing is not performed.
     */
    public var atlasX:Int;

    /**
     * Vertical offset within a texture atlas.
     *
     * - Value is 0 if tile packing is not performed.
     */
    public var atlasY:Int;
}
