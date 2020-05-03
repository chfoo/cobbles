package cobbles.native;

#if (cpp && !doc_gen)


import cpp.ConstCharStar;

@:include("cobbletext/cobbletext.h")
@:native("struct CobbletextTextProperties *")
extern class TextProperties {
    var language:ConstCharStar;

    var script:ConstCharStar;

    @:native("script_direction")
    var scriptDirection:ScriptDirection;

    var font:Int;

    @:native("font_size")
    var fontSize:Float;

    @:native("custom_property")
    var customProperty:Int;
}


@:include("cobbletext/cobbletext.h")
@:native("const struct CobbletextTextProperties *")
extern class ConstTextProperties extends TextProperties {
}

#elseif (hl && !doc_gen)

class TextProperties {
    public var language:String = "";
    public var script:String = "";
    public var scriptDirection:ScriptDirection = NotSpecified;
    public var font:Int = 0;
    public var fontSize:Float = 0;
    public var customProperty:Int = 0;

    public function new() {}
}

#else

extern class TextProperties {
    var language:String;
    var script:String;
    var scriptDirection:ScriptDirection;
    var font:Int;
    var fontSize:Float;
    var customProperty:Int;
}

#end
