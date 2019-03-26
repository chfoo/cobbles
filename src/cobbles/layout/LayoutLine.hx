package cobbles.layout;

enum LayoutLineItem {
    PenRunItem(penRun:PenRun);
    InlineObjectItem(inlineObject:InlineObject);
}

/**
 * A group of glyphs and objects representing a line.
 *
 * Coordinates and sizes are in 1/64th of a point.
 */
class LayoutLine {
    public var items:Array<LayoutLineItem>;
    public var length:Int = 0;
    public var spacing:Int = 0;
    public var x:Int = 0;
    public var y:Int = 0;

    public function new() {
        items = [];
    }
}
