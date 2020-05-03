package cobbles;

/**
 * Represents an inline object.
 */
interface InlineObject {
    /**
     * Returns the width in pixels that this object will occupy.
     */
    public function getWidth():Int;

    /**
     * Returns the height in pixels that this object will occupy.
     */
    public function getHeight():Int;
}
