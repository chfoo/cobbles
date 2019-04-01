package cobbles.example.heaps;

import hxd.net.BinaryLoader;
import haxe.io.Bytes;

class HeapsExample extends hxd.App {
    var textLayout:TextLayout;
    var fpsText:h2d.Text;
    var loadedFonts:Array<{name:String, data:Bytes}>;

    override function init() {
        super.init();

        textLayout = new TextLayout(loadedFonts);

        var atlasBitmap = new h2d.Bitmap(
            h2d.Tile.fromTexture(textLayout.texture), s2d);
        atlasBitmap.y = 30;
        atlasBitmap.alpha = 0.5;

        textLayout.tileGroup.y = 30;
        s2d.addChild(textLayout.tileGroup);
        textLayout.update();

        var font = hxd.res.DefaultFont.get();
        fpsText = new h2d.Text(font, s2d);
        fpsText.scale(2);
    }

    public static function main() {
        #if js
        cobbles.Runtime.loadEmscripten().then(success -> {
            trace("Starting Heaps");
            new HeapsExample();
        });
        #else
        new HeapsExample();
        #end
    }

    override function loadAssets(onLoaded:Void->Void) {
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
                'resource/fonts/noto/NotoSansCJKjp-Regular.otf',
            ];
        }

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
        textLayout.update();
        fpsText.text = 'FPS ${Std.int(hxd.Timer.fps())}';
	}
}
