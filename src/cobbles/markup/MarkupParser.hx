package cobbles.markup;

/**
 * Parses XML text and applies formatting using a customizable markup language.
 *
 * Using a markup language allows you to avoid hard-coding long strings and
 * related styling code. By trading for a small performance cost and packaging
 * your strings into a resource file, styled strings can be edited and
 * translated much easier.
 *
 * By default, the parser uses `ScriptDirectionHandler` for handling text.
 * If you don't need it, `StandardTextNodeHandler` can be used instead for
 * slight performance improvement.
 *
 * By default, element handlers are listed below are registered:
 *
 * - `BRHandler`
 * - `ObjectHandler`
 * - `ScriptDirectionHandler`
 * - `SpanHandler`
 *
 * As well, you can implement your own handlers. This is the recommended
 * approach over `SpanHandler`. In markup languages such as HTML5, element tags
 * are used to express semantics rather than style. For example, you can
 * create an `<em>` handler that sets the text to italic in latin script
 * while show emphasis dots in CJK scripts. Likewise, `<strong>` can be
 * implemented to show bold in latin and red color in other scripts.
 */
class MarkupParser {
    public var textNodeHandler:TextNodeHandler;
    public var elementHandlers(default, null):Map<String,ElementHandler>;

    public function new() {
        var scriptDirectionHandler = new ScriptDirectionHandler();

        textNodeHandler = scriptDirectionHandler;
        elementHandlers = [
            "br" => new BRHandler(),
            "object" => new ObjectHandler(),
            "sda" => scriptDirectionHandler,
            "span" => new SpanHandler()
        ];
    }

    /**
     * Parse the XML and format the text using the given context.
     *
     * @param context Text context.
     * @param text XML string. The outer document tag is not needed.
     */
    public function parse(context:TextContext, text:String) {
        var doc = Xml.parse(text);

        processNode(context, doc);
    }

    function processNode(context:TextContext, node:Xml) {
        switch node.nodeType {
            case Document:
                for (child in node) {
                    processNode(context, child);
                }
            case Element:
                processElement(context, node);
            case CData | PCData:
                handleTextNode(context, node);
            default:
                // pass
        }
    }

    function processElement(context:TextContext, element:Xml) {
        handleElementStart(context, element);

        for (childNode in element) {
            processNode(context, childNode);
        }

        handleElementEnd(context, element);
    }

    function handleTextNode(context:TextContext, node:Xml) {
        textNodeHandler.handleTextNode(context, node);
    }

    function handleElementStart(context:TextContext, element:Xml) {
        var handler = elementHandlers.get(element.nodeName);

        if (handler != null) {
            handler.handleElementStart(context, element);
        }
    }

    function handleElementEnd(context:TextContext, element:Xml) {
        var handler = elementHandlers.get(element.nodeName);

        if (handler != null) {
            handler.handleElementEnd(context, element);
        }
    }
}
