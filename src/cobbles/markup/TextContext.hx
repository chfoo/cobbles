package cobbles.markup;

import cobbles.InlineObject;
import cobbles.Engine;
import cobbles.Library;

using Safety;
using cobbles.util.ArrayTools;

/**
 * Interface to `Engine` that applies properties to text using ranges.
 */
class TextContext {
    public var engine(default, null):Engine;

    var fontKeyStack:Array<FontID>;
    var fontSizeStack:Array<Float>;
    var colorStack:Array<Int>;
    var scriptDirectionStack:Array<ScriptDirection>;
    var languageStack:Array<String>;
    var scriptStack:Array<String>;
    var dataStackMap:Map<String,Array<String>>;

    public var fontSize(get, never):Float;

    public function new(engine:Engine) {
        this.engine = engine;

        fontKeyStack = [engine.font];
        fontSizeStack = [engine.fontSize];
        colorStack = [engine.getCustomProperty("color").or(0xff000000)];
        scriptDirectionStack = [engine.scriptDirection];
        languageStack = [engine.language];
        scriptStack = [engine.script];
        dataStackMap = new Map();
    }

    function get_fontSize():Float {
        if (!fontSizeStack.isEmpty()) {
            return fontSizeStack.last();
        } else {
            return engine.fontSize;
        }
    }

    public function addText(text:String) {
        engine.addText(text);
    }

    public function addLineBreak() {
        engine.addLineBreak();
    }

    public function addInlineObject(inlineObject:InlineObject) {
        engine.addInlineObject(inlineObject);
    }

    public function pushFont(fontKey:FontID) {
        fontKeyStack.push(fontKey);
        engine.font = fontKey;
    }

    public function popFont() {
        fontKeyStack.pop();
        if (!fontKeyStack.isEmpty()) {
            engine.font = fontKeyStack.last();
        }
    }

    public function pushFontSize(size:Float) {
        fontSizeStack.push(size);
        engine.fontSize = size;
    }

    public function popFontSize() {
        fontSizeStack.pop();
        if (!fontSizeStack.isEmpty()) {
            engine.fontSize = fontSizeStack.last();
        }
    }

    public function pushColor(color:Int) {
        colorStack.push(color);
        engine.setCustomProperty("color", color);
    }

    public function popColor() {
        colorStack.pop();
        if (!colorStack.isEmpty()) {
            engine.setCustomProperty("color", colorStack.last());
        }

    }

    public function pushDirection(direction:ScriptDirection) {
        scriptDirectionStack.push(direction);
        engine.scriptDirection = direction;
    }

    public function popDirection() {
        scriptDirectionStack.pop();
        if (!scriptDirectionStack.isEmpty()) {
            engine.scriptDirection = scriptDirectionStack.last();
        }
    }

    public function pushLanguage(language:String) {
        languageStack.push(language);
        engine.language = language;
    }

    public function popLanguage() {
        languageStack.pop();
        if (!languageStack.isEmpty()) {
            engine.language = languageStack.last();
        }
    }

    public function pushScript(script:String) {
        scriptStack.push(script);
        engine.script = script;
    }

    public function popScript() {
        scriptStack.pop();
        if (!scriptStack.isEmpty()) {
            engine.script = scriptStack.last();
        }
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
