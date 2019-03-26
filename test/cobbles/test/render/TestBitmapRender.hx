package cobbles.test.render;

import utest.Assert;
import utest.Test;
import cobbles.test.TestLayout;
#if sys
import sys.FileSystem;
import cobbles.render.GreyscaleBitmap;
import cobbles.render.GreyscaleBitmapRenderer;
#end

class TestBitmapRender extends Test {
    #if sys
    public function testPGM() {
        var sample = TestLayout.getSample();
        var layout = sample.layout;
        var fontTable = sample.fontTable;

        var width = layout.point64ToPixel(layout.boundingWidth);
        var height = layout.point64ToPixel(layout.boundingHeight);
        var bitmap = new GreyscaleBitmap(width, height);

        var renderer = new GreyscaleBitmapRenderer(fontTable);
        renderer.setBitmap(bitmap);
        renderer.render(layout);

        FileSystem.createDirectory("out/test");
        bitmap.savePGM("out/test/bitmap_render.pgm");

        Assert.pass();
    }
    #end
}
