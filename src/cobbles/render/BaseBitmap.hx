package cobbles.render;

import haxe.io.Bytes;

class BaseBitmap implements Bitmap {
    var width:Int;
    var height:Int;

    public function new(width:Int, height:Int) {
        this.width = width;
        this.height = height;
    }

    public function getWidth():Int {
        return width;
    }

    public function getHeight():Int {
        return height;
    }

    public function drawBytes(x:Int, y:Int, width:Int, height:Int, bytes:Bytes) {
        for (row in 0...height) {
            for (col in 0...width) {
                var bitmapX = x + col;
                var bitmapY = y + row;

                if (bitmapX < 0 || bitmapX >= this.width ||
                bitmapY < 0 || bitmapY >= this.height) {
                    continue;
                }

                var incomingIndex = row * width + col;

                var bitmapValue = getValue(bitmapX, bitmapY);
                bitmapValue += bytes.get(incomingIndex);

                if (bitmapValue > 255) {
                    bitmapValue = 255;
                }

                setValue(bitmapX, bitmapY, bitmapValue);
            }
        }
    }

    public function drawDebugBox(x:Int, y:Int, width:Int, height:Int, filled:Bool) {
        if (width > 0) {
            width -= 1;
        }
        if (height > 0) {
            height -= 1;
        }

        // Top line
        drawLine(x, y, x + width, y);

        // Bottom line
        drawLine(x, y + height, x + width, y + height);

        // Left line
        drawLine(x, y, x, y + height);

        // Right line
        drawLine(x + width, y, x + width, y + height);

        if (filled) {
            // Draw "X"
            drawLine(x, y, x + width, y + height);
            drawLine(x, y + height, x + width, y);
        }
    }

    function drawLine(x1:Int, y1:Int, x2:Int, y2:Int, value:Int = 255) {
        // Awesome tutorial https://www.redblobgames.com/grids/line-drawing.html

        var distance = Std.int(Math.max(Math.abs(x2 - x1), Math.abs(y2 - y1)));

        for (step in 0...distance + 1) {
            var tValue = distance != 0 ? step / distance : 0;
            var x = Math.round(x1 + tValue * (x2 - x1));
            var y = Math.round(y1 + tValue * (y2 - y1));

            if (x < 0 || x >= width || y < 0 || y >= height) {
                continue;
            }

            setValue(x, y, value);
        }
    }

    function getValue(x:Int, y:Int):Int {
        throw 'Not implemented';
    }

    function setValue(x:Int, y:Int, value:Int) {
        throw 'Not implemented';
    }
}
