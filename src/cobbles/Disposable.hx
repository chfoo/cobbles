package cobbles;

/**
 * Interface for objects that hold references that can't be
 * automatically garbage collected, such as references to callback functions
 * or natively allocated resources.
 */
interface Disposable {
    /**
     * Clean up the object's internal references.
     */
    public function dispose():Void;
    /**
     * Returns whether the object is in the disposed state.
     *
     * Use of the object when disposed is undefined behavior or exception
     * thrown.
     * @return Bool
     */
    public function isDisposed():Bool;
}
