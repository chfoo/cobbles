package cobbles.native;

#if (cpp && !doc_gen)

@:include("cobbletext/cobbletext.h")
@:native("const struct CobbletextOutputInfo *")
extern class OutputInfo {
    @:native("text_width")
    var textWidth:Int;

    @:native("text_height")
    var textHeight:Int;
}

#elseif (hl && !doc_gen)

typedef OutputInfo = cobbles.OutputInfo;

#else

extern class OutputInfo {
    var textWidth:Int;
    var textHeight:Int;
}

#end
