package cobbles.render;

/**
 * Base class for renderers.
 */
class BaseRenderer {
    var penPixelX:Int = 0;
    var penPixelY:Int = 0;
    var library:Library;
    var engine:Engine;

    public function new(library:Library, engine:Engine) {
        this.library = library;
        this.engine = engine;
    }

    public function render() {
        penPixelX = penPixelY = 0;
        checkTileValidity();
        processAdvances();
    }

    function checkTileValidity() {
        if (!engine.tilesValid()) {
            engine.rasterize();
            saveGlyphImages();
        }
    }

    function saveGlyphImages() {
        prepareGlyphImageStorage();

        var tiles = engine.tiles();

        for (tile in tiles) {
            var glyph = library.getGlyphInfo(tile.glyphID);
            saveGlyphImage(tile, glyph);
        }

        renderGlyphImageStorage();
    }

    function prepareGlyphImageStorage() {
        // override me
    }

    function renderGlyphImageStorage() {
        // override me
    }

    function saveGlyphImage(tile:TileInfo, glyph:GlyphInfo) {
        // override me
    }

    function processAdvances() {
        var advances = engine.advances();

        for (advance in advances) {
            processAdvance(advance);
        }
    }

    function processAdvance(advance:AdvanceInfo) {
        switch advance.type {
            case Glyph:
                renderGlyph(advance);
            case InlineObject:
                renderInlineObject(advance);
            default:
                // pass
        }

        penPixelX += advance.advanceX;
        penPixelY += advance.advanceY;
    }

    function renderGlyph(advance:AdvanceInfo) {
        // override me
    }

    function renderInlineObject(advance:AdvanceInfo) {
        // override me
    }
}
