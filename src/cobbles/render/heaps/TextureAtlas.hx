package cobbles.render.heaps;


import haxe.Int64;
import cobbles.font.GlyphBitmap;
import h2d.Tile;
import h3d.mat.Texture;
import h3d.mat.Data.TextureFormat;
import cobbles.font.FontTable;
import cobbles.ds.Int64Map;

@:structInit
class GlyphAtlasInfo {
    public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;
    public var glyphBitmap:GlyphBitmap;
}

class TextureAtlas {
    public var width(default, null):Int;
    public var height(default, null):Int;
    public var bitmap(default, null):PixelsBitmap;
    public var texture(default, null):Texture;

    var glyphMap:GlyphMap<GlyphAtlasInfo>;

    public function new(width:Int, height:Int, maxGlyphs:Int = 1024) {
        this.width = width;
        this.height = height;
        bitmap = new PixelsBitmap(width, height);
        texture = new Texture(width, height, TextureFormat.RGBA);
        // glyphMap = new GlyphMap(new GlyphCache(maxGlyphs));
        glyphMap = new GlyphMap(new Int64Map<GlyphAtlasInfo>());
    }

    public function buildTexture() {
        bitmap.pixels.clear(0);

        var items = getGlyphsAsSortedArray();
        var penX = 0;
        var penY = 0;
        var maxHeight = 0;

        for (item in items) {
            var glyphAtlasInfo = item.value;
            var glyphBitmap = glyphAtlasInfo.glyphBitmap;

            bitmap.drawBytes(penX, penY,
                glyphAtlasInfo.width, glyphAtlasInfo.height,
                glyphBitmap.data);

            glyphAtlasInfo.x = penX;
            glyphAtlasInfo.y = penY;

            if (glyphAtlasInfo.height > maxHeight) {
                maxHeight = glyphAtlasInfo.height;
            }

            penX += glyphAtlasInfo.width;

            if (penX >= width) {
                penX = 0;
                penY += maxHeight;
                maxHeight = 0;
            }
        }

        texture.uploadPixels(bitmap.pixels);
    }

    function getGlyphsAsSortedArray():Array<{key:Int64, value:GlyphAtlasInfo}> {
        var items = [];

        for (item in glyphMap.keyValueIterator()) {
            items.push(item);
        }

        // Sort by tallest to shortest
        items.sort(function (item1, item2) {
            return Reflect.compare(item2.value.height, item1.value.height);
        });

        return items;
    }

    public function hasGlyph(fontKey:FontKey, glyphID:Int, height:Int,
    resolution:Int) {
        return glyphMap.existsGlyph(fontKey, glyphID, height, resolution);
    }

    public function addGlyph(fontKey:FontKey, glyphID:Int, height:Int,
    resolution:Int, glyphBitmap:GlyphBitmap) {
        glyphMap.setGlyph(
            fontKey, glyphID, height, resolution, {
                x: 0,
                y: 0,
                width: glyphBitmap.width,
                height: glyphBitmap.height,
                glyphBitmap: glyphBitmap
            });

        var result = glyphMap.getGlyph(fontKey, glyphID, height, resolution);
    }

    public function getGlyphTile(fontKey:FontKey, glyphID:Int, height:Int,
    resolution:Int):Tile {
        var tile = Tile.fromTexture(texture);

        var result = glyphMap.getGlyph(fontKey, glyphID, height, resolution);

        // trace('get $fontKey, $glyphID, $height, $resolution $result');

        switch result {
            case Some(glyphAtlasInfo):
                tile.setPosition(glyphAtlasInfo.x, glyphAtlasInfo.y);
                tile.setSize(glyphAtlasInfo.width, glyphAtlasInfo.height);
            case None:
                tile.setSize(16, 16);
        }

        return tile;
    }

    public function clear() {
        glyphMap = new GlyphMap(new Int64Map());
    }
}
