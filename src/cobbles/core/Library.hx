package cobbles.core;

import haxe.io.Bytes;

interface Library extends Disposable {
    public var fallbackFont(get, never):FontID;

    public function loadFont(path:String):FontID;
    public function loadFontBytes(data:Bytes, faceIndex:Int = 0):FontID;
    public function getFontInfo(id:FontID):FontInfo;
    public function getGlyphInfo(id:GlyphID):GlyphInfo;
    public function setFontAlternative(id:FontID, fallbackID:FontID):Void;
    public function getFontAlternative(id:FontID):FontID;
    public function clearGlyphs():Void;
}
