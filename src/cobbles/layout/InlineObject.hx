package cobbles.layout;

/**
 * Represents an object that is embedded within text.
 */
interface InlineObject {
    /**
     * Returns the width of the object in 1/64th of a point.
     */
    public function getWidth():Int;
    /**
     * Returns the height of the object in 1/64th of a point.
     */
    public function getHeight():Int;
}
