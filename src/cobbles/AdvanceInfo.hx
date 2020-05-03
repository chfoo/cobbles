package cobbles;

import haxe.Constraints.IMap;

/**
 * Type of information contained in `AdvanceInfo`.
 */
enum abstract AdvanceType(Int) {
    /**
     * This value shouldn't happen.
     */
    var Invalid = 0;

    /**
     * Draw a glyph.
     */
    var Glyph = 1;

    /**
     * Draw an inline object.
     */
    var InlineObject = 2;

    /**
     * Pen movement to position a new line.
     */
    var LineBreak = 3;

    /**
     * Pen movement to position to draw bidirectional text.
     */
    var Bidi = 4;

    /**
     * General purpose pen movement.
     */
    var Layout = 5;
}

/**
 * Representation of a pen drawing instruction.
 *
 * The origin of the X-Y coordinate system is defined to be the top-left
 * of the drawing area where
 *
 * - Positive X values move to the right
 * - Positive Y values move to the bottom
 *
 * The advance values are to be added to the current pen position after
 * drawing a glyph or object (if any).
 */
@:structInit
class AdvanceInfo {
    /**
     * The type of movement.
     */
    public var type:AdvanceType;

    /**
     * Position of the text in code points.
     */
    public var textIndex:Int;

    /**
     * Horizontal movement of the pen.
     */
    public var advanceX:Int;

    /**
     * Vertical movement of the pen.
     */
    public var advanceY:Int;

    /**
     * Glyph to be drawn.
     *
     * - Only valid when `type` is a glyph.
     */
    public var glyphID:GlyphID;

    /**
     * Horizontal offset to the current pen position when drawing a glyph.
     */
    public var glyphOffsetX:Int;

    /**
     * Vertical offset to the current pen position when drawing a glyph.
     */
    public var glyphOffsetY:Int;

    /**
     * User-provided inline object.
     *
     * - Only valid when `type` is a inline object.
     */
    public var inlineObject:Null<InlineObject>;

    /**
     * User-provided custom property map.
     *
     * - Value is `null` if it is not a glyph or inline object.
     */
    public var customProperties:Null<IMap<String,Any>>;
}
