package cobbles.algorithm;


/**
 * Determines where it is suitable for breaking runs of texts into lines.
 *
 * The line breaking algorithm includes word wrapping rules (such as spaces)
 * and specific Unicode code point rules (such as newlines) to properly
 * split text into lines following the document's preferences.
 */
interface LineBreakingAlgorithm {
    /**
     * Returns break information from the given text.
     */
    public function getBreaks(text:String):LineBreakInfo;
}

interface LineBreakInfo {
    /**
     * Returns the number of code points.
     */
    public function count():Int;

    /**
     * Returns whether a break is permitted before the code point
     * at the given index.
     */
    public function canBreak(index:Int):Bool;

    /**
     * Returns whether a line break is mandatory before the code
     * point at the given index.
     */
    public function isMandatory(index:Int):Bool;
}
