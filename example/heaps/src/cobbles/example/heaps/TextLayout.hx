package cobbles.example.heaps;

import haxe.io.Bytes;
import h3d.mat.Texture;
import haxe.Resource;
import h2d.TileGroup;
import cobbles.render.heaps.TileGroupRenderer;
import cobbles.font.FontTable;

enum DemoMode {
    LeftText;
    CenterText;
    RightText;
    RightToLeftMode;
}

class TextLayout {
    var cobbles:Cobbles;
    var defaultFont:Null<FontKey>;
    var counter:Int = 0;
    var demoMode:DemoMode = LeftText;

    var extraText:String = "";
    var renderer:TileGroupRenderer;
    public var tileGroup(default, null):TileGroup;
    public var texture(default, null):Texture;

    public function new(fonts:Array<{name:String, data:Bytes}>) {
        cobbles = new Cobbles();

        for (font in fonts) {
            var fontKey;

            trace('Load ${font.name}');

            if (font.data != null) {
                fontKey = Cobbles.fontTable.openBytes(font.data);
            } else {
                fontKey = Cobbles.fontTable.openFile(font.name);
            }

            if (defaultFont == null) {
                defaultFont = fontKey;
            }
        }

        cobbles.lineBreakLength = 0;
        cobbles.font = defaultFont;
        cobbles.fontSize = 24;
        cobbles.color = 0xffffffff;

        renderer = new TileGroupRenderer(Cobbles.fontTable);
        tileGroup = renderer.newTileGroup();

        texture = renderer.textureAtlas.texture;
    }

    function addDefaultText() {

        var dateStr = Date.now().toString();
        cobbles.addText('$dateStr $counter');
        cobbles.addLineBreak();

        cobbles.addText("The quick brown fox jumps over the lazy dog. ");
        cobbles.addText("Hel͜lo\nwo̎rld! ")
            .fontSize(40)
            .color(0xffff3333);

        // Text samples from http://kermitproject.org/utf8.html
        cobbles.addText("我能吞下玻璃而不伤身体。")
            .script("Hans")
            .detectFont();

        cobbles.addText("私はガラスを食べられます。それは私を傷つけません。")
            .script("Jpan")
            .detectFont();

        cobbles.addText("나는 유리를 먹을 수 있어요. 그래도 아프지 않아요. ")
            .script("Kore")
            .detectFont();

        cobbles.addText("Я могу есть стекло, оно мне не вредит. ")
            .script("Cyrl")
            .detectFont();

        cobbles.addText("Tôi có thể ăn thủy tinh mà không hại gì. ")
            .script("Latn")
            .detectFont();

        cobbles.addText("أنا قادر على أكل الزجاج و هذا لا يؤلمني. ")
            .script("Arab")
            .direction(Direction.RightToLeft)
            .detectFont();

        cobbles.addText("אני יכול לאכול זכוכית וזה לא מזיק לי. ")
            .script("Hebr")
            .direction(Direction.RightToLeft)
            .detectFont();
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

        var windowWidth = hxd.Window.getInstance().width;

        switch demoMode {
            case LeftText:
                tileGroup.x = 0;
            case CenterText:
                tileGroup.x = Math.round((windowWidth - cobbles.layout.point64ToPixel(cobbles.layout.boundingWidth)) / 2);
            case RightText | RightToLeftMode:
                tileGroup.x = windowWidth - cobbles.layout.point64ToPixel(cobbles.layout.boundingWidth);
        }

        counter += 1;
    }

    public function switchMode() {
        switch demoMode {
            case LeftText:
                cobbles.alignment = Alignment.Center;
                demoMode = CenterText;
            case CenterText:
                cobbles.alignment = Alignment.End;
                demoMode = RightText;
            case RightText:
                cobbles.alignment = Alignment.End;
                cobbles.lineDirection = RightToLeft;
                cobbles.textDirection = RightToLeft;
                demoMode = RightToLeftMode;
            case RightToLeftMode:
                cobbles.alignment = Alignment.Start;
                cobbles.lineDirection = LeftToRight;
                cobbles.textDirection = LeftToRight;
                demoMode = LeftText;

        }
    }

    public function setWidth(width:Int) {
        cobbles.lineBreakLength = width;
    }
}
