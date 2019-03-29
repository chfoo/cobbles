package cobbles.render;

import cobbles.layout.InlineObject;
import cobbles.font.GlyphInfo;
import cobbles.shaping.GlyphShape;
import cobbles.layout.PenRun;
import cobbles.font.FontTable;

using Safety;

/**
 * Renderer that outputs to a bitmap.
 */
class BitmapRenderer extends BaseRenderer {
    var fontTable:FontTable;
    var glyphInfoCache:GlyphInfoCache;
    var bitmap:Null<Bitmap>;

    public function new(fontTable:FontTable) {
        super();

        this.fontTable = fontTable;
        glyphInfoCache = new GlyphInfoCache(fontTable);
    }

    public function setBitmap(bitmap:Bitmap) {
        this.bitmap = bitmap;
    }

    override function renderGlyph(penRun:PenRun, glyphShapeIndex:Int) {
        var glyphShape = penRun.glyphShapes[glyphShapeIndex];
        var glyphInfo = getGlyphInfo(penRun, glyphShape);

        if (glyphShape.glyphID == 0) {
            drawNotDef(penRun, glyphShape);
            return;
        }

        bitmap.sure().drawBytes(
            penPixelX + point64ToPixel(glyphShape.offsetX) + glyphInfo.bitmapLeft,
            penPixelY + point64ToPixel(glyphShape.offsetY) - glyphInfo.bitmapTop,
            glyphInfo.bitmapWidth, glyphInfo.bitmapHeight,
            glyphInfo.bitmap);
    }

    override function renderInlineObject(inlineObject:InlineObject) {
        bitmap.sure().drawDebugBox(
            penPixelX, penPixelY - point64ToPixel(inlineObject.getHeight()),
            point64ToPixel(inlineObject.getWidth()),
            point64ToPixel(inlineObject.getHeight()),
            false);
    }

    function getGlyphInfo(penRun:PenRun, glyphShape:GlyphShape):GlyphInfo {
        return glyphInfoCache.getGlyphInfo(penRun, glyphShape, resolution);
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
