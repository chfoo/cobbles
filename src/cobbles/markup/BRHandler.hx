package cobbles.markup;

/**
 * Line break (`<br/>`) element handler.
 *
 * Example: `This an example<br/>of line breaking.`
 */
class BRHandler implements ElementHandler {
    public function new() {
    }

    public function handleElementStart(context:TextContext, element:Xml) {
        context.addLineBreak();
    }

    public function handleElementEnd(context:TextContext, element:Xml) {
    }
}
