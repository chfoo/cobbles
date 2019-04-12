package cobbles.markup;

import cobbles.layout.InlineObject;

/**
 * Represents an `<object>`.
 */
class MarkupObject implements InlineObject {
    /**
     * Attributes on the element.
     */
    public var properties(default, null):Map<String,String>;

    public var width:Int;
    public var height:Int;

    public function new(width:Int = 0, height:Int = 0) {
        this.width = width;
        this.height = height;

        properties = new Map();
    }

    public function getWidth():Int {
        return width;
    }

    public function getHeight():Int {
        return height;
    }
}
