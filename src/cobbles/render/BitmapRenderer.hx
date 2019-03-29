package cobbles.render;

import cobbles.layout.InlineObject;
import cobbles.font.GlyphBitmap;
import cobbles.shaping.GlyphShape;
import cobbles.layout.PenRun;
import cobbles.font.FontTable;

using Safety;

/**
 * Renderer that outputs to a bitmap.
 */
class BitmapRenderer extends BaseRenderer {
    var fontTable:FontTable;
    var glyphBitmapCache:GlyphBitmapCache;
    var bitmap:Null<Bitmap>;

    public function new(fontTable:FontTable) {
        super();

        this.fontTable = fontTable;
        glyphBitmapCache = new GlyphBitmapCache(fontTable);
    }

    public function setBitmap(bitmap:Bitmap) {
        this.bitmap = bitmap;
    }

    override function renderGlyph(penRun:PenRun, glyphShapeIndex:Int) {
        var glyphShape = penRun.glyphShapes[glyphShapeIndex];
        var glyphBitmap = getGlyphBitmap(penRun, glyphShape);

        if (glyphShape.glyphID == 0) {
            drawNotDef(penRun, glyphShape);
            return;
        }

        bitmap.sure().drawBytes(
            penPixelX + point64ToPixel(glyphShape.offsetX) + glyphBitmap.left,
            penPixelY + point64ToPixel(glyphShape.offsetY) - glyphBitmap.top,
            glyphBitmap.width, glyphBitmap.height,
            glyphBitmap.data);
    }

    override function renderInlineObject(inlineObject:InlineObject) {
        bitmap.sure().drawDebugBox(
            penPixelX, penPixelY - point64ToPixel(inlineObject.getHeight()),
            point64ToPixel(inlineObject.getWidth()),
            point64ToPixel(inlineObject.getHeight()),
            false);
    }

    function getGlyphBitmap(penRun:PenRun, glyphShape:GlyphShape):GlyphBitmap {
        return glyphBitmapCache.getGlyphBitmap(penRun, glyphShape, resolution);
    }

    function drawNotDef(penRun:PenRun, glyphShape:GlyphShape) {
        var width = glyphShape.advanceX != 0 ?
            point64ToPixel(glyphShape.advanceX) :
            point64ToPixel(penRun.fontSize);
        var height = glyphShape.advanceY != 0 ?
            point64ToPixel(glyphShape.advanceY) :
            point64ToPixel(penRun.fontSize);

        bitmap.sure().drawDebugBox(
            penPixelX, penPixelY - height, width, height, true);
    }
}
