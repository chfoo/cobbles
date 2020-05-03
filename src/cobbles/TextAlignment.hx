package cobbles;

/**
 * Alignment of text within a line.
 */
enum abstract TextAlignment(Int) {
    /**
     * Default alias for `Start`
     */
    var NotSpecified = 0;

    /**
     * Left-align text if LTR and right-align text if RTL.
     */
    var Start = 1;

    /**
     * Right-align text if LTR and left-align text if RTL.
     */
    var End = 2;

    /**
     * Force lines to be left-aligned.
     */
    var Left = 3;

    /**
     * Force lines to be right-aligned.
     */
    var Right = 4;

    /**
     * Centers each line.
     */
    var Center = 5;
}
