package cobbles;

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

    public function new() {
        fontTable = new FontTable();
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
