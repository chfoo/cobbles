package cobbles.render.heaps;

import cobbles.layout.InlineObject;
import cobbles.layout.PenRun;
import h2d.Tile;
import cobbles.layout.Layout;
import cobbles.font.GlyphInfo;
import cobbles.font.FontTable;
import h2d.TileGroup;

class TileGroupRenderer extends BaseRenderer {
    var fontTable:FontTable;
    var glyphInfoCache:GlyphInfoCache;
    public var textureAtlas(default, null):TextureAtlas;
    var tileGroup:TileGroup;

    public function new(fontTable:FontTable, textureSize:Int = 1024) {
        super();

        this.fontTable = fontTable;
        glyphInfoCache = new GlyphInfoCache(fontTable);
        textureAtlas = new TextureAtlas(textureSize, textureSize);
    }

    public function newTileGroup():TileGroup {
        return new TileGroup(Tile.fromTexture(textureAtlas.texture));
    }

    public function renderTileGroup(layout:Layout, tileGroup:TileGroup) {
        var glyphsAdded = gatherRequiredGlyphs(layout);

        if (glyphsAdded > 0) {
            textureAtlas.buildTexture();
        }

        tileGroup.clear();
        this.tileGroup = tileGroup;

        render(layout);
    }

    function gatherRequiredGlyphs(layout:Layout):Int {
        var missCount = 0;

        for (line in layout.lines) {
            for (item in line.items) {
                switch item {
                    case PenRunItem(penRun):
                        missCount += addPenRunGlyphsToAtlas(penRun, layout.resolution);
                    default:
                        // pass
                }
            }
        }

        return missCount;
    }

    function addPenRunGlyphsToAtlas(penRun:PenRun, resolution:Int):Int {
        var missCount = 0;

        for (glyphShape in penRun.glyphShapes) {
            if (textureAtlas.hasGlyph(penRun.fontKey, glyphShape.glyphID, penRun.fontSize, resolution)) {
                continue;
            }

            var glyphInfo = glyphInfoCache.getGlyphInfo(penRun, glyphShape, resolution);

            textureAtlas.addGlyph(penRun.fontKey, glyphShape.glyphID, penRun.fontSize, resolution, glyphInfo);
            missCount += 1;
        }

        return missCount;
    }

    override function renderGlyph(penRun:PenRun, glyphShapeIndex:Int) {
        var glyphShape = penRun.glyphShapes[glyphShapeIndex];

        var tile = textureAtlas.getGlyphTile(
            penRun.fontKey, glyphShape.glyphID,
            penRun.fontSize, resolution);


        var red = ((penRun.color & 0xFF0000) >> 16) / 255;
        var green = ((penRun.color & 0xFF00) >> 8) / 255;
        var blue = (penRun.color & 0xFF) / 255;

        // tileGroup.addColor(penPixelX, penPixelY, red, green, blue, 1.0, tile);
        tileGroup.add(penPixelX, penPixelY, tile);
    }

    override function renderInlineObject(inlineObject:InlineObject) {

    }
}
