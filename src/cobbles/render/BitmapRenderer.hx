package cobbles.render;

import haxe.io.Bytes;

using Safety;

private typedef GlyphEntry = {
    var image:Bytes;
    var imageWidth:Int;
    var imageHeight:Int;
    var imageOffsetX:Int;
    var imageOffsetY:Int;
};

/**
 * Renderer that outputs to a bitmap.
 */
class BitmapRenderer extends BaseRenderer {
    var bitmap:Null<Bitmap>;
    var glyphImageStorage:Map<Int,GlyphEntry> = [];

    public function setBitmap(bitmap:Bitmap) {
        this.bitmap = bitmap;
    }

    override function prepareGlyphImageStorage() {
        glyphImageStorage.clear();
    }

    override function saveGlyphImage(tile:TileInfo, glyph:GlyphInfo) {
        glyphImageStorage.set(tile.glyphID, {
            image: glyph.image,
            imageWidth: glyph.imageWidth,
            imageHeight: glyph.imageHeight,
            imageOffsetX: glyph.imageOffsetX,
            imageOffsetY: glyph.imageOffsetY,
        });
    }

    override function renderGlyph(advance:AdvanceInfo) {
        var glyphEntry = glyphImageStorage.get(advance.glyphID);

        if (glyphEntry == null) {
            drawNotDef();
            return;
        }

        bitmap.sure().drawBytes(
            penPixelX + advance.glyphOffsetX + glyphEntry.imageOffsetX,
            penPixelY + advance.glyphOffsetY + glyphEntry.imageOffsetY,
            glyphEntry.imageWidth, glyphEntry.imageHeight,
            glyphEntry.image);
    }

    function drawNotDef() {
        var size = Math.round(engine.fontSize);
        bitmap.sure().drawDebugBox(
            penPixelX, penPixelY - size, size, size, true);
    }

    override function renderInlineObject(advance:AdvanceInfo) {
        var inlineObject = advance.inlineObject.sure();

        bitmap.sure().drawDebugBox(
            penPixelX, penPixelY - inlineObject.getHeight(),
            inlineObject.getWidth(), inlineObject.getHeight(),
            false);
    }
}
