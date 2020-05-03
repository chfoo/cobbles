package cobbles.core;

#if (js && !doc_gen)
import haxe.io.Bytes;

class LibraryJS implements Library {
    public var fallbackFont(get, never):FontID;

    @:allow(cobbles)
    final module:cobbles.native.EmModule;
    @:allow(cobbles)
    final jsLibrary:cobbles.native.Library;

    var _disposed = false;

    public function new(module:cobbles.native.EmModule) {
        this.module = module;
        jsLibrary = js.Syntax.code("new {0}.Library()", module);
    }

    public function dispose() {
        jsLibrary.delete();
        _disposed = true;
    }

    public function isDisposed() {
        return _disposed;
    }

    function get_fallbackFont():FontID {
        return jsLibrary.fallbackFont();
    }

    public function loadFont(path:String):FontID {
        throw "not implemented";
    }

    public function loadFontBytes(bytes:Bytes, faceIndex:Int = 0):FontID {
        return jsLibrary.loadFontBytes(bytes.getData(), faceIndex);
    }

    public function getFontInfo(id:FontID):FontInfo {
        final jsInfo = jsLibrary.getFontInfo(id);
        return {
            id: jsInfo.id,
            familyName: jsInfo.familyName,
            styleName: jsInfo.styleName,
            unitsPerEM: jsInfo.unitsPerEM,
            ascender: jsInfo.ascender,
            descender: jsInfo.descender,
            height: jsInfo.height,
            underlinePosition: jsInfo.underlinePosition,
            underlineThickness: jsInfo.underlineThickness,
        };
    }

    public function getGlyphInfo(id:GlyphID):GlyphInfo {
        final jsInfo = jsLibrary.getGlyphInfo(id);

        final image = Bytes.alloc(jsInfo.image.size());

        for (index in 0...image.length) {
            image.set(index, jsInfo.image.get(index));
        }

        jsInfo.image.delete();

        return {
            id: jsInfo.id,
            image: image,
            imageWidth: jsInfo.imageWidth,
            imageHeight: jsInfo.imageHeight,
            imageOffsetX: jsInfo.imageOffsetX,
            imageOffsetY: jsInfo.imageOffsetY,
        }
    }

    public function setFontAlternative(id:FontID, fallbackID:FontID) {
        jsLibrary.setFontAlternative(id, fallbackID);
    }

    public function getFontAlternative(id:FontID):FontID {
        return jsLibrary.getFontAlternative(id);
    }

    public function clearGlyphs() {
        jsLibrary.clearGlyphs();
    }
}
#end
