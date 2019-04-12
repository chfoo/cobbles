package cobbles.test.render;

import utest.Assert;
import utest.Test;
import cobbles.test.layout.TestLayout;
#if sys
import sys.FileSystem;
import cobbles.render.GrayscaleBitmap;
import cobbles.render.BitmapRenderer;
#end

class TestBitmapRender extends Test {
    #if sys
    public function testPGM() {
        var sample = TestLayout.getSample();
        var layout = sample.layout;
        var fontTable = sample.fontTable;

        var width = layout.point64ToPixel(layout.boundingWidth);
        var height = layout.point64ToPixel(layout.boundingHeight);
        var bitmap = new GrayscaleBitmap(width, height);

        var renderer = new BitmapRenderer(fontTable);
        renderer.setBitmap(bitmap);
        renderer.render(layout);

        FileSystem.createDirectory("out/test");
        bitmap.savePGM("out/test/bitmap_render.pgm");

        Assert.pass();
    }
    #end
}
