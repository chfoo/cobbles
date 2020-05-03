package cobbles.render.heaps;

import haxe.io.Bytes;
import haxe.Int64;
import h2d.Tile;
import h3d.mat.Texture;
import h3d.mat.Data.TextureFormat;

@:structInit
class AtlasGlyph {
    public var x:Int;
    public var y:Int;
    public var width:Int;
    public var height:Int;
    public var imageOffsetX:Int;
    public var imageOffsetY:Int;
}

/**
 * A texture builder that contains glyphs required to display text.
 */
class TextureAtlas {
    public var width(default, null):Int;
    public var height(default, null):Int;
    public var bitmap(default, null):PixelsBitmap;
    public var texture(default, null):Texture;

    var glyphMap:Map<GlyphID,AtlasGlyph> = [];

    /**
     * @param width Width in pixels of the texture. Should be a multiple of 2.
     * @param height Height in pixels of the texture. Should be a multiple
     *  of 2 and match `width`
     */
    public function new(width:Int, height:Int) {
        this.width = width;
        this.height = height;
        bitmap = new PixelsBitmap(width, height);
        texture = new Texture(width, height, TextureFormat.RGBA);
    }

    /**
     * Clear the texture pixels buffer.
     */
    public function clearTexture() {
        bitmap.pixels.clear(0);
    }

    /**
     * Add glyph to the texture and draw to the texture pixels buffer.
     */
    public function addGlyph(tile:TileInfo, glyph:GlyphInfo) {
        bitmap.drawBytes(tile.atlasX, tile.atlasY,
            glyph.imageWidth, glyph.imageHeight, glyph.image);

        glyphMap.set(tile.glyphID, {
            x: tile.atlasX,
            y: tile.atlasY,
            width: glyph.imageWidth,
            height: glyph.imageHeight,
            imageOffsetX: glyph.imageOffsetX,
            imageOffsetY: glyph.imageOffsetY
        });
    }

    /**
     * Upload the texture pixels buffer to the texture.
     */
    public function uploadTexture() {
        texture.uploadPixels(bitmap.pixels);
    }

    /**
     * Returns whether the texture atlas has the given glyph.
     * @param glyphKey
     */
    public function hasGlyph(glyphKey:GlyphID) {
        return glyphMap.exists(glyphKey);
    }

    /**
     * Returns a new Tile instance that is positioned to a glyph in the
     * texture.
     */
    public function getGlyphTile(glyphKey:GlyphID):GlyphTile {
        var tile = Tile.fromTexture(texture);
        var glyphInfo = glyphMap.get(glyphKey);

        if (glyphInfo == null) {
            tile.setPosition(0, 0);
            tile.setSize(1, 1);

            return {
                tile: tile,
                offsetX: 0,
                offsetY: 0
            };
        }

        tile.setPosition(glyphInfo.x, glyphInfo.y);
        tile.setSize(glyphInfo.width, glyphInfo.height);

        return {
            tile: tile,
            offsetX: glyphInfo.imageOffsetX,
            offsetY: glyphInfo.imageOffsetY
        };
    }

    /**
     * Removes all the glyphs.
     *
     * This does not affect the texture until it is rebuilt.
     */
    public function clearGlyphs() {
        glyphMap.clear();
    }
}

@:structInit
class GlyphTile {
    public var tile:Tile;
    public var offsetX:Int;
    public var offsetY:Int;
}
