package cobbles.render;

import sys.io.File;
import haxe.io.Bytes;

/**
 * 8-bit, grayscale bitmap
 */
class GrayscaleBitmap extends BaseBitmap {
    var data:Bytes;

    public function new(width:Int, height:Int) {
        super(width, height);
        data = Bytes.alloc(width * height);
    }

    override function getValue(x:Int, y:Int):Int {
        return data.get(y * width + x);
    }

    override function setValue(x:Int, y:Int, value:Int) {
        data.set(y * width + x, value);
    }

    /**
     * Saves the bitmap to a PGM file.
     */
    public function savePGM(filename:String) {
        var file = File.write(filename);

        file.writeString('P5 $width $height 255\n');
        file.writeFullBytes(data, 0, data.length);
        file.close();
    }
}
