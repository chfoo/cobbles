package cobbles.example.heaps;

import cobbles.render.heaps.TextureAtlas;
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
    var cobbles:LayoutFacade;
    var defaultFont:Null<FontKey>;
    var counter:Int = 0;
    var demoMode:DemoMode = LeftText;

    var extraText:String = "";
    var renderer:TileGroupRenderer;
    public var tileGroup(default, null):TileGroup;
    public var texture(default, null):Texture;

    public function new(fonts:Array<{name:String, data:Bytes}>) {
        cobbles = new LayoutFacade();

        for (font in fonts) {
            var fontKey;

            trace('Load ${font.name}');

            if (font.data != null) {
                fontKey = LayoutFacade.fontTable.openBytes(font.data);
            } else {
                fontKey = LayoutFacade.fontTable.openFile(font.name);
            }

            if (defaultFont == null) {
                defaultFont = fontKey;
            }
        }

        // Setting the default text properties
        cobbles.lineBreakLength = 0;
        cobbles.font = defaultFont;
        cobbles.fontSize = 24;
        cobbles.color = 0xffffffff;

        // The tile group renderer handles positioning of the tiles to match
        // the glyphs in the texture.
        var textureAtlas = new TextureAtlas(512, 512);
        renderer = new TileGroupRenderer(LayoutFacade.fontTable, textureAtlas);
        tileGroup = renderer.newTileGroup();

        // Note in your application, you should reuse the same texture atlas
        // such that all your text will be rasterized onto to it. It will
        // handle rebuilding the texture and discarding unused glyphs
        // automatically.
        // You can do this by ensuring that you obtain tile groups from
        // a single renderer or by passing the same texture atlas to the
        // renderer.

        // Expose the texture so outside caller can use it to show
        // for debugging
        texture = renderer.textureAtlas.texture;
    }

    function addDefaultText() {
        // We only have one large layout as a demo. You should split out
        // your text into multiple layouts as you see fit in your application.
        var dateStr = Date.now().toString();
        cobbles.addText('$dateStr $counter');
        cobbles.addLineBreak(2.0);

        cobbles.addText("The quick brown fox jumps over the lazy dog. ");
        cobbles.addText("Hel͜lo\nwo̎rld! ")
            .fontSize(40)
            .color(0xffff3333);

        // Text samples from http://kermitproject.org/utf8.html
        cobbles.addText("我能吞下玻璃而不伤身体。")
            .script("Hans")
            .language("zh-Hans")
            .detectFont();

        cobbles.addText("私はガラスを食べられます。それは私を傷つけません。")
            .script("Jpan")
            .language("ja")
            .detectFont();

        cobbles.addText("나는 유리를 먹을 수 있어요. 그래도 아프지 않아요. ")
            .script("Kore")
            .language("ko")
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
        // Normally you wouldn't be clearing and rendering all your text on
        // every frame. You should build a wrapper class that integrates with
        // your application and layout the text only when the text is changed.
        // For this demo, we layout on each frame to test the performance
        // of rendering a paragraph of text.
        cobbles.clearText();
        addDefaultText();
        cobbles.addText(extraText);
        cobbles.layoutText();
        renderer.renderTileGroup(cobbles.layout, tileGroup);

        // This shows how to align your text. The output of the layout is based
        // on the bounding box of glyphs such that (0, 0) is the top-left of
        // the bounding box.
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

    // Some bookkeeping when changing state in the demo
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
