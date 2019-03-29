package cobbles.example.heaps;

import haxe.Resource;
import cobbles.font.FontTable;
import cobbles.render.heaps.TextureAtlas;
import h2d.TileGroup;
import h2d.Bitmap;
import h2d.Tile;
import h3d.mat.Data.TextureFormat;
import h3d.mat.Texture;
import haxe.io.Bytes;
import cobbles.render.heaps.PixelsBitmap;

using unifill.Unifill;

class HeapsExample extends hxd.App {
    var textLayout:TextLayout;
    var fpsText:h2d.Text;

    override function init() {
        super.init();

        textLayout = new TextLayout();
        textLayout.tileGroup.y = 50;
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
        // textLayout.update();
        fpsText.text = 'FPS ${hxd.Timer.fps()}';
	}
}
