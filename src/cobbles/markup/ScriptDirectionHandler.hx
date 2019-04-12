package cobbles.markup;

/**
 * Script-direction auto (`<sda>`) handler.
 *
 * This element provides access to `TextInputTextFI.detectScript()` for
 * including simple bidirectional text.
 *
 * - Example 1: `Unicode in Arabic is <sda>يونيكود</sda>.` This example
 *   demonstrates how to quickly include simple foreign text without manually
 *   specifying script and direction.
 * - Example 2: `Hello <sda>::username::</sda>!` This example demonstrates
 *   how to include text where the script and direction is not known at
 *   compile time such as a string template.
 *
 * In order for this handler to work, it must be registered as both an
 * element and text node handler.
 */
class ScriptDirectionHandler implements TextNodeHandler implements ElementHandler {
    var isolateLevel = 0;

    public function new() {
    }

    public function handleTextNode(context:TextContext, node:Xml) {
        var fluentInterface = context.addText(node.nodeValue);

        if (isolateLevel > 0) {
            fluentInterface.detectScript();
        }
    }

    public function handleElementStart(context:TextContext, element:Xml) {
        isolateLevel += 1;
    }

    public function handleElementEnd(context:TextContext, element:Xml) {
        isolateLevel -= 1;
    }
}
