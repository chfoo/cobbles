package cobbles;

/**
 * Sizes for the rendered text.
 *
 * There are two types of bounding boxes:
 *
 * - Text bounding box
 * - Raster bounding box
 *
 * The text bounding box (or text box) only includes sizes computed by pen
 * movements.
 *
 * The raster bounding box (or image size) includes what is actually drawn
 * to the image. TODO
 */
class OutputInfo {
    /**
     * Width of the text box in pixels.
     */
    public var textWidth:Int = 0;

    /**
     * Height of the text box in pixels.
     */
    public var textHeight:Int = 0;

    public function new() {
    }
}
