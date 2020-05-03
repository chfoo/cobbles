package cobbles;

/**
 * Font face properties.
 */
@:structInit
class FontInfo {
    /**
     * ID for this face.
     */
    public var id:FontID;

    /**
     * Font family name.
     */
    public var familyName:String;

    /**
     * Font style name.
     */
    public var styleName:String;

    /**
     * Number of font units per EM square.
     *
     * If value is 0, the font is a bitmap font and not a vector font.
     * Additionally, properties, such as ascender or height,
     * related to this EM size is not valid.
     */
    public var unitsPerEM:Int;

    /**
     * Ascender in font units.
     *
     * Positive is above baseline.
     */
    public var ascender:Int;

    /**
     * Descencder in font units.
     *
     * Negative is below baseline.
     */
    public var descender:Int;

    /**
     * Distance between two baselines in font units.
     *
     * If 0, it is not a vector, but a bitmap font.
     */
    public var height:Int;

    /**
     * Position of underline in font units.
     */
    public var underlinePosition:Int;

    /**
     * Thickness of underline in font units.
     */
    public var underlineThickness:Int;
}
