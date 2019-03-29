package cobbles.render.heaps;

import hxd.PixelFormat;
import hxd.Pixels;

class PixelsBitmap extends BaseBitmap {
    public var pixels(default, null):Pixels;

    public function new(width:Int, height:Int) {
        super(width, height);
        pixels = Pixels.alloc(width, height, PixelFormat.RGBA);
    }

    override function setValue(x:Int, y:Int, value:Int) {
        pixels.setPixel(x, y, 0xffffff | (value << 24));
    }

    override function getValue(x:Int, y:Int):Int {
        return pixels.getPixel(x, y) >> 24;
    }
}
