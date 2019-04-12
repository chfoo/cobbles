package cobbles.markup;

/**
 * A text node handler that simply adds the text.
 */
class StandardTextNodeHandler implements TextNodeHandler {
    public function new() {
    }

    public function handleTextNode(context:TextContext, node:Xml) {
        context.addText(node.nodeValue);
    }
}
