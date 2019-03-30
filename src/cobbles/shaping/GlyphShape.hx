package cobbles.shaping;

/**
 * Information for positioning a glyph.
 */
@:structInit
class GlyphShape {
    /**
     * Glyph index in the font face.
     */
    public var glyphID:Int;

    /**
     * Index of the original string which this glyph corresponds.
     *
     * Note that this is not a one-to-one mapping.
     */
    public var textIndex:Int;

    /**
     * Amount to move the pen, temporarily, towards the right in 1/64th of a
     * point before drawing.
     */
    public var offsetX:Int;

    /**
     * Amount to move the pen, temporarily, towards the bottom in 1/64th of a
     * point before drawing.
     */
    public var offsetY:Int;

    /**
     * Amount to move the pen towards the right in 1/64th of a point after
     * drawing.
     */
    public var advanceX:Int;

    /**
     * Amount to move the pen towards the bottom in 1/64th of a point after
     * drawing.
     */
    public var advanceY:Int;
}
