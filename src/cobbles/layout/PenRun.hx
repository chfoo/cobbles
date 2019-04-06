package cobbles.layout;

import haxe.ds.Vector;
import cobbles.font.FontTable.FontKey;
import cobbles.shaping.GlyphShape;
import unifill.CodePoint;

using unifill.Unifill;

/**
 * Group of ordered glyphs corresponding to a segment of text.
 *
 * Coordinates and sizes are in 1/64th of a point.
 */
@:structInit
class PenRun {
    public var fontKey:FontKey;
    public var fontSize:Int;
    public var script:String;
    public var color:Int;
    public var glyphShapes:Vector<GlyphShape>;
    public var textOffset:Int;
    public var rtl:Bool;
    public var width(get, never):Int;
    public var height(get, never):Int;

    public function new(fontKey, fontSize, script, color, glyphShapes, textOffset, rtl) {
        this.fontKey = fontKey;
        this.fontSize = fontSize;
        this.script = script;
        this.color = color;
        this.glyphShapes = glyphShapes;
        this.textOffset = textOffset;
        this.rtl = rtl;
    }

    function get_width():Int {
        var sum = 0;


        for (index in 0...glyphShapes.length) {
            sum += glyphShapes[index].advanceX;
        }

        return sum;
    }

    function get_height():Int {
        var sum = 0;

         for (index in 0...glyphShapes.length) {
            sum += glyphShapes[index].advanceY;
        }

        return sum;
    }

    /**
     * Returns a run with the specified segment of text and glyphs.
     *
     * @param glyphBeginIndex Starting index of selected segment.
     * @param glyphEndIndex Ending index of selected segment not included.
     */
    public function slice(glyphBeginIndex:Int, glyphEndIndex:Int):PenRun {
        if (glyphBeginIndex < 0 ||
        glyphEndIndex > glyphShapes.length ||
        glyphBeginIndex > glyphEndIndex) {
            throw 'invalid index range $glyphBeginIndex $glyphEndIndex';
        }

        var newGlyphShapes = new Vector(glyphEndIndex - glyphBeginIndex);
        Vector.blit(glyphShapes, glyphBeginIndex,
            newGlyphShapes, 0, newGlyphShapes.length);

        return {
            fontKey: fontKey,
            fontSize: fontSize,
            script: script,
            color: color,
            glyphShapes: newGlyphShapes,
            textOffset: textOffset,
            rtl: rtl
        };
    }
}
