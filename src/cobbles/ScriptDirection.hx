package cobbles;

/**
 * Script direction of a run of text.
 */
enum abstract ScriptDirection(Int) {
    /**
     * Automatically detect script direction.
     */
    var NotSpecified = 0;

    /**
     * Force script to be left-to-right.
     */
    var LeftToRight = 1;

    /**
     * Force script to be left-to-right.
     */
    var RightToLeft = 2;
}
