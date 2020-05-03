package cobbles.native;

#if cpp

import cpp.ConstCharStar;

@:include("cobbletext/cobbletext.h")
@:native("struct CobbletextEngineProperties *")
extern class EngineProperties {
    @:native("line_length")
    var lineLength:Int;

    var locale:ConstCharStar;

    @:native("text_alignment")
    var textAlignment:TextAlignment;
}


@:include("cobbletext/cobbletext.h")
@:native("const struct CobbletextEngineProperties *")
extern class ConstEngineProperties extends EngineProperties {
}

#elseif hl

class EngineProperties {
    public var lineLength:Int = 0;
    public var locale:String = "";
    public var textAlignment:TextAlignment = NotSpecified;

    public function new() {}
}

#else

extern class EngineProperties {
    var lineLength:Int;
    var locale:String;
    var textAlignment:Int;
}

#end
