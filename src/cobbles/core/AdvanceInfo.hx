package cobbles.core;

import cobbles.AdvanceInfo.AdvanceType;

@:structInit
class AdvanceInfo {
    public var type:AdvanceType;
    public var textIndex:Int;
    public var advanceX:Int;
    public var advanceY:Int;
    public var glyphID:GlyphID;
    public var glyphOffsetX:Int;
    public var glyphOffsetY:Int;
    public var inlineObject:InlineObjectID;
    public var customProperty:CustomPropertyID;
}
