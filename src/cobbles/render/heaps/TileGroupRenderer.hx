package cobbles.render.heaps;

import h2d.Tile;
import h2d.TileGroup;

using Safety;

/**
 * Renders glyphs by using TileGroup instances.
 *
 * A texture atlas is used to store glyphs and Tile instances are created
 * whenever a glyph needs to be displayed on the screen.
 */
class TileGroupRenderer extends BaseRenderer {
    public var textureAtlas(default, null):TextureAtlas;
    var tileGroup:TileGroup;

    /**
     * @param fontTable Font table containing the required fonts.
     * @param textureAtlas If given, it will be reused. Otherwise, a new
     *  texture atlas is used.
     */
    public function new(library:Library, engine:Engine,
            ?textureAtlas:TextureAtlas) {
        super(library, engine);

        this.textureAtlas = textureAtlas != null ?
            textureAtlas : new TextureAtlas(512, 512);
    }

    /**
     * Returns a tile group that references the texture atlas.
     */
    public function newTileGroup():TileGroup {
        return new TileGroup(Tile.fromTexture(textureAtlas.texture));
    }

    /**
     * Adds the Tile instances to the tile group required to display the text.
     */
    public function renderTileGroup(tileGroup:TileGroup) {
        this.tileGroup = tileGroup;

        tileGroup.clear();
        render();
    }

    override function prepareGlyphImageStorage() {
        textureAtlas.clearTexture();
        engine.packTiles(textureAtlas.width, textureAtlas.height);
    }

    override function renderGlyphImageStorage() {
        textureAtlas.uploadTexture();
    }

    override function saveGlyphImage(tile:TileInfo, glyph:GlyphInfo) {
        textureAtlas.addGlyph(tile, glyph);
    }

    override function renderGlyph(advance:AdvanceInfo) {
        final tile = textureAtlas.getGlyphTile(advance.glyphID);
        final x = penPixelX + advance.glyphOffsetX + tile.offsetX;
        final y = penPixelY + advance.glyphOffsetY + tile.offsetY;

        final color:Int = advance.customProperties.get("color").or(0xffffffff);
        final red = (color >> 16) & 0xff;
        final green = (color >> 8) & 0xff;
        final blue = (color >> 0) & 0xff;
        final alpha = (color >> 24) & 0xff;

        tileGroup.addColor(x, y,
            red / 255, green / 255, blue / 255, alpha / 255,
            tile.tile);
    }

    override function renderInlineObject(advance:AdvanceInfo) {
        // customize me
    }

}
