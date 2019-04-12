package cobbles;

import cobbles.algorithm.LineBreakingAlgorithm;
import cobbles.algorithm.SimpleLineBreaker;
import cobbles.font.FontTable;
import cobbles.markup.MarkupParser;

/**
 * Common text settings and instances.
 */
class TextConfig {
    static var _instance:Null<TextConfig>;

    /**
     * Font table instance.
     */
    public var fontTable:FontTable;

    /**
     * Markup parser instance.
     */
    public var markupParser:MarkupParser;

    /**
     * Line breaking algorithm instance.
     */
    public var lineBreakingAlgorithm:LineBreakingAlgorithm;

    public function new() {
        fontTable = new FontTable();
        markupParser = new MarkupParser();
        lineBreakingAlgorithm = new SimpleLineBreaker();
    }

    /**
     * Returns a singleton text config.
     */
    public static function instance():TextConfig {
        if (_instance == null) {
            _instance = new TextConfig();
        }

        return _instance;
    }
}
