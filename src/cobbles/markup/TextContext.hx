package cobbles.markup;

import cobbles.layout.InlineObject;
import cobbles.TextInput.TextInputTextFI;
import cobbles.font.FontTable.FontKey;

using cobbles.util.ArrayTools;

/**
 * Interface to `TextInput` that applies properties to text using ranges.
 */
class TextContext {
    public var textInput(default, null):TextInput;

    var fontKeyStack:Array<FontKey>;
    var fontSizeStack:Array<Float>;
    var colorStack:Array<Int>;
    var directionStack:Array<Direction>;
    var languageStack:Array<String>;
    var scriptStack:Array<String>;
    var dataStackMap:Map<String,Array<String>>;

    public var fontSize(get, never):Float;

    public function new(textInput:TextInput) {
        this.textInput = textInput;

        fontKeyStack = [];
        fontSizeStack = [];
        colorStack = [];
        directionStack = [];
        languageStack = [];
        scriptStack = [];
        dataStackMap = new Map();
    }

    function get_fontSize():Float {
        if (!fontSizeStack.isEmpty()) {
            return fontSizeStack.last();
        } else {
            return textInput.fontSize;
        }
    }

    public function addText(text:String):TextInputTextFI {
        var fluentInterface = textInput.addText(text);
        var properties = fluentInterface.properties;

        if (!fontKeyStack.isEmpty()) {
            properties.fontKey = fontKeyStack.last();
        }

        if (!fontSizeStack.isEmpty()) {
            properties.fontPointSize = fontSizeStack.last();
        }

        if (!colorStack.isEmpty()) {
            properties.color = colorStack.last();
        }

        if (!directionStack.isEmpty()) {
            properties.direction = directionStack.last();
        }

        if (!scriptStack.isEmpty()) {
            properties.script = scriptStack.last();
        }

        return fluentInterface;
    }

    public function addLineBreak() {
        textInput.addLineBreak();
    }

    public function addInlineObject(inlineObject:InlineObject) {
        textInput.addInlineObject(inlineObject);
    }

    public function pushFont(fontKey:FontKey) {
        fontKeyStack.push(fontKey);
    }

    public function popFont() {
        fontKeyStack.pop();
    }

    public function pushFontSize(size:Float) {
        fontSizeStack.push(size);
    }

    public function popFontSize() {
        fontSizeStack.pop();
    }

    public function pushColor(color:Int) {
        colorStack.push(color);
    }

    public function popColor() {
        colorStack.pop();
    }

    public function pushDirection(direction:Direction) {
        directionStack.push(direction);
    }

    public function popDirection() {
        directionStack.pop();
    }

    public function pushLanguage(language:String) {
        languageStack.push(language);
    }

    public function popLanguage() {
        languageStack.pop();
    }

    public function pushScript(script:String) {
        scriptStack.push(script);
    }

    public function popScript() {
        scriptStack.pop();
    }

    public function pushData(key:String, value:String) {
        var stack = dataStackMap.get(key);

        if (stack == null) {
            stack = [];
            dataStackMap.set(key, stack);
        }

        stack.push(value);
    }

    public function popData(key:String) {
        var stack = dataStackMap.get(key);

        if (stack != null) {
            stack.pop();

            if (stack.length == 0) {
                dataStackMap.remove(key);
            }
        }
    }
}
