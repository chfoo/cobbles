package cobbles.render;

import cobbles.layout.Layout;
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
    var glyphCache:GlyphCache<GlyphInfo>;
    var bitmap:Null<Bitmap>;

    public function new(fontTable:FontTable) {
        super();

        this.fontTable = fontTable;
        glyphCache = new GlyphCache();
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
        var cacheResult = glyphCache.getGlyph(penRun.fontKey, glyphShape.glyphID,
            penRun.fontSize, resolution);

        var glyphInfo;

        switch cacheResult {
            case Some(glyphInfo_):
                glyphInfo = glyphInfo_;
            case None:
                var font = fontTable.getFont(penRun.fontKey);
                glyphInfo = font.getGlyphInfo(glyphShape.glyphID);
                glyphCache.setGlyph(
                    penRun.fontKey, glyphShape.glyphID,
                    penRun.fontSize, resolution, glyphInfo);
        }

        return glyphInfo;
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
