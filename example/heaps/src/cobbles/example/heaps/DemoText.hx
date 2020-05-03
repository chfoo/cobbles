package cobbles.example.heaps;

import cobbles.render.heaps.TextureAtlas;
import haxe.io.Bytes;
import h3d.mat.Texture;
import haxe.Resource;
import h2d.TileGroup;
import cobbles.render.heaps.TileGroupRenderer;

enum DemoMode {
    LeftText;
    CenterText;
    RightText;
    RightToLeftMode;
}

class DemoText {
    var library:Library;
    var engine:Engine;
    var defaultFont:Null<FontID>;
    var fontKeys:Array<FontID> = [];
    var counter:Int = 0;
    var demoMode:DemoMode = LeftText;

    var extraText:String = "";
    var renderer:TileGroupRenderer;
    public var tileGroup(default, null):TileGroup;
    public var texture(default, null):Texture;

    public function new(fonts:Array<{name:String, data:Bytes}>, library:Library) {
        this.library = library;
        engine = new Engine(library);

        for (font in fonts) {
            var fontKey;

            trace('Load ${font.name}');

            if (font.data != null) {
                fontKey = library.loadFontBytes(font.data);
            } else {
                fontKey = library.loadFont(font.name);
            }

            if (defaultFont == null) {
                defaultFont = fontKey;
            }

            fontKeys.push(fontKey);
        }

        // Set up font fallback
        for (index in 0...fontKeys.length - 1) {
            library.setFontAlternative(fontKeys[index], fontKeys[index + 1]);
        }

        // Setting the default text properties
        engine.locale = "en-US"; // this should match your app's UI language
        engine.lineLength = 0;
        engine.font = defaultFont;
        engine.fontSize = 24;
        engine.setCustomProperty("color", 0xffffffff);
        // color is ARGB in word-order (BGRA in little-endian byte-order)
        // ie, 0xffff0000 = alpha=0xff, red=0xff, green=0x00, blue=0x00

        // The tile group renderer handles positioning of the tiles to match
        // the glyphs in the texture. You can use the same engine and renderer
        // to render many groups.
        var textureAtlas = new TextureAtlas(512, 512);
        renderer = new TileGroupRenderer(library, engine, textureAtlas);
        tileGroup = renderer.newTileGroup();

        // If you want to use more than one texture atlas, then create another
        // engine and renderer. For example, you dedicate one
        // {engine, texture atlas, renderer} to render GUI text labels, and
        // dedicate another {engine, texture atlas, renderer} to render
        // chat room message lines.

        // Expose the texture so outside caller can use it to show
        // for debugging
        texture = renderer.textureAtlas.texture;
    }

    function addDefaultText() {
        // We only have one large tile group as a demo. You should split out
        // your text into multiple tile groups as you see fit in your application.
        var dateStr = Date.now().toString();
        engine.addText('$dateStr $counter');
        engine.addLineBreak();

        engine.addText("The quick brown fox jumps over the lazy dog. ");

        // You can also use markup. This demo demonstrates the default
        // markup language.
        engine.addMarkup("<span size='40pt' color='#ff3333'>Hel͜lo<br/>wo̎rld! يونيكود</span>");

        // Text samples from http://kermitproject.org/utf8.html

        engine.addText(
            "我能吞下玻璃而不伤身体。" +
            "私はガラスを食べられます。それは私を傷つけません。" +
            "나는 유리를 먹을 수 있어요. 그래도 아프지 않아요. " +
            "Я могу есть стекло, оно мне не вредит. " +
            "Tôi có thể ăn thủy tinh mà không hại gì. " +
            "أنا قادر على أكل الزجاج و هذا لا يؤلمني. " +
            "אני יכול לאכול זכוכית וזה לא מזיק לי. ");
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
        engine.clear();
        addDefaultText();
        engine.addText(extraText);
        engine.layOut();
        renderer.renderTileGroup(tileGroup);

        counter += 1;
    }

    // Some bookkeeping when changing state in the demo
    public function switchMode() {
        switch demoMode {
            case LeftText:
                engine.textAlignment = Center;
                demoMode = CenterText;
            case CenterText:
                engine.textAlignment = End;
                demoMode = RightText;
            case RightText:
                engine.textAlignment = End;
                engine.scriptDirection = RightToLeft;
                demoMode = RightToLeftMode;
            case RightToLeftMode:
                engine.textAlignment = Start;
                engine.scriptDirection = LeftToRight;
                demoMode = LeftText;
        }
    }

    public function setWidth(width:Int) {
        engine.lineLength = width;
    }
}
