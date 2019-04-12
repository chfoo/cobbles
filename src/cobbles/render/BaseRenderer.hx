package cobbles.render;

import cobbles.layout.PenRun;
import cobbles.layout.InlineObject;
import cobbles.layout.LayoutLine;
import cobbles.layout.Layout;

/**
 * Base class for renderers.
 */
class BaseRenderer {
    var penPixelX:Int = 0;
    var penPixelY:Int = 0;

    var resolution:Int = 72;
    var verticalOrientation:Bool = false;

    public function new() {
    }

    public function render(layout:Layout) {
        resolution = layout.resolution;

        switch layout.orientation {
            case HorizontalTopBottom:
                verticalOrientation = false;
            case VerticalLeftRight | VerticalRightLeft:
                verticalOrientation = true;
        }

        for (line in layout.lines) {
            advanceLine(line);
            renderLine(line);
        }
    }

    function point64ToPixel(point64:Int):Int {
        return Math.round(point64 / 64 / 72 * resolution);
    }

    function advanceLine(layoutLine:LayoutLine) {
        penPixelX = point64ToPixel(layoutLine.x);
        penPixelY = point64ToPixel(layoutLine.y);
    }

    function renderLine(layoutLine:LayoutLine) {
        for (item in layoutLine.items) {
            switch item {
                case PenRunItem(penRun):
                    renderPenRun(penRun);
                case InlineObjectItem(inlineObject):
                    renderInlineObject(inlineObject);
                    advanceInlineObject(inlineObject);
            }
        }
    }

    function renderPenRun(penRun:PenRun) {
        for (index in 0...penRun.glyphShapes.length) {
            renderGlyph(penRun, index);
            advanceGlyph(penRun, index);
        }
    }

    function renderGlyph(penRun:PenRun, glyphShapeIndex:Int) {
        // override me
    }

    function advanceGlyph(penRun:PenRun, glyphShapeIndex:Int) {
        var glyphShape = penRun.glyphShapes[glyphShapeIndex];

        penPixelX += point64ToPixel(glyphShape.advanceX);
        penPixelY += point64ToPixel(glyphShape.advanceY);
    }

    function renderInlineObject(inlineObject:InlineObject) {
        // override me
    }

    function advanceInlineObject(inlineObject:InlineObject) {
        if (!verticalOrientation) {
            penPixelX += point64ToPixel(inlineObject.getWidth());
        } else {
            penPixelY += point64ToPixel(inlineObject.getHeight());
        }
    }
}
