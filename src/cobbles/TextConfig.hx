package cobbles;

import cobbles.markup.MarkupParser;
import cobbles.font.FontTable;

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

    public function new() {
        fontTable = new FontTable();
        markupParser = new MarkupParser();
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
