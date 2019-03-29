package cobbles.render;

import cobbles.shaping.GlyphShape;
import cobbles.layout.PenRun;
import cobbles.font.FontTable;
import cobbles.font.GlyphBitmap;

class GlyphBitmapCache extends GlyphCache<GlyphBitmap> {
    var fontTable:FontTable;

    public function new(fontTable:FontTable, maxSize:Int = 1024) {
        super(maxSize);
        this.fontTable = fontTable;
    }

    public function getGlyphBitmap(penRun:PenRun, glyphShape:GlyphShape, resolution:Int):GlyphBitmap {
        var cacheResult = getGlyph(penRun.fontKey, glyphShape.glyphID,
            penRun.fontSize, resolution);

        var glyphInfo;

        switch cacheResult {
            case Some(glyphInfo_):
                glyphInfo = glyphInfo_;
            case None:
                var font = fontTable.getFont(penRun.fontKey);
                glyphInfo = font.getGlyphBitmap(glyphShape.glyphID);
                setGlyph(
                    penRun.fontKey, glyphShape.glyphID,
                    penRun.fontSize, resolution, glyphInfo);
        }

        return glyphInfo;
    }
}