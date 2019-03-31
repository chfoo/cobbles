package cobbles.example.heaps;

class HeapsExample extends hxd.App {
    var textLayout:TextLayout;
    var fpsText:h2d.Text;

    override function init() {
        super.init();

        textLayout = new TextLayout();

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

    override function update(dt:Float) {
        textLayout.update();
        fpsText.text = 'FPS ${Std.int(hxd.Timer.fps())}';
	}
}
