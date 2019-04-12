package cobbles.markup;

/**
 * Handles XML text node.
 */
interface TextNodeHandler {
    public function handleTextNode(context:TextContext, node:Xml):Void;
}
