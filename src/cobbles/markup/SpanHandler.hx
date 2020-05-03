package cobbles.markup;

using StringTools;

@:enum
abstract SpanTextAttribute(String) from String to String {
    var FontFace = "font-face";
    var Size = "size";
    var Color = "color";
    var Dir = "dir";
    var Script = "script";
    var Lang = "lang";
}

/**
 * Span (`<span>`) element handler.
 *
 * This handler provides a way of setting the text properties for a segment of
 * text. It corresponds to members of `TextProperties`.
 *
 * Example: `<span color="#00ff00">Hello <span size="20pt">world</span>!</span>`
 *
 * The following attributes are supported:
 *
 * - `font-face`: String that matches a key in `fontFaceMap`.
 * - `size`: Float in points. The "pt" suffix is required like `123.45pt`.
 * - `color`: Hexadecimal RGB or ARGB. The "#" prefix is required like
 *   `#11bb66` or `#aa11bb66`.
 * - `dir`: String that is one of "ltr", "rtl", "ttb", or "btt".
 * - `script`: ISO 15924 tag.
 * - `lang`: BCP 47 tag.
 */
class SpanHandler implements ElementHandler {
    public var fontFaceMap(default, null):Map<String,FontID>;

    var attributesApplied:Array<Array<String>>;
    var level = 0;

    public function new() {
        fontFaceMap = new Map();
        attributesApplied = [];
    }

    public function handleElementStart(context:TextContext, element:Xml) {
        attributesApplied.push([]);

        for (name in element.attributes()) {
            switch name {
                case FontFace:
                    processFontFace(context, element);
                case Size:
                    processSize(context, element);
                case Color:
                    processColor(context, element);
                case Dir:
                    processDir(context, element);
                case Script:
                    processScript(context, element);
                case Lang:
                    processLang(context, element);
                case name_ if (name_.startsWith("data-")):
                    processData(context, element, name);
            }
        }

        level += 1;
    }

    public function handleElementEnd(context:TextContext, element:Xml) {
        level -= 1;

        for (attribute in attributesApplied[level]) {
            switch attribute {
                case FontFace:
                    context.popFont();
                case Size:
                    context.popFontSize();
                case Color:
                    context.popColor();
                case Dir:
                    context.popDirection();
                case Script:
                    context.popScript();
                case Lang:
                    context.popLanguage();
                case name_ if (name_.startsWith("data-")):
                    context.popData(name_.substr("data-".length));
            }
        }

        attributesApplied.pop();
    }

    function processFontFace(context:TextContext, element:Xml) {
        var name = element.get(FontFace);
        var fontKey = fontFaceMap.get(name);

        if (fontKey != null) {
            context.pushFont(fontKey);
            attributesApplied[level].push(FontFace);
        } else {
            Debug.warning('Unknown font face name "$name"');
        }
    }

    function processSize(context:TextContext, element:Xml) {
        var value = element.get(Size);

        switch ParseUtil.parseFontPoints(value) {
            case Some(points):
                context.pushFontSize(points);
                attributesApplied[level].push(Size);
            case None:
                Debug.warning('Invalid font size "$value"');
        }
    }

    function processColor(context:TextContext, element:Xml) {
        var value = element.get(Color);

        switch ParseUtil.parseColor(value) {
            case Some(color):
                context.pushColor(color);
                attributesApplied[level].push(Color);
            case None:
                Debug.warning('Invalid color "$value"');
        }
    }

    function processDir(context:TextContext, element:Xml) {
        var value = element.get(Dir);

        switch ParseUtil.parseDirection(value) {
            case Some(direction):
                context.pushDirection(direction);
                attributesApplied[level].push(Dir);
            case None:
                Debug.warning('Invalid direction "$value"');
        }
    }

    function processScript(context:TextContext, element:Xml) {
        context.pushLanguage(element.get(Script));
        attributesApplied[level].push(Script);
    }

    function processLang(context:TextContext, element:Xml) {
        context.pushLanguage(element.get(Lang));
        attributesApplied[level].push(Lang);
    }

    function processData(context:TextContext, element:Xml, name:String) {
        var key = name.substr("data-".length);
        context.pushData(key, element.get(name));
        attributesApplied[level].push(name);
    }
}
