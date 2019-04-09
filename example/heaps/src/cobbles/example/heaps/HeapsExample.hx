package cobbles.example.heaps;

import hxd.Event.EventKind;
import hxd.net.BinaryLoader;
import haxe.io.Bytes;

class HeapsExample extends hxd.App {
    var demoText:DemoText;
    var fpsText:h2d.Text;
    var loadedFonts:Array<{name:String, data:Bytes}>;

    override function init() {
        super.init();

        demoText = new DemoText(loadedFonts);

        // Show the texture atlas to see how well the library laid out the glyphs
        var atlasBitmap = new h2d.Bitmap(
            h2d.Tile.fromTexture(demoText.texture), s2d);
        atlasBitmap.y = 30;
        atlasBitmap.alpha = 0.5;

        // Add and position the tile group used for the glyphs
        demoText.tileGroup.y = 30;
        s2d.addChild(demoText.tileGroup);
        demoText.update();

        // Text label for showing the FPS
        var font = hxd.res.DefaultFont.get();
        fpsText = new h2d.Text(font, s2d);
        fpsText.scale(2);

        hxd.Window.getInstance().addResizeEvent(resizeCallback);
        hxd.Window.getInstance().addEventTarget(eventCallback);

        // The text will be wrapped to the window width and properly updated
        // using the above callbacks.
        demoText.setWidth(s2d.width);
    }

    public static function main() {
        #if js
        // The Emscripten library is compiled into a module so it won't
        // conflict with the window namespace.
        cobbles.Runtime.loadEmscripten().then(success -> {
            trace("Starting Heaps");
            new HeapsExample();
        });
        #else
        new HeapsExample();
        #end
    }

    override function loadAssets(onLoaded:Void->Void) {
        // We choose to selectively load the fonts in case the user
        // does not want to download all the fonts.
        #if js
        var loadAllFonts:Bool = untyped js.Browser.window.demoLoadAllFonts;
        #else
        var loadAllFonts = true;
        #end

        var pendingFonts = [];

        if (loadAllFonts) {
            pendingFonts = [
                'resource/fonts/noto/NotoSans-Regular.ttf',
                'resource/fonts/noto/NotoSansArabic-Regular.ttf',
                'resource/fonts/noto/NotoSansCJKsc-Regular.otf',
            ];
        }

        // This is the default font we'll want to use unconditionally.
        pendingFonts.push('resource/fonts/liberation/LiberationSerif-Regular.ttf');
        loadedFonts = new Array<{name:String, data:Bytes}>();

        #if js
        var loadNext;

        loadNext = function() {
            if (pendingFonts.length == 0) {
                onLoaded();
                return;
            }

            var name = pendingFonts.shift();
            var loader = new BinaryLoader(name);

            loader.onLoaded = function (data:Bytes) {
                trace('Loaded $name.');
                loadedFonts.push({name: name, data: data});
                loadNext();
            }

            trace('Loading $name..');
            loader.load();
        }

        loadNext();

        #else
        for (name in pendingFonts) {
            loadedFonts.push({name: name, data: null});
        }
        onLoaded();
        #end
    }

    override function update(dt:Float) {
        demoText.update();
        fpsText.text = 'FPS ${Std.int(hxd.Timer.fps())}. WIP. Resize window. Click to change mode.';
    }

    function resizeCallback() {
        demoText.setWidth(hxd.Window.getInstance().width);
    }

    function eventCallback(event:hxd.Event) {
        if (event.kind == EventKind.EPush) {
            demoText.switchMode();
        }
    }
}
