package cobbles.algorithm;

/**
 * Determines the ordering of code points from a logical order
 * to a visual order.
 *
 * The bidirectional algorithm modifies text by reordering code points such
 * that they can be processed in a single direction.
 */
interface BidiAlgorithm {
    /**
     * Applies the algorithm using default rules and returns the new text.
     */
    public function reorderSimple(text:String):String;
}
