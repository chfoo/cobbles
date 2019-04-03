package cobbles.algorithm;

import unifill.CodePoint;

/**
 * Determines where it is suitable for breaking runs of texts into lines.
 *
 * The line breaking algorithm includes word wrapping rules (such as spaces)
 * and specific Unicode code point rules (such as newlines) to properly
 * split text into lines following the document's preferences.
 */
interface LineBreakingAlgorithm {
    /**
     * Returns break information from the given text in code points.
     *
     * @param codePoints Text as iterable Unicode code points.
     * @param sot If true, a line break is never allowed at the start of the
     *  text. If false, it is assumed that the given input is a segment of a
     *  whole text and breaking at the start of the given input may be allowed.
     */
    public function getBreaks(codePoints:Iterable<CodePoint>, sot:Bool):Array<LineBreakRule>;
}

/**
 * Line breaking rule for breaking before the code point.
 */
enum LineBreakRule {
    /**
     * Break is required.
     */
    Mandatory;
    /**
     * May be broken.
     */
    Opportunity;
    /**
     * Break is not allowed.
     */
    Prohibited;
    /**
     * Not specified.
     */
    Unspecified;
}

