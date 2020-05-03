package cobbles.native;

#if (cpp && !doc_gen)


import cpp.ConstCharStar;

@:include("cobbletext/cobbletext.h")
@:native("const struct CobbletextFontInfo *")
extern class FontInfo {
    public var id:Int;

    @:native("family_name")
    public var familyName:ConstCharStar;

    @:native("style_name")
    public var styleName:ConstCharStar;

    @:native("units_per_em")
    public var unitsPerEM:Int;

    public var ascender:Int;

    public var descender:Int;

    public var height:Int;

    @:native("underline_position")
    public var underlinePosition:Int;

    @:native("underline_thickness")
    public var underlineThickness:Int;
}

#elseif (hl && !doc_gen)

typedef FontInfo = cobbles.FontInfo;

#else

extern class FontInfo {
    var id:Int;
    var familyName:String;
    var styleName:String;
    var unitsPerEM:Int;
    var ascender:Int;
    var descender:Int;
    var height:Int;
    var underlinePosition:Int;
    var underlineThickness:Int;
}

#end
