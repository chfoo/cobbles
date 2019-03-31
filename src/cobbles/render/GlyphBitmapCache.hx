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
        var key = new GlyphRenderKey(penRun.fontKey, glyphShape.glyphID,
            penRun.fontSize, resolution);
        var glyphBitmap = get(key);

        if (glyphBitmap != null) {
            return glyphBitmap;
        }

        var font = fontTable.getFont(penRun.fontKey);
        font.setSize(0, penRun.fontSize, 0, resolution);
        glyphBitmap = font.getGlyphBitmap(glyphShape.glyphID);
        set(key, glyphBitmap);

        return glyphBitmap;
    }
}
