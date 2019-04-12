package cobbles.markup;

/**
 * Handles an XML element node.
 */
interface ElementHandler {
    /**
     * Called when an XML element begins.
     */
    public function handleElementStart(context:TextContext, element:Xml):Void;

    /**
     * Called when an XML element ends.
     */
    public function handleElementEnd(context:TextContext, element:Xml):Void;
}
