package cobbles.example.heaps;

import h3d.mat.Texture;
import h2d.Bitmap;
import h2d.Tile;
import haxe.Resource;
import h2d.TileGroup;
import cobbles.render.heaps.TileGroupRenderer;
import cobbles.layout.TextSource;
import cobbles.font.FontTable;

class TextLayout {
    var cobbles:Cobbles;
    var defaultFont:FontKey;
    var counter:Int = 0;

    var extraText:String = "";
    var renderer:TileGroupRenderer;
    public var tileGroup(default, null):TileGroup;
    public var texture(default, null):Texture;

    public function new() {
        cobbles = new Cobbles();
        defaultFont = cobbles.addFontBytes(Resource.getBytes(
            "resource/fonts/liberation/LiberationSerif-Regular.ttf"));

        cobbles.resolution = 96;
        cobbles.lineBreakLength = 400;
        cobbles.font = defaultFont;
        cobbles.color = 0xffffffff;

        renderer = new TileGroupRenderer(cobbles.fontTable);
        tileGroup = renderer.newTileGroup();

        texture = renderer.textureAtlas.texture;
    }

    function addDefaultText() {

        var dateStr = Date.now().toString();
        cobbles.addText('$dateStr $counter');
        cobbles.addLineBreak();

        cobbles.addText("The quick brown fox jumps over the lazy dog. ");
        cobbles.addText("Hel͜lo wo̎rld! ")
            .fontSize(20);

        // Text samples from http://kermitproject.org/utf8.html
        cobbles.addText("我能吞下玻璃而不伤身体。")
            .script("Hans");

        cobbles.addText("私はガラスを食べられます。それは私を傷つけません。")
            .script("Jpan");

        cobbles.addText("나는 유리를 먹을 수 있어요. 그래도 아프지 않아요. ")
            .script("Kore");

        cobbles.addText("Я могу есть стекло, оно мне не вредит. ")
            .script("Cyrl");

        cobbles.addText("Tôi có thể ăn thủy tinh mà không hại gì. ")
            .script("Latn");

        cobbles.addText("أنا قادر على أكل الزجاج و هذا لا يؤلمني. ")
            .script("Arab")
            .direction(Direction.RightToLeft);

        cobbles.addText("אני יכול לאכול זכוכית וזה לא מזיק לי. ")
            .script("Hebr")
            .direction(Direction.RightToLeft);
    }

    public function setExtraText(text:String) {
        this.extraText = text;
    }

    public function update() {
        cobbles.clearText();
        addDefaultText();
        cobbles.addText(extraText);

        cobbles.layoutText();

        renderer.renderTileGroup(cobbles.layout, tileGroup);
    }
}
