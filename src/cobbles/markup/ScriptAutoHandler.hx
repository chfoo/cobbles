package cobbles.markup;

/**
 * Script Auto (`<sa>`) handler.
 *
 * This element provides access to `TextInputTextFI.detectScript()`
 * and `TextInputTextFI.detectFont()` for including simple bidirectional text.
 *
 * - Example 1: `Unicode in Arabic is <sa>يونيكود</sa>.` This example
 *   demonstrates how to quickly include simple foreign text without manually
 *   specifying script and direction.
 * - Example 2: `Hello <sa>::username::</sa>!` This example demonstrates
 *   how to include text where the script and direction is not known at
 *   compile time such as a string template.
 *
 * In order for this handler to work, it must be registered as both an
 * element and text node handler.
 */
class ScriptAutoHandler implements TextNodeHandler implements ElementHandler {
    var isolateLevel = 0;

    public function new() {
    }

    public function handleTextNode(context:TextContext, node:Xml) {
        var fluentInterface = context.addText(node.nodeValue);

        if (isolateLevel > 0) {
            fluentInterface.detectScript().detectFont();
        }
    }

    public function handleElementStart(context:TextContext, element:Xml) {
        isolateLevel += 1;
    }

    public function handleElementEnd(context:TextContext, element:Xml) {
        isolateLevel -= 1;
    }
}
