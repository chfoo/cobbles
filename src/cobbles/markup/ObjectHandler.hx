package cobbles.markup;

import cobbles.InlineObject;

/**
 * Inline object (`<object/>`) element handler.
 *
 * Example: `<object width="20pt" height="20pt" my-custom-property="abc"/>`
 *
 * The element's attributes will be placed on `MarkupObject.properties`.
 */
class ObjectHandler implements ElementHandler {
    public function new() {
    }

    public function handleElementStart(context:TextContext, element:Xml) {
        var object = new MarkupObject();

        for (name in element.attributes()) {
            var value = element.get(name);
            object.properties.set(name, value);

            if (name == "width") {
                switch ParseUtil.parseFontPoints(value) {
                    case Some(points):
                        object.width = Math.round(points * 64);
                    case None:
                        // pass
                }
            }

            if (name == "height") {
                switch ParseUtil.parseFontPoints(value) {
                    case Some(points):
                        object.height = Math.round(points * 64);
                    case None:
                        // pass
                }
            }
        }

        context.addInlineObject(object);
    }

    public function handleElementEnd(context:TextContext, element:Xml) {
    }

    function processObject(object:MarkupObject):InlineObject {
        return object;
    }
}
