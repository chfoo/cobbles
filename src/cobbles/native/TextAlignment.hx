package cobbles.native;

#if (js && !doc_gen)

extern class TextAlignment {
    public var value:Int;
}

class TextAlignmentHelper {
    public static function fromNative(textAlignment:TextAlignment)
            :cobbles.TextAlignment {
        switch (textAlignment.value) {
            case 0:
                return NotSpecified;
            case 1:
                return Start;
            case 2:
                return End;
            case 3:
                return Left;
            case 4:
                return Right;
            case 5:
                return Center;
            default:
                throw "shouldn't reach here";
        }
    }

    public static function toNative(module:EmModule,
            textAlignment:cobbles.TextAlignment):TextAlignment {
        switch textAlignment {
            case NotSpecified:
                return js.Syntax.code("{0}.TextAlignment.NotSpecified", module);
            case Start:
                return js.Syntax.code("{0}.TextAlignment.Start", module);
            case End:
                return js.Syntax.code("{0}.TextAlignment.End", module);
            case Left:
                return js.Syntax.code("{0}.TextAlignment.Left", module);
            case Right:
                return js.Syntax.code("{0}.TextAlignment.Right", module);
            case Center:
                return js.Syntax.code("{0}.TextAlignment.Center", module);
        }
    }
}

#else

typedef TextAlignment = cobbles.TextAlignment;

#end
