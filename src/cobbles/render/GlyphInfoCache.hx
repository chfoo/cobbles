package cobbles.render;

import cobbles.shaping.GlyphShape;
import cobbles.layout.PenRun;
import cobbles.font.FontTable;
import cobbles.font.GlyphInfo;

class GlyphInfoCache extends GlyphCache<GlyphInfo> {
    var fontTable:FontTable;

    public function new(fontTable:FontTable, maxSize:Int = 1024) {
        super(maxSize);
        this.fontTable = fontTable;
    }

    public function getGlyphInfo(penRun:PenRun, glyphShape:GlyphShape, resolution:Int):GlyphInfo {
        var cacheResult = getGlyph(penRun.fontKey, glyphShape.glyphID,
            penRun.fontSize, resolution);

        var glyphInfo;

        switch cacheResult {
            case Some(glyphInfo_):
                glyphInfo = glyphInfo_;
            case None:
                var font = fontTable.getFont(penRun.fontKey);
                glyphInfo = font.getGlyphInfo(glyphShape.glyphID);
                setGlyph(
                    penRun.fontKey, glyphShape.glyphID,
                    penRun.fontSize, resolution, glyphInfo);
        }

        return glyphInfo;
    }
}
